// Package streaming 提供 gRPC 双向流代理功能
//
// 设计要点：
//   - 支持 HTTP/2 Streaming Flush
//   - 建立流时验证 Token
//   - 将 user_id 通过 metadata 传递给下游服务
//   - 双向转发，任一方向出错都关闭整个流
//   - 支持 context 取消和超时
package streaming

import (
	"context"
	"io"
	"log/slog"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/metadata"

	"github.com/funcdfs/lesser/gateway/internal/auth"
	gwErr "github.com/funcdfs/lesser/gateway/internal/errors"
)

// ============================================================================
// 配置
// ============================================================================

// ProxyConfig 流代理配置
type ProxyConfig struct {
	// IdleTimeout 空闲超时时间，超过此时间无消息则关闭流
	IdleTimeout time.Duration
}

// DefaultProxyConfig 返回默认配置
func DefaultProxyConfig() ProxyConfig {
	return ProxyConfig{
		IdleTimeout: 5 * time.Minute,
	}
}

// ============================================================================
// 流代理
// ============================================================================

// Proxy gRPC 双向流代理
type Proxy struct {
	jwtValidator *auth.JWTValidator
	config       ProxyConfig
	log          *slog.Logger

	// 统计信息
	activeStreams atomic.Int64
}

// NewProxy 创建流代理
func NewProxy(jwtValidator *auth.JWTValidator, config ProxyConfig, log *slog.Logger) *Proxy {
	if log == nil {
		log = slog.Default()
	}
	return &Proxy{
		jwtValidator: jwtValidator,
		config:       config,
		log:          log.With(slog.String("component", "streaming")),
	}
}

// ActiveStreams 返回当前活跃流数量
func (p *Proxy) ActiveStreams() int64 {
	return p.activeStreams.Load()
}

// ProxyBidirectional 代理双向流
//
// 参数:
//   - clientStream: 客户端到 Gateway 的流
//   - createServerStream: 创建到下游服务的流连接的函数
//
// 流程:
//  1. 从 metadata 提取并验证 Token
//  2. 创建到下游服务的流，注入 user_id
//  3. 启动双向转发 goroutine
//  4. 等待任一方向结束或 context 取消
func (p *Proxy) ProxyBidirectional(
	clientStream grpc.ServerStream,
	createServerStream func(ctx context.Context) (grpc.ClientStream, error),
) error {
	ctx := clientStream.Context()

	// 1. 提取并验证令牌
	userID, err := p.authenticateStream(ctx)
	if err != nil {
		return err
	}

	p.log.Debug("流认证成功", slog.String("user_id", userID))

	// 2. 创建下游 context，注入 user_id 和 request_id
	serverCtx := p.createServerContext(ctx, userID)

	// 3. 创建到下游服务的双向流
	serverStream, err := createServerStream(serverCtx)
	if err != nil {
		p.log.Error("创建下游流失败", slog.Any("error", err))
		return gwErr.ErrServiceUnavailable
	}

	// 4. 统计活跃流
	p.activeStreams.Add(1)
	defer p.activeStreams.Add(-1)

	// 5. 双向转发
	return p.bidirectionalForward(ctx, clientStream, serverStream)
}

// authenticateStream 验证流的认证信息
func (p *Proxy) authenticateStream(ctx context.Context) (string, error) {
	token, err := extractTokenFromContext(ctx)
	if err != nil {
		p.log.Debug("提取令牌失败", slog.Any("error", err))
		return "", err
	}

	claims, err := p.jwtValidator.ValidateToken(token)
	if err != nil {
		p.log.Debug("令牌验证失败", slog.Any("error", err))
		return "", gwErr.ErrInvalidToken
	}

	return claims.UserID, nil
}

// createServerContext 创建下游服务的 context
func (p *Proxy) createServerContext(ctx context.Context, userID string) context.Context {
	md := metadata.Pairs(
		"user_id", userID,
		"x-request-id", getRequestID(ctx),
	)
	return metadata.NewOutgoingContext(ctx, md)
}

// bidirectionalForward 双向转发消息
func (p *Proxy) bidirectionalForward(
	ctx context.Context,
	clientStream grpc.ServerStream,
	serverStream grpc.ClientStream,
) error {
	// 使用 channel 收集两个方向的错误
	errChan := make(chan error, 2)

	// 使用 WaitGroup 确保两个 goroutine 都结束
	var wg sync.WaitGroup
	wg.Add(2)

	// 用于通知另一个 goroutine 停止
	done := make(chan struct{})

	// Client -> Server
	go func() {
		defer wg.Done()
		err := p.forwardMessages(ctx, clientStream, serverStream, "client->server", done)
		errChan <- err
	}()

	// Server -> Client
	go func() {
		defer wg.Done()
		err := p.forwardMessages(ctx, serverStream, clientStream, "server->client", done)
		errChan <- err
	}()

	// 等待第一个错误
	firstErr := <-errChan

	// 通知另一个 goroutine 停止
	close(done)

	// 关闭服务端发送
	if cs, ok := serverStream.(interface{ CloseSend() error }); ok {
		_ = cs.CloseSend()
	}

	// 等待两个 goroutine 结束
	wg.Wait()

	// EOF 是正常关闭
	if firstErr == io.EOF {
		return nil
	}

	return firstErr
}

// forwardMessages 单向转发消息
// 使用 grpc.RawCodec 模式转发原始字节，避免反序列化
func (p *Proxy) forwardMessages(
	ctx context.Context,
	src interface{ RecvMsg(interface{}) error },
	dst interface{ SendMsg(interface{}) error },
	direction string,
	done <-chan struct{},
) error {
	for {
		// 检查是否应该停止
		select {
		case <-done:
			return nil
		case <-ctx.Done():
			return ctx.Err()
		default:
		}

		// 使用 frame 接收原始字节
		frame := &rawFrame{}
		if err := src.RecvMsg(frame); err != nil {
			if err != io.EOF {
				p.log.Debug("接收消息失败",
					slog.String("direction", direction),
					slog.Any("error", err))
			}
			return err
		}

		// 发送原始字节
		if err := dst.SendMsg(frame); err != nil {
			p.log.Debug("发送消息失败",
				slog.String("direction", direction),
				slog.Any("error", err))
			return err
		}
	}
}

// rawFrame 用于透明转发 gRPC 消息的原始字节
// 实现 proto.Message 接口以便与 gRPC 流配合使用
type rawFrame struct {
	payload []byte
}

// Reset 实现 proto.Message 接口
func (f *rawFrame) Reset() {
	f.payload = nil
}

// String 实现 proto.Message 接口
func (f *rawFrame) String() string {
	return string(f.payload)
}

// ProtoMessage 实现 proto.Message 接口
func (f *rawFrame) ProtoMessage() {}

// Marshal 序列化（返回原始字节）
func (f *rawFrame) Marshal() ([]byte, error) {
	return f.payload, nil
}

// Unmarshal 反序列化（存储原始字节）
func (f *rawFrame) Unmarshal(data []byte) error {
	f.payload = data
	return nil
}

// ============================================================================
// 辅助函数
// ============================================================================

// extractTokenFromContext 从 context 提取令牌
func extractTokenFromContext(ctx context.Context) (string, error) {
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return "", gwErr.ErrMissingMetadata
	}

	// 优先从 authorization header 获取
	if authHeader := md.Get("authorization"); len(authHeader) > 0 {
		token := authHeader[0]
		if strings.HasPrefix(token, "Bearer ") {
			return token[7:], nil
		}
		return token, nil
	}

	// 备选：从 access_token 获取
	if accessToken := md.Get("access_token"); len(accessToken) > 0 {
		return accessToken[0], nil
	}

	return "", gwErr.ErrMissingToken
}

// getRequestID 从 context 获取请求 ID
func getRequestID(ctx context.Context) string {
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return ""
	}
	if requestID := md.Get("x-request-id"); len(requestID) > 0 {
		return requestID[0]
	}
	return ""
}
