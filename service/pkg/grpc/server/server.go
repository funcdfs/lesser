// Package server 提供 gRPC 服务器封装
// 支持优雅启停、健康检查、反射服务
package server

import (
	"context"
	"fmt"
	"log/slog"
	"net"
	"time"

	"github.com/funcdfs/lesser/pkg/grpc/interceptor"
	"github.com/funcdfs/lesser/pkg/log"
	"google.golang.org/grpc"
	"google.golang.org/grpc/health"
	"google.golang.org/grpc/health/grpc_health_v1"
	"google.golang.org/grpc/reflection"
)

// Server gRPC 服务器
type Server struct {
	server   *grpc.Server
	listener net.Listener
	log      *log.Logger
	config   Config
	health   *health.Server
}

// Config 服务器配置
type Config struct {
	// Port 监听端口
	Port int
	// EnableReflection 是否启用反射服务（用于 grpcurl 调试）
	EnableReflection bool
	// EnableHealthCheck 是否启用健康检查
	EnableHealthCheck bool
	// MaxRecvMsgSize 最大接收消息大小（字节）
	MaxRecvMsgSize int
	// MaxSendMsgSize 最大发送消息大小（字节）
	MaxSendMsgSize int
	// ConnectionTimeout 连接超时
	ConnectionTimeout time.Duration
}

// DefaultConfig 默认配置
func DefaultConfig() Config {
	return Config{
		Port:              50051,
		EnableReflection:  true,
		EnableHealthCheck: true,
		MaxRecvMsgSize:    4 * 1024 * 1024, // 4MB
		MaxSendMsgSize:    4 * 1024 * 1024, // 4MB
		ConnectionTimeout: 30 * time.Second,
	}
}

// Option 服务器选项
type Option func(*Server)

// WithConfig 设置配置
func WithConfig(cfg Config) Option {
	return func(s *Server) {
		s.config = cfg
	}
}

// New 创建 gRPC 服务器
func New(logger *log.Logger, opts ...Option) *Server {
	s := &Server{
		log:    logger,
		config: DefaultConfig(),
	}

	for _, opt := range opts {
		opt(s)
	}

	return s
}

// Build 构建 gRPC 服务器
func (s *Server) Build(unaryInterceptors []grpc.UnaryServerInterceptor, streamInterceptors []grpc.StreamServerInterceptor) *grpc.Server {
	// 默认拦截器
	defaultUnary := []grpc.UnaryServerInterceptor{
		interceptor.RecoveryInterceptor(s.log),
		interceptor.TraceInterceptor(),
		interceptor.LoggingInterceptor(s.log),
	}

	defaultStream := []grpc.StreamServerInterceptor{
		interceptor.StreamRecoveryInterceptor(s.log),
		interceptor.StreamTraceInterceptor(),
		interceptor.StreamLoggingInterceptor(s.log),
	}

	// 合并拦截器
	allUnary := append(defaultUnary, unaryInterceptors...)
	allStream := append(defaultStream, streamInterceptors...)

	// 服务器选项（暂时移除 keepalive 配置以排查问题）
	serverOpts := []grpc.ServerOption{
		grpc.ChainUnaryInterceptor(allUnary...),
		grpc.ChainStreamInterceptor(allStream...),
		grpc.MaxRecvMsgSize(s.config.MaxRecvMsgSize),
		grpc.MaxSendMsgSize(s.config.MaxSendMsgSize),
		grpc.ConnectionTimeout(s.config.ConnectionTimeout),
	}

	s.server = grpc.NewServer(serverOpts...)

	// 启用反射服务
	if s.config.EnableReflection {
		reflection.Register(s.server)
	}

	// 启用健康检查
	if s.config.EnableHealthCheck {
		s.health = health.NewServer()
		grpc_health_v1.RegisterHealthServer(s.server, s.health)
	}

	return s.server
}

// Server 返回底层 gRPC 服务器
func (s *Server) Server() *grpc.Server {
	return s.server
}

// SetServingStatus 设置服务健康状态
func (s *Server) SetServingStatus(service string, status grpc_health_v1.HealthCheckResponse_ServingStatus) {
	if s.health != nil {
		s.health.SetServingStatus(service, status)
	}
}

// Start 启动服务器
func (s *Server) Start() error {
	addr := fmt.Sprintf(":%d", s.config.Port)
	listener, err := net.Listen("tcp", addr)
	if err != nil {
		return fmt.Errorf("监听端口失败: %w", err)
	}

	s.listener = listener
	s.log.Info("gRPC server starting", slog.String("addr", addr))

	// 设置所有服务为健康状态
	if s.health != nil {
		s.health.SetServingStatus("", grpc_health_v1.HealthCheckResponse_SERVING)
	}

	return s.server.Serve(listener)
}

// Stop 优雅停止服务器
func (s *Server) Stop() {
	s.log.Info("gRPC server stopping")

	// 设置服务为不健康状态
	if s.health != nil {
		s.health.SetServingStatus("", grpc_health_v1.HealthCheckResponse_NOT_SERVING)
	}

	// 优雅停止
	s.server.GracefulStop()
	s.log.Info("gRPC server stopped")
}

// StopWithTimeout 带超时的优雅停止
func (s *Server) StopWithTimeout(timeout time.Duration) {
	s.log.Info("gRPC server stopping with timeout", slog.Duration("timeout", timeout))

	// 设置服务为不健康状态
	if s.health != nil {
		s.health.SetServingStatus("", grpc_health_v1.HealthCheckResponse_NOT_SERVING)
	}

	// 创建超时 context
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()

	// 在协程中执行优雅停止
	done := make(chan struct{})
	go func() {
		s.server.GracefulStop()
		close(done)
	}()

	// 等待停止完成或超时
	select {
	case <-done:
		s.log.Info("gRPC server stopped gracefully")
	case <-ctx.Done():
		s.log.Warn("gRPC server stop timeout, forcing stop")
		s.server.Stop()
	}
}

// RegisterService 注册服务的便捷方法
func (s *Server) RegisterService(desc *grpc.ServiceDesc, impl interface{}) {
	s.server.RegisterService(desc, impl)
}
