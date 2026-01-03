// Package server 提供服务代理实现
//
// 将 gRPC 请求透明转发到后端服务
// 每个服务代理负责将请求转发到对应的后端服务
package server

import (
	"context"
	"log/slog"

	"google.golang.org/grpc"

	authpb "github.com/funcdfs/lesser/gateway/proto/auth"
	"github.com/funcdfs/lesser/gateway/proto/common"
	searchpb "github.com/funcdfs/lesser/gateway/proto/search"
	userpb "github.com/funcdfs/lesser/gateway/proto/user"
)

// ============================================================================
// Auth 代理服务
// ============================================================================

// AuthProxyServer 代理 Auth 服务请求
type AuthProxyServer struct {
	authpb.UnimplementedAuthServiceServer
	client authpb.AuthServiceClient
	log    *slog.Logger
}

// NewAuthProxyServer 创建 Auth 代理服务器
func NewAuthProxyServer(conn *grpc.ClientConn, log *slog.Logger) *AuthProxyServer {
	if log == nil {
		log = slog.Default()
	}
	return &AuthProxyServer{
		client: authpb.NewAuthServiceClient(conn),
		log:    log.With(slog.String("component", "proxy.auth")),
	}
}

func (s *AuthProxyServer) Register(ctx context.Context, req *authpb.RegisterRequest) (*authpb.AuthResponse, error) {
	s.log.Debug("注册请求", slog.String("username", req.Username), slog.String("email", req.Email))
	return s.client.Register(ctx, req)
}

func (s *AuthProxyServer) Login(ctx context.Context, req *authpb.LoginRequest) (*authpb.AuthResponse, error) {
	s.log.Debug("登录请求", slog.String("email", req.Email))
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
	s.log.Debug("封禁用户请求", slog.String("user_id", req.UserId))
	return s.client.BanUser(ctx, req)
}

func (s *AuthProxyServer) CheckBanned(ctx context.Context, req *authpb.CheckBannedRequest) (*authpb.CheckBannedResponse, error) {
	s.log.Debug("检查封禁状态请求", slog.String("user_id", req.UserId))
	return s.client.CheckBanned(ctx, req)
}

func (s *AuthProxyServer) GetUser(ctx context.Context, req *authpb.GetUserRequest) (*authpb.User, error) {
	s.log.Debug("获取用户请求", slog.String("user_id", req.UserId))
	return s.client.GetUser(ctx, req)
}

// RegisterAuthProxyServer 注册 Auth 代理服务
func RegisterAuthProxyServer(s *grpc.Server, conn *grpc.ClientConn, log *slog.Logger) {
	proxy := NewAuthProxyServer(conn, log)
	authpb.RegisterAuthServiceServer(s, proxy)
	log.With(slog.String("component", "proxy")).Info("Auth 代理服务已注册")
}

// ============================================================================
// Search 代理服务
// ============================================================================

// SearchProxyServer 代理 Search 服务请求
type SearchProxyServer struct {
	searchpb.UnimplementedSearchServiceServer
	client searchpb.SearchServiceClient
	log    *slog.Logger
}

// NewSearchProxyServer 创建 Search 代理服务器
func NewSearchProxyServer(conn *grpc.ClientConn, log *slog.Logger) *SearchProxyServer {
	if log == nil {
		log = slog.Default()
	}
	return &SearchProxyServer{
		client: searchpb.NewSearchServiceClient(conn),
		log:    log.With(slog.String("component", "proxy.search")),
	}
}

func (s *SearchProxyServer) SearchPosts(ctx context.Context, req *searchpb.SearchPostsRequest) (*searchpb.SearchPostsResponse, error) {
	s.log.Debug("搜索帖子请求", slog.String("query", req.Query))
	return s.client.SearchPosts(ctx, req)
}

func (s *SearchProxyServer) SearchUsers(ctx context.Context, req *searchpb.SearchUsersRequest) (*searchpb.SearchUsersResponse, error) {
	s.log.Debug("搜索用户请求", slog.String("query", req.Query))
	return s.client.SearchUsers(ctx, req)
}

// RegisterSearchProxyServer 注册 Search 代理服务
func RegisterSearchProxyServer(s *grpc.Server, conn *grpc.ClientConn, log *slog.Logger) {
	proxy := NewSearchProxyServer(conn, log)
	searchpb.RegisterSearchServiceServer(s, proxy)
	log.With(slog.String("component", "proxy")).Info("Search 代理服务已注册")
}

// ============================================================================
// User 代理服务
// ============================================================================

// UserProxyServer 代理 User 服务请求
type UserProxyServer struct {
	userpb.UnimplementedUserServiceServer
	client userpb.UserServiceClient
	log    *slog.Logger
}

// NewUserProxyServer 创建 User 代理服务器
func NewUserProxyServer(conn *grpc.ClientConn, log *slog.Logger) *UserProxyServer {
	if log == nil {
		log = slog.Default()
	}
	return &UserProxyServer{
		client: userpb.NewUserServiceClient(conn),
		log:    log.With(slog.String("component", "proxy.user")),
	}
}

// ---- 用户资料 ----

func (s *UserProxyServer) GetProfile(ctx context.Context, req *userpb.GetProfileRequest) (*userpb.Profile, error) {
	s.log.Debug("获取用户资料", slog.String("user_id", req.UserId))
	return s.client.GetProfile(ctx, req)
}

func (s *UserProxyServer) GetProfileByUsername(ctx context.Context, req *userpb.GetProfileByUsernameRequest) (*userpb.Profile, error) {
	s.log.Debug("通过用户名获取资料", slog.String("username", req.Username))
	return s.client.GetProfileByUsername(ctx, req)
}

func (s *UserProxyServer) UpdateProfile(ctx context.Context, req *userpb.UpdateProfileRequest) (*userpb.Profile, error) {
	s.log.Debug("更新用户资料", slog.String("user_id", req.UserId))
	return s.client.UpdateProfile(ctx, req)
}

func (s *UserProxyServer) BatchGetProfiles(ctx context.Context, req *userpb.BatchGetProfilesRequest) (*userpb.BatchGetProfilesResponse, error) {
	s.log.Debug("批量获取用户资料", slog.Int("count", len(req.UserIds)))
	return s.client.BatchGetProfiles(ctx, req)
}

// ---- 关注系统 ----

func (s *UserProxyServer) Follow(ctx context.Context, req *userpb.FollowRequest) (*common.Empty, error) {
	s.log.Debug("关注用户", slog.String("follower_id", req.FollowerId), slog.String("following_id", req.FollowingId))
	return s.client.Follow(ctx, req)
}

func (s *UserProxyServer) Unfollow(ctx context.Context, req *userpb.UnfollowRequest) (*common.Empty, error) {
	s.log.Debug("取消关注", slog.String("follower_id", req.FollowerId), slog.String("following_id", req.FollowingId))
	return s.client.Unfollow(ctx, req)
}

func (s *UserProxyServer) GetFollowers(ctx context.Context, req *userpb.GetFollowersRequest) (*userpb.FollowListResponse, error) {
	s.log.Debug("获取粉丝列表", slog.String("user_id", req.UserId))
	return s.client.GetFollowers(ctx, req)
}

func (s *UserProxyServer) GetFollowing(ctx context.Context, req *userpb.GetFollowingRequest) (*userpb.FollowListResponse, error) {
	s.log.Debug("获取关注列表", slog.String("user_id", req.UserId))
	return s.client.GetFollowing(ctx, req)
}

func (s *UserProxyServer) CheckFollowing(ctx context.Context, req *userpb.CheckFollowingRequest) (*userpb.CheckFollowingResponse, error) {
	s.log.Debug("检查关注状态", slog.String("follower_id", req.FollowerId), slog.String("following_id", req.FollowingId))
	return s.client.CheckFollowing(ctx, req)
}

func (s *UserProxyServer) GetRelationship(ctx context.Context, req *userpb.GetRelationshipRequest) (*userpb.GetRelationshipResponse, error) {
	s.log.Debug("获取用户关系", slog.String("user_id", req.UserId), slog.String("target_id", req.TargetId))
	return s.client.GetRelationship(ctx, req)
}

func (s *UserProxyServer) GetMutualFollowers(ctx context.Context, req *userpb.GetMutualFollowersRequest) (*userpb.FollowListResponse, error) {
	s.log.Debug("获取共同关注", slog.String("user_id", req.UserId), slog.String("target_id", req.TargetId))
	return s.client.GetMutualFollowers(ctx, req)
}

// ---- 屏蔽系统 ----

func (s *UserProxyServer) Block(ctx context.Context, req *userpb.BlockRequest) (*common.Empty, error) {
	s.log.Debug("屏蔽用户", slog.String("blocker_id", req.BlockerId), slog.String("blocked_id", req.BlockedId))
	return s.client.Block(ctx, req)
}

func (s *UserProxyServer) Unblock(ctx context.Context, req *userpb.UnblockRequest) (*common.Empty, error) {
	s.log.Debug("取消屏蔽", slog.String("blocker_id", req.BlockerId), slog.String("blocked_id", req.BlockedId))
	return s.client.Unblock(ctx, req)
}

func (s *UserProxyServer) GetBlockList(ctx context.Context, req *userpb.GetBlockListRequest) (*userpb.BlockListResponse, error) {
	s.log.Debug("获取屏蔽列表", slog.String("user_id", req.UserId))
	return s.client.GetBlockList(ctx, req)
}

func (s *UserProxyServer) CheckBlocked(ctx context.Context, req *userpb.CheckBlockedRequest) (*userpb.CheckBlockedResponse, error) {
	s.log.Debug("检查屏蔽状态", slog.String("user_id", req.UserId), slog.String("target_id", req.TargetId))
	return s.client.CheckBlocked(ctx, req)
}

// ---- 用户设置 ----

func (s *UserProxyServer) GetUserSettings(ctx context.Context, req *userpb.GetUserSettingsRequest) (*userpb.UserSettings, error) {
	s.log.Debug("获取用户设置", slog.String("user_id", req.UserId))
	return s.client.GetUserSettings(ctx, req)
}

func (s *UserProxyServer) UpdateUserSettings(ctx context.Context, req *userpb.UpdateUserSettingsRequest) (*userpb.UserSettings, error) {
	s.log.Debug("更新用户设置", slog.String("user_id", req.UserId))
	return s.client.UpdateUserSettings(ctx, req)
}

// ---- 用户搜索 ----

func (s *UserProxyServer) SearchUsers(ctx context.Context, req *userpb.SearchUsersRequest) (*userpb.SearchUsersResponse, error) {
	s.log.Debug("搜索用户", slog.String("query", req.Query))
	return s.client.SearchUsers(ctx, req)
}

// RegisterUserProxyServer 注册 User 代理服务
func RegisterUserProxyServer(s *grpc.Server, conn *grpc.ClientConn, log *slog.Logger) {
	proxy := NewUserProxyServer(conn, log)
	userpb.RegisterUserServiceServer(s, proxy)
	log.With(slog.String("component", "proxy")).Info("User 代理服务已注册")
}

// ============================================================================
// Post 代理服务（占位）
// ============================================================================

// TODO: 实现 Post 代理服务
// PostProxyServer 代理 Post 服务请求
// type PostProxyServer struct {
// 	postpb.UnimplementedPostServiceServer
// 	client postpb.PostServiceClient
// }

// ============================================================================
// Feed 代理服务（占位）
// ============================================================================

// TODO: 实现 Feed 代理服务
// FeedProxyServer 代理 Feed 服务请求
// type FeedProxyServer struct {
// 	feedpb.UnimplementedFeedServiceServer
// 	client feedpb.FeedServiceClient
// }

// ============================================================================
// Notification 代理服务（占位）
// ============================================================================

// TODO: 实现 Notification 代理服务
// NotificationProxyServer 代理 Notification 服务请求
// type NotificationProxyServer struct {
// 	notificationpb.UnimplementedNotificationServiceServer
// 	client notificationpb.NotificationServiceClient
// }

// ============================================================================
// Chat 代理服务（占位）
// ============================================================================

// TODO: Chat 服务使用双向流，通过 streaming.Proxy 代理
// 参见 internal/streaming/stream.go
