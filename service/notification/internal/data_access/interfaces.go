// Package data_access 提供通知服务的数据访问层
package data_access

import (
	"context"
	"time"
)

// ============================================================================
// 数据实体
// ============================================================================

// Notification 通知实体
type Notification struct {
	ID         string    // 通知 ID（UUID）
	UserID     string    // 接收通知的用户 ID
	Type       int32     // 通知类型（见 NotificationType* 常量）
	ActorID    string    // 触发通知的用户 ID
	TargetType string    // 目标类型（content/comment/user）
	TargetID   string    // 目标 ID
	Message    string    // 通知消息（可选，如评论内容摘要）
	IsRead     bool      // 是否已读
	CreatedAt  time.Time // 创建时间
}

// ============================================================================
// 数据访问接口
// ============================================================================

// NotificationDataAccessInterface 通知数据访问接口
// 定义通知数据的 CRUD 操作
type NotificationDataAccessInterface interface {
	// Create 创建通知
	Create(ctx context.Context, notif *Notification) error

	// GetByID 根据 ID 获取通知
	GetByID(ctx context.Context, id string) (*Notification, error)

	// List 获取用户通知列表
	// unreadOnly: 是否只返回未读通知
	List(ctx context.Context, userID string, unreadOnly bool, limit, offset int) ([]*Notification, int, error)

	// MarkAsRead 标记单条通知为已读
	MarkAsRead(ctx context.Context, id string) error

	// MarkAsReadByUser 标记单条通知为已读（验证用户所有权）
	MarkAsReadByUser(ctx context.Context, id, userID string) error

	// MarkAllAsRead 标记用户所有通知为已读
	// 返回实际更新的通知数量
	MarkAllAsRead(ctx context.Context, userID string) (int64, error)

	// GetUnreadCount 获取用户未读通知数量
	GetUnreadCount(ctx context.Context, userID string) (int64, error)

	// Delete 删除通知
	Delete(ctx context.Context, id string) error

	// DeleteByUser 删除用户的所有通知
	DeleteByUser(ctx context.Context, userID string) error

	// CheckDuplicate 检查是否存在重复通知（幂等性检查）
	// 同一个 actor 对同一个 target 的同类型通知不应重复创建
	CheckDuplicate(ctx context.Context, userID, actorID, targetID string, notifType int32) (bool, error)
}
