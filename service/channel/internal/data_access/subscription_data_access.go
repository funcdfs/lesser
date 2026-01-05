// Package data_access 订阅数据访问层
package data_access

import (
	"context"
	"database/sql"
	"time"
)

// SubscriptionDataAccess 订阅数据访问接口
type SubscriptionDataAccess interface {
	// Subscribe 订阅频道
	Subscribe(ctx context.Context, channelID, userID string) error
	// Unsubscribe 取消订阅
	Unsubscribe(ctx context.Context, channelID, userID string) error
	// GetSubscribers 获取订阅者列表
	GetSubscribers(ctx context.Context, channelID string, offset, limit int) ([]string, error)
	// GetSubscribedChannels 获取用户订阅的频道列表
	GetSubscribedChannels(ctx context.Context, userID string, offset, limit int) ([]string, error)
	// IsSubscribed 检查是否已订阅
	IsSubscribed(ctx context.Context, channelID, userID string) (bool, error)
	// GetSubscriberCount 获取订阅者数量
	GetSubscriberCount(ctx context.Context, channelID string) (int64, error)
}

// subscriptionDataAccess 订阅数据访问实现
type subscriptionDataAccess struct {
	db *sql.DB
}

// NewSubscriptionDataAccess 创建订阅数据访问
func NewSubscriptionDataAccess(db *sql.DB) SubscriptionDataAccess {
	return &subscriptionDataAccess{db: db}
}

// Subscribe 订阅频道
func (r *subscriptionDataAccess) Subscribe(ctx context.Context, channelID, userID string) error {
	// 检查是否已订阅
	isSubscribed, err := r.IsSubscribed(ctx, channelID, userID)
	if err != nil {
		return err
	}
	if isSubscribed {
		return ErrAlreadySubscribed
	}

	_, err = r.db.ExecContext(ctx, `
		INSERT INTO channel_subscriptions (channel_id, user_id, created_at)
		VALUES ($1, $2, $3)
	`, channelID, userID, time.Now())

	return err
}

// Unsubscribe 取消订阅
func (r *subscriptionDataAccess) Unsubscribe(ctx context.Context, channelID, userID string) error {
	result, err := r.db.ExecContext(ctx, `
		DELETE FROM channel_subscriptions 
		WHERE channel_id = $1 AND user_id = $2
	`, channelID, userID)

	if err != nil {
		return err
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rows == 0 {
		return ErrNotSubscribed
	}

	return nil
}

// GetSubscribers 获取订阅者列表
func (r *subscriptionDataAccess) GetSubscribers(ctx context.Context, channelID string, offset, limit int) ([]string, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT user_id 
		FROM channel_subscriptions 
		WHERE channel_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`, channelID, limit, offset)

	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var subscribers []string
	for rows.Next() {
		var userID string
		if err := rows.Scan(&userID); err != nil {
			return nil, err
		}
		subscribers = append(subscribers, userID)
	}

	return subscribers, rows.Err()
}

// GetSubscribedChannels 获取用户订阅的频道列表
func (r *subscriptionDataAccess) GetSubscribedChannels(ctx context.Context, userID string, offset, limit int) ([]string, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT channel_id 
		FROM channel_subscriptions 
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`, userID, limit, offset)

	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var channelIDs []string
	for rows.Next() {
		var channelID string
		if err := rows.Scan(&channelID); err != nil {
			return nil, err
		}
		channelIDs = append(channelIDs, channelID)
	}

	return channelIDs, rows.Err()
}

// IsSubscribed 检查是否已订阅
func (r *subscriptionDataAccess) IsSubscribed(ctx context.Context, channelID, userID string) (bool, error) {
	var exists bool
	err := r.db.QueryRowContext(ctx, `
		SELECT EXISTS(
			SELECT 1 FROM channel_subscriptions 
			WHERE channel_id = $1 AND user_id = $2
		)
	`, channelID, userID).Scan(&exists)
	return exists, err
}

// GetSubscriberCount 获取订阅者数量
func (r *subscriptionDataAccess) GetSubscriberCount(ctx context.Context, channelID string) (int64, error) {
	var count int64
	err := r.db.QueryRowContext(ctx, `
		SELECT COUNT(*) 
		FROM channel_subscriptions 
		WHERE channel_id = $1
	`, channelID).Scan(&count)
	return count, err
}
