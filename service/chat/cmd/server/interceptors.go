package main

import (
	"context"
	"log/slog"
	"strings"
	"time"

	"github.com/funcdfs/lesser/chat/internal/service"
	"github.com/funcdfs/lesser/pkg/auth"
	"github.com/funcdfs/lesser/pkg/logger"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

// authUnaryInterceptor 认证拦截器
func authUnaryInterceptor(authClient *service.AuthClient) grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		md, ok := metadata.FromIncomingContext(ctx)
		if !ok {
			return handler(ctx, req)
		}

		// 内部服务调用跳过认证
		if internalKeys := md.Get("x-internal-service"); len(internalKeys) > 0 && internalKeys[0] == "true" {
			return handler(ctx, req)
		}

		// 从 authorization header 获取 token
		if authHeaders := md.Get("authorization"); len(authHeaders) > 0 {
			token := strings.TrimPrefix(authHeaders[0], "Bearer ")
			if token != "" && authClient != nil {
				userID, err := authClient.ValidateToken(ctx, token)
				if err != nil {
					return nil, status.Error(codes.Unauthenticated, "token 验证失败")
				}
				ctx = auth.ContextWithUserID(ctx, userID.String())
				return handler(ctx, req)
			}
		}

		// 从 x-user-id header 获取（Gateway 转发）
		if userIDHeaders := md.Get("x-user-id"); len(userIDHeaders) > 0 {
			ctx = auth.ContextWithUserID(ctx, userIDHeaders[0])
			return handler(ctx, req)
		}

		// 兼容 user_id header（客户端直接传递）
		if userIDHeaders := md.Get("user_id"); len(userIDHeaders) > 0 {
			ctx = auth.ContextWithUserID(ctx, userIDHeaders[0])
			return handler(ctx, req)
		}

		return handler(ctx, req)
	}
}

// loggingUnaryInterceptor 日志拦截器
func loggingUnaryInterceptor(log *logger.Logger) grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		start := time.Now()

		// Panic 恢复
		defer func() {
			if r := recover(); r != nil {
				log.LogPanic(ctx, r)
			}
		}()

		resp, err := handler(ctx, req)

		duration := time.Since(start)
		statusCode := codes.OK
		if err != nil {
			statusCode = status.Code(err)
		}

		// 记录请求日志
		log.Info("gRPC request",
			slog.String("method", info.FullMethod),
			slog.String("status", statusCode.String()),
			slog.Duration("duration", duration),
			slog.Any("error", err),
		)

		return resp, err
	}
}

// loggingStreamInterceptor 流日志拦截器
func loggingStreamInterceptor(log *logger.Logger) grpc.StreamServerInterceptor {
	return func(srv interface{}, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
		start := time.Now()

		// Panic 恢复
		defer func() {
			if r := recover(); r != nil {
				log.LogPanic(ss.Context(), r)
			}
		}()

		err := handler(srv, ss)

		duration := time.Since(start)
		statusCode := codes.OK
		if err != nil {
			statusCode = status.Code(err)
		}

		// 记录流请求日志
		log.Info("gRPC stream",
			slog.String("method", info.FullMethod),
			slog.String("status", statusCode.String()),
			slog.Duration("duration", duration),
			slog.Any("error", err),
		)

		return err
	}
}
