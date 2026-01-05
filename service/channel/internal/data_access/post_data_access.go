// Package data_access 频道内容数据访问层
package data_access

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
)

// PostDataAccess 频道内容数据访问接口
type PostDataAccess interface {
	// Create 创建频道内容
	Create(ctx context.Context, post *ChannelPost) error
	// GetByID 根据 ID 获取频道内容
	GetByID(ctx context.Context, id string) (*ChannelPost, error)
	// Delete 删除频道内容（软删除）
	Delete(ctx context.Context, id string) error
	// ListByChannel 获取频道内容列表
	ListByChannel(ctx context.Context, channelID string, offset, limit int) ([]*ChannelPost, error)
	// IncrementViewCount 增加浏览次数
	IncrementViewCount(ctx context.Context, postID string) error
	// GetPostCount 获取频道内容数量
	GetPostCount(ctx context.Context, channelID string) (int64, error)
}

// ChannelPost 频道内容实体
type ChannelPost struct {
	ID        string
	ChannelID string
	AuthorID  string
	Content   string
	MediaURLs []string
	ViewCount int64
	CreatedAt time.Time
	DeletedAt sql.NullTime
}

// postDataAccess 频道内容数据访问实现
type postDataAccess struct {
	db *sql.DB
}

// NewPostDataAccess 创建频道内容数据访问
func NewPostDataAccess(db *sql.DB) PostDataAccess {
	return &postDataAccess{db: db}
}

// Create 创建频道内容
func (r *postDataAccess) Create(ctx context.Context, post *ChannelPost) error {
	post.ID = uuid.New().String()
	post.CreatedAt = time.Now()

	_, err := r.db.ExecContext(ctx, `
		INSERT INTO channel_posts (id, channel_id, author_id, content, media_urls, view_count, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
	`, post.ID, post.ChannelID, post.AuthorID, post.Content, pq.Array(post.MediaURLs), post.ViewCount, post.CreatedAt)

	return err
}

// GetByID 根据 ID 获取频道内容
func (r *postDataAccess) GetByID(ctx context.Context, id string) (*ChannelPost, error) {
	post := &ChannelPost{}
	var mediaURLs pq.StringArray

	err := r.db.QueryRowContext(ctx, `
		SELECT id, channel_id, author_id, content, media_urls, view_count, created_at, deleted_at
		FROM channel_posts 
		WHERE id = $1 AND deleted_at IS NULL
	`, id).Scan(
		&post.ID, &post.ChannelID, &post.AuthorID, &post.Content,
		&mediaURLs, &post.ViewCount, &post.CreatedAt, &post.DeletedAt,
	)

	if err == sql.ErrNoRows {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, err
	}

	post.MediaURLs = mediaURLs

	return post, nil
}

// Delete 删除频道内容（软删除）
func (r *postDataAccess) Delete(ctx context.Context, id string) error {
	result, err := r.db.ExecContext(ctx, `
		UPDATE channel_posts 
		SET deleted_at = $1
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

// ListByChannel 获取频道内容列表
func (r *postDataAccess) ListByChannel(ctx context.Context, channelID string, offset, limit int) ([]*ChannelPost, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT id, channel_id, author_id, content, media_urls, view_count, created_at, deleted_at
		FROM channel_posts 
		WHERE channel_id = $1 AND deleted_at IS NULL
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`, channelID, limit, offset)

	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var posts []*ChannelPost
	for rows.Next() {
		post := &ChannelPost{}
		var mediaURLs pq.StringArray

		if err := rows.Scan(
			&post.ID, &post.ChannelID, &post.AuthorID, &post.Content,
			&mediaURLs, &post.ViewCount, &post.CreatedAt, &post.DeletedAt,
		); err != nil {
			return nil, err
		}

		post.MediaURLs = mediaURLs
		posts = append(posts, post)
	}

	return posts, rows.Err()
}

// IncrementViewCount 增加浏览次数
func (r *postDataAccess) IncrementViewCount(ctx context.Context, postID string) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE channel_posts 
		SET view_count = view_count + 1
		WHERE id = $1 AND deleted_at IS NULL
	`, postID)
	return err
}

// GetPostCount 获取频道内容数量
func (r *postDataAccess) GetPostCount(ctx context.Context, channelID string) (int64, error) {
	var count int64
	err := r.db.QueryRowContext(ctx, `
		SELECT COUNT(*) 
		FROM channel_posts 
		WHERE channel_id = $1 AND deleted_at IS NULL
	`, channelID).Scan(&count)
	return count, err
}
