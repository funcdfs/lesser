package server

import (
	"context"
	"log"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/lesser/chat/internal/auth"
	"github.com/lesser/chat/internal/service"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

// authUnaryInterceptor 认证拦截器，从 metadata 中提取并验证 token
func authUnaryInterceptor(authClient *service.AuthClient) grpc.UnaryServerInterceptor {
	return func(
		ctx context.Context,
		req interface{},
		info *grpc.UnaryServerInfo,
		handler grpc.UnaryHandler,
	) (interface{}, error) {
		// 内部服务调用可跳过认证（通过特定 header 标识）
		md, ok := metadata.FromIncomingContext(ctx)
		if ok {
			// 检查是否为内部服务调用
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
					// 将用户 ID 存入 context
					ctx = auth.SetUserIDInContext(ctx, userID)
					return handler(ctx, req)
				}
			}

			// 兼容开发环境：从 x-user-id header 获取（仅开发/测试使用）
			if userIDHeaders := md.Get("x-user-id"); len(userIDHeaders) > 0 {
				userID, err := uuid.Parse(userIDHeaders[0])
				if err == nil {
					ctx = auth.SetUserIDInContext(ctx, userID)
					return handler(ctx, req)
				}
			}
		}

		// 允许未认证的请求继续（由具体 handler 决定是否需要认证）
		return handler(ctx, req)
	}
}

// unaryServerInterceptor returns a unary server interceptor for logging and recovery
func unaryServerInterceptor() grpc.UnaryServerInterceptor {
	return func(
		ctx context.Context,
		req interface{},
		info *grpc.UnaryServerInfo,
		handler grpc.UnaryHandler,
	) (interface{}, error) {
		start := time.Now()

		// Recover from panics
		defer func() {
			if r := recover(); r != nil {
				log.Printf("Panic recovered in gRPC handler: %v", r)
			}
		}()

		// Call the handler
		resp, err := handler(ctx, req)

		// Log the request
		duration := time.Since(start)
		statusCode := codes.OK
		if err != nil {
			statusCode = status.Code(err)
		}

		log.Printf("gRPC %s | %s | %v | %v",
			info.FullMethod,
			statusCode,
			duration,
			err,
		)

		return resp, err
	}
}

// streamServerInterceptor returns a stream server interceptor for logging and recovery
func streamServerInterceptor() grpc.StreamServerInterceptor {
	return func(
		srv interface{},
		ss grpc.ServerStream,
		info *grpc.StreamServerInfo,
		handler grpc.StreamHandler,
	) error {
		start := time.Now()

		// Recover from panics
		defer func() {
			if r := recover(); r != nil {
				log.Printf("Panic recovered in gRPC stream handler: %v", r)
			}
		}()

		// Call the handler
		err := handler(srv, ss)

		// Log the request
		duration := time.Since(start)
		statusCode := codes.OK
		if err != nil {
			statusCode = status.Code(err)
		}

		log.Printf("gRPC Stream %s | %s | %v | %v",
			info.FullMethod,
			statusCode,
			duration,
			err,
		)

		return err
	}
}
