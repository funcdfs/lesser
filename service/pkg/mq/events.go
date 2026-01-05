// Package mq 提供 RabbitMQ 消息队列封装
package mq

// ============================================================================
// 事件路由键常量
// ============================================================================

const (
	// 评论相关事件
	EventCommentCreated = "comment.created" // 评论创建
	EventCommentLiked   = "comment.liked"   // 评论点赞

	// 内容相关事件
	EventContentCreated    = "content.created"    // 内容创建
	EventContentUpdated    = "content.updated"    // 内容更新
	EventContentDeleted    = "content.deleted"    // 内容删除
	EventContentLiked      = "content.liked"      // 内容点赞
	EventContentReposted   = "content.reposted"   // 内容转发
	EventContentBookmarked = "content.bookmarked" // 内容收藏

	// 用户相关事件
	EventUserFollowed  = "user.followed"  // 用户关注
	EventUserMentioned = "user.mentioned" // 用户被 @
)

// ============================================================================
// 事件数据结构
// ============================================================================

// CommentCreatedEvent 评论创建事件
type CommentCreatedEvent struct {
	CommentID       string `json:"comment_id"`
	AuthorID        string `json:"author_id"`
	ContentID       string `json:"content_id"`
	ContentAuthorID string `json:"content_author_id"` // 内容作者（通知接收者）
	ParentID        string `json:"parent_id"`         // 父评论 ID（回复场景）
	ParentAuthorID  string `json:"parent_author_id"`  // 父评论作者（回复通知接收者）
	Text            string `json:"text"`              // 评论内容摘要
}

// CommentLikedEvent 评论点赞事件
type CommentLikedEvent struct {
	CommentID       string `json:"comment_id"`
	CommentAuthorID string `json:"comment_author_id"` // 评论作者（通知接收者）
	LikerID         string `json:"liker_id"`          // 点赞者
}

// ContentLikedEvent 内容点赞事件
type ContentLikedEvent struct {
	ContentID       string `json:"content_id"`
	ContentAuthorID string `json:"content_author_id"` // 内容作者（通知接收者）
	LikerID         string `json:"liker_id"`          // 点赞者
}

// ContentRepostedEvent 内容转发事件
type ContentRepostedEvent struct {
	ContentID       string `json:"content_id"`
	ContentAuthorID string `json:"content_author_id"` // 内容作者（通知接收者）
	ReposterID      string `json:"reposter_id"`       // 转发者
	RepostID        string `json:"repost_id"`         // 转发记录 ID
}

// ContentBookmarkedEvent 内容收藏事件
type ContentBookmarkedEvent struct {
	ContentID       string `json:"content_id"`
	ContentAuthorID string `json:"content_author_id"` // 内容作者（通知接收者）
	BookmarkerID    string `json:"bookmarker_id"`     // 收藏者
}

// UserFollowedEvent 用户关注事件
type UserFollowedEvent struct {
	FollowerID  string `json:"follower_id"`  // 关注者
	FollowingID string `json:"following_id"` // 被关注者（通知接收者）
}

// UserMentionedEvent 用户被 @ 事件
type UserMentionedEvent struct {
	MentionedUserID string `json:"mentioned_user_id"` // 被 @ 的用户（通知接收者）
	MentionerID     string `json:"mentioner_id"`      // @ 发起者
	ContentID       string `json:"content_id"`        // 内容 ID
	ContentType     string `json:"content_type"`      // "content" 或 "comment"
}

// ContentIndexEvent 内容索引事件（搜索服务消费）
type ContentIndexEvent struct {
	ContentID   string `json:"content_id"`
	AuthorID    string `json:"author_id"`
	Title       string `json:"title"`
	Text        string `json:"text"`
	ContentType string `json:"content_type"` // story/short/article
	Action      string `json:"action"`       // create/update/delete
}
