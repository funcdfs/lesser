// Package interceptor 提供 gRPC 拦截器
// 包含认证、限流、日志等中间件功能
package interceptor

import (
	"context"
	"strings"

	"go.uber.org/zap"
	"google.golang.org/grpc"
	"google.golang.org/grpc/metadata"

	"github.com/funcdfs/lesser/gateway/internal/auth"
	gwErr "github.com/funcdfs/lesser/gateway/internal/errors"
	"github.com/funcdfs/lesser/gateway/internal/ratelimit"
)

// 上下文键
type ctxKey string

const (
	// UserIDKey 用户ID上下文键
	UserIDKey ctxKey = "user_id"
)

// 公开方法列表（不需要认证）
var publicMethods = map[string]bool{
	"/gateway.GatewayService/Health": true,
	"/auth.AuthService/Login":        true,
	"/auth.AuthService/Register":     true,
	"/auth.AuthService/GetPublicKey": true,
	"/auth.AuthService/RefreshToken": true,
}

// AuthInterceptor 创建认证拦截器
func AuthInterceptor(validator *auth.JWTValidator, limiter *ratelimit.Limiter, log *zap.Logger) grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		// 公开方法跳过认证
		if publicMethods[info.FullMethod] {
			return handler(ctx, req)
		}

		// 限流检查
		if !limiter.Allow() {
			log.Warn("请求被限流", zap.String("method", info.FullMethod))
			return nil, gwErr.ErrRateLimitExceeded
		}

		// 提取并验证令牌
		token, err := extractToken(ctx)
		if err != nil {
			return nil, err
		}

		claims, err := validator.ValidateToken(token)
		if err != nil {
			log.Debug("令牌验证失败", zap.Error(err), zap.String("method", info.FullMethod))
			return nil, gwErr.ErrInvalidToken
		}

		// 注入用户信息到 context
		ctx = context.WithValue(ctx, UserIDKey, claims.UserID)

		// 传递 user_id 到下游服务
		md, _ := metadata.FromIncomingContext(ctx)
		md = metadata.Join(md, metadata.Pairs("user_id", claims.UserID))
		ctx = metadata.NewOutgoingContext(ctx, md)

		return handler(ctx, req)
	}
}

// StreamAuthInterceptor 创建流式认证拦截器
func StreamAuthInterceptor(validator *auth.JWTValidator, limiter *ratelimit.Limiter, log *zap.Logger) grpc.StreamServerInterceptor {
	return func(srv interface{}, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
		// 公开方法跳过认证
		if publicMethods[info.FullMethod] {
			return handler(srv, ss)
		}

		// 限流检查
		if !limiter.Allow() {
			log.Warn("流请求被限流", zap.String("method", info.FullMethod))
			return gwErr.ErrRateLimitExceeded
		}

		// 提取并验证令牌
		token, err := extractToken(ss.Context())
		if err != nil {
			return err
		}

		claims, err := validator.ValidateToken(token)
		if err != nil {
			log.Debug("流令牌验证失败", zap.Error(err), zap.String("method", info.FullMethod))
			return gwErr.ErrInvalidToken
		}

		// 包装 ServerStream，注入用户信息
		wrapped := &wrappedServerStream{
			ServerStream: ss,
			ctx:          context.WithValue(ss.Context(), UserIDKey, claims.UserID),
		}

		return handler(srv, wrapped)
	}
}

// wrappedServerStream 包装的 ServerStream，用于注入自定义 context
type wrappedServerStream struct {
	grpc.ServerStream
	ctx context.Context
}

func (w *wrappedServerStream) Context() context.Context {
	return w.ctx
}

// extractToken 从 context 的 metadata 中提取令牌
func extractToken(ctx context.Context) (string, error) {
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

// UserIDFromContext 从 context 获取用户ID
func UserIDFromContext(ctx context.Context) string {
	if userID, ok := ctx.Value(UserIDKey).(string); ok {
		return userID
	}
	return ""
}
