// Package repository 提供 Interaction 服务的数据访问层
package repository

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
)

// Repost 转发实体
type Repost struct {
	ID        string
	UserID    string
	ContentID string
	Quote     string
	CreatedAt time.Time
}

// RepostRepository 转发数据仓库
type RepostRepository struct {
	db *sql.DB
}

// NewRepostRepository 创建转发仓库
func NewRepostRepository(db *sql.DB) *RepostRepository {
	return &RepostRepository{db: db}
}

// Create 创建转发记录
// 返回值：创建的转发记录、是否实际插入了新记录、错误
func (r *RepostRepository) Create(userID, contentID, quote string) (*Repost, bool, error) {
	repost := &Repost{
		ID:        uuid.New().String(),
		UserID:    userID,
		ContentID: contentID,
		Quote:     quote,
		CreatedAt: time.Now(),
	}

	result, err := r.db.Exec(`
		INSERT INTO reposts (id, user_id, content_id, quote, created_at)
		VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (user_id, content_id) DO NOTHING
	`, repost.ID, repost.UserID, repost.ContentID, nullString(repost.Quote), repost.CreatedAt)
	if err != nil {
		return nil, false, err
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		// 已存在，获取现有记录
		existing, err := r.GetByUserAndContent(userID, contentID)
		return existing, false, err
	}
	return repost, true, nil
}

// Delete 删除转发记录
// 返回值：是否实际删除了记录、错误
func (r *RepostRepository) Delete(userID, contentID string) (bool, error) {
	result, err := r.db.Exec(`DELETE FROM reposts WHERE user_id = $1 AND content_id = $2`, userID, contentID)
	if err != nil {
		return false, err
	}
	rows, _ := result.RowsAffected()
	return rows > 0, nil
}

// Exists 检查是否已转发
func (r *RepostRepository) Exists(userID, contentID string) (bool, error) {
	var exists bool
	err := r.db.QueryRow(`SELECT EXISTS(SELECT 1 FROM reposts WHERE user_id = $1 AND content_id = $2)`, userID, contentID).Scan(&exists)
	return exists, err
}

// BatchExists 批量检查是否已转发
func (r *RepostRepository) BatchExists(userID string, contentIDs []string) (map[string]bool, error) {
	result := make(map[string]bool)
	if len(contentIDs) == 0 {
		return result, nil
	}

	// 使用 pq.Array 转换 []string 为 PostgreSQL 数组类型
	rows, err := r.db.Query(`
		SELECT content_id FROM reposts 
		WHERE user_id = $1 AND content_id = ANY($2)
	`, userID, pq.Array(contentIDs))
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var contentID string
		if err := rows.Scan(&contentID); err != nil {
			continue
		}
		result[contentID] = true
	}
	return result, nil
}

// GetByUserAndContent 根据用户和内容获取转发记录
func (r *RepostRepository) GetByUserAndContent(userID, contentID string) (*Repost, error) {
	repost := &Repost{}
	var quote sql.NullString
	err := r.db.QueryRow(`
		SELECT id, user_id, content_id, quote, created_at 
		FROM reposts WHERE user_id = $1 AND content_id = $2
	`, userID, contentID).Scan(&repost.ID, &repost.UserID, &repost.ContentID, &quote, &repost.CreatedAt)
	if err != nil {
		return nil, err
	}
	repost.Quote = quote.String
	return repost, nil
}

func nullString(s string) sql.NullString {
	if s == "" {
		return sql.NullString{}
	}
	return sql.NullString{String: s, Valid: true}
}
