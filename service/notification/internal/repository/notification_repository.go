// Package repository 提供通知数据访问层
package repository

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"github.com/google/uuid"
)

// 通知类型常量
const (
	NotificationTypeLike     int32 = 1 // 点赞
	NotificationTypeComment  int32 = 2 // 评论
	NotificationTypeReply    int32 = 3 // 回复
	NotificationTypeBookmark int32 = 4 // 收藏
	NotificationTypeMention  int32 = 5 // @提及
	NotificationTypeFollow   int32 = 6 // 关注
	NotificationTypeRepost   int32 = 7 // 转发
)

// 目标类型常量
const (
	TargetTypeContent = "content" // 内容
	TargetTypeComment = "comment" // 评论
	TargetTypeUser    = "user"    // 用户
)

// 错误定义
var (
	ErrNotificationNotFound = errors.New("notification not found")
)

// Notification 通知实体
type Notification struct {
	ID         string
	UserID     string
	Type       int32
	ActorID    string
	TargetType string // 目标类型: content, comment, user
	TargetID   string
	Message    string
	IsRead     bool
	CreatedAt  time.Time
}

// NotificationRepository 通知数据仓库
type NotificationRepository struct {
	db *sql.DB
}

// NewNotificationRepository 创建通知仓库实例
func NewNotificationRepository(db *sql.DB) *NotificationRepository {
	return &NotificationRepository{db: db}
}

// Create 创建通知
func (r *NotificationRepository) Create(ctx context.Context, notif *Notification) error {
	notif.ID = uuid.New().String()
	notif.CreatedAt = time.Now()
	notif.IsRead = false

	_, err := r.db.ExecContext(ctx, `
		INSERT INTO notifications (id, user_id, type, actor_id, target_type, target_id, message, is_read, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
	`, notif.ID, notif.UserID, notif.Type, nullString(notif.ActorID), nullString(notif.TargetType),
		nullString(notif.TargetID), nullString(notif.Message), notif.IsRead, notif.CreatedAt)
	return err
}

// GetByID 根据 ID 获取通知
func (r *NotificationRepository) GetByID(ctx context.Context, id string) (*Notification, error) {
	n := &Notification{}
	var actorID, targetType, targetID, message sql.NullString

	err := r.db.QueryRowContext(ctx, `
		SELECT id, user_id, type, actor_id, target_type, target_id, message, is_read, created_at
		FROM notifications WHERE id = $1
	`, id).Scan(&n.ID, &n.UserID, &n.Type, &actorID, &targetType, &targetID, &message, &n.IsRead, &n.CreatedAt)

	if err == sql.ErrNoRows {
		return nil, ErrNotificationNotFound
	}
	if err != nil {
		return nil, err
	}

	n.ActorID = actorID.String
	n.TargetType = targetType.String
	n.TargetID = targetID.String
	n.Message = message.String
	return n, nil
}

// List 获取用户通知列表
func (r *NotificationRepository) List(ctx context.Context, userID string, unreadOnly bool, limit, offset int) ([]*Notification, int, error) {
	// 获取总数
	var total int
	countQuery := `SELECT COUNT(*) FROM notifications WHERE user_id = $1`
	if unreadOnly {
		countQuery += ` AND is_read = false`
	}
	if err := r.db.QueryRowContext(ctx, countQuery, userID).Scan(&total); err != nil {
		return nil, 0, err
	}

	// 获取列表
	query := `
		SELECT id, user_id, type, actor_id, target_type, target_id, message, is_read, created_at
		FROM notifications WHERE user_id = $1`
	if unreadOnly {
		query += ` AND is_read = false`
	}
	query += ` ORDER BY created_at DESC LIMIT $2 OFFSET $3`

	rows, err := r.db.QueryContext(ctx, query, userID, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var notifications []*Notification
	for rows.Next() {
		n := &Notification{}
		var actorID, targetType, targetID, message sql.NullString
		if err := rows.Scan(&n.ID, &n.UserID, &n.Type, &actorID, &targetType, &targetID, &message, &n.IsRead, &n.CreatedAt); err != nil {
			return nil, 0, err
		}
		n.ActorID = actorID.String
		n.TargetType = targetType.String
		n.TargetID = targetID.String
		n.Message = message.String
		notifications = append(notifications, n)
	}

	if err := rows.Err(); err != nil {
		return nil, 0, err
	}

	return notifications, total, nil
}

// MarkAsRead 标记单条通知为已读
func (r *NotificationRepository) MarkAsRead(ctx context.Context, id string) error {
	result, err := r.db.ExecContext(ctx, `UPDATE notifications SET is_read = true WHERE id = $1`, id)
	if err != nil {
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rowsAffected == 0 {
		return ErrNotificationNotFound
	}
	return nil
}

// MarkAsReadByUser 标记单条通知为已读（验证用户所有权）
func (r *NotificationRepository) MarkAsReadByUser(ctx context.Context, id, userID string) error {
	result, err := r.db.ExecContext(ctx, `UPDATE notifications SET is_read = true WHERE id = $1 AND user_id = $2`, id, userID)
	if err != nil {
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rowsAffected == 0 {
		return ErrNotificationNotFound
	}
	return nil
}

// MarkAllAsRead 标记用户所有通知为已读
func (r *NotificationRepository) MarkAllAsRead(ctx context.Context, userID string) (int64, error) {
	result, err := r.db.ExecContext(ctx, `UPDATE notifications SET is_read = true WHERE user_id = $1 AND is_read = false`, userID)
	if err != nil {
		return 0, err
	}
	return result.RowsAffected()
}

// GetUnreadCount 获取用户未读通知数量
func (r *NotificationRepository) GetUnreadCount(ctx context.Context, userID string) (int64, error) {
	var count int64
	err := r.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND is_read = false`, userID).Scan(&count)
	return count, err
}

// Delete 删除通知
func (r *NotificationRepository) Delete(ctx context.Context, id string) error {
	_, err := r.db.ExecContext(ctx, `DELETE FROM notifications WHERE id = $1`, id)
	return err
}

// DeleteByUser 删除用户的所有通知
func (r *NotificationRepository) DeleteByUser(ctx context.Context, userID string) error {
	_, err := r.db.ExecContext(ctx, `DELETE FROM notifications WHERE user_id = $1`, userID)
	return err
}

// CheckDuplicate 检查是否存在重复通知（防止重复创建）
// 用于幂等性检查：同一个 actor 对同一个 target 的同类型通知
func (r *NotificationRepository) CheckDuplicate(ctx context.Context, userID, actorID, targetID string, notifType int32) (bool, error) {
	var exists bool
	err := r.db.QueryRowContext(ctx, `
		SELECT EXISTS(
			SELECT 1 FROM notifications 
			WHERE user_id = $1 AND actor_id = $2 AND target_id = $3 AND type = $4
		)
	`, userID, actorID, targetID, notifType).Scan(&exists)
	return exists, err
}

// nullString 将空字符串转换为 sql.NullString
func nullString(s string) sql.NullString {
	if s == "" {
		return sql.NullString{}
	}
	return sql.NullString{String: s, Valid: true}
}
