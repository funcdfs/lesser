// Package interceptor 提供 gRPC 服务端拦截器
// 支持日志、认证、恢复、限流、OpenTelemetry 追踪等功能
package interceptor

import (
	"context"
	"log/slog"
	"runtime/debug"

	"github.com/funcdfs/lesser/pkg/logger"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// RecoveryInterceptor 创建 panic 恢复拦截器
func RecoveryInterceptor(log *logger.Logger) grpc.UnaryServerInterceptor {
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

// StreamRecoveryInterceptor 创建流式 panic 恢复拦截器
func StreamRecoveryInterceptor(log *logger.Logger) grpc.StreamServerInterceptor {
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
