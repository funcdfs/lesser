// Package server 提供服务代理实现
//
// 将 gRPC 请求透明转发到后端服务
// 每个服务代理负责将请求转发到对应的后端服务
package server

import (
	"context"
	"log/slog"

	"google.golang.org/grpc"

	authpb "github.com/funcdfs/lesser/gateway/gen_protos/auth"
	commentpb "github.com/funcdfs/lesser/gateway/gen_protos/comment"
	"github.com/funcdfs/lesser/gateway/gen_protos/common"
	contentpb "github.com/funcdfs/lesser/gateway/gen_protos/content"
	interactionpb "github.com/funcdfs/lesser/gateway/gen_protos/interaction"
	notificationpb "github.com/funcdfs/lesser/gateway/gen_protos/notification"
	searchpb "github.com/funcdfs/lesser/gateway/gen_protos/search"
	timelinepb "github.com/funcdfs/lesser/gateway/gen_protos/timeline"
	userpb "github.com/funcdfs/lesser/gateway/gen_protos/user"
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

func (s *SearchProxyServer) SearchComments(ctx context.Context, req *searchpb.SearchCommentsRequest) (*searchpb.SearchCommentsResponse, error) {
	s.log.Debug("搜索评论请求", slog.String("query", req.Query), slog.String("post_id", req.PostId))
	return s.client.SearchComments(ctx, req)
}

func (s *SearchProxyServer) SearchAll(ctx context.Context, req *searchpb.SearchAllRequest) (*searchpb.SearchAllResponse, error) {
	s.log.Debug("综合搜索请求", slog.String("query", req.Query))
	return s.client.SearchAll(ctx, req)
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
// Content 代理服务
// ============================================================================

// ContentProxyServer 代理 Content 服务请求
type ContentProxyServer struct {
	contentpb.UnimplementedContentServiceServer
	client contentpb.ContentServiceClient
	log    *slog.Logger
}

// NewContentProxyServer 创建 Content 代理服务器
func NewContentProxyServer(conn *grpc.ClientConn, log *slog.Logger) *ContentProxyServer {
	if log == nil {
		log = slog.Default()
	}
	return &ContentProxyServer{
		client: contentpb.NewContentServiceClient(conn),
		log:    log.With(slog.String("component", "proxy.content")),
	}
}

// ---- 基础 CRUD ----

func (s *ContentProxyServer) CreateContent(ctx context.Context, req *contentpb.CreateContentRequest) (*contentpb.CreateContentResponse, error) {
	s.log.Debug("创建内容", slog.String("author_id", req.AuthorId), slog.String("type", req.Type.String()))
	return s.client.CreateContent(ctx, req)
}

func (s *ContentProxyServer) GetContent(ctx context.Context, req *contentpb.GetContentRequest) (*contentpb.GetContentResponse, error) {
	s.log.Debug("获取内容", slog.String("content_id", req.ContentId))
	return s.client.GetContent(ctx, req)
}

func (s *ContentProxyServer) UpdateContent(ctx context.Context, req *contentpb.UpdateContentRequest) (*contentpb.UpdateContentResponse, error) {
	s.log.Debug("更新内容", slog.String("content_id", req.ContentId), slog.String("user_id", req.UserId))
	return s.client.UpdateContent(ctx, req)
}

func (s *ContentProxyServer) DeleteContent(ctx context.Context, req *contentpb.DeleteContentRequest) (*contentpb.DeleteContentResponse, error) {
	s.log.Debug("删除内容", slog.String("content_id", req.ContentId), slog.String("user_id", req.UserId))
	return s.client.DeleteContent(ctx, req)
}

// ---- 列表查询 ----

func (s *ContentProxyServer) ListContents(ctx context.Context, req *contentpb.ListContentsRequest) (*contentpb.ListContentsResponse, error) {
	s.log.Debug("列表查询", slog.String("author_id", req.AuthorId), slog.String("type", req.Type.String()))
	return s.client.ListContents(ctx, req)
}

func (s *ContentProxyServer) BatchGetContents(ctx context.Context, req *contentpb.BatchGetContentsRequest) (*contentpb.BatchGetContentsResponse, error) {
	s.log.Debug("批量获取内容", slog.Int("count", len(req.ContentIds)))
	return s.client.BatchGetContents(ctx, req)
}

// ---- 草稿管理 ----

func (s *ContentProxyServer) GetUserDrafts(ctx context.Context, req *contentpb.GetUserDraftsRequest) (*contentpb.GetUserDraftsResponse, error) {
	s.log.Debug("获取用户草稿", slog.String("user_id", req.UserId))
	return s.client.GetUserDrafts(ctx, req)
}

func (s *ContentProxyServer) PublishDraft(ctx context.Context, req *contentpb.PublishDraftRequest) (*contentpb.PublishDraftResponse, error) {
	s.log.Debug("发布草稿", slog.String("content_id", req.ContentId), slog.String("user_id", req.UserId))
	return s.client.PublishDraft(ctx, req)
}

// ---- 回复/评论 ----

func (s *ContentProxyServer) GetReplies(ctx context.Context, req *contentpb.GetRepliesRequest) (*contentpb.GetRepliesResponse, error) {
	s.log.Debug("获取回复列表", slog.String("content_id", req.ContentId))
	return s.client.GetReplies(ctx, req)
}

// ---- Story 专用 ----

func (s *ContentProxyServer) GetUserStories(ctx context.Context, req *contentpb.GetUserStoriesRequest) (*contentpb.GetUserStoriesResponse, error) {
	s.log.Debug("获取用户 Story", slog.String("user_id", req.UserId))
	return s.client.GetUserStories(ctx, req)
}

// ---- 置顶 ----

func (s *ContentProxyServer) PinContent(ctx context.Context, req *contentpb.PinContentRequest) (*contentpb.PinContentResponse, error) {
	s.log.Debug("置顶内容", slog.String("content_id", req.ContentId), slog.Bool("pin", req.Pin))
	return s.client.PinContent(ctx, req)
}

// RegisterContentProxyServer 注册 Content 代理服务
func RegisterContentProxyServer(s *grpc.Server, conn *grpc.ClientConn, log *slog.Logger) {
	proxy := NewContentProxyServer(conn, log)
	contentpb.RegisterContentServiceServer(s, proxy)
	log.With(slog.String("component", "proxy")).Info("Content 代理服务已注册")
}

// ============================================================================
// Notification 代理服务
// ============================================================================

// NotificationProxyServer 代理 Notification 服务请求
type NotificationProxyServer struct {
	notificationpb.UnimplementedNotificationServiceServer
	client notificationpb.NotificationServiceClient
	log    *slog.Logger
}

// NewNotificationProxyServer 创建 Notification 代理服务器
func NewNotificationProxyServer(conn *grpc.ClientConn, log *slog.Logger) *NotificationProxyServer {
	if log == nil {
		log = slog.Default()
	}
	return &NotificationProxyServer{
		client: notificationpb.NewNotificationServiceClient(conn),
		log:    log.With(slog.String("component", "proxy.notification")),
	}
}

// List 获取通知列表
func (s *NotificationProxyServer) List(ctx context.Context, req *notificationpb.ListNotificationsRequest) (*notificationpb.ListNotificationsResponse, error) {
	s.log.Debug("获取通知列表", slog.String("user_id", req.UserId), slog.Bool("unread_only", req.UnreadOnly))
	return s.client.List(ctx, req)
}

// Read 标记单条通知已读
func (s *NotificationProxyServer) Read(ctx context.Context, req *notificationpb.ReadNotificationRequest) (*common.Empty, error) {
	s.log.Debug("标记通知已读", slog.String("notification_id", req.NotificationId), slog.String("user_id", req.UserId))
	return s.client.Read(ctx, req)
}

// ReadAll 标记所有通知已读
func (s *NotificationProxyServer) ReadAll(ctx context.Context, req *notificationpb.ReadAllNotificationsRequest) (*common.Empty, error) {
	s.log.Debug("标记所有通知已读", slog.String("user_id", req.UserId))
	return s.client.ReadAll(ctx, req)
}

// GetUnreadCount 获取未读通知数量
func (s *NotificationProxyServer) GetUnreadCount(ctx context.Context, req *notificationpb.GetUnreadCountRequest) (*notificationpb.UnreadCountResponse, error) {
	s.log.Debug("获取未读通知数量", slog.String("user_id", req.UserId))
	return s.client.GetUnreadCount(ctx, req)
}

// RegisterNotificationProxyServer 注册 Notification 代理服务
func RegisterNotificationProxyServer(s *grpc.Server, conn *grpc.ClientConn, log *slog.Logger) {
	proxy := NewNotificationProxyServer(conn, log)
	notificationpb.RegisterNotificationServiceServer(s, proxy)
	log.With(slog.String("component", "proxy")).Info("Notification 代理服务已注册")
}

// ============================================================================
// Chat 代理服务（占位）
// ============================================================================

// TODO: Chat 服务使用双向流，通过 streaming.Proxy 代理
// 参见 internal/streaming/stream.go

// ============================================================================
// Interaction 代理服务
// ============================================================================

// InteractionProxyServer 代理 Interaction 服务请求
type InteractionProxyServer struct {
	interactionpb.UnimplementedInteractionServiceServer
	client interactionpb.InteractionServiceClient
	log    *slog.Logger
}

// NewInteractionProxyServer 创建 Interaction 代理服务器
func NewInteractionProxyServer(conn *grpc.ClientConn, log *slog.Logger) *InteractionProxyServer {
	if log == nil {
		log = slog.Default()
	}
	return &InteractionProxyServer{
		client: interactionpb.NewInteractionServiceClient(conn),
		log:    log.With(slog.String("component", "proxy.interaction")),
	}
}

// ---- 点赞 ----

func (s *InteractionProxyServer) Like(ctx context.Context, req *interactionpb.LikeRequest) (*interactionpb.LikeResponse, error) {
	s.log.Debug("点赞", slog.String("user_id", req.UserId), slog.String("content_id", req.ContentId))
	return s.client.Like(ctx, req)
}

func (s *InteractionProxyServer) Unlike(ctx context.Context, req *interactionpb.UnlikeRequest) (*interactionpb.UnlikeResponse, error) {
	s.log.Debug("取消点赞", slog.String("user_id", req.UserId), slog.String("content_id", req.ContentId))
	return s.client.Unlike(ctx, req)
}

func (s *InteractionProxyServer) CheckLiked(ctx context.Context, req *interactionpb.CheckLikedRequest) (*interactionpb.CheckLikedResponse, error) {
	s.log.Debug("检查点赞状态", slog.String("user_id", req.UserId), slog.String("content_id", req.ContentId))
	return s.client.CheckLiked(ctx, req)
}

// ---- 收藏 ----

func (s *InteractionProxyServer) Bookmark(ctx context.Context, req *interactionpb.BookmarkRequest) (*interactionpb.BookmarkResponse, error) {
	s.log.Debug("收藏", slog.String("user_id", req.UserId), slog.String("content_id", req.ContentId))
	return s.client.Bookmark(ctx, req)
}

func (s *InteractionProxyServer) Unbookmark(ctx context.Context, req *interactionpb.UnbookmarkRequest) (*interactionpb.UnbookmarkResponse, error) {
	s.log.Debug("取消收藏", slog.String("user_id", req.UserId), slog.String("content_id", req.ContentId))
	return s.client.Unbookmark(ctx, req)
}

func (s *InteractionProxyServer) ListBookmarks(ctx context.Context, req *interactionpb.ListBookmarksRequest) (*interactionpb.ListBookmarksResponse, error) {
	s.log.Debug("获取收藏列表", slog.String("user_id", req.UserId))
	return s.client.ListBookmarks(ctx, req)
}

// ---- 转发 ----

func (s *InteractionProxyServer) CreateRepost(ctx context.Context, req *interactionpb.CreateRepostRequest) (*interactionpb.CreateRepostResponse, error) {
	s.log.Debug("创建转发", slog.String("user_id", req.UserId), slog.String("content_id", req.ContentId))
	return s.client.CreateRepost(ctx, req)
}

func (s *InteractionProxyServer) DeleteRepost(ctx context.Context, req *interactionpb.DeleteRepostRequest) (*interactionpb.DeleteRepostResponse, error) {
	s.log.Debug("删除转发", slog.String("user_id", req.UserId), slog.String("content_id", req.ContentId))
	return s.client.DeleteRepost(ctx, req)
}

// ---- 批量查询 ----

func (s *InteractionProxyServer) BatchGetInteractionStatus(ctx context.Context, req *interactionpb.BatchGetInteractionStatusRequest) (*interactionpb.BatchGetInteractionStatusResponse, error) {
	s.log.Debug("批量获取交互状态", slog.String("user_id", req.UserId), slog.Int("count", len(req.ContentIds)))
	return s.client.BatchGetInteractionStatus(ctx, req)
}

// RegisterInteractionProxyServer 注册 Interaction 代理服务
func RegisterInteractionProxyServer(s *grpc.Server, conn *grpc.ClientConn, log *slog.Logger) {
	proxy := NewInteractionProxyServer(conn, log)
	interactionpb.RegisterInteractionServiceServer(s, proxy)
	log.With(slog.String("component", "proxy")).Info("Interaction 代理服务已注册")
}

// ============================================================================
// Comment 代理服务
// ============================================================================

// CommentProxyServer 代理 Comment 服务请求
type CommentProxyServer struct {
	commentpb.UnimplementedCommentServiceServer
	client commentpb.CommentServiceClient
	log    *slog.Logger
}

// NewCommentProxyServer 创建 Comment 代理服务器
func NewCommentProxyServer(conn *grpc.ClientConn, log *slog.Logger) *CommentProxyServer {
	if log == nil {
		log = slog.Default()
	}
	return &CommentProxyServer{
		client: commentpb.NewCommentServiceClient(conn),
		log:    log.With(slog.String("component", "proxy.comment")),
	}
}

// CreateComment 创建评论
func (s *CommentProxyServer) CreateComment(ctx context.Context, req *commentpb.CreateCommentRequest) (*commentpb.CreateCommentResponse, error) {
	s.log.Debug("创建评论", slog.String("author_id", req.AuthorId), slog.String("content_id", req.ContentId))
	return s.client.CreateComment(ctx, req)
}

// GetComment 获取单条评论
func (s *CommentProxyServer) GetComment(ctx context.Context, req *commentpb.GetCommentRequest) (*commentpb.GetCommentResponse, error) {
	s.log.Debug("获取评论", slog.String("comment_id", req.CommentId))
	return s.client.GetComment(ctx, req)
}

// DeleteComment 删除评论
func (s *CommentProxyServer) DeleteComment(ctx context.Context, req *commentpb.DeleteCommentRequest) (*commentpb.DeleteCommentResponse, error) {
	s.log.Debug("删除评论", slog.String("comment_id", req.CommentId), slog.String("user_id", req.UserId))
	return s.client.DeleteComment(ctx, req)
}

// ListComments 获取评论列表
func (s *CommentProxyServer) ListComments(ctx context.Context, req *commentpb.ListCommentsRequest) (*commentpb.ListCommentsResponse, error) {
	s.log.Debug("获取评论列表",
		slog.String("content_id", req.ContentId),
		slog.String("parent_id", req.ParentId),
		slog.String("sort_by", req.SortBy.String()))
	return s.client.ListComments(ctx, req)
}

// GetCommentCount 获取评论数量
func (s *CommentProxyServer) GetCommentCount(ctx context.Context, req *commentpb.GetCommentCountRequest) (*commentpb.GetCommentCountResponse, error) {
	s.log.Debug("获取评论数量", slog.String("content_id", req.ContentId))
	return s.client.GetCommentCount(ctx, req)
}

// BatchGetCommentCount 批量获取评论数量
func (s *CommentProxyServer) BatchGetCommentCount(ctx context.Context, req *commentpb.BatchGetCommentCountRequest) (*commentpb.BatchGetCommentCountResponse, error) {
	s.log.Debug("批量获取评论数量", slog.Int("count", len(req.ContentIds)))
	return s.client.BatchGetCommentCount(ctx, req)
}

// LikeComment 点赞评论
func (s *CommentProxyServer) LikeComment(ctx context.Context, req *commentpb.LikeCommentRequest) (*commentpb.LikeCommentResponse, error) {
	s.log.Debug("点赞评论", slog.String("user_id", req.UserId), slog.String("comment_id", req.CommentId))
	return s.client.LikeComment(ctx, req)
}

// UnlikeComment 取消点赞评论
func (s *CommentProxyServer) UnlikeComment(ctx context.Context, req *commentpb.UnlikeCommentRequest) (*commentpb.UnlikeCommentResponse, error) {
	s.log.Debug("取消点赞评论", slog.String("user_id", req.UserId), slog.String("comment_id", req.CommentId))
	return s.client.UnlikeComment(ctx, req)
}

// RegisterCommentProxyServer 注册 Comment 代理服务
func RegisterCommentProxyServer(s *grpc.Server, conn *grpc.ClientConn, log *slog.Logger) {
	proxy := NewCommentProxyServer(conn, log)
	commentpb.RegisterCommentServiceServer(s, proxy)
	log.With(slog.String("component", "proxy")).Info("Comment 代理服务已注册")
}

// ============================================================================
// Timeline 代理服务
// ============================================================================

// TimelineProxyServer 代理 Timeline 服务请求
type TimelineProxyServer struct {
	timelinepb.UnimplementedTimelineServiceServer
	client timelinepb.TimelineServiceClient
	log    *slog.Logger
}

// NewTimelineProxyServer 创建 Timeline 代理服务器
func NewTimelineProxyServer(conn *grpc.ClientConn, log *slog.Logger) *TimelineProxyServer {
	if log == nil {
		log = slog.Default()
	}
	return &TimelineProxyServer{
		client: timelinepb.NewTimelineServiceClient(conn),
		log:    log.With(slog.String("component", "proxy.timeline")),
	}
}

func (s *TimelineProxyServer) GetFollowingFeed(ctx context.Context, req *timelinepb.GetFollowingFeedRequest) (*timelinepb.GetFollowingFeedResponse, error) {
	s.log.Debug("获取关注 Feed", slog.String("user_id", req.UserId))
	return s.client.GetFollowingFeed(ctx, req)
}

func (s *TimelineProxyServer) GetRecommendFeed(ctx context.Context, req *timelinepb.GetRecommendFeedRequest) (*timelinepb.GetRecommendFeedResponse, error) {
	s.log.Debug("获取推荐 Feed", slog.String("user_id", req.UserId))
	return s.client.GetRecommendFeed(ctx, req)
}

func (s *TimelineProxyServer) GetUserFeed(ctx context.Context, req *timelinepb.GetUserFeedRequest) (*timelinepb.GetUserFeedResponse, error) {
	s.log.Debug("获取用户 Feed", slog.String("user_id", req.UserId), slog.String("viewer_id", req.ViewerId))
	return s.client.GetUserFeed(ctx, req)
}

func (s *TimelineProxyServer) GetHotFeed(ctx context.Context, req *timelinepb.GetHotFeedRequest) (*timelinepb.GetHotFeedResponse, error) {
	s.log.Debug("获取热门 Feed", slog.String("user_id", req.UserId), slog.String("time_range", req.TimeRange))
	return s.client.GetHotFeed(ctx, req)
}

func (s *TimelineProxyServer) GetContentDetail(ctx context.Context, req *timelinepb.GetContentDetailRequest) (*timelinepb.GetContentDetailResponse, error) {
	s.log.Debug("获取内容详情", slog.String("content_id", req.ContentId), slog.String("viewer_id", req.ViewerId))
	return s.client.GetContentDetail(ctx, req)
}

// RegisterTimelineProxyServer 注册 Timeline 代理服务
func RegisterTimelineProxyServer(s *grpc.Server, conn *grpc.ClientConn, log *slog.Logger) {
	proxy := NewTimelineProxyServer(conn, log)
	timelinepb.RegisterTimelineServiceServer(s, proxy)
	log.With(slog.String("component", "proxy")).Info("Timeline 代理服务已注册")
}
