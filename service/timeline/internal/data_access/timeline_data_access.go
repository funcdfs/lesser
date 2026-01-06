// Package data_access 提供 Timeline 服务的数据访问层
package data_access

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/funcdfs/lesser/pkg/log"
	"github.com/lib/pq"
)

// 时间范围常量
const (
	TimeRangeDay   = "day"
	TimeRangeWeek  = "week"
	TimeRangeMonth = "month"
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

// TimelineDataAccess Feed 流数据访问层
type TimelineDataAccess struct {
	db  *sql.DB
	log *log.Logger
}

// NewTimelineDataAccess 创建 Feed 流数据访问层实例
func NewTimelineDataAccess(db *sql.DB, logger *log.Logger) *TimelineDataAccess {
	return &TimelineDataAccess{
		db:  db,
		log: logger.With(log.String("component", "data_access")),
	}
}

// ============================================================================
// Feed 查询
// ============================================================================

// GetFollowingFeed 获取关注用户的 Feed 流
// 使用 idx_contents_feed_timeline 索引优化查询性能
func (da *TimelineDataAccess) GetFollowingFeed(ctx context.Context, userID string, limit, offset int) ([]*FeedItem, int, error) {
	// 获取总数
	var total int
	err := da.db.QueryRowContext(ctx, `
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
	rows, err := da.db.QueryContext(ctx, `
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

	items, err := scanFeedItems(rows)
	if err != nil {
		return nil, 0, err
	}

	return items, total, nil
}

// GetUserFeed 获取指定用户的 Feed（用户主页）
// 使用 idx_contents_user_feed 索引优化查询性能
// 置顶内容优先显示，然后按发布时间降序排列
func (da *TimelineDataAccess) GetUserFeed(ctx context.Context, targetUserID string, limit, offset int) ([]*FeedItem, int, error) {
	// 获取总数
	var total int
	err := da.db.QueryRowContext(ctx, `
		SELECT COUNT(*) 
		FROM contents 
		WHERE author_id = $1 
		  AND status = 2
		  AND (expires_at IS NULL OR expires_at > NOW())
	`, targetUserID).Scan(&total)
	if err != nil {
		return nil, 0, fmt.Errorf("统计用户 Feed 总数失败: %w", err)
	}

	// 查询 Feed 列表（置顶优先）
	rows, err := da.db.QueryContext(ctx, `
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

	items, err := scanFeedItems(rows)
	if err != nil {
		return nil, 0, err
	}

	return items, total, nil
}

// GetHotFeed 获取热门 Feed
// 按互动量排序：like_count + comment_count*2 + repost_count*3
func (da *TimelineDataAccess) GetHotFeed(ctx context.Context, timeRange string, limit, offset int) ([]*FeedItem, int, error) {
	// 根据时间范围确定查询条件
	interval := timeRangeToInterval(timeRange)

	// 获取总数
	var total int
	err := da.db.QueryRowContext(ctx, `
		SELECT COUNT(*) 
		FROM contents c
		WHERE c.status = 2
		  AND (c.expires_at IS NULL OR c.expires_at > NOW())
		  AND c.created_at > NOW() - $1::interval
	`, interval).Scan(&total)
	if err != nil {
		return nil, 0, fmt.Errorf("统计热门 Feed 总数失败: %w", err)
	}

	// 查询热门 Feed（按互动量排序）
	rows, err := da.db.QueryContext(ctx, `
		SELECT 
			c.id, c.author_id, c.type, c.status, c.title, c.text, c.summary,
			c.media_urls, c.tags, c.reply_to_id, c.quote_id,
			c.like_count, c.comment_count, c.repost_count, c.bookmark_count, c.view_count,
			c.created_at, c.updated_at, c.published_at, c.expires_at,
			c.is_pinned, c.comments_disabled, c.language
		FROM contents c
		WHERE c.status = 2
		  AND (c.expires_at IS NULL OR c.expires_at > NOW())
		  AND c.created_at > NOW() - $1::interval
		ORDER BY (c.like_count + c.comment_count * 2 + c.repost_count * 3) DESC, c.created_at DESC
		LIMIT $2 OFFSET $3
	`, interval, limit, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("查询热门 Feed 失败: %w", err)
	}
	defer rows.Close()

	items, err := scanFeedItems(rows)
	if err != nil {
		return nil, 0, err
	}

	return items, total, nil
}

// GetRecommendFeed 获取推荐 Feed
// 推荐算法：综合考虑内容热度、新鲜度、多样性
// 热度分数 = like_count + comment_count*2 + repost_count*3 + view_count*0.1
// 时间衰减：越新的内容权重越高
func (da *TimelineDataAccess) GetRecommendFeed(ctx context.Context, userID string, limit, offset int) ([]*FeedItem, int, error) {
	// 获取总数（排除用户自己的内容，增加发现性）
	var total int
	err := da.db.QueryRowContext(ctx, `
		SELECT COUNT(*) 
		FROM contents c
		WHERE c.status = 2
		  AND (c.expires_at IS NULL OR c.expires_at > NOW())
		  AND c.created_at > NOW() - INTERVAL '30 days'
		  AND ($1 = '' OR c.author_id != $1::uuid)
	`, userID).Scan(&total)
	if err != nil {
		return nil, 0, fmt.Errorf("统计推荐 Feed 总数失败: %w", err)
	}

	// 推荐算法查询
	// 综合评分 = 热度分数 * 时间衰减因子
	// 时间衰减：使用指数衰减，半衰期为 3 天
	rows, err := da.db.QueryContext(ctx, `
		SELECT 
			c.id, c.author_id, c.type, c.status, c.title, c.text, c.summary,
			c.media_urls, c.tags, c.reply_to_id, c.quote_id,
			c.like_count, c.comment_count, c.repost_count, c.bookmark_count, c.view_count,
			c.created_at, c.updated_at, c.published_at, c.expires_at,
			c.is_pinned, c.comments_disabled, c.language
		FROM contents c
		WHERE c.status = 2
		  AND (c.expires_at IS NULL OR c.expires_at > NOW())
		  AND c.created_at > NOW() - INTERVAL '30 days'
		  AND ($1 = '' OR c.author_id != $1::uuid)
		ORDER BY 
			(c.like_count + c.comment_count * 2 + c.repost_count * 3 + c.view_count * 0.1) 
			* EXP(-EXTRACT(EPOCH FROM (NOW() - c.created_at)) / (3 * 24 * 3600)) DESC,
			c.created_at DESC
		LIMIT $2 OFFSET $3
	`, userID, limit, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("查询推荐 Feed 失败: %w", err)
	}
	defer rows.Close()

	items, err := scanFeedItems(rows)
	if err != nil {
		return nil, 0, err
	}

	return items, total, nil
}

// GetContentByID 获取单个内容
func (da *TimelineDataAccess) GetContentByID(ctx context.Context, contentID string) (*FeedItem, error) {
	row := da.db.QueryRowContext(ctx, `
		SELECT 
			c.id, c.author_id, c.type, c.status, c.title, c.text, c.summary,
			c.media_urls, c.tags, c.reply_to_id, c.quote_id,
			c.like_count, c.comment_count, c.repost_count, c.bookmark_count, c.view_count,
			c.created_at, c.updated_at, c.published_at, c.expires_at,
			c.is_pinned, c.comments_disabled, c.language
		FROM contents c
		WHERE c.id = $1 AND c.status != 4
	`, contentID)

	item, err := scanSingleFeedItem(row)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("查询内容详情失败: %w", err)
	}

	return item, nil
}

// ============================================================================
// 辅助函数
// ============================================================================

// ExtractContentIDs 从 FeedItem 列表中提取内容 ID
func ExtractContentIDs(items []*FeedItem) []string {
	ids := make([]string, len(items))
	for i, item := range items {
		ids[i] = item.ContentID
	}
	return ids
}

// GetContentIDs 从 FeedItem 列表中提取内容 ID（兼容旧接口）
// Deprecated: 请使用 ExtractContentIDs
func GetContentIDs(items []*FeedItem) []string {
	return ExtractContentIDs(items)
}

// timeRangeToInterval 将时间范围转换为 PostgreSQL interval 字符串
func timeRangeToInterval(timeRange string) string {
	switch timeRange {
	case TimeRangeDay:
		return "1 day"
	case TimeRangeMonth:
		return "30 days"
	case TimeRangeWeek:
		fallthrough
	default:
		return "7 days"
	}
}

// scanFeedItems 扫描 Feed 条目列表
func scanFeedItems(rows *sql.Rows) ([]*FeedItem, error) {
	var items []*FeedItem
	for rows.Next() {
		item, err := scanFeedItemFromRows(rows)
		if err != nil {
			return nil, err
		}
		items = append(items, item)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("迭代 Feed 结果集失败: %w", err)
	}

	return items, nil
}

// scanFeedItemFromRows 从 rows 扫描单个 FeedItem
func scanFeedItemFromRows(rows *sql.Rows) (*FeedItem, error) {
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
		return nil, fmt.Errorf("扫描 Feed 条目失败: %w", err)
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

// scanSingleFeedItem 从单行查询结果扫描 FeedItem
func scanSingleFeedItem(row *sql.Row) (*FeedItem, error) {
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
