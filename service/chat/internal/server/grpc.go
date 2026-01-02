package server

import (
	"context"
	"log"
	"net"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/funcdfs/lesser/chat/internal/auth"
	grpchandler "github.com/funcdfs/lesser/chat/internal/handler/grpc"
	"github.com/funcdfs/lesser/chat/internal/service"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/keepalive"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/reflection"
	"google.golang.org/grpc/status"
)

type GRPCServer struct {
	server      *grpc.Server
	chatHandler *grpchandler.ChatHandler
}

func NewGRPCServer(chatService *service.ChatService, authClient *service.AuthClient) *GRPCServer {
	keepalivePolicy := keepalive.EnforcementPolicy{
		MinTime:             10 * time.Second,
		PermitWithoutStream: true,
	}

	keepaliveParams := keepalive.ServerParameters{
		MaxConnectionIdle:     5 * time.Minute,
		MaxConnectionAge:      30 * time.Minute,
		MaxConnectionAgeGrace: 10 * time.Second,
		Time:                  30 * time.Second,
		Timeout:               10 * time.Second,
	}

	server := grpc.NewServer(
		grpc.KeepaliveEnforcementPolicy(keepalivePolicy),
		grpc.KeepaliveParams(keepaliveParams),
		grpc.MaxRecvMsgSize(4*1024*1024),
		grpc.MaxSendMsgSize(4*1024*1024),
		grpc.MaxConcurrentStreams(100),
		grpc.ChainUnaryInterceptor(
			authUnaryInterceptor(authClient),
			loggingUnaryInterceptor(),
		),
		grpc.StreamInterceptor(loggingStreamInterceptor()),
	)

	chatHandler := grpchandler.NewChatHandler(chatService)
	chatHandler.Register(server)

	reflection.Register(server)

	return &GRPCServer{
		server:      server,
		chatHandler: chatHandler,
	}
}

func (s *GRPCServer) Serve(listener net.Listener) error {
	return s.server.Serve(listener)
}

func (s *GRPCServer) GracefulStop() {
	s.server.GracefulStop()
}

func (s *GRPCServer) Stop() {
	s.server.Stop()
}

// 认证拦截器
func authUnaryInterceptor(authClient *service.AuthClient) grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		md, ok := metadata.FromIncomingContext(ctx)
		if ok {
			if internalKeys := md.Get("x-internal-service"); len(internalKeys) > 0 && internalKeys[0] == "true" {
				return handler(ctx, req)
			}

			if authHeaders := md.Get("authorization"); len(authHeaders) > 0 {
				token := strings.TrimPrefix(authHeaders[0], "Bearer ")
				if token != "" && authClient != nil {
					userID, err := authClient.ValidateToken(ctx, token)
					if err != nil {
						return nil, status.Error(codes.Unauthenticated, "token 验证失败")
					}
					ctx = auth.SetUserIDInContext(ctx, userID)
					return handler(ctx, req)
				}
			}

			// 检查 user_id header（客户端传递）
			if userIDHeaders := md.Get("user_id"); len(userIDHeaders) > 0 {
				userID, err := uuid.Parse(userIDHeaders[0])
				if err == nil {
					ctx = auth.SetUserIDInContext(ctx, userID)
					return handler(ctx, req)
				}
			}
			
			// 兼容 x-user-id header（Gateway 转发）
			if userIDHeaders := md.Get("x-user-id"); len(userIDHeaders) > 0 {
				userID, err := uuid.Parse(userIDHeaders[0])
				if err == nil {
					ctx = auth.SetUserIDInContext(ctx, userID)
					return handler(ctx, req)
				}
			}
		}
		return handler(ctx, req)
	}
}

// 日志拦截器
func loggingUnaryInterceptor() grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		start := time.Now()

		defer func() {
			if r := recover(); r != nil {
				log.Printf("Panic recovered in gRPC handler: %v", r)
			}
		}()

		resp, err := handler(ctx, req)

		duration := time.Since(start)
		statusCode := codes.OK
		if err != nil {
			statusCode = status.Code(err)
		}

		log.Printf("gRPC %s | %s | %v | %v", info.FullMethod, statusCode, duration, err)

		return resp, err
	}
}

func loggingStreamInterceptor() grpc.StreamServerInterceptor {
	return func(srv interface{}, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
		start := time.Now()

		defer func() {
			if r := recover(); r != nil {
				log.Printf("Panic recovered in gRPC stream handler: %v", r)
			}
		}()

		err := handler(srv, ss)

		duration := time.Since(start)
		statusCode := codes.OK
		if err != nil {
			statusCode = status.Code(err)
		}

		log.Printf("gRPC Stream %s | %s | %v | %v", info.FullMethod, statusCode, duration, err)

		return err
	}
}
