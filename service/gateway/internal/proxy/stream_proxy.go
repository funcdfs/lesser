package proxy

import (
	"context"
	"io"
	"log"
	"sync"

	"github.com/lesser/gateway/internal/auth"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

// StreamProxy gRPC 双向流代理
// 设计要点：
// 1. 支持 HTTP/2 Streaming Flush
// 2. 在建立流时验证 Token
// 3. 将 user_id 通过 metadata 传递给下游服务
// 4. 双向转发，任一方向出错都关闭整个流
type StreamProxy struct {
	jwtValidator *auth.JWTValidator
	chatConn     *grpc.ClientConn
}

// NewStreamProxy 创建流代理
func NewStreamProxy(jwtValidator *auth.JWTValidator, chatConn *grpc.ClientConn) *StreamProxy {
	return &StreamProxy{
		jwtValidator: jwtValidator,
		chatConn:     chatConn,
	}
}

// ClientEvent 客户端事件（简化定义，实际使用 proto 生成的类型）
type ClientEvent interface{}

// ServerEvent 服务端事件（简化定义，实际使用 proto 生成的类型）
type ServerEvent interface{}

// BidirectionalStream 双向流接口
type BidirectionalStream interface {
	Send(interface{}) error
	Recv() (interface{}, error)
	Context() context.Context
}

// ProxyStreamEvents 代理 Chat 双向流
// 关键：确保支持 HTTP/2 Streaming Flush，不能使用 HTTP/1.1 中间件
func (p *StreamProxy) ProxyStreamEvents(
	clientStream grpc.ServerStream,
	createServerStream func(ctx context.Context) (grpc.ClientStream, error),
) error {
	ctx := clientStream.Context()

	// 1. 从 metadata 提取 Token
	token, err := extractTokenFromContext(ctx)
	if err != nil {
		log.Printf("[StreamProxy] Failed to extract token: %v", err)
		return status.Error(codes.Unauthenticated, "missing or invalid authorization")
	}

	// 2. 本地验签 JWT
	claims, err := p.jwtValidator.ValidateToken(token)
	if err != nil {
		log.Printf("[StreamProxy] Token validation failed: %v", err)
		return status.Error(codes.Unauthenticated, "invalid token")
	}

	log.Printf("[StreamProxy] Stream authenticated for user: %s", claims.UserID)

	// 3. 创建到下游服务的 context，注入 user_id
	md := metadata.Pairs(
		"user_id", claims.UserID,
		"x-request-id", getRequestID(ctx),
	)
	serverCtx := metadata.NewOutgoingContext(ctx, md)

	// 4. 创建到下游服务的双向流
	serverStream, err := createServerStream(serverCtx)
	if err != nil {
		log.Printf("[StreamProxy] Failed to create server stream: %v", err)
		return status.Error(codes.Unavailable, "failed to connect to chat service")
	}

	// 5. 双向转发
	errChan := make(chan error, 2)
	var wg sync.WaitGroup
	wg.Add(2)

	// Client -> Server 转发
	go func() {
		defer wg.Done()
		err := p.forwardClientToServer(clientStream, serverStream)
		if err != nil && err != io.EOF {
			log.Printf("[StreamProxy] Client->Server error: %v", err)
		}
		errChan <- err
	}()

	// Server -> Client 转发
	go func() {
		defer wg.Done()
		err := p.forwardServerToClient(serverStream, clientStream)
		if err != nil && err != io.EOF {
			log.Printf("[StreamProxy] Server->Client error: %v", err)
		}
		errChan <- err
	}()

	// 等待任一方向结束
	err = <-errChan

	// 关闭流
	if cs, ok := serverStream.(interface{ CloseSend() error }); ok {
		cs.CloseSend()
	}

	// 等待两个 goroutine 结束
	wg.Wait()

	// 正常关闭返回 nil
	if err == io.EOF {
		return nil
	}

	return err
}


// forwardClientToServer 转发客户端消息到服务端
func (p *StreamProxy) forwardClientToServer(clientStream grpc.ServerStream, serverStream grpc.ClientStream) error {
	for {
		// 检查 context 是否已取消
		if err := clientStream.Context().Err(); err != nil {
			return err
		}

		// 接收客户端消息
		msg := new(interface{})
		if err := clientStream.RecvMsg(msg); err != nil {
			if err == io.EOF {
				// 客户端正常关闭
				return io.EOF
			}
			return err
		}

		// 转发到服务端
		if err := serverStream.SendMsg(msg); err != nil {
			return err
		}
	}
}

// forwardServerToClient 转发服务端消息到客户端
func (p *StreamProxy) forwardServerToClient(serverStream grpc.ClientStream, clientStream grpc.ServerStream) error {
	for {
		// 检查 context 是否已取消
		if err := serverStream.Context().Err(); err != nil {
			return err
		}

		// 接收服务端消息
		msg := new(interface{})
		if err := serverStream.RecvMsg(msg); err != nil {
			if err == io.EOF {
				// 服务端正常关闭
				return io.EOF
			}
			return err
		}

		// 转发到客户端
		if err := clientStream.SendMsg(msg); err != nil {
			return err
		}
	}
}

// extractTokenFromContext 从 context 提取 Token
func extractTokenFromContext(ctx context.Context) (string, error) {
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return "", status.Error(codes.Unauthenticated, "missing metadata")
	}

	// 尝试从 authorization header 获取
	authHeader := md.Get("authorization")
	if len(authHeader) > 0 {
		token := authHeader[0]
		// 移除 "Bearer " 前缀
		if len(token) > 7 && token[:7] == "Bearer " {
			return token[7:], nil
		}
		return token, nil
	}

	// 尝试从 access_token 获取
	accessToken := md.Get("access_token")
	if len(accessToken) > 0 {
		return accessToken[0], nil
	}

	return "", status.Error(codes.Unauthenticated, "missing authorization token")
}

// getRequestID 从 context 获取请求 ID
func getRequestID(ctx context.Context) string {
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return ""
	}

	requestID := md.Get("x-request-id")
	if len(requestID) > 0 {
		return requestID[0]
	}

	return ""
}

// GenericStreamProxy 通用流代理（用于任意 gRPC 双向流）
type GenericStreamProxy struct {
	jwtValidator *auth.JWTValidator
}

// NewGenericStreamProxy 创建通用流代理
func NewGenericStreamProxy(jwtValidator *auth.JWTValidator) *GenericStreamProxy {
	return &GenericStreamProxy{
		jwtValidator: jwtValidator,
	}
}

// Proxy 代理任意双向流
func (p *GenericStreamProxy) Proxy(
	clientStream grpc.ServerStream,
	serverStream grpc.ClientStream,
) error {
	errChan := make(chan error, 2)
	var wg sync.WaitGroup
	wg.Add(2)

	// Client -> Server
	go func() {
		defer wg.Done()
		for {
			msg := new(interface{})
			if err := clientStream.RecvMsg(msg); err != nil {
				errChan <- err
				return
			}
			if err := serverStream.SendMsg(msg); err != nil {
				errChan <- err
				return
			}
		}
	}()

	// Server -> Client
	go func() {
		defer wg.Done()
		for {
			msg := new(interface{})
			if err := serverStream.RecvMsg(msg); err != nil {
				errChan <- err
				return
			}
			if err := clientStream.SendMsg(msg); err != nil {
				errChan <- err
				return
			}
		}
	}()

	err := <-errChan
	wg.Wait()

	if err == io.EOF {
		return nil
	}
	return err
}
