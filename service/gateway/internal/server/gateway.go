// Package server 提供 Gateway gRPC 服务实现
//
// Gateway 职责：
//   - JWT 验签（本地验签，不调用 AuthService）
//   - 限流（令牌桶算法）
//   - 路由转发（透明代理到后端服务）
//   - 不处理业务逻辑
package server

import (
	"context"
	"log/slog"

	"google.golang.org/grpc"

	"github.com/funcdfs/lesser/gateway/internal/auth"
	"github.com/funcdfs/lesser/gateway/internal/interceptor"
	"github.com/funcdfs/lesser/gateway/internal/ratelimit"
	"github.com/funcdfs/lesser/gateway/internal/router"
	"github.com/funcdfs/lesser/gateway/internal/streaming"
	authpb "github.com/funcdfs/lesser/gateway/proto/auth"
	pb "github.com/funcdfs/lesser/gateway/proto/gateway"
)

// ============================================================================
// 配置
// ============================================================================

// Config Gateway 配置
type Config struct {
	// 服务地址
	AuthServiceAddr         string
	UserServiceAddr         string
	PostServiceAddr         string
	FeedServiceAddr         string
	ChatServiceAddr         string
	SearchServiceAddr       string
	NotificationServiceAddr string

	// 限流配置
	RateLimitRate  float64
	RateLimitBurst int
}

// ============================================================================
// Gateway 服务器
// ============================================================================

// GatewayServer Gateway 服务实现
type GatewayServer struct {
	pb.UnimplementedGatewayServiceServer

	// 核心组件
	jwtValidator   *auth.JWTValidator
	rateLimiter    *ratelimit.Limiter
	router         *router.Router
	streamingProxy *streaming.Proxy

	// 日志
	log *slog.Logger
}

// NewGatewayServer 创建 Gateway 服务器
func NewGatewayServer(cfg Config, log *slog.Logger) (*GatewayServer, error) {
	if log == nil {
		log = slog.Default()
	}
	log = log.With(slog.String("component", "gateway"))

	// 创建限流器
	rateLimiter := ratelimit.NewLimiter(ratelimit.Config{
		Rate:  cfg.RateLimitRate,
		Burst: cfg.RateLimitBurst,
	})

	// 创建路由器
	r, err := router.NewRouter(router.ServiceConfig{
		AuthAddr:         cfg.AuthServiceAddr,
		UserAddr:         cfg.UserServiceAddr,
		PostAddr:         cfg.PostServiceAddr,
		FeedAddr:         cfg.FeedServiceAddr,
		ChatAddr:         cfg.ChatServiceAddr,
		SearchAddr:       cfg.SearchServiceAddr,
		NotificationAddr: cfg.NotificationServiceAddr,
	}, log)
	if err != nil {
		return nil, err
	}

	// 创建 JWT 验签器
	jwtValidator := auth.NewJWTValidator(auth.DefaultValidatorConfig(), log)

	// 创建流代理
	streamingProxy := streaming.NewProxy(jwtValidator, streaming.DefaultProxyConfig(), log)

	return &GatewayServer{
		jwtValidator:   jwtValidator,
		rateLimiter:    rateLimiter,
		router:         r,
		streamingProxy: streamingProxy,
		log:            log,
	}, nil
}

// Start 启动 Gateway 服务
func (s *GatewayServer) Start(ctx context.Context) error {
	authConn := s.router.GetAuthConn()
	if authConn == nil {
		s.log.Warn("Auth 服务未配置，JWT 验签已禁用")
		return nil
	}

	// 创建 Auth 服务客户端适配器
	authClient := authpb.NewAuthServiceClient(authConn)
	adapter := &authClientAdapter{client: authClient}

	// 启动 JWT 验签器
	if err := s.jwtValidator.Start(ctx, adapter); err != nil {
		s.log.Warn("JWT 验签器启动失败", slog.Any("error", err))
		return nil
	}

	s.log.Info("Gateway 服务已启动")
	return nil
}

// Stop 停止 Gateway 服务
func (s *GatewayServer) Stop() {
	if s.jwtValidator != nil {
		s.jwtValidator.Stop()
	}
	if s.rateLimiter != nil {
		s.rateLimiter.Stop()
	}
	if s.router != nil {
		s.router.Close()
	}
	s.log.Info("Gateway 服务已停止")
}

// ============================================================================
// gRPC 服务方法
// ============================================================================

// Health 健康检查
func (s *GatewayServer) Health(ctx context.Context, req *pb.HealthRequest) (*pb.HealthResponse, error) {
	services := s.router.HealthCheck(ctx)
	servicesMap := make(map[string]*pb.ServiceStatus)
	for k, v := range services {
		servicesMap[k] = &pb.ServiceStatus{Healthy: v}
	}
	return &pb.HealthResponse{
		Healthy:  true,
		Services: servicesMap,
	}, nil
}

// ============================================================================
// 拦截器
// ============================================================================

// AuthInterceptor 返回认证拦截器
func (s *GatewayServer) AuthInterceptor() grpc.UnaryServerInterceptor {
	return interceptor.AuthInterceptor(s.jwtValidator, s.rateLimiter, s.log)
}

// StreamAuthInterceptor 返回流式认证拦截器
func (s *GatewayServer) StreamAuthInterceptor() grpc.StreamServerInterceptor {
	return interceptor.StreamAuthInterceptor(s.jwtValidator, s.rateLimiter, s.log)
}

// ============================================================================
// Getter 方法
// ============================================================================

// GetRouter 获取路由器
func (s *GatewayServer) GetRouter() *router.Router {
	return s.router
}

// GetJWTValidator 获取 JWT 验签器
func (s *GatewayServer) GetJWTValidator() *auth.JWTValidator {
	return s.jwtValidator
}

// GetRateLimiter 获取限流器
func (s *GatewayServer) GetRateLimiter() *ratelimit.Limiter {
	return s.rateLimiter
}

// GetStreamingProxy 获取流代理
func (s *GatewayServer) GetStreamingProxy() *streaming.Proxy {
	return s.streamingProxy
}

// ============================================================================
// 注册函数
// ============================================================================

// RegisterGatewayServer 注册 Gateway gRPC 服务
func RegisterGatewayServer(s *grpc.Server, srv *GatewayServer) {
	pb.RegisterGatewayServiceServer(s, srv)
}

// ============================================================================
// Auth 客户端适配器
// ============================================================================

// authClientAdapter 适配 authpb.AuthServiceClient 到 auth.AuthServiceClient 接口
type authClientAdapter struct {
	client authpb.AuthServiceClient
}

func (a *authClientAdapter) GetPublicKey(ctx context.Context, in *auth.GetPublicKeyRequest, opts ...grpc.CallOption) (*auth.GetPublicKeyResponse, error) {
	resp, err := a.client.GetPublicKey(ctx, &authpb.GetPublicKeyRequest{}, opts...)
	if err != nil {
		return nil, err
	}
	return &auth.GetPublicKeyResponse{
		PublicKey: resp.GetPublicKey(),
		KeyID:     resp.GetKeyId(),
		Algorithm: resp.GetAlgorithm(),
		ExpiresAt: resp.GetExpiresAt(),
	}, nil
}
