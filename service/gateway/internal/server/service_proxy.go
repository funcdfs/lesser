// Package server 提供服务代理实现
//
// 将 gRPC 请求透明转发到后端服务
// 每个服务代理负责将请求转发到对应的后端服务
package server

import (
	"context"

	"go.uber.org/zap"
	"google.golang.org/grpc"

	authpb "github.com/funcdfs/lesser/gateway/proto/auth"
	"github.com/funcdfs/lesser/gateway/proto/common"
	searchpb "github.com/funcdfs/lesser/gateway/proto/search"
)

// ============================================================================
// Auth 代理服务
// ============================================================================

// AuthProxyServer 代理 Auth 服务请求
type AuthProxyServer struct {
	authpb.UnimplementedAuthServiceServer
	client authpb.AuthServiceClient
	log    *zap.Logger
}

// NewAuthProxyServer 创建 Auth 代理服务器
func NewAuthProxyServer(conn *grpc.ClientConn, log *zap.Logger) *AuthProxyServer {
	if log == nil {
		log = zap.NewNop()
	}
	return &AuthProxyServer{
		client: authpb.NewAuthServiceClient(conn),
		log:    log.Named("proxy.auth"),
	}
}

func (s *AuthProxyServer) Register(ctx context.Context, req *authpb.RegisterRequest) (*authpb.AuthResponse, error) {
	s.log.Debug("注册请求", zap.String("username", req.Username), zap.String("email", req.Email))
	return s.client.Register(ctx, req)
}

func (s *AuthProxyServer) Login(ctx context.Context, req *authpb.LoginRequest) (*authpb.AuthResponse, error) {
	s.log.Debug("登录请求", zap.String("email", req.Email))
	return s.client.Login(ctx, req)
}

func (s *AuthProxyServer) Logout(ctx context.Context, req *authpb.LogoutRequest) (*common.Empty, error) {
	s.log.Debug("登出请求")
	return s.client.Logout(ctx, req)
}

func (s *AuthProxyServer) RefreshToken(ctx context.Context, req *authpb.RefreshRequest) (*authpb.AuthResponse, error) {
	s.log.Debug("刷新令牌请求")
	return s.client.RefreshToken(ctx, req)
}

func (s *AuthProxyServer) GetPublicKey(ctx context.Context, req *authpb.GetPublicKeyRequest) (*authpb.GetPublicKeyResponse, error) {
	s.log.Debug("获取公钥请求")
	return s.client.GetPublicKey(ctx, req)
}

func (s *AuthProxyServer) BanUser(ctx context.Context, req *authpb.BanUserRequest) (*authpb.BanUserResponse, error) {
	s.log.Debug("封禁用户请求", zap.String("user_id", req.UserId))
	return s.client.BanUser(ctx, req)
}

func (s *AuthProxyServer) CheckBanned(ctx context.Context, req *authpb.CheckBannedRequest) (*authpb.CheckBannedResponse, error) {
	s.log.Debug("检查封禁状态请求", zap.String("user_id", req.UserId))
	return s.client.CheckBanned(ctx, req)
}

func (s *AuthProxyServer) GetUser(ctx context.Context, req *authpb.GetUserRequest) (*authpb.User, error) {
	s.log.Debug("获取用户请求", zap.String("user_id", req.UserId))
	return s.client.GetUser(ctx, req)
}

// RegisterAuthProxyServer 注册 Auth 代理服务
func RegisterAuthProxyServer(s *grpc.Server, conn *grpc.ClientConn, log *zap.Logger) {
	proxy := NewAuthProxyServer(conn, log)
	authpb.RegisterAuthServiceServer(s, proxy)
	log.Named("proxy").Info("Auth 代理服务已注册")
}

// ============================================================================
// Search 代理服务
// ============================================================================

// SearchProxyServer 代理 Search 服务请求
type SearchProxyServer struct {
	searchpb.UnimplementedSearchServiceServer
	client searchpb.SearchServiceClient
	log    *zap.Logger
}

// NewSearchProxyServer 创建 Search 代理服务器
func NewSearchProxyServer(conn *grpc.ClientConn, log *zap.Logger) *SearchProxyServer {
	if log == nil {
		log = zap.NewNop()
	}
	return &SearchProxyServer{
		client: searchpb.NewSearchServiceClient(conn),
		log:    log.Named("proxy.search"),
	}
}

func (s *SearchProxyServer) SearchPosts(ctx context.Context, req *searchpb.SearchPostsRequest) (*searchpb.SearchPostsResponse, error) {
	s.log.Debug("搜索帖子请求", zap.String("query", req.Query))
	return s.client.SearchPosts(ctx, req)
}

func (s *SearchProxyServer) SearchUsers(ctx context.Context, req *searchpb.SearchUsersRequest) (*searchpb.SearchUsersResponse, error) {
	s.log.Debug("搜索用户请求", zap.String("query", req.Query))
	return s.client.SearchUsers(ctx, req)
}

// RegisterSearchProxyServer 注册 Search 代理服务
func RegisterSearchProxyServer(s *grpc.Server, conn *grpc.ClientConn, log *zap.Logger) {
	proxy := NewSearchProxyServer(conn, log)
	searchpb.RegisterSearchServiceServer(s, proxy)
	log.Named("proxy").Info("Search 代理服务已注册")
}

// ============================================================================
// User 代理服务（占位）
// ============================================================================

// TODO: 实现 User 代理服务
// UserProxyServer 代理 User 服务请求
// type UserProxyServer struct {
// 	userpb.UnimplementedUserServiceServer
// 	client userpb.UserServiceClient
// 	log    *zap.Logger
// }

// ============================================================================
// Post 代理服务（占位）
// ============================================================================

// TODO: 实现 Post 代理服务
// PostProxyServer 代理 Post 服务请求
// type PostProxyServer struct {
// 	postpb.UnimplementedPostServiceServer
// 	client postpb.PostServiceClient
// 	log    *zap.Logger
// }

// ============================================================================
// Feed 代理服务（占位）
// ============================================================================

// TODO: 实现 Feed 代理服务
// FeedProxyServer 代理 Feed 服务请求
// type FeedProxyServer struct {
// 	feedpb.UnimplementedFeedServiceServer
// 	client feedpb.FeedServiceClient
// 	log    *zap.Logger
// }

// ============================================================================
// Notification 代理服务（占位）
// ============================================================================

// TODO: 实现 Notification 代理服务
// NotificationProxyServer 代理 Notification 服务请求
// type NotificationProxyServer struct {
// 	notificationpb.UnimplementedNotificationServiceServer
// 	client notificationpb.NotificationServiceClient
// 	log    *zap.Logger
// }

// ============================================================================
// Chat 代理服务（占位）
// ============================================================================

// TODO: Chat 服务使用双向流，通过 streaming.Proxy 代理
// 参见 internal/streaming/stream.go
