// Package handler 提供用户服务的 gRPC 处理器
package handler

import (
	"context"

	"github.com/funcdfs/lesser/pkg/gen_protos/common"
	"github.com/funcdfs/lesser/pkg/log"
	"github.com/funcdfs/lesser/pkg/page"
	"github.com/funcdfs/lesser/pkg/validate"
	pb "github.com/funcdfs/lesser/user/gen_protos/user"
	"github.com/funcdfs/lesser/user/internal/data_access"
	"github.com/funcdfs/lesser/user/internal/logic"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// UserHandler 用户服务 gRPC 处理器
type UserHandler struct {
	pb.UnimplementedUserServiceServer
	userService *logic.UserService
	log         *log.Logger
}

// NewUserHandler 创建用户处理器实例
func NewUserHandler(userService *logic.UserService, logger *log.Logger) *UserHandler {
	if logger == nil {
		logger = log.Global()
	}
	return &UserHandler{
		userService: userService,
		log:         logger.With(log.String("component", "handler")),
	}
}

// ============================================================================
// 用户资料
// ============================================================================

// GetProfile 获取用户资料
func (h *UserHandler) GetProfile(ctx context.Context, req *pb.GetProfileRequest) (*pb.Profile, error) {
	// 参数验证
	if err := validate.UUID("user_id", req.UserId); err != nil {
		return nil, err
	}

	user, relationship, err := h.userService.GetProfileWithRelationship(ctx, req.UserId, req.ViewerId)
	if err != nil {
		h.log.Error("获取用户资料失败",
			log.String("user_id", req.UserId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, h.handleError(err)
	}

	return userToProto(user, relationship), nil
}

// GetProfileByUsername 通过用户名获取资料
func (h *UserHandler) GetProfileByUsername(ctx context.Context, req *pb.GetProfileByUsernameRequest) (*pb.Profile, error) {
	// 参数验证
	if err := validate.Required("username", req.Username); err != nil {
		return nil, err
	}

	user, err := h.userService.GetProfileByUsername(ctx, req.Username)
	if err != nil {
		h.log.Error("通过用户名获取资料失败",
			log.String("username", req.Username),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, h.handleError(err)
	}

	// 如果有查看者，获取关系状态
	var relationship *data_access.RelationshipStatus
	if req.ViewerId != "" && req.ViewerId != user.ID {
		relationship, _ = h.userService.GetRelationship(ctx, req.ViewerId, user.ID)
	}

	return userToProto(user, relationship), nil
}

// UpdateProfile 更新用户资料
func (h *UserHandler) UpdateProfile(ctx context.Context, req *pb.UpdateProfileRequest) (*pb.Profile, error) {
	// 参数验证
	if err := validate.UUID("user_id", req.UserId); err != nil {
		return nil, err
	}

	// 构建更新字段
	updates := make(map[string]interface{})
	if req.DisplayName != nil {
		updates["display_name"] = *req.DisplayName
	}
	if req.AvatarUrl != nil {
		updates["avatar_url"] = *req.AvatarUrl
	}
	if req.Bio != nil {
		updates["bio"] = *req.Bio
	}
	if req.Location != nil {
		updates["location"] = *req.Location
	}
	if req.Website != nil {
		updates["website"] = *req.Website
	}
	if req.IsPrivate != nil {
		updates["is_private"] = *req.IsPrivate
	}

	user, err := h.userService.UpdateProfile(ctx, req.UserId, updates)
	if err != nil {
		h.log.Error("更新用户资料失败",
			log.String("user_id", req.UserId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, h.handleError(err)
	}

	return userToProto(user, nil), nil
}

// BatchGetProfiles 批量获取用户资料
func (h *UserHandler) BatchGetProfiles(ctx context.Context, req *pb.BatchGetProfilesRequest) (*pb.BatchGetProfilesResponse, error) {
	if len(req.UserIds) == 0 {
		return &pb.BatchGetProfilesResponse{Profiles: make(map[string]*pb.Profile)}, nil
	}

	users, err := h.userService.BatchGetProfiles(ctx, req.UserIds)
	if err != nil {
		h.log.Error("批量获取用户资料失败",
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, h.handleError(err)
	}

	profiles := make(map[string]*pb.Profile)
	for id, user := range users {
		profiles[id] = userToProto(user, nil)
	}

	return &pb.BatchGetProfilesResponse{Profiles: profiles}, nil
}

// ============================================================================
// 关注系统
// ============================================================================

// Follow 关注用户
func (h *UserHandler) Follow(ctx context.Context, req *pb.FollowRequest) (*common.Empty, error) {
	// 参数验证
	v := validate.New()
	v.Required("follower_id", req.FollowerId).UUID("follower_id", req.FollowerId)
	v.Required("following_id", req.FollowingId).UUID("following_id", req.FollowingId)
	if err := v.ToGRPCError(); err != nil {
		return nil, err
	}

	if err := h.userService.Follow(ctx, req.FollowerId, req.FollowingId); err != nil {
		h.log.Error("关注用户失败",
			log.String("follower_id", req.FollowerId),
			log.String("following_id", req.FollowingId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, h.handleError(err)
	}

	return &common.Empty{}, nil
}

// Unfollow 取消关注
func (h *UserHandler) Unfollow(ctx context.Context, req *pb.UnfollowRequest) (*common.Empty, error) {
	// 参数验证
	v := validate.New()
	v.Required("follower_id", req.FollowerId).UUID("follower_id", req.FollowerId)
	v.Required("following_id", req.FollowingId).UUID("following_id", req.FollowingId)
	if err := v.ToGRPCError(); err != nil {
		return nil, err
	}

	if err := h.userService.Unfollow(ctx, req.FollowerId, req.FollowingId); err != nil {
		h.log.Error("取消关注失败",
			log.String("follower_id", req.FollowerId),
			log.String("following_id", req.FollowingId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, h.handleError(err)
	}

	return &common.Empty{}, nil
}

// GetFollowers 获取粉丝列表
func (h *UserHandler) GetFollowers(ctx context.Context, req *pb.GetFollowersRequest) (*pb.FollowListResponse, error) {
	// 参数验证
	if err := validate.UUID("user_id", req.UserId); err != nil {
		return nil, err
	}

	pageNum, pageSize := getPagination(req.Pagination)
	limit, offset := page.BuildLimitOffset(pageNum, pageSize)

	users, total, err := h.userService.GetFollowers(ctx, req.UserId, int(limit), int(offset))
	if err != nil {
		h.log.Error("获取粉丝列表失败",
			log.String("user_id", req.UserId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, h.handleError(err)
	}

	return &pb.FollowListResponse{
		Users:      usersToProto(users, req.ViewerId, h.userService),
		Pagination: &common.Pagination{Page: pageNum, PageSize: pageSize, Total: int32(total)},
	}, nil
}

// GetFollowing 获取关注列表
func (h *UserHandler) GetFollowing(ctx context.Context, req *pb.GetFollowingRequest) (*pb.FollowListResponse, error) {
	// 参数验证
	if err := validate.UUID("user_id", req.UserId); err != nil {
		return nil, err
	}

	pageNum, pageSize := getPagination(req.Pagination)
	limit, offset := page.BuildLimitOffset(pageNum, pageSize)

	users, total, err := h.userService.GetFollowing(ctx, req.UserId, int(limit), int(offset))
	if err != nil {
		h.log.Error("获取关注列表失败",
			log.String("user_id", req.UserId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, h.handleError(err)
	}

	return &pb.FollowListResponse{
		Users:      usersToProto(users, req.ViewerId, h.userService),
		Pagination: &common.Pagination{Page: pageNum, PageSize: pageSize, Total: int32(total)},
	}, nil
}

// CheckFollowing 检查是否关注
func (h *UserHandler) CheckFollowing(ctx context.Context, req *pb.CheckFollowingRequest) (*pb.CheckFollowingResponse, error) {
	// 参数验证
	v := validate.New()
	v.Required("follower_id", req.FollowerId).UUID("follower_id", req.FollowerId)
	v.Required("following_id", req.FollowingId).UUID("following_id", req.FollowingId)
	if err := v.ToGRPCError(); err != nil {
		return nil, err
	}

	isFollowing, err := h.userService.CheckFollowing(ctx, req.FollowerId, req.FollowingId)
	if err != nil {
		h.log.Error("检查是否关注失败",
			log.String("follower_id", req.FollowerId),
			log.String("following_id", req.FollowingId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, h.handleError(err)
	}

	return &pb.CheckFollowingResponse{IsFollowing: isFollowing}, nil
}

// GetRelationship 获取两用户间关系
func (h *UserHandler) GetRelationship(ctx context.Context, req *pb.GetRelationshipRequest) (*pb.GetRelationshipResponse, error) {
	// 参数验证
	v := validate.New()
	v.Required("user_id", req.UserId).UUID("user_id", req.UserId)
	v.Required("target_id", req.TargetId).UUID("target_id", req.TargetId)
	if err := v.ToGRPCError(); err != nil {
		return nil, err
	}

	relationship, err := h.userService.GetRelationship(ctx, req.UserId, req.TargetId)
	if err != nil {
		h.log.Error("获取用户关系失败",
			log.String("user_id", req.UserId),
			log.String("target_id", req.TargetId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, h.handleError(err)
	}

	return &pb.GetRelationshipResponse{
		Relationship: relationshipToProto(relationship),
	}, nil
}

// GetMutualFollowers 获取共同关注
func (h *UserHandler) GetMutualFollowers(ctx context.Context, req *pb.GetMutualFollowersRequest) (*pb.FollowListResponse, error) {
	// 参数验证
	v := validate.New()
	v.Required("user_id", req.UserId).UUID("user_id", req.UserId)
	v.Required("target_id", req.TargetId).UUID("target_id", req.TargetId)
	if err := v.ToGRPCError(); err != nil {
		return nil, err
	}

	pageNum, pageSize := getPagination(req.Pagination)
	limit, offset := page.BuildLimitOffset(pageNum, pageSize)

	users, total, err := h.userService.GetMutualFollowers(ctx, req.UserId, req.TargetId, int(limit), int(offset))
	if err != nil {
		h.log.Error("获取共同关注失败",
			log.String("user_id", req.UserId),
			log.String("target_id", req.TargetId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, h.handleError(err)
	}

	return &pb.FollowListResponse{
		Users:      usersToProto(users, req.UserId, h.userService),
		Pagination: &common.Pagination{Page: pageNum, PageSize: pageSize, Total: int32(total)},
	}, nil
}

// ============================================================================
// 屏蔽系统
// ============================================================================

// Block 屏蔽用户
func (h *UserHandler) Block(ctx context.Context, req *pb.BlockRequest) (*common.Empty, error) {
	// 参数验证
	v := validate.New()
	v.Required("blocker_id", req.BlockerId).UUID("blocker_id", req.BlockerId)
	v.Required("blocked_id", req.BlockedId).UUID("blocked_id", req.BlockedId)
	if err := v.ToGRPCError(); err != nil {
		return nil, err
	}

	blockType := protoToBlockType(req.BlockType)
	if blockType == data_access.BlockTypeUnspecified {
		return nil, status.Error(codes.InvalidArgument, "block_type 不能为空")
	}

	if err := h.userService.Block(ctx, req.BlockerId, req.BlockedId, blockType); err != nil {
		h.log.Error("屏蔽用户失败",
			log.String("blocker_id", req.BlockerId),
			log.String("blocked_id", req.BlockedId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, h.handleError(err)
	}

	return &common.Empty{}, nil
}

// Unblock 取消屏蔽
func (h *UserHandler) Unblock(ctx context.Context, req *pb.UnblockRequest) (*common.Empty, error) {
	// 参数验证
	v := validate.New()
	v.Required("blocker_id", req.BlockerId).UUID("blocker_id", req.BlockerId)
	v.Required("blocked_id", req.BlockedId).UUID("blocked_id", req.BlockedId)
	if err := v.ToGRPCError(); err != nil {
		return nil, err
	}

	blockType := protoToBlockType(req.BlockType)
	if blockType == data_access.BlockTypeUnspecified {
		blockType = data_access.BlockTypeBlock // 默认取消全部
	}

	if err := h.userService.Unblock(ctx, req.BlockerId, req.BlockedId, blockType); err != nil {
		h.log.Error("取消屏蔽失败",
			log.String("blocker_id", req.BlockerId),
			log.String("blocked_id", req.BlockedId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, h.handleError(err)
	}

	return &common.Empty{}, nil
}

// GetBlockList 获取屏蔽列表
func (h *UserHandler) GetBlockList(ctx context.Context, req *pb.GetBlockListRequest) (*pb.BlockListResponse, error) {
	// 参数验证
	if err := validate.UUID("user_id", req.UserId); err != nil {
		return nil, err
	}

	pageNum, pageSize := getPagination(req.Pagination)
	limit, offset := page.BuildLimitOffset(pageNum, pageSize)

	blockType := protoToBlockType(req.BlockType)
	blockedUsers, total, err := h.userService.GetBlockList(ctx, req.UserId, blockType, int(limit), int(offset))
	if err != nil {
		h.log.Error("获取屏蔽列表失败",
			log.String("user_id", req.UserId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, h.handleError(err)
	}

	return &pb.BlockListResponse{
		Users:      blockedUsersToProto(blockedUsers),
		Pagination: &common.Pagination{Page: pageNum, PageSize: pageSize, Total: int32(total)},
	}, nil
}

// CheckBlocked 检查屏蔽状态
func (h *UserHandler) CheckBlocked(ctx context.Context, req *pb.CheckBlockedRequest) (*pb.CheckBlockedResponse, error) {
	// 参数验证
	v := validate.New()
	v.Required("user_id", req.UserId).UUID("user_id", req.UserId)
	v.Required("target_id", req.TargetId).UUID("target_id", req.TargetId)
	if err := v.ToGRPCError(); err != nil {
		return nil, err
	}

	relationship, err := h.userService.CheckBlocked(ctx, req.UserId, req.TargetId)
	if err != nil {
		h.log.Error("检查屏蔽状态失败",
			log.String("user_id", req.UserId),
			log.String("target_id", req.TargetId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, h.handleError(err)
	}

	return &pb.CheckBlockedResponse{
		IsBlocking:     relationship.IsBlocking,
		IsBlockedBy:    relationship.IsBlockedBy,
		MyBlockType:    blockTypeToProto(relationship.MyBlockType),
		TheirBlockType: blockTypeToProto(relationship.TheirBlockType),
		CanViewProfile: relationship.CanViewProfile(),
		CanBeViewed:    relationship.CanBeViewed(),
	}, nil
}

// ============================================================================
// 用户设置
// ============================================================================

// GetUserSettings 获取用户设置
func (h *UserHandler) GetUserSettings(ctx context.Context, req *pb.GetUserSettingsRequest) (*pb.UserSettings, error) {
	// 参数验证
	if err := validate.UUID("user_id", req.UserId); err != nil {
		return nil, err
	}

	settings, err := h.userService.GetUserSettings(ctx, req.UserId)
	if err != nil {
		h.log.Error("获取用户设置失败",
			log.String("user_id", req.UserId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, h.handleError(err)
	}

	return settingsToProto(settings), nil
}

// UpdateUserSettings 更新用户设置
func (h *UserHandler) UpdateUserSettings(ctx context.Context, req *pb.UpdateUserSettingsRequest) (*pb.UserSettings, error) {
	// 参数验证
	if err := validate.UUID("user_id", req.UserId); err != nil {
		return nil, err
	}

	// 更新隐私设置
	if req.Privacy != nil {
		privacySettings := protoToPrivacySettings(req.UserId, req.Privacy)
		if err := h.userService.UpdatePrivacySettings(ctx, req.UserId, privacySettings); err != nil {
			h.log.Error("更新隐私设置失败",
				log.String("user_id", req.UserId),
				log.String("trace_id", log.TraceIDFromContext(ctx)),
				log.Any("error", err),
			)
			return nil, h.handleError(err)
		}
	}

	// 更新通知设置
	if req.Notification != nil {
		notificationSettings := protoToNotificationSettings(req.UserId, req.Notification)
		if err := h.userService.UpdateNotificationSettings(ctx, req.UserId, notificationSettings); err != nil {
			h.log.Error("更新通知设置失败",
				log.String("user_id", req.UserId),
				log.String("trace_id", log.TraceIDFromContext(ctx)),
				log.Any("error", err),
			)
			return nil, h.handleError(err)
		}
	}

	// 返回更新后的设置
	settings, err := h.userService.GetUserSettings(ctx, req.UserId)
	if err != nil {
		h.log.Error("获取更新后的用户设置失败",
			log.String("user_id", req.UserId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, h.handleError(err)
	}

	return settingsToProto(settings), nil
}

// ============================================================================
// 用户搜索
// ============================================================================

// SearchUsers 搜索用户
func (h *UserHandler) SearchUsers(ctx context.Context, req *pb.SearchUsersRequest) (*pb.SearchUsersResponse, error) {
	// 参数验证
	if err := validate.Required("query", req.Query); err != nil {
		return nil, err
	}

	pageNum, pageSize := getPagination(req.Pagination)
	limit, offset := page.BuildLimitOffset(pageNum, pageSize)

	users, total, err := h.userService.SearchUsers(ctx, req.Query, int(limit), int(offset))
	if err != nil {
		h.log.Error("搜索用户失败",
			log.String("query", req.Query),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, h.handleError(err)
	}

	return &pb.SearchUsersResponse{
		Users:      usersToProto(users, req.ViewerId, h.userService),
		Pagination: &common.Pagination{Page: pageNum, PageSize: pageSize, Total: int32(total)},
	}, nil
}
