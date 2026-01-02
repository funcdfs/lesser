package server

import (
	"context"
	"log"

	"github.com/lesser/gateway/internal/auth"
	"github.com/lesser/gateway/internal/ratelimit"
	"github.com/lesser/gateway/internal/router"
	authpb "github.com/lesser/gateway/proto/auth"
	pb "github.com/lesser/gateway/proto/gateway"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

// GatewayServer 实现 GatewayService
// 设计要点：
// 1. Gateway 只做 JWT 验签、限流、路由，不做业务逻辑
// 2. JWT 验签在本地完成（内存持有公钥）
// 3. 所有业务请求同步转发到对应 Service
type GatewayServer struct {
	pb.UnimplementedGatewayServiceServer
	jwtValidator *auth.JWTValidator
	rateLimiter  *ratelimit.Limiter
	router       *router.Router
}

// GatewayConfig Gateway 配置
type GatewayConfig struct {
	AuthServiceAddr         string
	UserServiceAddr         string
	PostServiceAddr         string
	FeedServiceAddr         string
	ChatServiceAddr         string
	SearchServiceAddr       string
	NotificationServiceAddr string
	RateLimitRate           float64
	RateLimitBurst          int
}

// NewGatewayServer 创建新的 Gateway 服务器
func NewGatewayServer(config GatewayConfig) (*GatewayServer, error) {
	rateLimiter := ratelimit.NewLimiter(ratelimit.Config{
		Rate:  config.RateLimitRate,
		Burst: config.RateLimitBurst,
	})

	r, err := router.NewRouter(router.ServiceConfig{
		AuthAddr:         config.AuthServiceAddr,
		UserAddr:         config.UserServiceAddr,
		PostAddr:         config.PostServiceAddr,
		FeedAddr:         config.FeedServiceAddr,
		ChatAddr:         config.ChatServiceAddr,
		SearchAddr:       config.SearchServiceAddr,
		NotificationAddr: config.NotificationServiceAddr,
	})
	if err != nil {
		return nil, err
	}

	jwtValidator := auth.NewJWTValidator(auth.DefaultJWTValidatorConfig())

	return &GatewayServer{
		jwtValidator: jwtValidator,
		rateLimiter:  rateLimiter,
		router:       r,
	}, nil
}


// Start 启动 Gateway
func (s *GatewayServer) Start(ctx context.Context) error {
	authConn := s.router.GetAuthConn()
	if authConn == nil {
		log.Println("[Gateway] Warning: Auth Service not configured, JWT validation disabled")
		return nil
	}

	// 创建 Auth 服务客户端适配器
	authClient := authpb.NewAuthServiceClient(authConn)
	adapter := &authClientAdapter{client: authClient}

	// 启动 JWT 验证器
	if err := s.jwtValidator.Start(ctx, adapter); err != nil {
		log.Printf("[Gateway] Warning: Failed to start JWT validator: %v", err)
		return nil
	}

	log.Println("[Gateway] JWT validator started successfully")
	return nil
}

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

// Stop 停止 Gateway
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
	log.Println("[Gateway] Server stopped")
}

// RegisterGatewayServer 注册 gRPC 服务
func RegisterGatewayServer(s *grpc.Server, srv *GatewayServer) {
	pb.RegisterGatewayServiceServer(s, srv)
}

// Health 健康检查
func (s *GatewayServer) Health(ctx context.Context, req *pb.HealthRequest) (*pb.HealthResponse, error) {
	services := s.router.HealthCheck(ctx)
	servicesMap := make(map[string]*pb.ServiceStatus)
	for k, v := range services {
		servicesMap[k] = &pb.ServiceStatus{
			Healthy: v,
		}
	}
	return &pb.HealthResponse{
		Healthy:  true,
		Services: servicesMap,
	}, nil
}

// GetRouter 获取路由器（供外部使用）
func (s *GatewayServer) GetRouter() *router.Router {
	return s.router
}

// GetJWTValidator 获取 JWT 验签器（供外部使用）
func (s *GatewayServer) GetJWTValidator() *auth.JWTValidator {
	return s.jwtValidator
}

// GetRateLimiter 获取限流器（供外部使用）
func (s *GatewayServer) GetRateLimiter() *ratelimit.Limiter {
	return s.rateLimiter
}

// AuthInterceptor 认证拦截器（用于 gRPC 中间件）
func (s *GatewayServer) AuthInterceptor() grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		// 跳过不需要认证的方法
		if isPublicMethod(info.FullMethod) {
			return handler(ctx, req)
		}

		// 限流检查
		if !s.rateLimiter.Allow() {
			return nil, status.Error(codes.ResourceExhausted, "rate limit exceeded")
		}

		// JWT 验签
		token, err := extractToken(ctx)
		if err != nil {
			return nil, err
		}

		claims, err := s.jwtValidator.ValidateToken(token)
		if err != nil {
			return nil, status.Error(codes.Unauthenticated, "invalid token")
		}

		// 将用户信息注入 context
		ctx = context.WithValue(ctx, "user_id", claims.UserID)
		md, _ := metadata.FromIncomingContext(ctx)
		md = metadata.Join(md, metadata.Pairs("user_id", claims.UserID))
		ctx = metadata.NewOutgoingContext(ctx, md)

		return handler(ctx, req)
	}
}

// StreamAuthInterceptor 流式认证拦截器
func (s *GatewayServer) StreamAuthInterceptor() grpc.StreamServerInterceptor {
	return func(srv interface{}, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
		if isPublicMethod(info.FullMethod) {
			return handler(srv, ss)
		}

		if !s.rateLimiter.Allow() {
			return status.Error(codes.ResourceExhausted, "rate limit exceeded")
		}

		token, err := extractToken(ss.Context())
		if err != nil {
			return err
		}

		claims, err := s.jwtValidator.ValidateToken(token)
		if err != nil {
			return status.Error(codes.Unauthenticated, "invalid token")
		}

		wrapped := &wrappedServerStream{
			ServerStream: ss,
			ctx:          context.WithValue(ss.Context(), "user_id", claims.UserID),
		}

		return handler(srv, wrapped)
	}
}

// wrappedServerStream 包装的 ServerStream
type wrappedServerStream struct {
	grpc.ServerStream
	ctx context.Context
}

func (w *wrappedServerStream) Context() context.Context {
	return w.ctx
}

// isPublicMethod 判断是否为公开方法（不需要认证）
func isPublicMethod(method string) bool {
	publicMethods := map[string]bool{
		"/gateway.GatewayService/Health": true,
		"/auth.AuthService/Login":        true,
		"/auth.AuthService/Register":     true,
		"/auth.AuthService/GetPublicKey": true,
	}
	return publicMethods[method]
}

// extractToken 从 context 提取 Token
func extractToken(ctx context.Context) (string, error) {
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return "", status.Error(codes.Unauthenticated, "missing metadata")
	}

	authHeader := md.Get("authorization")
	if len(authHeader) > 0 {
		token := authHeader[0]
		if len(token) > 7 && token[:7] == "Bearer " {
			return token[7:], nil
		}
		return token, nil
	}

	accessToken := md.Get("access_token")
	if len(accessToken) > 0 {
		return accessToken[0], nil
	}

	return "", status.Error(codes.Unauthenticated, "missing authorization token")
}
