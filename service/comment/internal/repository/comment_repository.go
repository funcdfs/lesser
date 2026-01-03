// Package repository 提供 Comment 服务的数据访问层
package repository

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
)

// 错误定义
var (
	ErrCommentNotFound = errors.New("评论不存在")
	ErrInvalidParent   = errors.New("父评论不存在或已删除")
	ErrAlreadyLiked    = errors.New("已经点赞过")
	ErrNotLiked        = errors.New("未点赞")
)

// SortBy 排序方式
type SortBy int32

const (
	SortByUnspecified SortBy = 0 // 默认：最新优先
	SortByOldest      SortBy = 1 // 最早优先
	SortByNewest      SortBy = 2 // 最新优先
	SortByHottest     SortBy = 3 // 最热门
	SortByRecommended SortBy = 4 // AI 推荐（预留）
)

// Comment 评论实体
type Comment struct {
	ID         string
	AuthorID   string
	ContentID  string // 所属内容 ID
	ParentID   string // 父评论 ID（用于回复）
	Text       string
	IsDeleted  bool
	CreatedAt  time.Time
	UpdatedAt  time.Time
	ReplyCount int32
	LikeCount  int32
}

// CommentRepository 评论数据仓库
type CommentRepository struct {
	db *sql.DB
}

// NewCommentRepository 创建评论仓库
func NewCommentRepository(db *sql.DB) *CommentRepository {
	return &CommentRepository{db: db}
}


// Create 创建评论记录
func (r *CommentRepository) Create(ctx context.Context, comment *Comment) error {
	comment.ID = uuid.New().String()
	comment.CreatedAt = time.Now()
	comment.UpdatedAt = time.Now()

	// 如果有父评论，验证父评论存在且未删除
	if comment.ParentID != "" {
		var exists bool
		err := r.db.QueryRowContext(ctx, `
			SELECT EXISTS(SELECT 1 FROM comments WHERE id = $1 AND is_deleted = false)
		`, comment.ParentID).Scan(&exists)
		if err != nil {
			return err
		}
		if !exists {
			return ErrInvalidParent
		}
	}

	// 使用事务确保数据一致性
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	// 插入评论
	_, err = tx.ExecContext(ctx, `
		INSERT INTO comments (id, author_id, post_id, parent_id, content, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
	`, comment.ID, comment.AuthorID, comment.ContentID, nullString(comment.ParentID), comment.Text, comment.CreatedAt, comment.UpdatedAt)
	if err != nil {
		return err
	}

	// 如果是回复，更新父评论的回复计数
	if comment.ParentID != "" {
		_, err = tx.ExecContext(ctx, `
			UPDATE comments SET reply_count = reply_count + 1, updated_at = $1 WHERE id = $2
		`, time.Now(), comment.ParentID)
		if err != nil {
			return err
		}
	}

	return tx.Commit()
}

// GetByID 根据 ID 获取评论
func (r *CommentRepository) GetByID(ctx context.Context, id string) (*Comment, error) {
	comment := &Comment{}
	var parentID sql.NullString

	err := r.db.QueryRowContext(ctx, `
		SELECT id, author_id, post_id, parent_id, content, is_deleted, created_at, updated_at, reply_count, like_count
		FROM comments WHERE id = $1
	`, id).Scan(&comment.ID, &comment.AuthorID, &comment.ContentID, &parentID, &comment.Text, &comment.IsDeleted, &comment.CreatedAt, &comment.UpdatedAt, &comment.ReplyCount, &comment.LikeCount)
	if err == sql.ErrNoRows {
		return nil, ErrCommentNotFound
	}
	if err != nil {
		return nil, err
	}
	comment.ParentID = parentID.String
	return comment, nil
}


// List 获取评论列表（支持多种排序）
func (r *CommentRepository) List(ctx context.Context, contentID, parentID string, sortBy SortBy, limit, offset int) ([]*Comment, int, error) {
	var total int
	var countQuery string
	var countArgs []interface{}

	if parentID != "" {
		countQuery = `SELECT COUNT(*) FROM comments WHERE post_id = $1 AND parent_id = $2 AND is_deleted = false`
		countArgs = []interface{}{contentID, parentID}
	} else {
		countQuery = `SELECT COUNT(*) FROM comments WHERE post_id = $1 AND parent_id IS NULL AND is_deleted = false`
		countArgs = []interface{}{contentID}
	}

	if err := r.db.QueryRowContext(ctx, countQuery, countArgs...).Scan(&total); err != nil {
		return nil, 0, err
	}

	// 构建排序子句
	orderClause := r.buildOrderClause(sortBy, parentID != "")

	var listQuery string
	var listArgs []interface{}

	if parentID != "" {
		listQuery = `
			SELECT id, author_id, post_id, parent_id, content, is_deleted, created_at, updated_at, reply_count, like_count
			FROM comments 
			WHERE post_id = $1 AND parent_id = $2 AND is_deleted = false
			` + orderClause + `
			LIMIT $3 OFFSET $4`
		listArgs = []interface{}{contentID, parentID, limit, offset}
	} else {
		listQuery = `
			SELECT id, author_id, post_id, parent_id, content, is_deleted, created_at, updated_at, reply_count, like_count
			FROM comments 
			WHERE post_id = $1 AND parent_id IS NULL AND is_deleted = false
			` + orderClause + `
			LIMIT $2 OFFSET $3`
		listArgs = []interface{}{contentID, limit, offset}
	}

	rows, err := r.db.QueryContext(ctx, listQuery, listArgs...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var comments []*Comment
	for rows.Next() {
		c := &Comment{}
		var pID sql.NullString
		if err := rows.Scan(&c.ID, &c.AuthorID, &c.ContentID, &pID, &c.Text, &c.IsDeleted, &c.CreatedAt, &c.UpdatedAt, &c.ReplyCount, &c.LikeCount); err != nil {
			return nil, 0, err
		}
		c.ParentID = pID.String
		comments = append(comments, c)
	}

	if err := rows.Err(); err != nil {
		return nil, 0, err
	}

	return comments, total, nil
}

// buildOrderClause 构建排序子句
func (r *CommentRepository) buildOrderClause(sortBy SortBy, isReply bool) string {
	switch sortBy {
	case SortByOldest:
		// 最早优先
		return "ORDER BY created_at ASC"
	case SortByHottest:
		// 最热门：点赞数倒序，相同点赞数按时间倒序
		return "ORDER BY like_count DESC, created_at DESC"
	case SortByRecommended:
		// AI 推荐：暂时使用热门排序作为占位
		return "ORDER BY like_count DESC, created_at DESC"
	case SortByNewest, SortByUnspecified:
		fallthrough
	default:
		// 默认/最新优先
		if isReply {
			// 回复默认按时间正序（对话流）
			return "ORDER BY created_at ASC"
		}
		return "ORDER BY created_at DESC"
	}
}


// Delete 软删除评论
func (r *CommentRepository) Delete(ctx context.Context, id string) (*Comment, error) {
	comment, err := r.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	if comment.IsDeleted {
		return nil, ErrCommentNotFound
	}

	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback()

	_, err = tx.ExecContext(ctx, `
		UPDATE comments SET is_deleted = true, updated_at = $1 WHERE id = $2
	`, time.Now(), id)
	if err != nil {
		return nil, err
	}

	if comment.ParentID != "" {
		_, err = tx.ExecContext(ctx, `
			UPDATE comments SET reply_count = GREATEST(reply_count - 1, 0), updated_at = $1 WHERE id = $2
		`, time.Now(), comment.ParentID)
		if err != nil {
			return nil, err
		}
	}

	if err := tx.Commit(); err != nil {
		return nil, err
	}

	return comment, nil
}

// GetCount 获取内容的评论数量
func (r *CommentRepository) GetCount(ctx context.Context, contentID string) (int32, error) {
	var count int32
	err := r.db.QueryRowContext(ctx, `
		SELECT COUNT(*) FROM comments WHERE post_id = $1 AND is_deleted = false
	`, contentID).Scan(&count)
	return count, err
}

// BatchGetCount 批量获取评论数量
func (r *CommentRepository) BatchGetCount(ctx context.Context, contentIDs []string) (map[string]int32, error) {
	result := make(map[string]int32)
	if len(contentIDs) == 0 {
		return result, nil
	}

	for _, id := range contentIDs {
		result[id] = 0
	}

	rows, err := r.db.QueryContext(ctx, `
		SELECT post_id, COUNT(*) FROM comments 
		WHERE post_id = ANY($1) AND is_deleted = false
		GROUP BY post_id
	`, pq.Array(contentIDs))
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var contentID string
		var count int32
		if err := rows.Scan(&contentID, &count); err != nil {
			continue
		}
		result[contentID] = count
	}

	return result, rows.Err()
}


// ============================================================================
// 评论点赞相关
// ============================================================================

// LikeComment 点赞评论
func (r *CommentRepository) LikeComment(ctx context.Context, userID, commentID string) (int32, error) {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return 0, err
	}
	defer tx.Rollback()

	// 检查评论是否存在
	var exists bool
	err = tx.QueryRowContext(ctx, `
		SELECT EXISTS(SELECT 1 FROM comments WHERE id = $1 AND is_deleted = false)
	`, commentID).Scan(&exists)
	if err != nil {
		return 0, err
	}
	if !exists {
		return 0, ErrCommentNotFound
	}

	// 检查是否已经点赞
	var alreadyLiked bool
	err = tx.QueryRowContext(ctx, `
		SELECT EXISTS(SELECT 1 FROM comment_likes WHERE user_id = $1 AND comment_id = $2)
	`, userID, commentID).Scan(&alreadyLiked)
	if err != nil {
		return 0, err
	}
	if alreadyLiked {
		return 0, ErrAlreadyLiked
	}

	// 插入点赞记录
	_, err = tx.ExecContext(ctx, `
		INSERT INTO comment_likes (id, user_id, comment_id, created_at)
		VALUES ($1, $2, $3, $4)
	`, uuid.New().String(), userID, commentID, time.Now())
	if err != nil {
		return 0, err
	}

	// 更新点赞计数
	var newCount int32
	err = tx.QueryRowContext(ctx, `
		UPDATE comments SET like_count = like_count + 1, updated_at = $1 
		WHERE id = $2 
		RETURNING like_count
	`, time.Now(), commentID).Scan(&newCount)
	if err != nil {
		return 0, err
	}

	if err := tx.Commit(); err != nil {
		return 0, err
	}

	return newCount, nil
}

// UnlikeComment 取消点赞评论
func (r *CommentRepository) UnlikeComment(ctx context.Context, userID, commentID string) (int32, error) {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return 0, err
	}
	defer tx.Rollback()

	// 删除点赞记录
	result, err := tx.ExecContext(ctx, `
		DELETE FROM comment_likes WHERE user_id = $1 AND comment_id = $2
	`, userID, commentID)
	if err != nil {
		return 0, err
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		return 0, ErrNotLiked
	}

	// 更新点赞计数
	var newCount int32
	err = tx.QueryRowContext(ctx, `
		UPDATE comments SET like_count = GREATEST(like_count - 1, 0), updated_at = $1 
		WHERE id = $2 
		RETURNING like_count
	`, time.Now(), commentID).Scan(&newCount)
	if err != nil {
		return 0, err
	}

	if err := tx.Commit(); err != nil {
		return 0, err
	}

	return newCount, nil
}

// CheckLiked 检查用户是否已点赞评论
func (r *CommentRepository) CheckLiked(ctx context.Context, userID, commentID string) (bool, error) {
	var exists bool
	err := r.db.QueryRowContext(ctx, `
		SELECT EXISTS(SELECT 1 FROM comment_likes WHERE user_id = $1 AND comment_id = $2)
	`, userID, commentID).Scan(&exists)
	return exists, err
}

// BatchCheckLiked 批量检查用户是否已点赞评论
func (r *CommentRepository) BatchCheckLiked(ctx context.Context, userID string, commentIDs []string) (map[string]bool, error) {
	result := make(map[string]bool)
	if len(commentIDs) == 0 || userID == "" {
		return result, nil
	}

	for _, id := range commentIDs {
		result[id] = false
	}

	rows, err := r.db.QueryContext(ctx, `
		SELECT comment_id FROM comment_likes 
		WHERE user_id = $1 AND comment_id = ANY($2)
	`, userID, pq.Array(commentIDs))
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var commentID string
		if err := rows.Scan(&commentID); err != nil {
			continue
		}
		result[commentID] = true
	}

	return result, rows.Err()
}

// nullString 辅助函数
func nullString(s string) sql.NullString {
	if s == "" {
		return sql.NullString{}
	}
	return sql.NullString{String: s, Valid: true}
}
