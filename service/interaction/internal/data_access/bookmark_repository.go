// Package repository 提供 Interaction 服务的数据访问层
package data_access

import (
	"database/sql"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
)

// Bookmark 收藏实体
type Bookmark struct {
	ID        string
	UserID    string
	ContentID string
	CreatedAt time.Time
}

// BookmarkRepository 收藏数据仓库
type BookmarkRepository struct {
	db *sql.DB
}

// NewBookmarkRepository 创建收藏仓库
func NewBookmarkRepository(db *sql.DB) *BookmarkRepository {
	return &BookmarkRepository{db: db}
}

// Create 创建收藏记录
// 返回值：是否实际插入了新记录、错误
func (r *BookmarkRepository) Create(userID, contentID string) (bool, error) {
	result, err := r.db.Exec(`
		INSERT INTO bookmarks (id, user_id, content_id, created_at)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (user_id, content_id) DO NOTHING
	`, uuid.New().String(), userID, contentID, time.Now())
	if err != nil {
		return false, err
	}
	rows, _ := result.RowsAffected()
	return rows > 0, nil
}

// Delete 删除收藏记录
// 返回值：是否实际删除了记录、错误
func (r *BookmarkRepository) Delete(userID, contentID string) (bool, error) {
	result, err := r.db.Exec(`DELETE FROM bookmarks WHERE user_id = $1 AND content_id = $2`, userID, contentID)
	if err != nil {
		return false, err
	}
	rows, _ := result.RowsAffected()
	return rows > 0, nil
}

// Exists 检查是否已收藏
func (r *BookmarkRepository) Exists(userID, contentID string) (bool, error) {
	var exists bool
	err := r.db.QueryRow(`SELECT EXISTS(SELECT 1 FROM bookmarks WHERE user_id = $1 AND content_id = $2)`, userID, contentID).Scan(&exists)
	return exists, err
}

// BatchExists 批量检查是否已收藏
func (r *BookmarkRepository) BatchExists(userID string, contentIDs []string) (map[string]bool, error) {
	result := make(map[string]bool)
	if len(contentIDs) == 0 {
		return result, nil
	}

	// 使用 pq.Array 转换 []string 为 PostgreSQL 数组类型
	rows, err := r.db.Query(`
		SELECT content_id FROM bookmarks 
		WHERE user_id = $1 AND content_id = ANY($2)
	`, userID, pq.Array(contentIDs))
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var contentID string
		if err := rows.Scan(&contentID); err != nil {
			return nil, fmt.Errorf("扫描行失败: %w", err)
		}
		result[contentID] = true
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("行迭代错误: %w", err)
	}

	return result, nil
}

// List 获取收藏列表
func (r *BookmarkRepository) List(userID string, limit, offset int) ([]*Bookmark, int, error) {
	var total int
	if err := r.db.QueryRow(`SELECT COUNT(*) FROM bookmarks WHERE user_id = $1`, userID).Scan(&total); err != nil {
		return nil, 0, fmt.Errorf("统计收藏数失败: %w", err)
	}

	rows, err := r.db.Query(`
		SELECT id, user_id, content_id, created_at FROM bookmarks
		WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3
	`, userID, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var bookmarks []*Bookmark
	for rows.Next() {
		b := &Bookmark{}
		if err := rows.Scan(&b.ID, &b.UserID, &b.ContentID, &b.CreatedAt); err != nil {
			return nil, 0, fmt.Errorf("扫描行失败: %w", err)
		}
		bookmarks = append(bookmarks, b)
	}

	if err := rows.Err(); err != nil {
		return nil, 0, fmt.Errorf("行迭代错误: %w", err)
	}

	return bookmarks, total, nil
}
