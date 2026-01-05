// Package handler 提供用户服务的 gRPC 处理器
package handler

import (
	"context"

	"github.com/funcdfs/lesser/pkg/gen_protos/common"
	pb "github.com/funcdfs/lesser/user/gen_protos/user"
	"github.com/funcdfs/lesser/user/internal/data_access"
	"github.com/funcdfs/lesser/user/internal/logic"
)

// ============================================================================
// Proto 转换器
// ============================================================================

// userToProto 将用户模型转换为 Proto
func userToProto(user *data_access.User, relationship *data_access.RelationshipStatus) *pb.Profile {
	if user == nil {
		return nil
	}

	profile := &pb.Profile{
		Id:             user.ID,
		Username:       user.Username,
		Email:          user.Email,
		DisplayName:    user.DisplayName,
		AvatarUrl:      user.AvatarURL,
		Bio:            user.Bio,
		Location:       user.Location,
		Website:        user.Website,
		IsVerified:     user.IsVerified,
		IsPrivate:      user.IsPrivate,
		FollowersCount: user.FollowersCount,
		FollowingCount: user.FollowingCount,
		PostsCount:     user.PostsCount,
		CreatedAt:      &common.Timestamp{Seconds: user.CreatedAt.Unix()},
		UpdatedAt:      &common.Timestamp{Seconds: user.UpdatedAt.Unix()},
	}

	// 生日
	if user.Birthday.Valid {
		profile.Birthday = user.Birthday.Time.Format("2006-01-02")
	}

	// 关系状态
	if relationship != nil {
		profile.Relationship = relationshipToProto(relationship)
	}

	return profile
}

// usersToProto 批量转换用户列表
func usersToProto(users []*data_access.User, viewerID string, svc *logic.UserService) []*pb.Profile {
	result := make([]*pb.Profile, len(users))
	for i, u := range users {
		var relationship *data_access.RelationshipStatus
		if viewerID != "" && viewerID != u.ID {
			relationship, _ = svc.GetRelationship(context.Background(), viewerID, u.ID)
		}
		result[i] = userToProto(u, relationship)
	}
	return result
}

// relationshipToProto 将关系状态转换为 Proto
func relationshipToProto(r *data_access.RelationshipStatus) *pb.RelationshipStatus {
	if r == nil {
		return nil
	}
	return &pb.RelationshipStatus{
		IsFollowing:  r.IsFollowing,
		IsFollowedBy: r.IsFollowedBy,
		IsMutual:     r.IsMutual,
		IsBlocking:   r.IsBlocking,
		IsBlockedBy:  r.IsBlockedBy,
		IsMuting:     r.IsMuting,
		IsHidingFrom: r.IsHidingFrom,
	}
}

// blockedUsersToProto 转换屏蔽用户列表
func blockedUsersToProto(blockedUsers []*data_access.BlockedUser) []*pb.BlockedUser {
	result := make([]*pb.BlockedUser, len(blockedUsers))
	for i, bu := range blockedUsers {
		result[i] = &pb.BlockedUser{
			Profile:   userToProto(bu.User, nil),
			BlockType: blockTypeToProto(bu.BlockType),
			BlockedAt: &common.Timestamp{Seconds: bu.BlockedAt.Unix()},
		}
	}
	return result
}

// settingsToProto 将设置转换为 Proto
func settingsToProto(settings *data_access.UserSettings) *pb.UserSettings {
	if settings == nil {
		return nil
	}
	return &pb.UserSettings{
		UserId:       settings.UserID,
		Privacy:      privacySettingsToProto(settings.Privacy),
		Notification: notificationSettingsToProto(settings.Notification),
	}
}

// privacySettingsToProto 转换隐私设置
func privacySettingsToProto(p *data_access.PrivacySettings) *pb.PrivacySettings {
	if p == nil {
		return nil
	}
	return &pb.PrivacySettings{
		IsPrivateAccount:       p.IsPrivateAccount,
		AllowMessageFromAnyone: p.AllowMessageFromAnyone,
		ShowOnlineStatus:       p.ShowOnlineStatus,
		ShowLastSeen:           p.ShowLastSeen,
		AllowTagging:           p.AllowTagging,
		ShowActivityStatus:     p.ShowActivityStatus,
	}
}

// notificationSettingsToProto 转换通知设置
func notificationSettingsToProto(n *data_access.NotificationSettings) *pb.NotificationSettings {
	if n == nil {
		return nil
	}
	return &pb.NotificationSettings{
		PushEnabled:       n.PushEnabled,
		EmailEnabled:      n.EmailEnabled,
		NotifyNewFollower: n.NotifyNewFollower,
		NotifyLike:        n.NotifyLike,
		NotifyComment:     n.NotifyComment,
		NotifyMention:     n.NotifyMention,
		NotifyRepost:      n.NotifyRepost,
		NotifyMessage:     n.NotifyMessage,
	}
}

// ============================================================================
// Proto 反向转换器
// ============================================================================

// protoToPrivacySettings 从 Proto 转换隐私设置
func protoToPrivacySettings(userID string, p *pb.PrivacySettings) *data_access.PrivacySettings {
	if p == nil {
		return nil
	}
	return &data_access.PrivacySettings{
		UserID:                 userID,
		IsPrivateAccount:       p.IsPrivateAccount,
		AllowMessageFromAnyone: p.AllowMessageFromAnyone,
		ShowOnlineStatus:       p.ShowOnlineStatus,
		ShowLastSeen:           p.ShowLastSeen,
		AllowTagging:           p.AllowTagging,
		ShowActivityStatus:     p.ShowActivityStatus,
	}
}

// protoToNotificationSettings 从 Proto 转换通知设置
func protoToNotificationSettings(userID string, n *pb.NotificationSettings) *data_access.NotificationSettings {
	if n == nil {
		return nil
	}
	return &data_access.NotificationSettings{
		UserID:            userID,
		PushEnabled:       n.PushEnabled,
		EmailEnabled:      n.EmailEnabled,
		NotifyNewFollower: n.NotifyNewFollower,
		NotifyLike:        n.NotifyLike,
		NotifyComment:     n.NotifyComment,
		NotifyMention:     n.NotifyMention,
		NotifyRepost:      n.NotifyRepost,
		NotifyMessage:     n.NotifyMessage,
	}
}

// ============================================================================
// 屏蔽类型转换
// ============================================================================

// blockTypeToProto 将屏蔽类型转换为 Proto
func blockTypeToProto(bt data_access.BlockType) pb.BlockType {
	switch bt {
	case data_access.BlockTypeHidePosts:
		return pb.BlockType_BLOCK_TYPE_HIDE_POSTS
	case data_access.BlockTypeHideMe:
		return pb.BlockType_BLOCK_TYPE_HIDE_ME
	case data_access.BlockTypeBlock:
		return pb.BlockType_BLOCK_TYPE_BLOCK
	default:
		return pb.BlockType_BLOCK_TYPE_UNSPECIFIED
	}
}

// protoToBlockType 从 Proto 转换屏蔽类型
func protoToBlockType(bt pb.BlockType) data_access.BlockType {
	switch bt {
	case pb.BlockType_BLOCK_TYPE_HIDE_POSTS:
		return data_access.BlockTypeHidePosts
	case pb.BlockType_BLOCK_TYPE_HIDE_ME:
		return data_access.BlockTypeHideMe
	case pb.BlockType_BLOCK_TYPE_BLOCK:
		return data_access.BlockTypeBlock
	default:
		return data_access.BlockTypeUnspecified
	}
}

// ============================================================================
// 辅助方法
// ============================================================================

// getPagination 获取分页参数
func getPagination(p *common.Pagination) (page, pageSize int32) {
	page, pageSize = int32(1), int32(20)
	if p != nil {
		if p.Page > 0 {
			page = p.Page
		}
		if p.PageSize > 0 {
			pageSize = p.PageSize
		}
		if pageSize > 100 {
			pageSize = 100
		}
	}
	return
}

// handleError 处理错误并转换为 gRPC 错误
func (h *UserHandler) handleError(err error) error {
	return logic.ToGRPCError(err)
}
