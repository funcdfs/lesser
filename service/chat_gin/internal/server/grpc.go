package server

import (
	"net"

	grpchandler "github.com/lesser/chat/internal/handler/grpc"
	"github.com/lesser/chat/internal/service"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

// GRPCServer represents the gRPC server
type GRPCServer struct {
	server      *grpc.Server
	chatHandler *grpchandler.ChatHandler
}

// NewGRPCServer creates a new gRPC server
func NewGRPCServer(chatService *service.ChatService) *GRPCServer {
	// Create gRPC server with options
	server := grpc.NewServer(
		grpc.UnaryInterceptor(unaryServerInterceptor()),
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
