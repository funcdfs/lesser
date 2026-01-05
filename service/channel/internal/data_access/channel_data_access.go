// Package data_access Channel 数据访问层
package data_access

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
)

// ChannelDataAccess 频道数据访问接口
type ChannelDataAccess interface {
	// Create 创建频道
	Create(ctx context.Context, channel *Channel) error
	// GetByID 根据 ID 获取频道
	GetByID(ctx context.Context, id string) (*Channel, error)
	// Update 更新频道
	Update(ctx context.Context, channel *Channel) error
	// Delete 删除频道（软删除）
	Delete(ctx context.Context, id string) error
	// List 获取频道列表
	List(ctx context.Context, offset, limit int) ([]*Channel, error)
	// GetByOwnerID 获取用户拥有的频道列表
	GetByOwnerID(ctx context.Context, ownerID string, offset, limit int) ([]*Channel, error)
	// IncrementSubscriberCount 增加订阅者数量
	IncrementSubscriberCount(ctx context.Context, channelID string) error
	// DecrementSubscriberCount 减少订阅者数量
	DecrementSubscriberCount(ctx context.Context, channelID string) error
	// IncrementPostCount 增加内容数量
	IncrementPostCount(ctx context.Context, channelID string) error
	// DecrementPostCount 减少内容数量
	DecrementPostCount(ctx context.Context, channelID string) error
	// GetAdmins 获取频道管理员列表
	GetAdmins(ctx context.Context, channelID string) ([]string, error)
	// AddAdmin 添加管理员
	AddAdmin(ctx context.Context, channelID, userID string) error
	// RemoveAdmin 移除管理员
	RemoveAdmin(ctx context.Context, channelID, userID string) error
	// IsAdmin 检查是否为管理员
	IsAdmin(ctx context.Context, channelID, userID string) (bool, error)
}

// Channel 频道实体
type Channel struct {
	ID              string
	Name            string
	Description     string
	AvatarURL       string
	OwnerID         string
	SubscriberCount int64
	PostCount       int64
	CreatedAt       time.Time
	UpdatedAt       time.Time
	DeletedAt       sql.NullTime
}

// channelDataAccess 频道数据访问实现
type channelDataAccess struct {
	db *sql.DB
}

// NewChannelDataAccess 创建频道数据访问
func NewChannelDataAccess(db *sql.DB) ChannelDataAccess {
	return &channelDataAccess{db: db}
}

// Create 创建频道
func (r *channelDataAccess) Create(ctx context.Context, channel *Channel) error {
	channel.ID = uuid.New().String()
	channel.CreatedAt = time.Now()
	channel.UpdatedAt = time.Now()

	_, err := r.db.ExecContext(ctx, `
		INSERT INTO channels (id, name, description, avatar_url, owner_id, 
			subscriber_count, post_count, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
	`, channel.ID, channel.Name, channel.Description, channel.AvatarURL, channel.OwnerID,
		channel.SubscriberCount, channel.PostCount, channel.CreatedAt, channel.UpdatedAt)

	if err != nil {
		return err
	}

	// 自动将创建者添加为管理员
	return r.AddAdmin(ctx, channel.ID, channel.OwnerID)
}

// GetByID 根据 ID 获取频道
func (r *channelDataAccess) GetByID(ctx context.Context, id string) (*Channel, error) {
	channel := &Channel{}
	var description, avatarURL sql.NullString

	err := r.db.QueryRowContext(ctx, `
		SELECT id, name, description, avatar_url, owner_id, 
			subscriber_count, post_count, created_at, updated_at, deleted_at
		FROM channels 
		WHERE id = $1 AND deleted_at IS NULL
	`, id).Scan(
		&channel.ID, &channel.Name, &description, &avatarURL, &channel.OwnerID,
		&channel.SubscriberCount, &channel.PostCount, &channel.CreatedAt,
		&channel.UpdatedAt, &channel.DeletedAt,
	)

	if err == sql.ErrNoRows {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, err
	}

	if description.Valid {
		channel.Description = description.String
	}
	if avatarURL.Valid {
		channel.AvatarURL = avatarURL.String
	}

	return channel, nil
}

// Update 更新频道
func (r *channelDataAccess) Update(ctx context.Context, channel *Channel) error {
	channel.UpdatedAt = time.Now()

	result, err := r.db.ExecContext(ctx, `
		UPDATE channels 
		SET name = $1, description = $2, avatar_url = $3, updated_at = $4
		WHERE id = $5 AND deleted_at IS NULL
	`, channel.Name, channel.Description, channel.AvatarURL, channel.UpdatedAt, channel.ID)

	if err != nil {
		return err
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rows == 0 {
		return ErrNotFound
	}

	return nil
}

// Delete 删除频道（软删除）
func (r *channelDataAccess) Delete(ctx context.Context, id string) error {
	result, err := r.db.ExecContext(ctx, `
		UPDATE channels 
		SET deleted_at = $1, updated_at = $1
		WHERE id = $2 AND deleted_at IS NULL
	`, time.Now(), id)

	if err != nil {
		return err
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rows == 0 {
		return ErrNotFound
	}

	return nil
}

// List 获取频道列表
func (r *channelDataAccess) List(ctx context.Context, offset, limit int) ([]*Channel, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT id, name, description, avatar_url, owner_id, 
			subscriber_count, post_count, created_at, updated_at, deleted_at
		FROM channels 
		WHERE deleted_at IS NULL
		ORDER BY subscriber_count DESC, created_at DESC
		LIMIT $1 OFFSET $2
	`, limit, offset)

	if err != nil {
		return nil, err
	}
	defer rows.Close()

	return r.scanChannels(rows)
}

// GetByOwnerID 获取用户拥有的频道列表
func (r *channelDataAccess) GetByOwnerID(ctx context.Context, ownerID string, offset, limit int) ([]*Channel, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT id, name, description, avatar_url, owner_id, 
			subscriber_count, post_count, created_at, updated_at, deleted_at
		FROM channels 
		WHERE owner_id = $1 AND deleted_at IS NULL
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`, ownerID, limit, offset)

	if err != nil {
		return nil, err
	}
	defer rows.Close()

	return r.scanChannels(rows)
}

// IncrementSubscriberCount 增加订阅者数量
func (r *channelDataAccess) IncrementSubscriberCount(ctx context.Context, channelID string) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE channels 
		SET subscriber_count = subscriber_count + 1, updated_at = NOW()
		WHERE id = $1 AND deleted_at IS NULL
	`, channelID)
	return err
}

// DecrementSubscriberCount 减少订阅者数量
func (r *channelDataAccess) DecrementSubscriberCount(ctx context.Context, channelID string) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE channels 
		SET subscriber_count = GREATEST(subscriber_count - 1, 0), updated_at = NOW()
		WHERE id = $1 AND deleted_at IS NULL
	`, channelID)
	return err
}

// IncrementPostCount 增加内容数量
func (r *channelDataAccess) IncrementPostCount(ctx context.Context, channelID string) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE channels 
		SET post_count = post_count + 1, updated_at = NOW()
		WHERE id = $1 AND deleted_at IS NULL
	`, channelID)
	return err
}

// DecrementPostCount 减少内容数量
func (r *channelDataAccess) DecrementPostCount(ctx context.Context, channelID string) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE channels 
		SET post_count = GREATEST(post_count - 1, 0), updated_at = NOW()
		WHERE id = $1 AND deleted_at IS NULL
	`, channelID)
	return err
}

// GetAdmins 获取频道管理员列表
func (r *channelDataAccess) GetAdmins(ctx context.Context, channelID string) ([]string, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT user_id 
		FROM channel_admins 
		WHERE channel_id = $1
		ORDER BY created_at ASC
	`, channelID)

	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var admins []string
	for rows.Next() {
		var userID string
		if err := rows.Scan(&userID); err != nil {
			return nil, err
		}
		admins = append(admins, userID)
	}

	return admins, rows.Err()
}

// AddAdmin 添加管理员
func (r *channelDataAccess) AddAdmin(ctx context.Context, channelID, userID string) error {
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO channel_admins (channel_id, user_id, created_at)
		VALUES ($1, $2, NOW())
		ON CONFLICT (channel_id, user_id) DO NOTHING
	`, channelID, userID)
	return err
}

// RemoveAdmin 移除管理员
func (r *channelDataAccess) RemoveAdmin(ctx context.Context, channelID, userID string) error {
	result, err := r.db.ExecContext(ctx, `
		DELETE FROM channel_admins 
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
		return ErrNotFound
	}

	return nil
}

// IsAdmin 检查是否为管理员
func (r *channelDataAccess) IsAdmin(ctx context.Context, channelID, userID string) (bool, error) {
	var exists bool
	err := r.db.QueryRowContext(ctx, `
		SELECT EXISTS(
			SELECT 1 FROM channel_admins 
			WHERE channel_id = $1 AND user_id = $2
		)
	`, channelID, userID).Scan(&exists)
	return exists, err
}

// scanChannels 扫描频道列表
func (r *channelDataAccess) scanChannels(rows *sql.Rows) ([]*Channel, error) {
	var channels []*Channel
	for rows.Next() {
		channel := &Channel{}
		var description, avatarURL sql.NullString

		if err := rows.Scan(
			&channel.ID, &channel.Name, &description, &avatarURL, &channel.OwnerID,
			&channel.SubscriberCount, &channel.PostCount, &channel.CreatedAt,
			&channel.UpdatedAt, &channel.DeletedAt,
		); err != nil {
			return nil, err
		}

		if description.Valid {
			channel.Description = description.String
		}
		if avatarURL.Valid {
			channel.AvatarURL = avatarURL.String
		}

		channels = append(channels, channel)
	}

	return channels, rows.Err()
}
