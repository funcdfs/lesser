package interceptor

import (
	"context"
	"log/slog"
	"time"

	"github.com/funcdfs/lesser/pkg/log"
	"google.golang.org/grpc"
	"google.golang.org/grpc/status"
)

// LoggingInterceptor 创建日志拦截器
func LoggingInterceptor(logger *log.Logger) grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		start := time.Now()

		// 调用处理器
		resp, err := handler(ctx, req)

		duration := time.Since(start)

		// 记录日志
		if err != nil {
			code, _ := status.FromError(err)
			logger.WithContext(ctx).Error("grpc request failed",
				slog.String("method", info.FullMethod),
				slog.Duration("duration", duration),
				slog.String("code", code.Code().String()),
				slog.Any("error", err))
		} else {
			logger.WithContext(ctx).Info("grpc request completed",
				slog.String("method", info.FullMethod),
				slog.Duration("duration", duration))
		}

		return resp, err
	}
}

// StreamLoggingInterceptor 创建流式日志拦截器
func StreamLoggingInterceptor(logger *log.Logger) grpc.StreamServerInterceptor {
	return func(srv interface{}, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
		start := time.Now()

		err := handler(srv, ss)

		duration := time.Since(start)

		if err != nil {
			code, _ := status.FromError(err)
			logger.Error("stream request failed",
				slog.String("method", info.FullMethod),
				slog.Duration("duration", duration),
				slog.String("code", code.Code().String()),
				slog.Any("error", err))
		} else {
			logger.Info("stream request completed",
				slog.String("method", info.FullMethod),
				slog.Duration("duration", duration))
		}

		return err
	}
}
