// Package service 提供通知业务逻辑层
package service

import (
	"context"
	"fmt"

	"github.com/funcdfs/lesser/notification/internal/repository"
)

// NotificationService 通知服务
type NotificationService struct {
	notifRepo *repository.NotificationRepository
}

// NewNotificationService 创建通知服务实例
func NewNotificationService(notifRepo *repository.NotificationRepository) *NotificationService {
	return &NotificationService{notifRepo: notifRepo}
}

// Create 创建通知
func (s *NotificationService) Create(ctx context.Context, userID string, notifType int32, actorID, targetType, targetID, message string) (*repository.Notification, error) {
	// 不给自己发通知
	if userID == actorID {
		return nil, nil
	}

	// 检查重复通知（幂等性）
	exists, err := s.notifRepo.CheckDuplicate(ctx, userID, actorID, targetID, notifType)
	if err != nil {
		return nil, fmt.Errorf("检查重复通知失败: %w", err)
	}
	if exists {
		return nil, nil // 已存在，跳过
	}

	notif := &repository.Notification{
		UserID:     userID,
		Type:       notifType,
		ActorID:    actorID,
		TargetType: targetType,
		TargetID:   targetID,
		Message:    message,
	}
	if err := s.notifRepo.Create(ctx, notif); err != nil {
		return nil, fmt.Errorf("创建通知失败: %w", err)
	}
	return notif, nil
}

// CreateLikeNotification 创建点赞通知
func (s *NotificationService) CreateLikeNotification(ctx context.Context, contentAuthorID, likerID, contentID string) (*repository.Notification, error) {
	return s.Create(ctx, contentAuthorID, repository.NotificationTypeLike, likerID, repository.TargetTypeContent, contentID, "")
}

// CreateCommentNotification 创建评论通知
func (s *NotificationService) CreateCommentNotification(ctx context.Context, contentAuthorID, commenterID, contentID, commentText string) (*repository.Notification, error) {
	// 截取评论内容作为消息摘要
	message := truncateText(commentText, 100)
	return s.Create(ctx, contentAuthorID, repository.NotificationTypeComment, commenterID, repository.TargetTypeContent, contentID, message)
}

// CreateReplyNotification 创建回复通知
func (s *NotificationService) CreateReplyNotification(ctx context.Context, parentAuthorID, replierID, commentID, replyText string) (*repository.Notification, error) {
	message := truncateText(replyText, 100)
	return s.Create(ctx, parentAuthorID, repository.NotificationTypeReply, replierID, repository.TargetTypeComment, commentID, message)
}

// CreateBookmarkNotification 创建收藏通知
func (s *NotificationService) CreateBookmarkNotification(ctx context.Context, contentAuthorID, bookmarkerID, contentID string) (*repository.Notification, error) {
	return s.Create(ctx, contentAuthorID, repository.NotificationTypeBookmark, bookmarkerID, repository.TargetTypeContent, contentID, "")
}

// CreateFollowNotification 创建关注通知
func (s *NotificationService) CreateFollowNotification(ctx context.Context, followingID, followerID string) (*repository.Notification, error) {
	return s.Create(ctx, followingID, repository.NotificationTypeFollow, followerID, repository.TargetTypeUser, followerID, "")
}

// CreateRepostNotification 创建转发通知
func (s *NotificationService) CreateRepostNotification(ctx context.Context, contentAuthorID, reposterID, contentID string) (*repository.Notification, error) {
	return s.Create(ctx, contentAuthorID, repository.NotificationTypeRepost, reposterID, repository.TargetTypeContent, contentID, "")
}

// CreateMentionNotification 创建 @ 提及通知
func (s *NotificationService) CreateMentionNotification(ctx context.Context, mentionedUserID, mentionerID, targetType, targetID string) (*repository.Notification, error) {
	return s.Create(ctx, mentionedUserID, repository.NotificationTypeMention, mentionerID, targetType, targetID, "")
}

// List 获取用户通知列表
func (s *NotificationService) List(ctx context.Context, userID string, unreadOnly bool, limit, offset int) ([]*repository.Notification, int, error) {
	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}
	return s.notifRepo.List(ctx, userID, unreadOnly, limit, offset)
}

// MarkAsRead 标记单条通知为已读
func (s *NotificationService) MarkAsRead(ctx context.Context, id, userID string) error {
	return s.notifRepo.MarkAsReadByUser(ctx, id, userID)
}

// MarkAllAsRead 标记用户所有通知为已读
func (s *NotificationService) MarkAllAsRead(ctx context.Context, userID string) (int64, error) {
	return s.notifRepo.MarkAllAsRead(ctx, userID)
}

// GetUnreadCount 获取用户未读通知数量
func (s *NotificationService) GetUnreadCount(ctx context.Context, userID string) (int64, error) {
	return s.notifRepo.GetUnreadCount(ctx, userID)
}

// truncateText 截取文本，超过指定长度时添加省略号
func truncateText(text string, maxLen int) string {
	runes := []rune(text)
	if len(runes) <= maxLen {
		return text
	}
	return string(runes[:maxLen-3]) + "..."
}
