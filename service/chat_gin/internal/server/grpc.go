package server

import (
	"net"
	"time"

	grpchandler "github.com/lesser/chat/internal/handler/grpc"
	"github.com/lesser/chat/internal/service"
	"google.golang.org/grpc"
	"google.golang.org/grpc/keepalive"
	"google.golang.org/grpc/reflection"
)

// GRPCServer represents the gRPC server
type GRPCServer struct {
	server      *grpc.Server
	chatHandler *grpchandler.ChatHandler
}

// NewGRPCServer creates a new gRPC server
func NewGRPCServer(chatService *service.ChatService, authClient *service.AuthClient) *GRPCServer {
	// Keepalive 配置
	keepalivePolicy := keepalive.EnforcementPolicy{
		MinTime:             10 * time.Second, // 客户端 ping 最小间隔
		PermitWithoutStream: true,             // 允许无活动流时 ping
	}

	keepaliveParams := keepalive.ServerParameters{
		MaxConnectionIdle:     5 * time.Minute,  // 空闲连接最大时间
		MaxConnectionAge:      30 * time.Minute, // 连接最大存活时间
		MaxConnectionAgeGrace: 10 * time.Second, // 优雅关闭等待时间
		Time:                  30 * time.Second, // 服务端 ping 间隔
		Timeout:               10 * time.Second, // ping 超时时间
	}

	// Create gRPC server with options
	// 使用 ChainUnaryInterceptor 链式调用多个拦截器
	server := grpc.NewServer(
		grpc.KeepaliveEnforcementPolicy(keepalivePolicy),
		grpc.KeepaliveParams(keepaliveParams),
		grpc.MaxRecvMsgSize(4*1024*1024),  // 4MB 最大接收消息
		grpc.MaxSendMsgSize(4*1024*1024),  // 4MB 最大发送消息
		grpc.MaxConcurrentStreams(100),    // 最大并发流
		grpc.ChainUnaryInterceptor(
			authUnaryInterceptor(authClient), // 认证拦截器
			unaryServerInterceptor(),         // 日志拦截器
		),
		grpc.StreamInterceptor(streamServerInterceptor()),
	)

	// Create and register chat handler
	chatHandler := grpchandler.NewChatHandler(chatService)
	chatHandler.Register(server)

	// Enable reflection for debugging
	reflection.Register(server)

	return &GRPCServer{
		server:      server,
		chatHandler: chatHandler,
	}
}

// Serve starts the gRPC server
func (s *GRPCServer) Serve(listener net.Listener) error {
	return s.server.Serve(listener)
}

// GracefulStop gracefully stops the server
func (s *GRPCServer) GracefulStop() {
	s.server.GracefulStop()
}

// Stop immediately stops the server
func (s *GRPCServer) Stop() {
	s.server.Stop()
}

// GetServer returns the underlying gRPC server
func (s *GRPCServer) GetServer() *grpc.Server {
	return s.server
}
