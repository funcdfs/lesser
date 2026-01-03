// Package middleware 提供 gRPC 服务端中间件
// 支持日志、认证、恢复、限流等功能
package middleware

import (
	"context"
	"log/slog"
	"runtime/debug"
	"time"

	"github.com/funcdfs/lesser/pkg/logger"
	"github.com/google/uuid"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

// UnaryServerInterceptor 一元 RPC 拦截器类型
type UnaryServerInterceptor = grpc.UnaryServerInterceptor

// StreamServerInterceptor 流式 RPC 拦截器类型
type StreamServerInterceptor = grpc.StreamServerInterceptor

// RecoveryInterceptor 创建 panic 恢复拦截器
func RecoveryInterceptor(log *logger.Logger) UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (resp interface{}, err error) {
		defer func() {
			if r := recover(); r != nil {
				log.WithContext(ctx).Error("panic recovered",
					slog.Any("panic", r),
					slog.String("method", info.FullMethod),
					slog.String("stack", string(debug.Stack())))
				err = status.Errorf(codes.Internal, "内部服务错误")
			}
		}()
		return handler(ctx, req)
	}
}

// LoggingInterceptor 创建日志拦截器
func LoggingInterceptor(log *logger.Logger) UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		start := time.Now()

		// 调用处理器
		resp, err := handler(ctx, req)

		duration := time.Since(start)

		// 记录日志
		if err != nil {
			code, _ := status.FromError(err)
			log.WithContext(ctx).Error("grpc request failed",
				slog.String("method", info.FullMethod),
				slog.Duration("duration", duration),
				slog.String("code", code.Code().String()),
				slog.Any("error", err))
		} else {
			log.WithContext(ctx).Info("grpc request completed",
				slog.String("method", info.FullMethod),
				slog.Duration("duration", duration))
		}

		return resp, err
	}
}

// TraceInterceptor 创建链路追踪拦截器
func TraceInterceptor() UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		// 从 metadata 中提取 trace_id
		var traceID string
		if md, ok := metadata.FromIncomingContext(ctx); ok {
			if values := md.Get("trace_id"); len(values) > 0 {
				traceID = values[0]
			}
		}

		// 如果没有 trace_id，生成一个新的
		if traceID == "" {
			traceID = uuid.New().String()
		}

		// 注入到 context
		ctx = logger.ContextWithTraceID(ctx, traceID)

		return handler(ctx, req)
	}
}

// TimeoutInterceptor 创建超时拦截器
func TimeoutInterceptor(timeout time.Duration) UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		ctx, cancel := context.WithTimeout(ctx, timeout)
		defer cancel()
		return handler(ctx, req)
	}
}

// ChainUnaryServer 链接多个一元拦截器
func ChainUnaryServer(interceptors ...UnaryServerInterceptor) UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		// 构建拦截器链
		chain := handler
		for i := len(interceptors) - 1; i >= 0; i-- {
			interceptor := interceptors[i]
			next := chain
			chain = func(ctx context.Context, req interface{}) (interface{}, error) {
				return interceptor(ctx, req, info, next)
			}
		}
		return chain(ctx, req)
	}
}

// ---- 流式拦截器 ----

// StreamRecoveryInterceptor 创建流式 panic 恢复拦截器
func StreamRecoveryInterceptor(log *logger.Logger) StreamServerInterceptor {
	return func(srv interface{}, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) (err error) {
		defer func() {
			if r := recover(); r != nil {
				log.Error("stream panic recovered",
					slog.Any("panic", r),
					slog.String("method", info.FullMethod),
					slog.String("stack", string(debug.Stack())))
				err = status.Errorf(codes.Internal, "内部服务错误")
			}
		}()
		return handler(srv, ss)
	}
}

// StreamLoggingInterceptor 创建流式日志拦截器
func StreamLoggingInterceptor(log *logger.Logger) StreamServerInterceptor {
	return func(srv interface{}, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
		start := time.Now()

		err := handler(srv, ss)

		duration := time.Since(start)

		if err != nil {
			code, _ := status.FromError(err)
			log.Error("stream request failed",
				slog.String("method", info.FullMethod),
				slog.Duration("duration", duration),
				slog.String("code", code.Code().String()),
				slog.Any("error", err))
		} else {
			log.Info("stream request completed",
				slog.String("method", info.FullMethod),
				slog.Duration("duration", duration))
		}

		return err
	}
}

// StreamTraceInterceptor 创建流式链路追踪拦截器
func StreamTraceInterceptor() StreamServerInterceptor {
	return func(srv interface{}, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
		ctx := ss.Context()

		// 从 metadata 中提取 trace_id
		var traceID string
		if md, ok := metadata.FromIncomingContext(ctx); ok {
			if values := md.Get("trace_id"); len(values) > 0 {
				traceID = values[0]
			}
		}

		// 如果没有 trace_id，生成一个新的
		if traceID == "" {
			traceID = uuid.New().String()
		}

		// 包装 ServerStream 以注入 trace_id
		wrapped := &wrappedServerStream{
			ServerStream: ss,
			ctx:          logger.ContextWithTraceID(ctx, traceID),
		}

		return handler(srv, wrapped)
	}
}

// wrappedServerStream 包装 ServerStream 以支持自定义 context
type wrappedServerStream struct {
	grpc.ServerStream
	ctx context.Context
}

func (w *wrappedServerStream) Context() context.Context {
	return w.ctx
}

// ChainStreamServer 链接多个流式拦截器
func ChainStreamServer(interceptors ...StreamServerInterceptor) StreamServerInterceptor {
	return func(srv interface{}, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
		chain := handler
		for i := len(interceptors) - 1; i >= 0; i-- {
			interceptor := interceptors[i]
			next := chain
			chain = func(srv interface{}, ss grpc.ServerStream) error {
				return interceptor(srv, ss, info, next)
			}
		}
		return chain(srv, ss)
	}
}
