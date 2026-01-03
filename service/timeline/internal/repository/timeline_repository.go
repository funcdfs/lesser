// Package repository 提供 Timeline 服务的数据访问层
package repository

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/lib/pq"
)

// FeedItem Feed 流中的单个条目
type FeedItem struct {
	// 内容信息
	ContentID   string
	AuthorID    string
	ContentType int32
	Status      int32
	Title       string
	Text        string
	Summary     string
	MediaURLs   []string
	Tags        []string
	ReplyToID   string
	QuoteID     string

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

// TimelineRepository Feed 流数据仓库
type TimelineRepository struct {
	db *sql.DB
}

// NewTimelineRepository 创建 Feed 流仓库
func NewTimelineRepository(db *sql.DB) *TimelineRepository {
	return &TimelineRepository{db: db}
}

// GetFollowingFeed 获取关注用户的 Feed 流
func (r *TimelineRepository) GetFollowingFeed(ctx context.Context, userID string, limit, offset int) ([]*FeedItem, int, error) {
	// 获取总数
	var total int
	err := r.db.QueryRowContext(ctx, `
		SELECT COUNT(*) 
		FROM contents c
		JOIN follows f ON c.author_id = f.following_id
		WHERE f.follower_id = $1 
		  AND c.status = 2
		  AND (c.expires_at IS NULL OR c.expires_at > NOW())
	`, userID).Scan(&total)
	if err != nil {
		return nil, 0, fmt.Errorf("统计关注 Feed 总数失败: %w", err)
	}

	// 查询 Feed 列表
	rows, err := r.db.QueryContext(ctx, `
		SELECT 
			c.id, c.author_id, c.type, c.status, c.title, c.text, c.summary,
			c.media_urls, c.tags, c.reply_to_id, c.quote_id,
			c.like_count, c.comment_count, c.repost_count, c.bookmark_count, c.view_count,
			c.created_at, c.updated_at, c.published_at, c.expires_at,
			c.is_pinned, c.comments_disabled, c.language
		FROM contents c
		JOIN follows f ON c.author_id = f.following_id
		WHERE f.follower_id = $1 
		  AND c.status = 2
		  AND (c.expires_at IS NULL OR c.expires_at > NOW())
		ORDER BY c.published_at DESC NULLS LAST, c.created_at DESC
		LIMIT $2 OFFSET $3
	`, userID, limit, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("查询关注 Feed 失败: %w", err)
	}
	defer rows.Close()

	return scanFeedItems(rows), total, nil
}

// GetUserFeed 获取指定用户的 Feed（用户主页）
func (r *TimelineRepository) GetUserFeed(ctx context.Context, targetUserID string, limit, offset int) ([]*FeedItem, int, error) {
	// 获取总数
	var total int
	err := r.db.QueryRowContext(ctx, `
		SELECT COUNT(*) 
		FROM contents 
		WHERE author_id = $1 
		  AND status = 2
		  AND (expires_at IS NULL OR expires_at > NOW())
	`, targetUserID).Scan(&total)
	if err != nil {
		return nil, 0, fmt.Errorf("统计用户 Feed 总数失败: %w", err)
	}

	// 查询 Feed 列表
	rows, err := r.db.QueryContext(ctx, `
		SELECT 
			c.id, c.author_id, c.type, c.status, c.title, c.text, c.summary,
			c.media_urls, c.tags, c.reply_to_id, c.quote_id,
			c.like_count, c.comment_count, c.repost_count, c.bookmark_count, c.view_count,
			c.created_at, c.updated_at, c.published_at, c.expires_at,
			c.is_pinned, c.comments_disabled, c.language
		FROM contents c
		WHERE c.author_id = $1 
		  AND c.status = 2
		  AND (c.expires_at IS NULL OR c.expires_at > NOW())
		ORDER BY c.is_pinned DESC, c.published_at DESC NULLS LAST, c.created_at DESC
		LIMIT $2 OFFSET $3
	`, targetUserID, limit, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("查询用户 Feed 失败: %w", err)
	}
	defer rows.Close()

	return scanFeedItems(rows), total, nil
}

// GetHotFeed 获取热门 Feed
func (r *TimelineRepository) GetHotFeed(ctx context.Context, timeRange string, limit, offset int) ([]*FeedItem, int, error) {
	// 根据时间范围确定查询条件
	var timeCondition string
	switch timeRange {
	case "day":
		timeCondition = "AND c.created_at > NOW() - INTERVAL '1 day'"
	case "week":
		timeCondition = "AND c.created_at > NOW() - INTERVAL '7 days'"
	case "month":
		timeCondition = "AND c.created_at > NOW() - INTERVAL '30 days'"
	default:
		timeCondition = "AND c.created_at > NOW() - INTERVAL '7 days'"
	}

	// 获取总数
	var total int
	countQuery := fmt.Sprintf(`
		SELECT COUNT(*) 
		FROM contents c
		WHERE c.status = 2
		  AND (c.expires_at IS NULL OR c.expires_at > NOW())
		  %s
	`, timeCondition)
	r.db.QueryRowContext(ctx, countQuery).Scan(&total)

	// 查询热门 Feed（按互动量排序）
	query := fmt.Sprintf(`
		SELECT 
			c.id, c.author_id, c.type, c.status, c.title, c.text, c.summary,
			c.media_urls, c.tags, c.reply_to_id, c.quote_id,
			c.like_count, c.comment_count, c.repost_count, c.bookmark_count, c.view_count,
			c.created_at, c.updated_at, c.published_at, c.expires_at,
			c.is_pinned, c.comments_disabled, c.language
		FROM contents c
		WHERE c.status = 2
		  AND (c.expires_at IS NULL OR c.expires_at > NOW())
		  %s
		ORDER BY (c.like_count + c.comment_count * 2 + c.repost_count * 3) DESC, c.created_at DESC
		LIMIT $1 OFFSET $2
	`, timeCondition)

	rows, err := r.db.QueryContext(ctx, query, limit, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("查询热门 Feed 失败: %w", err)
	}
	defer rows.Close()

	return scanFeedItems(rows), total, nil
}

// GetContentByID 获取单个内容
func (r *TimelineRepository) GetContentByID(ctx context.Context, contentID string) (*FeedItem, error) {
	row := r.db.QueryRowContext(ctx, `
		SELECT 
			c.id, c.author_id, c.type, c.status, c.title, c.text, c.summary,
			c.media_urls, c.tags, c.reply_to_id, c.quote_id,
			c.like_count, c.comment_count, c.repost_count, c.bookmark_count, c.view_count,
			c.created_at, c.updated_at, c.published_at, c.expires_at,
			c.is_pinned, c.comments_disabled, c.language
		FROM contents c
		WHERE c.id = $1 AND c.status != 4
	`, contentID)

	item := &FeedItem{}
	var title, summary, replyToID, quoteID, language sql.NullString
	var publishedAt, expiresAt sql.NullTime

	err := row.Scan(
		&item.ContentID, &item.AuthorID, &item.ContentType, &item.Status,
		&title, &item.Text, &summary,
		pq.Array(&item.MediaURLs), pq.Array(&item.Tags),
		&replyToID, &quoteID,
		&item.LikeCount, &item.CommentCount, &item.RepostCount,
		&item.BookmarkCount, &item.ViewCount,
		&item.CreatedAt, &item.UpdatedAt, &publishedAt, &expiresAt,
		&item.IsPinned, &item.CommentsDisabled, &language,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	item.Title = title.String
	item.Summary = summary.String
	item.ReplyToID = replyToID.String
	item.QuoteID = quoteID.String
	item.Language = language.String
	if publishedAt.Valid {
		item.PublishedAt = &publishedAt.Time
	}
	if expiresAt.Valid {
		item.ExpiresAt = &expiresAt.Time
	}

	return item, nil
}

// GetContentIDs 从 FeedItem 列表中提取内容 ID
func GetContentIDs(items []*FeedItem) []string {
	ids := make([]string, len(items))
	for i, item := range items {
		ids[i] = item.ContentID
	}
	return ids
}

// scanFeedItems 扫描 Feed 条目列表
func scanFeedItems(rows *sql.Rows) []*FeedItem {
	var items []*FeedItem
	for rows.Next() {
		item := &FeedItem{}
		var title, summary, replyToID, quoteID, language sql.NullString
		var publishedAt, expiresAt sql.NullTime

		err := rows.Scan(
			&item.ContentID, &item.AuthorID, &item.ContentType, &item.Status,
			&title, &item.Text, &summary,
			pq.Array(&item.MediaURLs), pq.Array(&item.Tags),
			&replyToID, &quoteID,
			&item.LikeCount, &item.CommentCount, &item.RepostCount,
			&item.BookmarkCount, &item.ViewCount,
			&item.CreatedAt, &item.UpdatedAt, &publishedAt, &expiresAt,
			&item.IsPinned, &item.CommentsDisabled, &language,
		)
		if err != nil {
			continue
		}

		item.Title = title.String
		item.Summary = summary.String
		item.ReplyToID = replyToID.String
		item.QuoteID = quoteID.String
		item.Language = language.String
		if publishedAt.Valid {
			item.PublishedAt = &publishedAt.Time
		}
		if expiresAt.Valid {
			item.ExpiresAt = &expiresAt.Time
		}

		items = append(items, item)
	}
	return items
}
