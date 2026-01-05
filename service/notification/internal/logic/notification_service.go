// Package logic 提供通知服务的业务逻辑层
// 负责通知的创建、查询、标记已读等核心业务规则
package logic

import (
	"context"
	"fmt"

	"github.com/funcdfs/lesser/notification/internal/data_access"
)

// ============================================================================
// 服务实现
// ============================================================================

// NotificationService 通知服务
// 提供通知管理的业务逻辑
type NotificationService struct {
	notifDA data_access.NotificationDataAccessInterface
}

// NewNotificationService 创建通知服务实例
func NewNotificationService(notifDA data_access.NotificationDataAccessInterface) *NotificationService {
	return &NotificationService{notifDA: notifDA}
}

// ============================================================================
// 通知创建
// ============================================================================

// Create 创建通知
// 幂等操作：同一个 actor 对同一个 target 的同类型通知不会重复创建
// 自我通知过滤：不会给自己发通知
func (s *NotificationService) Create(ctx context.Context, userID string, notifType int32, actorID, targetType, targetID, message string) (*data_access.Notification, error) {
	// 参数验证
	if userID == "" {
		return nil, ErrInvalidInput
	}

	// 不给自己发通知
	if userID == actorID {
		return nil, nil
	}

	// 检查重复通知（幂等性）
	exists, err := s.notifDA.CheckDuplicate(ctx, userID, actorID, targetID, notifType)
	if err != nil {
		return nil, fmt.Errorf("检查重复通知失败: %w", err)
	}
	if exists {
		return nil, nil // 已存在，跳过
	}

	notif := &data_access.Notification{
		UserID:     userID,
		Type:       notifType,
		ActorID:    actorID,
		TargetType: targetType,
		TargetID:   targetID,
		Message:    message,
	}
	if err := s.notifDA.Create(ctx, notif); err != nil {
		return nil, fmt.Errorf("创建通知失败: %w", err)
	}
	return notif, nil
}

// CreateLikeNotification 创建点赞通知
// contentAuthorID: 内容作者（通知接收者）
// likerID: 点赞者（触发者）
// contentID: 被点赞的内容 ID
func (s *NotificationService) CreateLikeNotification(ctx context.Context, contentAuthorID, likerID, contentID string) (*data_access.Notification, error) {
	return s.Create(ctx, contentAuthorID, data_access.NotificationTypeLike, likerID, data_access.TargetTypeContent, contentID, "")
}

// CreateCommentNotification 创建评论通知
// contentAuthorID: 内容作者（通知接收者）
// commenterID: 评论者（触发者）
// contentID: 被评论的内容 ID
// commentText: 评论内容（会被截取作为消息摘要）
func (s *NotificationService) CreateCommentNotification(ctx context.Context, contentAuthorID, commenterID, contentID, commentText string) (*data_access.Notification, error) {
	// 截取评论内容作为消息摘要
	message := truncateText(commentText, 100)
	return s.Create(ctx, contentAuthorID, data_access.NotificationTypeComment, commenterID, data_access.TargetTypeContent, contentID, message)
}

// CreateReplyNotification 创建回复通知
// parentAuthorID: 父评论作者（通知接收者）
// replierID: 回复者（触发者）
// commentID: 回复的评论 ID
// replyText: 回复内容（会被截取作为消息摘要）
func (s *NotificationService) CreateReplyNotification(ctx context.Context, parentAuthorID, replierID, commentID, replyText string) (*data_access.Notification, error) {
	message := truncateText(replyText, 100)
	return s.Create(ctx, parentAuthorID, data_access.NotificationTypeReply, replierID, data_access.TargetTypeComment, commentID, message)
}

// CreateBookmarkNotification 创建收藏通知
// contentAuthorID: 内容作者（通知接收者）
// bookmarkerID: 收藏者（触发者）
// contentID: 被收藏的内容 ID
func (s *NotificationService) CreateBookmarkNotification(ctx context.Context, contentAuthorID, bookmarkerID, contentID string) (*data_access.Notification, error) {
	return s.Create(ctx, contentAuthorID, data_access.NotificationTypeBookmark, bookmarkerID, data_access.TargetTypeContent, contentID, "")
}

// CreateFollowNotification 创建关注通知
// followingID: 被关注者（通知接收者）
// followerID: 关注者（触发者）
func (s *NotificationService) CreateFollowNotification(ctx context.Context, followingID, followerID string) (*data_access.Notification, error) {
	return s.Create(ctx, followingID, data_access.NotificationTypeFollow, followerID, data_access.TargetTypeUser, followerID, "")
}

// CreateRepostNotification 创建转发通知
// contentAuthorID: 内容作者（通知接收者）
// reposterID: 转发者（触发者）
// contentID: 被转发的内容 ID
func (s *NotificationService) CreateRepostNotification(ctx context.Context, contentAuthorID, reposterID, contentID string) (*data_access.Notification, error) {
	return s.Create(ctx, contentAuthorID, data_access.NotificationTypeRepost, reposterID, data_access.TargetTypeContent, contentID, "")
}

// CreateMentionNotification 创建 @ 提及通知
// mentionedUserID: 被 @ 的用户（通知接收者）
// mentionerID: @ 发起者（触发者）
// targetType: 目标类型（content 或 comment）
// targetID: 目标 ID
func (s *NotificationService) CreateMentionNotification(ctx context.Context, mentionedUserID, mentionerID, targetType, targetID string) (*data_access.Notification, error) {
	return s.Create(ctx, mentionedUserID, data_access.NotificationTypeMention, mentionerID, targetType, targetID, "")
}

// CreateCommentLikeNotification 创建评论点赞通知
// commentAuthorID: 评论作者（通知接收者）
// likerID: 点赞者（触发者）
// commentID: 被点赞的评论 ID
func (s *NotificationService) CreateCommentLikeNotification(ctx context.Context, commentAuthorID, likerID, commentID string) (*data_access.Notification, error) {
	return s.Create(ctx, commentAuthorID, data_access.NotificationTypeLike, likerID, data_access.TargetTypeComment, commentID, "")
}

// ============================================================================
// 通知查询
// ============================================================================

// List 获取用户通知列表
// unreadOnly: 是否只返回未读通知
// limit: 每页数量，默认 20，最大 100
// offset: 偏移量
func (s *NotificationService) List(ctx context.Context, userID string, unreadOnly bool, limit, offset int) ([]*data_access.Notification, int, error) {
	if userID == "" {
		return nil, 0, ErrInvalidInput
	}

	// 参数边界处理
	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}
	if offset < 0 {
		offset = 0
	}

	return s.notifDA.List(ctx, userID, unreadOnly, limit, offset)
}

// GetUnreadCount 获取用户未读通知数量
func (s *NotificationService) GetUnreadCount(ctx context.Context, userID string) (int64, error) {
	if userID == "" {
		return 0, ErrInvalidInput
	}
	return s.notifDA.GetUnreadCount(ctx, userID)
}

// ============================================================================
// 通知状态管理
// ============================================================================

// MarkAsRead 标记单条通知为已读
// 验证用户所有权：只有通知的接收者才能标记为已读
func (s *NotificationService) MarkAsRead(ctx context.Context, id, userID string) error {
	if id == "" || userID == "" {
		return ErrInvalidInput
	}
	return s.notifDA.MarkAsReadByUser(ctx, id, userID)
}

// MarkAllAsRead 标记用户所有通知为已读
// 返回实际更新的通知数量
func (s *NotificationService) MarkAllAsRead(ctx context.Context, userID string) (int64, error) {
	if userID == "" {
		return 0, ErrInvalidInput
	}
	return s.notifDA.MarkAllAsRead(ctx, userID)
}

// ============================================================================
// 辅助函数
// ============================================================================

// truncateText 截取文本，超过指定长度时添加省略号
// 按 Unicode 字符（rune）截取，正确处理中文等多字节字符
func truncateText(text string, maxLen int) string {
	if maxLen <= 3 {
		return text
	}

	runes := []rune(text)
	if len(runes) <= maxLen {
		return text
	}
	return string(runes[:maxLen-3]) + "..."
}
