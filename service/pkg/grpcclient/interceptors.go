package grpcclient

import (
	"context"
	"time"

	"github.com/lesser/pkg/logger"
	"go.uber.org/zap"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

// TraceInterceptor 创建 trace_id 传递拦截器
// 从 context 中提取 trace_id 并添加到 gRPC metadata 中
func TraceInterceptor() grpc.UnaryClientInterceptor {
	return func(ctx context.Context, method string, req, reply interface{},
		cc *grpc.ClientConn, invoker grpc.UnaryInvoker, opts ...grpc.CallOption) error {

		// 从 context 中提取 trace_id
		traceID := logger.TraceIDFromContext(ctx)
		if traceID != "" {
			// 添加到 gRPC metadata
			ctx = metadata.AppendToOutgoingContext(ctx, "trace_id", traceID)
		}

		return invoker(ctx, method, req, reply, cc, opts...)
	}
}

// LoggingInterceptor 创建日志拦截器
// 记录 gRPC 调用的方法、耗时和错误
func LoggingInterceptor(log *logger.Logger) grpc.UnaryClientInterceptor {
	return func(ctx context.Context, method string, req, reply interface{},
		cc *grpc.ClientConn, invoker grpc.UnaryInvoker, opts ...grpc.CallOption) error {

		start := time.Now()
		err := invoker(ctx, method, req, reply, cc, opts...)
		duration := time.Since(start)

		fields := []zap.Field{
			zap.String("method", method),
			zap.Duration("duration", duration),
		}

		if err != nil {
			fields = append(fields, zap.Error(err))
			log.WithContext(ctx).Error("grpc call failed", fields...)
		} else {
			log.WithContext(ctx).Debug("grpc call completed", fields...)
		}

		return err
	}
}

// RetryInterceptor 创建重试拦截器
// 对可重试的错误进行自动重试
func RetryInterceptor(maxRetries int, backoff time.Duration) grpc.UnaryClientInterceptor {
	return func(ctx context.Context, method string, req, reply interface{},
		cc *grpc.ClientConn, invoker grpc.UnaryInvoker, opts ...grpc.CallOption) error {

		var lastErr error
		for i := 0; i <= maxRetries; i++ {
			err := invoker(ctx, method, req, reply, cc, opts...)
			if err == nil {
				return nil
			}
			lastErr = err

			// 检查是否可重试
			if !isRetryable(err) {
				return err
			}

			// 检查 context 是否已取消
			select {
			case <-ctx.Done():
				return ctx.Err()
			default:
			}

			// 等待退避时间
			if i < maxRetries {
				time.Sleep(backoff * time.Duration(i+1))
			}
		}

		return lastErr
	}
}

// isRetryable 判断错误是否可重试
func isRetryable(err error) bool {
	s, ok := status.FromError(err)
	if !ok {
		return false
	}

	switch s.Code() {
	case codes.Unavailable, codes.ResourceExhausted, codes.Aborted, codes.DeadlineExceeded:
		return true
	default:
		return false
	}
}

// ChainUnaryClient 链接多个拦截器
func ChainUnaryClient(interceptors ...grpc.UnaryClientInterceptor) grpc.UnaryClientInterceptor {
	return func(ctx context.Context, method string, req, reply interface{},
		cc *grpc.ClientConn, invoker grpc.UnaryInvoker, opts ...grpc.CallOption) error {

		// 构建拦截器链
		chain := invoker
		for i := len(interceptors) - 1; i >= 0; i-- {
			interceptor := interceptors[i]
			next := chain
			chain = func(ctx context.Context, method string, req, reply interface{},
				cc *grpc.ClientConn, opts ...grpc.CallOption) error {
				return interceptor(ctx, method, req, reply, cc, next, opts...)
			}
		}

		return chain(ctx, method, req, reply, cc, opts...)
	}
}
