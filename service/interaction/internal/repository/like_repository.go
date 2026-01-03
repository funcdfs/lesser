// Package repository 提供 Interaction 服务的数据访问层
package repository

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

// LikeRepository 点赞数据仓库
type LikeRepository struct {
	db *sql.DB
}

// NewLikeRepository 创建点赞仓库
func NewLikeRepository(db *sql.DB) *LikeRepository {
	return &LikeRepository{db: db}
}

// Create 创建点赞记录
// 返回值：是否实际插入了新记录、错误
func (r *LikeRepository) Create(userID, contentID string) (bool, error) {
	result, err := r.db.Exec(`
		INSERT INTO likes (id, user_id, content_id, created_at)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (user_id, content_id) DO NOTHING
	`, uuid.New().String(), userID, contentID, time.Now())
	if err != nil {
		return false, err
	}
	rows, _ := result.RowsAffected()
	return rows > 0, nil
}

// Delete 删除点赞记录
// 返回值：是否实际删除了记录、错误
func (r *LikeRepository) Delete(userID, contentID string) (bool, error) {
	result, err := r.db.Exec(`DELETE FROM likes WHERE user_id = $1 AND content_id = $2`, userID, contentID)
	if err != nil {
		return false, err
	}
	rows, _ := result.RowsAffected()
	return rows > 0, nil
}

// Exists 检查是否已点赞
func (r *LikeRepository) Exists(userID, contentID string) (bool, error) {
	var exists bool
	err := r.db.QueryRow(`SELECT EXISTS(SELECT 1 FROM likes WHERE user_id = $1 AND content_id = $2)`, userID, contentID).Scan(&exists)
	return exists, err
}

// BatchExists 批量检查是否已点赞
func (r *LikeRepository) BatchExists(userID string, contentIDs []string) (map[string]bool, error) {
	result := make(map[string]bool)
	if len(contentIDs) == 0 {
		return result, nil
	}

	rows, err := r.db.Query(`
		SELECT content_id FROM likes 
		WHERE user_id = $1 AND content_id = ANY($2)
	`, userID, contentIDs)
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
