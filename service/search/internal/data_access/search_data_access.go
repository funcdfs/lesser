// Package data_access 提供搜索服务的数据访问层
package data_access

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"fmt"
	"time"

	"github.com/lib/pq"
)

// Content 内容实体（对应 contents 表）
type Content struct {
	ID        string
	AuthorID  string
	Title     string
	Text      string
	MediaURLs []string
	CreatedAt time.Time
	Score     float64 // 相关性得分
}

// User 用户实体
type User struct {
	ID          string
	Username    string
	DisplayName string
	AvatarURL   string
	Bio         string
	CreatedAt   time.Time
	Score       float64
}

// Comment 评论实体
type Comment struct {
	ID        string
	AuthorID  string
	PostID    string
	Content   string
	CreatedAt time.Time
	Score     float64
}

// SearchDataAccess 搜索数据访问层
type SearchDataAccess struct {
	db *sql.DB
}

// NewSearchDataAccess 创建搜索数据访问层实例
func NewSearchDataAccess(db *sql.DB) *SearchDataAccess {
	return &SearchDataAccess{db: db}
}

// ============================================================================
// 内容搜索
// ============================================================================

// SearchContents 搜索内容（关键词匹配）
// 使用 ILIKE 进行模糊匹配，按创建时间降序排列
func (da *SearchDataAccess) SearchContents(ctx context.Context, query string, limit, offset int) ([]*Content, int, error) {
	pattern := "%" + query + "%"

	// 统计总数
	var total int
	err := da.db.QueryRowContext(ctx, `
		SELECT COUNT(*) FROM contents 
		WHERE status = 2 AND (title ILIKE $1 OR text ILIKE $1)
	`, pattern).Scan(&total)
	if err != nil {
		return nil, 0, fmt.Errorf("统计内容搜索结果失败: %w", err)
	}

	// 查询结果
	rows, err := da.db.QueryContext(ctx, `
		SELECT id, author_id, title, text, media_urls, created_at
		FROM contents 
		WHERE status = 2 AND (title ILIKE $1 OR text ILIKE $1)
		ORDER BY created_at DESC 
		LIMIT $2 OFFSET $3
	`, pattern, limit, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("查询内容搜索结果失败: %w", err)
	}
	defer rows.Close()

	contents, err := scanContents(rows)
	if err != nil {
		return nil, 0, err
	}

	return contents, total, nil
}

// SearchContentsSemantic 语义搜索内容（使用 pgvector）
// 使用余弦相似度进行向量搜索
func (da *SearchDataAccess) SearchContentsSemantic(ctx context.Context, embedding []float32, limit, offset int) ([]*Content, int, error) {
	// 统计有向量的内容总数
	var total int
	err := da.db.QueryRowContext(ctx, `
		SELECT COUNT(*) FROM content_embeddings ce
		JOIN contents c ON ce.content_id = c.id
		WHERE c.status = 2
	`).Scan(&total)
	if err != nil {
		return nil, 0, fmt.Errorf("统计语义搜索结果失败: %w", err)
	}

	// 使用余弦相似度搜索
	rows, err := da.db.QueryContext(ctx, `
		SELECT c.id, c.author_id, c.title, c.text, c.media_urls, c.created_at,
		       1 - (ce.embedding <=> $1::vector) as score
		FROM content_embeddings ce
		JOIN contents c ON ce.content_id = c.id
		WHERE c.status = 2
		ORDER BY ce.embedding <=> $1::vector
		LIMIT $2 OFFSET $3
	`, pq.Array(embedding), limit, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("执行语义搜索失败: %w", err)
	}
	defer rows.Close()

	contents, err := scanContentsWithScore(rows)
	if err != nil {
		return nil, 0, err
	}

	return contents, total, nil
}

// ============================================================================
// 用户搜索
// ============================================================================

// SearchUsers 搜索用户（关键词匹配）
func (da *SearchDataAccess) SearchUsers(ctx context.Context, query string, limit, offset int) ([]*User, int, error) {
	pattern := "%" + query + "%"

	var total int
	err := da.db.QueryRowContext(ctx, `
		SELECT COUNT(*) FROM users 
		WHERE is_active = true AND (username ILIKE $1 OR display_name ILIKE $1)
	`, pattern).Scan(&total)
	if err != nil {
		return nil, 0, fmt.Errorf("统计用户搜索结果失败: %w", err)
	}

	rows, err := da.db.QueryContext(ctx, `
		SELECT id, username, display_name, avatar_url, bio, created_at
		FROM users 
		WHERE is_active = true AND (username ILIKE $1 OR display_name ILIKE $1)
		ORDER BY created_at DESC 
		LIMIT $2 OFFSET $3
	`, pattern, limit, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("查询用户搜索结果失败: %w", err)
	}
	defer rows.Close()

	users, err := scanUsers(rows)
	if err != nil {
		return nil, 0, err
	}

	return users, total, nil
}

// SearchUsersSemantic 语义搜索用户
func (da *SearchDataAccess) SearchUsersSemantic(ctx context.Context, embedding []float32, limit, offset int) ([]*User, int, error) {
	var total int
	err := da.db.QueryRowContext(ctx, `
		SELECT COUNT(*) FROM user_embeddings ue
		JOIN users u ON ue.user_id = u.id
		WHERE u.is_active = true
	`).Scan(&total)
	if err != nil {
		return nil, 0, fmt.Errorf("统计用户语义搜索结果失败: %w", err)
	}

	rows, err := da.db.QueryContext(ctx, `
		SELECT u.id, u.username, u.display_name, u.avatar_url, u.bio, u.created_at,
		       1 - (ue.embedding <=> $1::vector) as score
		FROM user_embeddings ue
		JOIN users u ON ue.user_id = u.id
		WHERE u.is_active = true
		ORDER BY ue.embedding <=> $1::vector
		LIMIT $2 OFFSET $3
	`, pq.Array(embedding), limit, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("执行用户语义搜索失败: %w", err)
	}
	defer rows.Close()

	users, err := scanUsersWithScore(rows)
	if err != nil {
		return nil, 0, err
	}

	return users, total, nil
}

// ============================================================================
// 评论搜索
// ============================================================================

// SearchComments 搜索评论（关键词匹配）
// postID 为空时搜索所有评论，否则限定在指定帖子下
func (da *SearchDataAccess) SearchComments(ctx context.Context, query, postID string, limit, offset int) ([]*Comment, int, error) {
	pattern := "%" + query + "%"

	var total int
	var rows *sql.Rows
	var err error

	if postID != "" {
		err = da.db.QueryRowContext(ctx, `
			SELECT COUNT(*) FROM comments 
			WHERE is_deleted = false AND post_id = $1 AND content ILIKE $2
		`, postID, pattern).Scan(&total)
		if err != nil {
			return nil, 0, fmt.Errorf("统计评论搜索结果失败: %w", err)
		}

		rows, err = da.db.QueryContext(ctx, `
			SELECT id, author_id, post_id, content, created_at
			FROM comments 
			WHERE is_deleted = false AND post_id = $1 AND content ILIKE $2
			ORDER BY created_at DESC 
			LIMIT $3 OFFSET $4
		`, postID, pattern, limit, offset)
	} else {
		err = da.db.QueryRowContext(ctx, `
			SELECT COUNT(*) FROM comments 
			WHERE is_deleted = false AND content ILIKE $1
		`, pattern).Scan(&total)
		if err != nil {
			return nil, 0, fmt.Errorf("统计评论搜索结果失败: %w", err)
		}

		rows, err = da.db.QueryContext(ctx, `
			SELECT id, author_id, post_id, content, created_at
			FROM comments 
			WHERE is_deleted = false AND content ILIKE $1
			ORDER BY created_at DESC 
			LIMIT $2 OFFSET $3
		`, pattern, limit, offset)
	}

	if err != nil {
		return nil, 0, fmt.Errorf("查询评论搜索结果失败: %w", err)
	}
	defer rows.Close()

	comments, err := scanComments(rows)
	if err != nil {
		return nil, 0, err
	}

	return comments, total, nil
}

// SearchCommentsSemantic 语义搜索评论
func (da *SearchDataAccess) SearchCommentsSemantic(ctx context.Context, embedding []float32, postID string, limit, offset int) ([]*Comment, int, error) {
	var total int
	var rows *sql.Rows
	var err error

	if postID != "" {
		err = da.db.QueryRowContext(ctx, `
			SELECT COUNT(*) FROM comment_embeddings ce
			JOIN comments c ON ce.comment_id = c.id
			WHERE c.is_deleted = false AND c.post_id = $1
		`, postID).Scan(&total)
		if err != nil {
			return nil, 0, fmt.Errorf("统计评论语义搜索结果失败: %w", err)
		}

		rows, err = da.db.QueryContext(ctx, `
			SELECT c.id, c.author_id, c.post_id, c.content, c.created_at,
			       1 - (ce.embedding <=> $1::vector) as score
			FROM comment_embeddings ce
			JOIN comments c ON ce.comment_id = c.id
			WHERE c.is_deleted = false AND c.post_id = $2
			ORDER BY ce.embedding <=> $1::vector
			LIMIT $3 OFFSET $4
		`, pq.Array(embedding), postID, limit, offset)
	} else {
		err = da.db.QueryRowContext(ctx, `
			SELECT COUNT(*) FROM comment_embeddings ce
			JOIN comments c ON ce.comment_id = c.id
			WHERE c.is_deleted = false
		`).Scan(&total)
		if err != nil {
			return nil, 0, fmt.Errorf("统计评论语义搜索结果失败: %w", err)
		}

		rows, err = da.db.QueryContext(ctx, `
			SELECT c.id, c.author_id, c.post_id, c.content, c.created_at,
			       1 - (ce.embedding <=> $1::vector) as score
			FROM comment_embeddings ce
			JOIN comments c ON ce.comment_id = c.id
			WHERE c.is_deleted = false
			ORDER BY ce.embedding <=> $1::vector
			LIMIT $2 OFFSET $3
		`, pq.Array(embedding), limit, offset)
	}

	if err != nil {
		return nil, 0, fmt.Errorf("执行评论语义搜索失败: %w", err)
	}
	defer rows.Close()

	comments, err := scanCommentsWithScore(rows)
	if err != nil {
		return nil, 0, err
	}

	return comments, total, nil
}

// ============================================================================
// 向量嵌入管理
// ============================================================================

// UpsertContentEmbedding 更新或插入内容向量
func (da *SearchDataAccess) UpsertContentEmbedding(ctx context.Context, contentID string, embedding []float32, text string) error {
	textHash := hashText(text)
	_, err := da.db.ExecContext(ctx, `
		INSERT INTO content_embeddings (content_id, embedding, text_hash)
		VALUES ($1, $2::vector, $3)
		ON CONFLICT (content_id) DO UPDATE SET
			embedding = EXCLUDED.embedding,
			text_hash = EXCLUDED.text_hash,
			updated_at = NOW()
	`, contentID, pq.Array(embedding), textHash)
	if err != nil {
		return fmt.Errorf("更新内容向量失败: %w", err)
	}
	return nil
}

// UpsertCommentEmbedding 更新或插入评论向量
func (da *SearchDataAccess) UpsertCommentEmbedding(ctx context.Context, commentID string, embedding []float32, text string) error {
	textHash := hashText(text)
	_, err := da.db.ExecContext(ctx, `
		INSERT INTO comment_embeddings (comment_id, embedding, text_hash)
		VALUES ($1, $2::vector, $3)
		ON CONFLICT (comment_id) DO UPDATE SET
			embedding = EXCLUDED.embedding,
			text_hash = EXCLUDED.text_hash,
			updated_at = NOW()
	`, commentID, pq.Array(embedding), textHash)
	if err != nil {
		return fmt.Errorf("更新评论向量失败: %w", err)
	}
	return nil
}

// UpsertUserEmbedding 更新或插入用户向量
func (da *SearchDataAccess) UpsertUserEmbedding(ctx context.Context, userID string, embedding []float32, text string) error {
	textHash := hashText(text)
	_, err := da.db.ExecContext(ctx, `
		INSERT INTO user_embeddings (user_id, embedding, text_hash)
		VALUES ($1, $2::vector, $3)
		ON CONFLICT (user_id) DO UPDATE SET
			embedding = EXCLUDED.embedding,
			text_hash = EXCLUDED.text_hash,
			updated_at = NOW()
	`, userID, pq.Array(embedding), textHash)
	if err != nil {
		return fmt.Errorf("更新用户向量失败: %w", err)
	}
	return nil
}

// ============================================================================
// 索引管理（供 MQ 消费者调用）
// ============================================================================

// IndexContent 索引内容（更新全文搜索索引）
// 使用 PostgreSQL 的 tsvector 进行全文搜索
func (da *SearchDataAccess) IndexContent(ctx context.Context, contentID, authorID, title, text, contentType string) error {
	// 更新内容的搜索向量
	_, err := da.db.ExecContext(ctx, `
		UPDATE contents 
		SET search_vector = to_tsvector('simple', COALESCE($2, '') || ' ' || COALESCE($3, ''))
		WHERE id = $1
	`, contentID, title, text)

	// 如果 search_vector 列不存在，忽略错误（兼容旧表结构）
	if err != nil {
		// 尝试验证内容存在
		var exists bool
		checkErr := da.db.QueryRowContext(ctx, `SELECT EXISTS(SELECT 1 FROM contents WHERE id = $1)`, contentID).Scan(&exists)
		if checkErr != nil {
			return fmt.Errorf("验证内容存在失败: %w", checkErr)
		}
		if !exists {
			return ErrNotFound
		}
	}

	return nil
}

// DeleteContentIndex 删除内容索引
func (da *SearchDataAccess) DeleteContentIndex(ctx context.Context, contentID string) error {
	// 删除向量嵌入（如果存在）
	_, err := da.db.ExecContext(ctx, `DELETE FROM content_embeddings WHERE content_id = $1`, contentID)
	if err != nil {
		return fmt.Errorf("删除内容向量失败: %w", err)
	}
	return nil
}

// ============================================================================
// 辅助函数
// ============================================================================

// hashText 计算文本的 SHA256 哈希
func hashText(text string) string {
	h := sha256.Sum256([]byte(text))
	return hex.EncodeToString(h[:])
}

// scanContents 扫描内容结果集
func scanContents(rows *sql.Rows) ([]*Content, error) {
	var contents []*Content
	for rows.Next() {
		c := &Content{}
		var title, text sql.NullString
		if err := rows.Scan(&c.ID, &c.AuthorID, &title, &text, pq.Array(&c.MediaURLs), &c.CreatedAt); err != nil {
			return nil, fmt.Errorf("扫描内容记录失败: %w", err)
		}
		c.Title = title.String
		c.Text = text.String
		contents = append(contents, c)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("迭代内容结果集失败: %w", err)
	}
	return contents, nil
}

// scanContentsWithScore 扫描带相关性得分的内容结果集
func scanContentsWithScore(rows *sql.Rows) ([]*Content, error) {
	var contents []*Content
	for rows.Next() {
		c := &Content{}
		var title, text sql.NullString
		if err := rows.Scan(&c.ID, &c.AuthorID, &title, &text, pq.Array(&c.MediaURLs), &c.CreatedAt, &c.Score); err != nil {
			return nil, fmt.Errorf("扫描内容记录失败: %w", err)
		}
		c.Title = title.String
		c.Text = text.String
		contents = append(contents, c)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("迭代内容结果集失败: %w", err)
	}
	return contents, nil
}

// scanUsers 扫描用户结果集
func scanUsers(rows *sql.Rows) ([]*User, error) {
	var users []*User
	for rows.Next() {
		u := &User{}
		var displayName, avatarURL, bio sql.NullString
		if err := rows.Scan(&u.ID, &u.Username, &displayName, &avatarURL, &bio, &u.CreatedAt); err != nil {
			return nil, fmt.Errorf("扫描用户记录失败: %w", err)
		}
		u.DisplayName = displayName.String
		u.AvatarURL = avatarURL.String
		u.Bio = bio.String
		users = append(users, u)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("迭代用户结果集失败: %w", err)
	}
	return users, nil
}

// scanUsersWithScore 扫描带相关性得分的用户结果集
func scanUsersWithScore(rows *sql.Rows) ([]*User, error) {
	var users []*User
	for rows.Next() {
		u := &User{}
		var displayName, avatarURL, bio sql.NullString
		if err := rows.Scan(&u.ID, &u.Username, &displayName, &avatarURL, &bio, &u.CreatedAt, &u.Score); err != nil {
			return nil, fmt.Errorf("扫描用户记录失败: %w", err)
		}
		u.DisplayName = displayName.String
		u.AvatarURL = avatarURL.String
		u.Bio = bio.String
		users = append(users, u)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("迭代用户结果集失败: %w", err)
	}
	return users, nil
}

// scanComments 扫描评论结果集
func scanComments(rows *sql.Rows) ([]*Comment, error) {
	var comments []*Comment
	for rows.Next() {
		c := &Comment{}
		if err := rows.Scan(&c.ID, &c.AuthorID, &c.PostID, &c.Content, &c.CreatedAt); err != nil {
			return nil, fmt.Errorf("扫描评论记录失败: %w", err)
		}
		comments = append(comments, c)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("迭代评论结果集失败: %w", err)
	}
	return comments, nil
}

// scanCommentsWithScore 扫描带相关性得分的评论结果集
func scanCommentsWithScore(rows *sql.Rows) ([]*Comment, error) {
	var comments []*Comment
	for rows.Next() {
		c := &Comment{}
		if err := rows.Scan(&c.ID, &c.AuthorID, &c.PostID, &c.Content, &c.CreatedAt, &c.Score); err != nil {
			return nil, fmt.Errorf("扫描评论记录失败: %w", err)
		}
		comments = append(comments, c)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("迭代评论结果集失败: %w", err)
	}
	return comments, nil
}
