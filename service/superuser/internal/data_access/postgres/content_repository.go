// Package postgres 内容管理 PostgreSQL 仓库实现
package postgres

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/funcdfs/lesser/superuser/internal/data_access"
	"github.com/google/uuid"
	"github.com/lib/pq"
)

// ContentRepository PostgreSQL 内容仓库
type ContentRepository struct {
	db *sql.DB
}

// NewContentRepository 创建内容仓库
func NewContentRepository(db *sql.DB) *ContentRepository {
	return &ContentRepository{db: db}
}

// List 获取内容列表
func (r *ContentRepository) List(ctx context.Context, filter data_access.ContentFilter) ([]*data_access.Content, int, error) {
	// 构建查询条件
	var conditions []string
	var args []interface{}
	argIndex := 1

	if filter.AuthorID != nil {
		conditions = append(conditions, fmt.Sprintf("c.author_id = $%d", argIndex))
		args = append(args, *filter.AuthorID)
		argIndex++
	}
	if filter.Type != nil {
		conditions = append(conditions, fmt.Sprintf("c.type = $%d", argIndex))
		args = append(args, *filter.Type)
		argIndex++
	}
	if filter.Status != nil {
		conditions = append(conditions, fmt.Sprintf("c.status = $%d", argIndex))
		args = append(args, *filter.Status)
		argIndex++
	}
	if filter.Search != nil && *filter.Search != "" {
		conditions = append(conditions, fmt.Sprintf("(c.title ILIKE $%d OR c.text ILIKE $%d)", argIndex, argIndex))
		args = append(args, "%"+*filter.Search+"%")
		argIndex++
	}

	whereClause := ""
	if len(conditions) > 0 {
		whereClause = "WHERE " + strings.Join(conditions, " AND ")
	}

	// 获取总数
	countQuery := fmt.Sprintf(`SELECT COUNT(*) FROM contents c %s`, whereClause)
	var total int
	if err := r.db.QueryRowContext(ctx, countQuery, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	// 排序
	sortBy := "created_at"
	if filter.SortBy != "" {
		switch filter.SortBy {
		case "like_count", "comment_count", "repost_count", "view_count", "created_at", "published_at":
			sortBy = filter.SortBy
		}
	}
	sortOrder := "DESC"
	if filter.SortOrder == "asc" {
		sortOrder = "ASC"
	}

	// 分页
	if filter.Page < 1 {
		filter.Page = 1
	}
	if filter.PageSize < 1 {
		filter.PageSize = 20
	}
	offset := (filter.Page - 1) * filter.PageSize

	query := fmt.Sprintf(`
		SELECT c.id, c.author_id, u.username, c.type, c.status, c.title, c.text, 
		       c.media_urls, c.tags, c.like_count, c.comment_count, c.repost_count, c.view_count,
		       c.created_at, c.published_at
		FROM contents c
		LEFT JOIN users u ON c.author_id = u.id
		%s
		ORDER BY c.%s %s
		LIMIT $%d OFFSET $%d
	`, whereClause, sortBy, sortOrder, argIndex, argIndex+1)
	args = append(args, filter.PageSize, offset)

	rows, err := r.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var contents []*data_access.Content
	for rows.Next() {
		content := &data_access.Content{}
		err := rows.Scan(
			&content.ID, &content.AuthorID, &content.AuthorUsername, &content.Type, &content.Status,
			&content.Title, &content.Text, pq.Array(&content.MediaURLs), pq.Array(&content.Tags),
			&content.LikeCount, &content.CommentCount, &content.RepostCount, &content.ViewCount,
			&content.CreatedAt, &content.PublishedAt,
		)
		if err != nil {
			return nil, 0, err
		}
		contents = append(contents, content)
	}

	return contents, total, rows.Err()
}

// GetByID 根据 ID 获取内容
func (r *ContentRepository) GetByID(ctx context.Context, id uuid.UUID) (*data_access.Content, error) {
	query := `
		SELECT c.id, c.author_id, u.username, c.type, c.status, c.title, c.text, 
		       c.media_urls, c.tags, c.like_count, c.comment_count, c.repost_count, c.view_count,
		       c.created_at, c.published_at
		FROM contents c
		LEFT JOIN users u ON c.author_id = u.id
		WHERE c.id = $1
	`
	content := &data_access.Content{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&content.ID, &content.AuthorID, &content.AuthorUsername, &content.Type, &content.Status,
		&content.Title, &content.Text, pq.Array(&content.MediaURLs), pq.Array(&content.Tags),
		&content.LikeCount, &content.CommentCount, &content.RepostCount, &content.ViewCount,
		&content.CreatedAt, &content.PublishedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return content, nil
}

// SoftDelete 软删除内容
func (r *ContentRepository) SoftDelete(ctx context.Context, id uuid.UUID) error {
	query := `UPDATE contents SET status = 4, updated_at = $2 WHERE id = $1`
	_, err := r.db.ExecContext(ctx, query, id, time.Now())
	return err
}

// HardDelete 硬删除内容
func (r *ContentRepository) HardDelete(ctx context.Context, id uuid.UUID) error {
	query := `DELETE FROM contents WHERE id = $1`
	_, err := r.db.ExecContext(ctx, query, id)
	return err
}

// BatchDelete 批量删除内容
func (r *ContentRepository) BatchDelete(ctx context.Context, ids []uuid.UUID, hard bool) (int, []uuid.UUID, error) {
	if len(ids) == 0 {
		return 0, nil, nil
	}

	var deletedCount int
	var failedIDs []uuid.UUID

	for _, id := range ids {
		var err error
		if hard {
			err = r.HardDelete(ctx, id)
		} else {
			err = r.SoftDelete(ctx, id)
		}
		if err != nil {
			failedIDs = append(failedIDs, id)
		} else {
			deletedCount++
		}
	}

	return deletedCount, failedIDs, nil
}
