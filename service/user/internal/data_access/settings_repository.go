// Package repository 提供用户服务的数据访问层
package data_access

import (
	"context"
	"database/sql"
	"time"
)

// SettingsRepository 用户设置数据仓库
type SettingsRepository struct {
	db *sql.DB
}

// NewSettingsRepository 创建设置仓库实例
func NewSettingsRepository(db *sql.DB) *SettingsRepository {
	return &SettingsRepository{db: db}
}

// ============================================================================
// 隐私设置
// ============================================================================

// GetPrivacySettings 获取隐私设置
func (r *SettingsRepository) GetPrivacySettings(ctx context.Context, userID string) (*PrivacySettings, error) {
	settings := &PrivacySettings{}
	err := r.db.QueryRowContext(ctx, `
		SELECT user_id, is_private_account, allow_message_from_anyone, 
		       show_online_status, show_last_seen, allow_tagging, show_activity_status,
		       created_at, updated_at
		FROM user_privacy_settings WHERE user_id = $1
	`, userID).Scan(
		&settings.UserID, &settings.IsPrivateAccount, &settings.AllowMessageFromAnyone,
		&settings.ShowOnlineStatus, &settings.ShowLastSeen, &settings.AllowTagging,
		&settings.ShowActivityStatus, &settings.CreatedAt, &settings.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		// 返回默认设置
		return DefaultPrivacySettings(userID), nil
	}
	return settings, err
}

// UpsertPrivacySettings 创建或更新隐私设置
func (r *SettingsRepository) UpsertPrivacySettings(ctx context.Context, settings *PrivacySettings) error {
	now := time.Now()
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO user_privacy_settings (
			user_id, is_private_account, allow_message_from_anyone,
			show_online_status, show_last_seen, allow_tagging, show_activity_status,
			created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $8)
		ON CONFLICT (user_id) DO UPDATE SET
			is_private_account = $2,
			allow_message_from_anyone = $3,
			show_online_status = $4,
			show_last_seen = $5,
			allow_tagging = $6,
			show_activity_status = $7,
			updated_at = $8
	`, settings.UserID, settings.IsPrivateAccount, settings.AllowMessageFromAnyone,
		settings.ShowOnlineStatus, settings.ShowLastSeen, settings.AllowTagging,
		settings.ShowActivityStatus, now)
	return err
}

// UpdatePrivacySettings 部分更新隐私设置
func (r *SettingsRepository) UpdatePrivacySettings(ctx context.Context, userID string, updates map[string]interface{}) error {
	// 先获取现有设置
	settings, err := r.GetPrivacySettings(ctx, userID)
	if err != nil {
		return err
	}

	// 应用更新
	if v, ok := updates["is_private_account"]; ok {
		settings.IsPrivateAccount = v.(bool)
	}
	if v, ok := updates["allow_message_from_anyone"]; ok {
		settings.AllowMessageFromAnyone = v.(bool)
	}
	if v, ok := updates["show_online_status"]; ok {
		settings.ShowOnlineStatus = v.(bool)
	}
	if v, ok := updates["show_last_seen"]; ok {
		settings.ShowLastSeen = v.(bool)
	}
	if v, ok := updates["allow_tagging"]; ok {
		settings.AllowTagging = v.(bool)
	}
	if v, ok := updates["show_activity_status"]; ok {
		settings.ShowActivityStatus = v.(bool)
	}

	return r.UpsertPrivacySettings(ctx, settings)
}

// ============================================================================
// 通知设置
// ============================================================================

// GetNotificationSettings 获取通知设置
func (r *SettingsRepository) GetNotificationSettings(ctx context.Context, userID string) (*NotificationSettings, error) {
	settings := &NotificationSettings{}
	err := r.db.QueryRowContext(ctx, `
		SELECT user_id, push_enabled, email_enabled, 
		       notify_new_follower, notify_like, notify_comment,
		       notify_mention, notify_repost, notify_message,
		       created_at, updated_at
		FROM user_notification_settings WHERE user_id = $1
	`, userID).Scan(
		&settings.UserID, &settings.PushEnabled, &settings.EmailEnabled,
		&settings.NotifyNewFollower, &settings.NotifyLike, &settings.NotifyComment,
		&settings.NotifyMention, &settings.NotifyRepost, &settings.NotifyMessage,
		&settings.CreatedAt, &settings.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		// 返回默认设置
		return DefaultNotificationSettings(userID), nil
	}
	return settings, err
}

// UpsertNotificationSettings 创建或更新通知设置
func (r *SettingsRepository) UpsertNotificationSettings(ctx context.Context, settings *NotificationSettings) error {
	now := time.Now()
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO user_notification_settings (
			user_id, push_enabled, email_enabled,
			notify_new_follower, notify_like, notify_comment,
			notify_mention, notify_repost, notify_message,
			created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $10)
		ON CONFLICT (user_id) DO UPDATE SET
			push_enabled = $2,
			email_enabled = $3,
			notify_new_follower = $4,
			notify_like = $5,
			notify_comment = $6,
			notify_mention = $7,
			notify_repost = $8,
			notify_message = $9,
			updated_at = $10
	`, settings.UserID, settings.PushEnabled, settings.EmailEnabled,
		settings.NotifyNewFollower, settings.NotifyLike, settings.NotifyComment,
		settings.NotifyMention, settings.NotifyRepost, settings.NotifyMessage, now)
	return err
}

// UpdateNotificationSettings 部分更新通知设置
func (r *SettingsRepository) UpdateNotificationSettings(ctx context.Context, userID string, updates map[string]interface{}) error {
	// 先获取现有设置
	settings, err := r.GetNotificationSettings(ctx, userID)
	if err != nil {
		return err
	}

	// 应用更新
	if v, ok := updates["push_enabled"]; ok {
		settings.PushEnabled = v.(bool)
	}
	if v, ok := updates["email_enabled"]; ok {
		settings.EmailEnabled = v.(bool)
	}
	if v, ok := updates["notify_new_follower"]; ok {
		settings.NotifyNewFollower = v.(bool)
	}
	if v, ok := updates["notify_like"]; ok {
		settings.NotifyLike = v.(bool)
	}
	if v, ok := updates["notify_comment"]; ok {
		settings.NotifyComment = v.(bool)
	}
	if v, ok := updates["notify_mention"]; ok {
		settings.NotifyMention = v.(bool)
	}
	if v, ok := updates["notify_repost"]; ok {
		settings.NotifyRepost = v.(bool)
	}
	if v, ok := updates["notify_message"]; ok {
		settings.NotifyMessage = v.(bool)
	}

	return r.UpsertNotificationSettings(ctx, settings)
}

// ============================================================================
// 完整设置
// ============================================================================

// GetUserSettings 获取用户完整设置
func (r *SettingsRepository) GetUserSettings(ctx context.Context, userID string) (*UserSettings, error) {
	privacy, err := r.GetPrivacySettings(ctx, userID)
	if err != nil {
		return nil, err
	}

	notification, err := r.GetNotificationSettings(ctx, userID)
	if err != nil {
		return nil, err
	}

	return &UserSettings{
		UserID:       userID,
		Privacy:      privacy,
		Notification: notification,
	}, nil
}

// InitializeUserSettings 初始化用户设置（新用户注册时调用）
func (r *SettingsRepository) InitializeUserSettings(ctx context.Context, userID string) error {
	// 创建默认隐私设置
	if err := r.UpsertPrivacySettings(ctx, DefaultPrivacySettings(userID)); err != nil {
		return err
	}

	// 创建默认通知设置
	return r.UpsertNotificationSettings(ctx, DefaultNotificationSettings(userID))
}

// IsPrivateAccount 检查用户是否为私密账户
func (r *SettingsRepository) IsPrivateAccount(ctx context.Context, userID string) (bool, error) {
	var isPrivate bool
	err := r.db.QueryRowContext(ctx, `
		SELECT COALESCE(
			(SELECT is_private_account FROM user_privacy_settings WHERE user_id = $1),
			(SELECT is_private FROM users WHERE id = $1),
			false
		)
	`, userID).Scan(&isPrivate)
	return isPrivate, err
}
