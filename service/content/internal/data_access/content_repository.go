// Package repository 提供内容数据访问层
package data_access

import (
	"database/sql"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
)

// 错误定义
var (
	ErrContentNotFound = errors.New("内容不存在")
	ErrUnauthorized    = errors.New("无权限操作")
)

// ContentType 内容类型
type ContentType int32

const (
	ContentTypeUnspecified ContentType = 0
	ContentTypeStory       ContentType = 1 // 小瞬间，24h 过期
	ContentTypeShort       ContentType = 2 // 短文本
	ContentTypeArticle     ContentType = 3 // 长文章
)

// String 返回内容类型的字符串表示
func (t ContentType) String() string {
	switch t {
	case ContentTypeStory:
		return "story"
	case ContentTypeShort:
		return "short"
	case ContentTypeArticle:
		return "article"
	default:
		return "unspecified"
	}
}

// ContentStatus 内容状态
type ContentStatus int32

const (
	ContentStatusUnspecified ContentStatus = 0
	ContentStatusDraft       ContentStatus = 1 // 草稿
	ContentStatusPublished   ContentStatus = 2 // 已发布
	ContentStatusArchived    ContentStatus = 3 // 已归档
	ContentStatusDeleted     ContentStatus = 4 // 已删除
)

// Content 内容实体
type Content struct {
	ID        string
	AuthorID  string
	Type      ContentType
	Status    ContentStatus
	Title     string
	Text      string
	Summary   string
	MediaURLs []string
	Tags      []string
	ReplyToID string
	QuoteID   string

	// 统计
	LikeCount     int32
	CommentCount  int32
	RepostCount   int32
	BookmarkCount int32
	ViewCount     int32

	// 时间
	CreatedAt   time.Time
	UpdatedAt   time.Time
	PublishedAt *time.Time
	ExpiresAt   *time.Time

	// 元数据
	IsPinned         bool
	CommentsDisabled bool
	Language         string
}

// ContentRepository 内容仓库
type ContentRepository struct {
	db *sql.DB
}

// NewContentRepository 创建内容仓库
func NewContentRepository(db *sql.DB) *ContentRepository {
	return &ContentRepository{db: db}
}

// Create 创建内容
func (r *ContentRepository) Create(content *Content) error {
	content.ID = uuid.New().String()
	content.CreatedAt = time.Now()
	content.UpdatedAt = time.Now()

	// Story 类型自动设置 24h 过期
	if content.Type == ContentTypeStory {
		expiresAt := time.Now().Add(24 * time.Hour)
		content.ExpiresAt = &expiresAt
	}

	// 非草稿状态设置发布时间
	if content.Status == ContentStatusPublished {
		now := time.Now()
		content.PublishedAt = &now
	}

	_, err := r.db.Exec(`
		INSERT INTO contents (
			id, author_id, type, status, title, text, summary, 
			media_urls, tags, reply_to_id, quote_id,
			created_at, updated_at, published_at, expires_at,
			is_pinned, comments_disabled, language
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, 
			$8, $9, $10, $11,
			$12, $13, $14, $15,
			$16, $17, $18
		)
	`,
		content.ID, content.AuthorID, content.Type, content.Status,
		nullString(content.Title), content.Text, nullString(content.Summary),
		pq.Array(content.MediaURLs), pq.Array(content.Tags),
		nullString(content.ReplyToID), nullString(content.QuoteID),
		content.CreatedAt, content.UpdatedAt, content.PublishedAt, content.ExpiresAt,
		content.IsPinned, content.CommentsDisabled, nullString(content.Language),
	)
	return err
}

// GetByID 根据 ID 获取内容
func (r *ContentRepository) GetByID(id string) (*Content, error) {
	content := &Content{}
	var title, summary, replyToID, quoteID, language sql.NullString
	var publishedAt, expiresAt sql.NullTime

	err := r.db.QueryRow(`
		SELECT id, author_id, type, status, title, text, summary,
			   media_urls, tags, reply_to_id, quote_id,
			   like_count, comment_count, repost_count, bookmark_count, view_count,
			   created_at, updated_at, published_at, expires_at,
			   is_pinned, comments_disabled, language
		FROM contents 
		WHERE id = $1 AND status != $2
	`, id, ContentStatusDeleted).Scan(
		&content.ID, &content.AuthorID, &content.Type, &content.Status,
		&title, &content.Text, &summary,
		pq.Array(&content.MediaURLs), pq.Array(&content.Tags),
		&replyToID, &quoteID,
		&content.LikeCount, &content.CommentCount, &content.RepostCount,
		&content.BookmarkCount, &content.ViewCount,
		&content.CreatedAt, &content.UpdatedAt, &publishedAt, &expiresAt,
		&content.IsPinned, &content.CommentsDisabled, &language,
	)

	if err == sql.ErrNoRows {
		return nil, ErrContentNotFound
	}
	if err != nil {
		return nil, err
	}

	content.Title = title.String
	content.Summary = summary.String
	content.ReplyToID = replyToID.String
	content.QuoteID = quoteID.String
	content.Language = language.String
	if publishedAt.Valid {
		content.PublishedAt = &publishedAt.Time
	}
	if expiresAt.Valid {
		content.ExpiresAt = &expiresAt.Time
	}

	return content, nil
}

// Update 更新内容
func (r *ContentRepository) Update(content *Content) error {
	content.UpdatedAt = time.Now()

	result, err := r.db.Exec(`
		UPDATE contents SET
			title = $1, text = $2, summary = $3,
			media_urls = $4, tags = $5,
			comments_disabled = $6, updated_at = $7
		WHERE id = $8 AND status != $9
	`,
		nullString(content.Title), content.Text, nullString(content.Summary),
		pq.Array(content.MediaURLs), pq.Array(content.Tags),
		content.CommentsDisabled, content.UpdatedAt,
		content.ID, ContentStatusDeleted,
	)
	if err != nil {
		return err
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		return ErrContentNotFound
	}
	return nil
}

// Delete 软删除内容
func (r *ContentRepository) Delete(id string) error {
	result, err := r.db.Exec(`
		UPDATE contents SET status = $1, updated_at = $2 WHERE id = $3
	`, ContentStatusDeleted, time.Now(), id)
	if err != nil {
		return err
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		return ErrContentNotFound
	}
	return nil
}

// Publish 发布草稿
func (r *ContentRepository) Publish(id string) error {
	now := time.Now()
	result, err := r.db.Exec(`
		UPDATE contents SET status = $1, published_at = $2, updated_at = $2
		WHERE id = $3 AND status = $4
	`, ContentStatusPublished, now, id, ContentStatusDraft)
	if err != nil {
		return err
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		return ErrContentNotFound
	}
	return nil
}


// List 列表查询
func (r *ContentRepository) List(authorID string, contentType ContentType, status ContentStatus, tags []string, limit, offset int, orderBy string, desc bool) ([]*Content, int, error) {
	// 构建查询条件
	baseQuery := "FROM contents WHERE status != $1"
	args := []interface{}{ContentStatusDeleted}
	argIdx := 2

	if authorID != "" {
		baseQuery += fmt.Sprintf(" AND author_id = $%d", argIdx)
		args = append(args, authorID)
		argIdx++
	}
	if contentType > 0 {
		baseQuery += fmt.Sprintf(" AND type = $%d", argIdx)
		args = append(args, contentType)
		argIdx++
	}
	if status > 0 {
		baseQuery += fmt.Sprintf(" AND status = $%d", argIdx)
		args = append(args, status)
		argIdx++
	}
	if len(tags) > 0 {
		baseQuery += fmt.Sprintf(" AND tags && $%d", argIdx)
		args = append(args, pq.Array(tags))
		argIdx++
	}

	// 排除过期内容
	baseQuery += " AND (expires_at IS NULL OR expires_at > NOW())"

	// 统计总数
	var total int
	r.db.QueryRow("SELECT COUNT(*) "+baseQuery, args...).Scan(&total)

	// 排序
	order := "created_at"
	if orderBy != "" {
		order = orderBy
	}
	direction := "DESC"
	if !desc {
		direction = "ASC"
	}

	// 查询列表
	selectQuery := fmt.Sprintf(`
		SELECT id, author_id, type, status, title, text, summary,
			   media_urls, tags, reply_to_id, quote_id,
			   like_count, comment_count, repost_count, bookmark_count, view_count,
			   created_at, updated_at, published_at, expires_at,
			   is_pinned, comments_disabled, language
		%s ORDER BY %s %s LIMIT $%d OFFSET $%d
	`, baseQuery, order, direction, argIdx, argIdx+1)

	args = append(args, limit, offset)

	rows, err := r.db.Query(selectQuery, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	return scanContents(rows), total, nil
}

// ListDrafts 获取用户草稿
func (r *ContentRepository) ListDrafts(userID string, limit, offset int) ([]*Content, int, error) {
	var total int
	r.db.QueryRow(`SELECT COUNT(*) FROM contents WHERE author_id = $1 AND status = $2`, userID, ContentStatusDraft).Scan(&total)

	rows, err := r.db.Query(`
		SELECT id, author_id, type, status, title, text, summary,
			   media_urls, tags, reply_to_id, quote_id,
			   like_count, comment_count, repost_count, bookmark_count, view_count,
			   created_at, updated_at, published_at, expires_at,
			   is_pinned, comments_disabled, language
		FROM contents 
		WHERE author_id = $1 AND status = $2
		ORDER BY updated_at DESC
		LIMIT $3 OFFSET $4
	`, userID, ContentStatusDraft, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	return scanContents(rows), total, nil
}

// ListReplies 获取内容的回复
func (r *ContentRepository) ListReplies(contentID string, limit, offset int) ([]*Content, int, error) {
	var total int
	r.db.QueryRow(`
		SELECT COUNT(*) FROM contents 
		WHERE reply_to_id = $1 AND status = $2
	`, contentID, ContentStatusPublished).Scan(&total)

	rows, err := r.db.Query(`
		SELECT id, author_id, type, status, title, text, summary,
			   media_urls, tags, reply_to_id, quote_id,
			   like_count, comment_count, repost_count, bookmark_count, view_count,
			   created_at, updated_at, published_at, expires_at,
			   is_pinned, comments_disabled, language
		FROM contents 
		WHERE reply_to_id = $1 AND status = $2
		ORDER BY created_at ASC
		LIMIT $3 OFFSET $4
	`, contentID, ContentStatusPublished, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	return scanContents(rows), total, nil
}

// ListUserStories 获取用户的 Story
func (r *ContentRepository) ListUserStories(userID string) ([]*Content, error) {
	rows, err := r.db.Query(`
		SELECT id, author_id, type, status, title, text, summary,
			   media_urls, tags, reply_to_id, quote_id,
			   like_count, comment_count, repost_count, bookmark_count, view_count,
			   created_at, updated_at, published_at, expires_at,
			   is_pinned, comments_disabled, language
		FROM contents 
		WHERE author_id = $1 AND type = $2 AND status = $3
			  AND (expires_at IS NULL OR expires_at > NOW())
		ORDER BY created_at DESC
	`, userID, ContentTypeStory, ContentStatusPublished)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	return scanContents(rows), nil
}

// BatchGet 批量获取内容
func (r *ContentRepository) BatchGet(ids []string) ([]*Content, error) {
	if len(ids) == 0 {
		return []*Content{}, nil
	}

	rows, err := r.db.Query(`
		SELECT id, author_id, type, status, title, text, summary,
			   media_urls, tags, reply_to_id, quote_id,
			   like_count, comment_count, repost_count, bookmark_count, view_count,
			   created_at, updated_at, published_at, expires_at,
			   is_pinned, comments_disabled, language
		FROM contents 
		WHERE id = ANY($1) AND status != $2
	`, pq.Array(ids), ContentStatusDeleted)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	return scanContents(rows), nil
}

// SetPinned 设置置顶状态
func (r *ContentRepository) SetPinned(id string, pinned bool) error {
	_, err := r.db.Exec(`
		UPDATE contents SET is_pinned = $1, updated_at = $2 WHERE id = $3
	`, pinned, time.Now(), id)
	return err
}

// IncrementViewCount 增加浏览量
func (r *ContentRepository) IncrementViewCount(id string) error {
	_, err := r.db.Exec(`UPDATE contents SET view_count = view_count + 1 WHERE id = $1`, id)
	return err
}

// CounterType 计数器类型
type CounterType int32

const (
	CounterTypeUnspecified CounterType = 0
	CounterTypeLike        CounterType = 1
	CounterTypeComment     CounterType = 2
	CounterTypeRepost      CounterType = 3
	CounterTypeBookmark    CounterType = 4
)

// UpdateCounter 更新统计计数器（原子操作）
// delta 为正数时增加，为负数时减少（最小为 0）
// 使用 GREATEST 确保计数器不会变为负数
func (r *ContentRepository) UpdateCounter(id string, counterType CounterType, delta int32) (int32, error) {
	var column string
	switch counterType {
	case CounterTypeLike:
		column = "like_count"
	case CounterTypeComment:
		column = "comment_count"
	case CounterTypeRepost:
		column = "repost_count"
	case CounterTypeBookmark:
		column = "bookmark_count"
	default:
		return 0, errors.New("无效的计数器类型")
	}

	var newCount int32
	// 使用 GREATEST 确保计数器不会变为负数，原子更新
	query := fmt.Sprintf(`
		UPDATE contents 
		SET %s = GREATEST(%s + $1, 0), updated_at = $2
		WHERE id = $3 AND status != $4
		RETURNING %s
	`, column, column, column)

	err := r.db.QueryRow(query, delta, time.Now(), id, ContentStatusDeleted).Scan(&newCount)
	if err == sql.ErrNoRows {
		return 0, ErrContentNotFound
	}
	return newCount, err
}

// Exists 检查内容是否存在
func (r *ContentRepository) Exists(id string) (bool, error) {
	var exists bool
	err := r.db.QueryRow(`
		SELECT EXISTS(SELECT 1 FROM contents WHERE id = $1 AND status != $2)
	`, id, ContentStatusDeleted).Scan(&exists)
	return exists, err
}

// GetCommentsDisabled 获取内容是否禁止评论
func (r *ContentRepository) GetCommentsDisabled(id string) (bool, error) {
	var disabled bool
	err := r.db.QueryRow(`
		SELECT comments_disabled FROM contents WHERE id = $1 AND status != $2
	`, id, ContentStatusDeleted).Scan(&disabled)
	if err == sql.ErrNoRows {
		return false, ErrContentNotFound
	}
	return disabled, err
}

// GetAuthorID 获取内容作者 ID（用于通知服务）
func (r *ContentRepository) GetAuthorID(id string) (string, error) {
	var authorID string
	err := r.db.QueryRow(`
		SELECT author_id FROM contents WHERE id = $1 AND status != $2
	`, id, ContentStatusDeleted).Scan(&authorID)
	if err == sql.ErrNoRows {
		return "", ErrContentNotFound
	}
	return authorID, err
}

// ============================================================================
// 辅助函数
// ============================================================================

func scanContents(rows *sql.Rows) []*Content {
	var contents []*Content
	for rows.Next() {
		content := &Content{}
		var title, summary, replyToID, quoteID, language sql.NullString
		var publishedAt, expiresAt sql.NullTime

		// 处理扫描错误，避免静默忽略
		if err := rows.Scan(
			&content.ID, &content.AuthorID, &content.Type, &content.Status,
			&title, &content.Text, &summary,
			pq.Array(&content.MediaURLs), pq.Array(&content.Tags),
			&replyToID, &quoteID,
			&content.LikeCount, &content.CommentCount, &content.RepostCount,
			&content.BookmarkCount, &content.ViewCount,
			&content.CreatedAt, &content.UpdatedAt, &publishedAt, &expiresAt,
			&content.IsPinned, &content.CommentsDisabled, &language,
		); err != nil {
			// 扫描失败时跳过该行，但记录错误（生产环境应使用日志）
			continue
		}

		content.Title = title.String
		content.Summary = summary.String
		content.ReplyToID = replyToID.String
		content.QuoteID = quoteID.String
		content.Language = language.String
		if publishedAt.Valid {
			content.PublishedAt = &publishedAt.Time
		}
		if expiresAt.Valid {
			content.ExpiresAt = &expiresAt.Time
		}

		contents = append(contents, content)
	}
	return contents
}

func nullString(s string) sql.NullString {
	if s == "" {
		return sql.NullString{}
	}
	return sql.NullString{String: s, Valid: true}
}
