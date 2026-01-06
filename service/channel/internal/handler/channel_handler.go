// Package handler Channel gRPC 处理器
package handler

import (
	"context"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	pb "github.com/funcdfs/lesser/channel/gen_protos/channel"
	"github.com/funcdfs/lesser/channel/internal/logic"
	"github.com/funcdfs/lesser/pkg/auth"
	common "github.com/funcdfs/lesser/pkg/gen_protos/common"
	"github.com/funcdfs/lesser/pkg/log"
)

// ChannelHandler 频道 gRPC 处理器
type ChannelHandler struct {
	pb.UnimplementedChannelServiceServer
	service       logic.ChannelService
	streamManager *StreamManager
	log           *log.Logger
}

// NewChannelHandler 创建频道处理器
func NewChannelHandler(service logic.ChannelService, streamManager *StreamManager, logger *log.Logger) *ChannelHandler {
	return &ChannelHandler{
		service:       service,
		streamManager: streamManager,
		log:           logger,
	}
}

// ============================================================================
// 频道管理
// ============================================================================

// CreateChannel 创建频道
func (h *ChannelHandler) CreateChannel(ctx context.Context, req *pb.CreateChannelRequest) (*pb.Channel, error) {
	// 获取用户 ID（从 context value 中获取，由拦截器注入）
	userID, err := auth.MustUserIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	// 参数验证
	if req.Name == "" {
		return nil, status.Error(codes.InvalidArgument, "频道名称不能为空")
	}

	// 调用服务
	channel, err := h.service.CreateChannel(ctx, userID, &logic.CreateChannelRequest{
		Name:        req.Name,
		Description: req.Description,
		AvatarURL:   req.AvatarUrl,
		Username:    req.Username,
		IsPublic:    req.IsPublic,
	})
	if err != nil {
		return nil, logic.ToGRPCError(err)
	}

	return channelToProto(channel, true, true, true, nil), nil
}

// GetChannel 获取频道信息
func (h *ChannelHandler) GetChannel(ctx context.Context, req *pb.GetChannelRequest) (*pb.Channel, error) {
	// 获取用户 ID（可选，从 context value 中获取）
	userID := auth.UserIDFromContext(ctx)

	// 参数验证
	if req.ChannelId == "" {
		return nil, status.Error(codes.InvalidArgument, "频道 ID 不能为空")
	}

	// 调用服务
	info, err := h.service.GetChannel(ctx, req.ChannelId, userID)
	if err != nil {
		return nil, logic.ToGRPCError(err)
	}

	return channelInfoToProto(info), nil
}

// UpdateChannel 更新频道信息
func (h *ChannelHandler) UpdateChannel(ctx context.Context, req *pb.UpdateChannelRequest) (*pb.Channel, error) {
	// 获取用户 ID（从 context value 中获取，由拦截器注入）
	userID, err := auth.MustUserIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	// 参数验证
	if req.ChannelId == "" {
		return nil, status.Error(codes.InvalidArgument, "频道 ID 不能为空")
	}

	// 调用服务
	channel, err := h.service.UpdateChannel(ctx, userID, &logic.UpdateChannelRequest{
		ChannelID:   req.ChannelId,
		Name:        req.Name,
		Description: req.Description,
		AvatarURL:   req.AvatarUrl,
		Username:    req.Username,
		IsPublic:    req.IsPublic,
	})
	if err != nil {
		return nil, logic.ToGRPCError(err)
	}

	return channelToProto(channel, true, true, channel.OwnerID == userID, nil), nil
}

// DeleteChannel 删除频道
func (h *ChannelHandler) DeleteChannel(ctx context.Context, req *pb.DeleteChannelRequest) (*common.Empty, error) {
	// 获取用户 ID（从 context value 中获取，由拦截器注入）
	userID, err := auth.MustUserIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	// 参数验证
	if req.ChannelId == "" {
		return nil, status.Error(codes.InvalidArgument, "频道 ID 不能为空")
	}

	// 调用服务
	if err := h.service.DeleteChannel(ctx, req.ChannelId, userID); err != nil {
		return nil, logic.ToGRPCError(err)
	}

	return &common.Empty{}, nil
}

// GetSubscribedChannels 获取用户订阅的频道列表
func (h *ChannelHandler) GetSubscribedChannels(ctx context.Context, req *pb.GetSubscribedChannelsRequest) (*pb.ChannelsResponse, error) {
	// 获取用户 ID（优先使用请求参数，否则从 context 获取）
	userID := req.UserId
	if userID == "" {
		var err error
		userID, err = auth.MustUserIDFromContext(ctx)
		if err != nil {
			return nil, err
		}
	}

	// 分页参数
	limit, offset := getPagination(req.Pagination)

	// 调用服务
	channels, total, err := h.service.GetSubscribedChannels(ctx, userID, limit, offset)
	if err != nil {
		return nil, logic.ToGRPCError(err)
	}

	return &pb.ChannelsResponse{
		Channels:   channelInfosToProto(channels),
		Pagination: buildPaginationResponse(calculatePage(offset, limit), limit, total),
	}, nil
}

// GetOwnedChannels 获取用户管理的频道列表
func (h *ChannelHandler) GetOwnedChannels(ctx context.Context, req *pb.GetOwnedChannelsRequest) (*pb.ChannelsResponse, error) {
	// 获取用户 ID（优先使用请求参数，否则从 context 获取）
	userID := req.UserId
	if userID == "" {
		var err error
		userID, err = auth.MustUserIDFromContext(ctx)
		if err != nil {
			return nil, err
		}
	}

	// 分页参数
	limit, offset := getPagination(req.Pagination)

	// 调用服务
	channels, total, err := h.service.GetOwnedChannels(ctx, userID, limit, offset)
	if err != nil {
		return nil, logic.ToGRPCError(err)
	}

	return &pb.ChannelsResponse{
		Channels:   channelInfosToProto(channels),
		Pagination: buildPaginationResponse(calculatePage(offset, limit), limit, total),
	}, nil
}

// SearchChannels 搜索频道
func (h *ChannelHandler) SearchChannels(ctx context.Context, req *pb.SearchChannelsRequest) (*pb.ChannelsResponse, error) {
	// 获取用户 ID（可选，从 context value 中获取）
	userID := auth.UserIDFromContext(ctx)

	// 分页参数
	limit, offset := getPagination(req.Pagination)

	// 调用服务
	channels, total, err := h.service.SearchChannels(ctx, req.Query, userID, limit, offset)
	if err != nil {
		return nil, logic.ToGRPCError(err)
	}

	return &pb.ChannelsResponse{
		Channels:   channelInfosToProto(channels),
		Pagination: buildPaginationResponse(calculatePage(offset, limit), limit, total),
	}, nil
}

// ============================================================================
// 订阅管理
// ============================================================================

// Subscribe 订阅频道
func (h *ChannelHandler) Subscribe(ctx context.Context, req *pb.SubscribeRequest) (*common.Empty, error) {
	// 获取用户 ID（从 context value 中获取，由拦截器注入）
	userID, err := auth.MustUserIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	// 参数验证
	if req.ChannelId == "" {
		return nil, status.Error(codes.InvalidArgument, "频道 ID 不能为空")
	}

	// 调用服务
	if err := h.service.Subscribe(ctx, req.ChannelId, userID); err != nil {
		return nil, logic.ToGRPCError(err)
	}

	return &common.Empty{}, nil
}

// Unsubscribe 取消订阅
func (h *ChannelHandler) Unsubscribe(ctx context.Context, req *pb.UnsubscribeRequest) (*common.Empty, error) {
	// 获取用户 ID（从 context value 中获取，由拦截器注入）
	userID, err := auth.MustUserIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	// 参数验证
	if req.ChannelId == "" {
		return nil, status.Error(codes.InvalidArgument, "频道 ID 不能为空")
	}

	// 调用服务
	if err := h.service.Unsubscribe(ctx, req.ChannelId, userID); err != nil {
		return nil, logic.ToGRPCError(err)
	}

	return &common.Empty{}, nil
}

// GetSubscribers 获取频道订阅者列表
func (h *ChannelHandler) GetSubscribers(ctx context.Context, req *pb.GetSubscribersRequest) (*pb.SubscribersResponse, error) {
	// 参数验证
	if req.ChannelId == "" {
		return nil, status.Error(codes.InvalidArgument, "频道 ID 不能为空")
	}

	// 分页参数
	limit, offset := getPagination(req.Pagination)

	// 调用服务
	subscribers, total, err := h.service.GetSubscribers(ctx, req.ChannelId, limit, offset)
	if err != nil {
		return nil, logic.ToGRPCError(err)
	}

	return &pb.SubscribersResponse{
		Subscribers: subscribersToProto(subscribers),
		Pagination:  buildPaginationResponse(calculatePage(offset, limit), limit, total),
	}, nil
}

// CheckSubscription 检查是否已订阅
func (h *ChannelHandler) CheckSubscription(ctx context.Context, req *pb.CheckSubscriptionRequest) (*pb.CheckSubscriptionResponse, error) {
	// 获取用户 ID（从 context value 中获取，由拦截器注入）
	userID, err := auth.MustUserIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	// 参数验证
	if req.ChannelId == "" {
		return nil, status.Error(codes.InvalidArgument, "频道 ID 不能为空")
	}

	// 调用服务
	isSubscribed, err := h.service.CheckSubscription(ctx, req.ChannelId, userID)
	if err != nil {
		return nil, logic.ToGRPCError(err)
	}

	return &pb.CheckSubscriptionResponse{IsSubscribed: isSubscribed}, nil
}

// ============================================================================
// 管理员管理
// ============================================================================

// AddAdmin 添加管理员
func (h *ChannelHandler) AddAdmin(ctx context.Context, req *pb.AddAdminRequest) (*common.Empty, error) {
	// 获取用户 ID（从 context value 中获取，由拦截器注入）
	userID, err := auth.MustUserIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	// 参数验证
	if req.ChannelId == "" {
		return nil, status.Error(codes.InvalidArgument, "频道 ID 不能为空")
	}
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "用户 ID 不能为空")
	}

	// 调用服务
	if err := h.service.AddAdmin(ctx, req.ChannelId, req.UserId, userID); err != nil {
		return nil, logic.ToGRPCError(err)
	}

	return &common.Empty{}, nil
}

// RemoveAdmin 移除管理员
func (h *ChannelHandler) RemoveAdmin(ctx context.Context, req *pb.RemoveAdminRequest) (*common.Empty, error) {
	// 获取用户 ID（从 context value 中获取，由拦截器注入）
	userID, err := auth.MustUserIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	// 参数验证
	if req.ChannelId == "" {
		return nil, status.Error(codes.InvalidArgument, "频道 ID 不能为空")
	}
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "用户 ID 不能为空")
	}

	// 调用服务
	if err := h.service.RemoveAdmin(ctx, req.ChannelId, req.UserId, userID); err != nil {
		return nil, logic.ToGRPCError(err)
	}

	return &common.Empty{}, nil
}

// GetAdmins 获取管理员列表
func (h *ChannelHandler) GetAdmins(ctx context.Context, req *pb.GetAdminsRequest) (*pb.AdminsResponse, error) {
	// 参数验证
	if req.ChannelId == "" {
		return nil, status.Error(codes.InvalidArgument, "频道 ID 不能为空")
	}

	// 调用服务
	admins, err := h.service.GetAdmins(ctx, req.ChannelId)
	if err != nil {
		return nil, logic.ToGRPCError(err)
	}

	return &pb.AdminsResponse{Admins: adminsToProto(admins)}, nil
}

// ============================================================================
// 内容发布
// ============================================================================

// PublishPost 发布内容
func (h *ChannelHandler) PublishPost(ctx context.Context, req *pb.PublishPostRequest) (*pb.ChannelPost, error) {
	// 获取用户 ID（从 context value 中获取，由拦截器注入）
	userID, err := auth.MustUserIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	// 参数验证
	if req.ChannelId == "" {
		return nil, status.Error(codes.InvalidArgument, "频道 ID 不能为空")
	}
	if req.Content == "" && len(req.MediaUrls) == 0 {
		return nil, status.Error(codes.InvalidArgument, "内容不能为空")
	}

	// 调用服务
	post, err := h.service.PublishPost(ctx, userID, &logic.PublishPostRequest{
		ChannelID: req.ChannelId,
		Content:   req.Content,
		MediaURLs: req.MediaUrls,
	})
	if err != nil {
		return nil, logic.ToGRPCError(err)
	}

	return postToProto(post), nil
}

// GetPosts 获取频道内容列表
func (h *ChannelHandler) GetPosts(ctx context.Context, req *pb.GetPostsRequest) (*pb.PostsResponse, error) {
	// 参数验证
	if req.ChannelId == "" {
		return nil, status.Error(codes.InvalidArgument, "频道 ID 不能为空")
	}

	// 分页参数
	limit, offset := getPagination(req.Pagination)

	// 调用服务
	posts, total, err := h.service.GetPosts(ctx, req.ChannelId, limit, offset)
	if err != nil {
		return nil, logic.ToGRPCError(err)
	}

	return &pb.PostsResponse{
		Posts:      postsToProto(posts),
		Pagination: buildPaginationResponse(calculatePage(offset, limit), limit, total),
	}, nil
}

// GetPost 获取单个内容详情
func (h *ChannelHandler) GetPost(ctx context.Context, req *pb.GetPostRequest) (*pb.ChannelPost, error) {
	// 参数验证
	if req.PostId == "" {
		return nil, status.Error(codes.InvalidArgument, "内容 ID 不能为空")
	}

	// 调用服务
	post, err := h.service.GetPost(ctx, req.PostId)
	if err != nil {
		return nil, logic.ToGRPCError(err)
	}

	return postToProto(post), nil
}

// EditPost 编辑频道内容
func (h *ChannelHandler) EditPost(ctx context.Context, req *pb.EditPostRequest) (*pb.ChannelPost, error) {
	// 获取用户 ID（从 context value 中获取，由拦截器注入）
	userID, err := auth.MustUserIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	// 参数验证
	if req.PostId == "" {
		return nil, status.Error(codes.InvalidArgument, "内容 ID 不能为空")
	}

	// 调用服务
	post, err := h.service.EditPost(ctx, userID, &logic.EditPostRequest{
		PostID:    req.PostId,
		Content:   req.Content,
		MediaURLs: req.MediaUrls,
	})
	if err != nil {
		return nil, logic.ToGRPCError(err)
	}

	return postToProto(post), nil
}

// DeletePost 删除频道内容
func (h *ChannelHandler) DeletePost(ctx context.Context, req *pb.DeletePostRequest) (*common.Empty, error) {
	// 获取用户 ID（从 context value 中获取，由拦截器注入）
	userID, err := auth.MustUserIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	// 参数验证
	if req.PostId == "" {
		return nil, status.Error(codes.InvalidArgument, "内容 ID 不能为空")
	}

	// 调用服务
	if err := h.service.DeletePost(ctx, req.PostId, userID); err != nil {
		return nil, logic.ToGRPCError(err)
	}

	return &common.Empty{}, nil
}

// PinPost 置顶内容
func (h *ChannelHandler) PinPost(ctx context.Context, req *pb.PinPostRequest) (*common.Empty, error) {
	// 获取用户 ID（从 context value 中获取，由拦截器注入）
	userID, err := auth.MustUserIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	// 参数验证
	if req.PostId == "" {
		return nil, status.Error(codes.InvalidArgument, "内容 ID 不能为空")
	}

	// 调用服务
	if err := h.service.PinPost(ctx, req.PostId, userID); err != nil {
		return nil, logic.ToGRPCError(err)
	}

	return &common.Empty{}, nil
}

// UnpinPost 取消置顶
func (h *ChannelHandler) UnpinPost(ctx context.Context, req *pb.UnpinPostRequest) (*common.Empty, error) {
	// 获取用户 ID（从 context value 中获取，由拦截器注入）
	userID, err := auth.MustUserIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	// 参数验证
	if req.PostId == "" {
		return nil, status.Error(codes.InvalidArgument, "内容 ID 不能为空")
	}

	// 调用服务
	if err := h.service.UnpinPost(ctx, req.PostId, userID); err != nil {
		return nil, logic.ToGRPCError(err)
	}

	return &common.Empty{}, nil
}

// StreamUpdates 双向流：实时频道更新
func (h *ChannelHandler) StreamUpdates(stream grpc.BidiStreamingServer[pb.ChannelClientEvent, pb.ChannelServerEvent]) error {
	if h.streamManager == nil {
		return status.Error(codes.Unavailable, "流管理器未初始化")
	}
	return h.streamManager.HandleStreamUpdates(stream)
}

// GetStreamManager 获取流管理器（用于广播）
func (h *ChannelHandler) GetStreamManager() *StreamManager {
	return h.streamManager
}
