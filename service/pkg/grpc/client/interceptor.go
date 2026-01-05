package client

import (
	"context"
	"log/slog"
	"time"

	"github.com/funcdfs/lesser/pkg/log"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/codes"
	"go.opentelemetry.io/otel/trace"
	"google.golang.org/grpc"
	grpccodes "google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

// TraceInterceptor 创建 trace_id 传递拦截器
// 从 context 中提取 trace_id 并添加到 gRPC metadata 中
// 同时创建 OpenTelemetry Span 用于追踪
func TraceInterceptor() grpc.UnaryClientInterceptor {
	return func(ctx context.Context, method string, req, reply interface{},
		cc *grpc.ClientConn, invoker grpc.UnaryInvoker, opts ...grpc.CallOption) error {

		// 从 context 中提取 trace_id
		traceID := log.TraceIDFromContext(ctx)
		if traceID != "" {
			// 添加到 gRPC metadata
			ctx = metadata.AppendToOutgoingContext(ctx, "trace_id", traceID)
		}

		// 创建 OpenTelemetry Span
		tracer := otel.Tracer("grpc-client")
		ctx, span := tracer.Start(ctx, method,
			trace.WithSpanKind(trace.SpanKindClient),
		)
		defer span.End()

		// 设置 Span 属性
		span.SetAttributes(
			attribute.String("rpc.system", "grpc"),
			attribute.String("rpc.method", method),
			attribute.String("rpc.service", extractServiceName(method)),
		)
		if traceID != "" {
			span.SetAttributes(attribute.String("trace_id", traceID))
		}

		// 调用远程服务
		err := invoker(ctx, method, req, reply, cc, opts...)

		// 记录错误到 Span
		if err != nil {
			span.RecordError(err)
			span.SetStatus(codes.Error, err.Error())
			if s, ok := status.FromError(err); ok {
				span.SetAttributes(attribute.String("rpc.grpc.status_code", s.Code().String()))
			}
		} else {
			span.SetStatus(codes.Ok, "")
			span.SetAttributes(attribute.String("rpc.grpc.status_code", "OK"))
		}

		return err
	}
}

// extractServiceName 从完整方法名中提取服务名
// 例如：/auth.AuthService/Login -> auth.AuthService
func extractServiceName(fullMethod string) string {
	if len(fullMethod) == 0 {
		return ""
	}
	// 移除开头的 /
	if fullMethod[0] == '/' {
		fullMethod = fullMethod[1:]
	}
	// 找到最后一个 /
	for i := len(fullMethod) - 1; i >= 0; i-- {
		if fullMethod[i] == '/' {
			return fullMethod[:i]
		}
	}
	return fullMethod
}

// LoggingInterceptor 创建日志拦截器
// 记录 gRPC 调用的方法、耗时和错误
func LoggingInterceptor(logger *log.Logger) grpc.UnaryClientInterceptor {
	return func(ctx context.Context, method string, req, reply interface{},
		cc *grpc.ClientConn, invoker grpc.UnaryInvoker, opts ...grpc.CallOption) error {

		start := time.Now()
		err := invoker(ctx, method, req, reply, cc, opts...)
		duration := time.Since(start)

		if err != nil {
			logger.WithContext(ctx).Error("grpc call failed",
				slog.String("method", method),
				slog.Duration("duration", duration),
				slog.Any("error", err))
		} else {
			logger.WithContext(ctx).Debug("grpc call completed",
				slog.String("method", method),
				slog.Duration("duration", duration))
		}

		return err
	}
}

// RetryInterceptor 创建重试拦截器
// 对可重试的错误进行自动重试（指数退避）
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
			if !IsRetryable(err) {
				return err
			}

			// 检查 context 是否已取消
			select {
			case <-ctx.Done():
				return ctx.Err()
			default:
			}

			// 等待退避时间（指数退避）
			if i < maxRetries {
				time.Sleep(backoff * time.Duration(i+1))
			}
		}

		return lastErr
	}
}

// IsRetryable 判断错误是否可重试
// 可重试的错误码：Unavailable, ResourceExhausted, Aborted, DeadlineExceeded
func IsRetryable(err error) bool {
	s, ok := status.FromError(err)
	if !ok {
		return false
	}

	switch s.Code() {
	case grpccodes.Unavailable, grpccodes.ResourceExhausted, grpccodes.Aborted, grpccodes.DeadlineExceeded:
		return true
	default:
		return false
	}
}

// ChainUnaryClient 链接多个拦截器
// 使用递归方式构建拦截器链，避免闭包变量捕获问题
func ChainUnaryClient(interceptors ...grpc.UnaryClientInterceptor) grpc.UnaryClientInterceptor {
	n := len(interceptors)
	if n == 0 {
		return func(ctx context.Context, method string, req, reply interface{},
			cc *grpc.ClientConn, invoker grpc.UnaryInvoker, opts ...grpc.CallOption) error {
			return invoker(ctx, method, req, reply, cc, opts...)
		}
	}
	if n == 1 {
		return interceptors[0]
	}

	return func(ctx context.Context, method string, req, reply interface{},
		cc *grpc.ClientConn, invoker grpc.UnaryInvoker, opts ...grpc.CallOption) error {
		// 使用递归构建链式调用
		return interceptors[0](ctx, method, req, reply, cc,
			buildChainInvoker(interceptors[1:], invoker), opts...)
	}
}

// buildChainInvoker 递归构建拦截器链
func buildChainInvoker(interceptors []grpc.UnaryClientInterceptor, finalInvoker grpc.UnaryInvoker) grpc.UnaryInvoker {
	if len(interceptors) == 0 {
		return finalInvoker
	}
	return func(ctx context.Context, method string, req, reply interface{},
		cc *grpc.ClientConn, opts ...grpc.CallOption) error {
		return interceptors[0](ctx, method, req, reply, cc,
			buildChainInvoker(interceptors[1:], finalInvoker), opts...)
	}
}
