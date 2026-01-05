package grpcclient

import (
	"time"

	"github.com/funcdfs/lesser/pkg/grpc/client"
	"github.com/funcdfs/lesser/pkg/logger"
	"google.golang.org/grpc"
)

// TraceInterceptor 创建 trace_id 传递拦截器
// Deprecated: 请使用 client.TraceInterceptor
func TraceInterceptor() grpc.UnaryClientInterceptor {
	return client.TraceInterceptor()
}

// LoggingInterceptor 创建日志拦截器
// Deprecated: 请使用 client.LoggingInterceptor
func LoggingInterceptor(log *logger.Logger) grpc.UnaryClientInterceptor {
	return client.LoggingInterceptor(log)
}

// RetryInterceptor 创建重试拦截器
// Deprecated: 请使用 client.RetryInterceptor
func RetryInterceptor(maxRetries int, backoff time.Duration) grpc.UnaryClientInterceptor {
	return client.RetryInterceptor(maxRetries, backoff)
}

// ChainUnaryClient 链接多个拦截器
// Deprecated: 请使用 client.ChainUnaryClient
func ChainUnaryClient(interceptors ...grpc.UnaryClientInterceptor) grpc.UnaryClientInterceptor {
	return client.ChainUnaryClient(interceptors...)
}
