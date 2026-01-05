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
	"time"

	"google.golang.org/grpc"

	authpb "github.com/funcdfs/lesser/gateway/gen_protos/auth"
	pb "github.com/funcdfs/lesser/gateway/gen_protos/gateway"
	"github.com/funcdfs/lesser/gateway/internal/auth"
	"github.com/funcdfs/lesser/gateway/internal/interceptor"
	"github.com/funcdfs/lesser/gateway/internal/ratelimit"
	"github.com/funcdfs/lesser/gateway/internal/router"
	"github.com/funcdfs/lesser/gateway/internal/streaming"
	"github.com/funcdfs/lesser/pkg/log"
)

// ============================================================================
// 配置
// ============================================================================

// Config Gateway 配置
type Config struct {
	// 服务地址
	AuthServiceAddr         string
	UserServiceAddr         string
	ContentServiceAddr      string
	InteractionServiceAddr  string
	CommentServiceAddr      string
	TimelineServiceAddr     string
	ChatServiceAddr         string
	ChannelServiceAddr      string
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
	log *log.Logger
}

// NewGatewayServer 创建 Gateway 服务器
func NewGatewayServer(cfg Config, logger *log.Logger) (*GatewayServer, error) {
	if logger == nil {
		logger = log.Global()
	}
	logger = logger.With(log.String("component", "gateway"))

	// 创建限流器
	rateLimiter := ratelimit.NewLimiter(ratelimit.Config{
		Rate:  cfg.RateLimitRate,
		Burst: cfg.RateLimitBurst,
	})

	// 创建路由器
	r, err := router.NewRouter(router.ServiceConfig{
		AuthAddr:         cfg.AuthServiceAddr,
		UserAddr:         cfg.UserServiceAddr,
		ContentAddr:      cfg.ContentServiceAddr,
		InteractionAddr:  cfg.InteractionServiceAddr,
		CommentAddr:      cfg.CommentServiceAddr,
		TimelineAddr:     cfg.TimelineServiceAddr,
		ChatAddr:         cfg.ChatServiceAddr,
		ChannelAddr:      cfg.ChannelServiceAddr,
		SearchAddr:       cfg.SearchServiceAddr,
		NotificationAddr: cfg.NotificationServiceAddr,
	}, logger)
	if err != nil {
		return nil, err
	}

	// 创建 JWT 验签器
	jwtValidator := auth.NewJWTValidator(auth.DefaultValidatorConfig(), logger)

	// 创建流代理
	streamingProxy := streaming.NewProxy(jwtValidator, streaming.DefaultProxyConfig(), logger)

	return &GatewayServer{
		jwtValidator:   jwtValidator,
		rateLimiter:    rateLimiter,
		router:         r,
		streamingProxy: streamingProxy,
		log:            logger,
	}, nil
}

// Start 启动 Gateway 服务
// 包含重试机制，确保 Auth 服务可用后能正确加载公钥
func (s *GatewayServer) Start(ctx context.Context) error {
	authConn := s.router.GetAuthConn()
	if authConn == nil {
		s.log.Warn("Auth 服务未配置，JWT 验签已禁用")
		return nil
	}

	// 创建 Auth 服务客户端适配器
	authClient := authpb.NewAuthServiceClient(authConn)
	adapter := &authClientAdapter{client: authClient}

	// 启动 JWT 验签器（带重试）
	if err := s.startJWTValidatorWithRetry(ctx, adapter); err != nil {
		s.log.Warn("JWT 验签器启动失败", log.Any("error", err))
		// 启动后台重试协程
		go s.backgroundJWTValidatorRetry(adapter)
		return nil
	}

	s.log.Info("Gateway 服务已启动")
	return nil
}

// startJWTValidatorWithRetry 带重试的 JWT 验签器启动
// 最多重试 5 次，每次间隔递增（1s, 2s, 4s, 8s, 16s）
func (s *GatewayServer) startJWTValidatorWithRetry(ctx context.Context, adapter *authClientAdapter) error {
	maxRetries := 5
	baseDelay := time.Second

	var lastErr error
	for i := 0; i < maxRetries; i++ {
		if err := s.jwtValidator.Start(ctx, adapter); err != nil {
			lastErr = err
			delay := baseDelay * time.Duration(1<<i) // 指数退避
			s.log.Warn("JWT 验签器启动失败，准备重试",
				log.Int("attempt", i+1),
				log.Int("max_retries", maxRetries),
				log.Duration("delay", delay),
				log.Any("error", err))

			select {
			case <-ctx.Done():
				return ctx.Err()
			case <-time.After(delay):
				continue
			}
		}
		return nil // 成功
	}
	return lastErr
}

// backgroundJWTValidatorRetry 后台重试 JWT 验签器启动
// 当初始启动失败时，在后台持续重试直到成功
func (s *GatewayServer) backgroundJWTValidatorRetry(adapter *authClientAdapter) {
	retryInterval := 30 * time.Second
	maxRetries := 60 // 最多重试 30 分钟

	for i := 0; i < maxRetries; i++ {
		time.Sleep(retryInterval)

		// 检查是否已经就绪
		if s.jwtValidator.IsReady() {
			s.log.Info("JWT 验签器已就绪")
			return
		}

		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		if err := s.jwtValidator.Start(ctx, adapter); err != nil {
			s.log.Debug("后台重试 JWT 验签器失败",
				log.Int("attempt", i+1),
				log.Any("error", err))
		} else {
			s.log.Info("后台重试 JWT 验签器成功")
			cancel()
			return
		}
		cancel()
	}

	s.log.Error("JWT 验签器后台重试超时，请检查 Auth 服务状态")
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
