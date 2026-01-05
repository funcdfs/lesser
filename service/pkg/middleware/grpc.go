// Package middleware 提供 gRPC 服务端中间件
// Deprecated: 请使用 github.com/funcdfs/lesser/pkg/grpc/interceptor 包
package middleware

import (
	"context"
	"time"

	"github.com/funcdfs/lesser/pkg/grpc/interceptor"
	"github.com/funcdfs/lesser/pkg/logger"
	"google.golang.org/grpc"
)

// UnaryServerInterceptor 一元 RPC 拦截器类型
// Deprecated: 请使用 interceptor.UnaryServerInterceptor
type UnaryServerInterceptor = grpc.UnaryServerInterceptor

// StreamServerInterceptor 流式 RPC 拦截器类型
// Deprecated: 请使用 interceptor.StreamServerInterceptor
type StreamServerInterceptor = grpc.StreamServerInterceptor

// RecoveryInterceptor 创建 panic 恢复拦截器
// Deprecated: 请使用 interceptor.RecoveryInterceptor
func RecoveryInterceptor(log *logger.Logger) UnaryServerInterceptor {
	return interceptor.RecoveryInterceptor(log)
}

// LoggingInterceptor 创建日志拦截器
// Deprecated: 请使用 interceptor.LoggingInterceptor
func LoggingInterceptor(log *logger.Logger) UnaryServerInterceptor {
	return interceptor.LoggingInterceptor(log)
}

// TraceInterceptor 创建链路追踪拦截器
// Deprecated: 请使用 interceptor.TraceInterceptor
func TraceInterceptor() UnaryServerInterceptor {
	return interceptor.TraceInterceptor()
}

// TimeoutInterceptor 创建超时拦截器
// Deprecated: 请使用 interceptor.TimeoutInterceptor
func TimeoutInterceptor(timeout time.Duration) UnaryServerInterceptor {
	return interceptor.TimeoutInterceptor(timeout)
}

// ChainUnaryServer 链接多个一元拦截器
// Deprecated: 请使用 interceptor.ChainUnaryServer
func ChainUnaryServer(interceptors ...UnaryServerInterceptor) UnaryServerInterceptor {
	return interceptor.ChainUnaryServer(interceptors...)
}

// StreamRecoveryInterceptor 创建流式 panic 恢复拦截器
// Deprecated: 请使用 interceptor.StreamRecoveryInterceptor
func StreamRecoveryInterceptor(log *logger.Logger) StreamServerInterceptor {
	return interceptor.StreamRecoveryInterceptor(log)
}

// StreamLoggingInterceptor 创建流式日志拦截器
// Deprecated: 请使用 interceptor.StreamLoggingInterceptor
func StreamLoggingInterceptor(log *logger.Logger) StreamServerInterceptor {
	return interceptor.StreamLoggingInterceptor(log)
}

// StreamTraceInterceptor 创建流式链路追踪拦截器
// Deprecated: 请使用 interceptor.StreamTraceInterceptor
func StreamTraceInterceptor() StreamServerInterceptor {
	return interceptor.StreamTraceInterceptor()
}

// ChainStreamServer 链接多个流式拦截器
// Deprecated: 请使用 interceptor.ChainStreamServer
func ChainStreamServer(interceptors ...StreamServerInterceptor) StreamServerInterceptor {
	return interceptor.ChainStreamServer(interceptors...)
}

// PerKeyRateLimiter 按 key 限流器
// Deprecated: 请使用 interceptor.PerKeyRateLimiter
type PerKeyRateLimiter = interceptor.PerKeyRateLimiter

// NewPerKeyRateLimiter 创建按 key 限流器
// Deprecated: 请使用 interceptor.NewPerKeyRateLimiter
func NewPerKeyRateLimiter(rate, capacity float64) *PerKeyRateLimiter {
	return interceptor.NewPerKeyRateLimiter(rate, capacity)
}

// RateLimitInterceptor 创建限流拦截器
// Deprecated: 请使用 interceptor.RateLimitInterceptor
func RateLimitInterceptor(limiter *PerKeyRateLimiter, keyExtractor func(ctx context.Context) string) UnaryServerInterceptor {
	return interceptor.RateLimitInterceptor(limiter, keyExtractor)
}

// IPKeyExtractor 从 metadata 中提取 IP 作为限流 key
// Deprecated: 请使用 interceptor.IPKeyExtractor
func IPKeyExtractor(ctx context.Context) string {
	return interceptor.IPKeyExtractor(ctx)
}

// UserIDKeyExtractor 从 metadata 中提取用户 ID 作为限流 key
// Deprecated: 请使用 interceptor.UserIDKeyExtractor
func UserIDKeyExtractor(ctx context.Context) string {
	return interceptor.UserIDKeyExtractor(ctx)
}
