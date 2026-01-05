// Package broker 提供 RabbitMQ 消息队列封装
// Deprecated: 请使用 github.com/funcdfs/lesser/pkg/mq 包
package broker

import "github.com/funcdfs/lesser/pkg/mq"

// ============================================================================
// 事件路由键常量
// ============================================================================

const (
	// 评论相关事件
	EventCommentCreated = mq.EventCommentCreated
	EventCommentLiked   = mq.EventCommentLiked

	// 内容相关事件
	EventContentCreated    = mq.EventContentCreated
	EventContentUpdated    = mq.EventContentUpdated
	EventContentDeleted    = mq.EventContentDeleted
	EventContentLiked      = mq.EventContentLiked
	EventContentReposted   = mq.EventContentReposted
	EventContentBookmarked = mq.EventContentBookmarked

	// 用户相关事件
	EventUserFollowed  = mq.EventUserFollowed
	EventUserMentioned = mq.EventUserMentioned
)

// ============================================================================
// 事件数据结构别名
// ============================================================================

// CommentCreatedEvent 评论创建事件
// Deprecated: 请使用 mq.CommentCreatedEvent
type CommentCreatedEvent = mq.CommentCreatedEvent

// CommentLikedEvent 评论点赞事件
// Deprecated: 请使用 mq.CommentLikedEvent
type CommentLikedEvent = mq.CommentLikedEvent

// ContentLikedEvent 内容点赞事件
// Deprecated: 请使用 mq.ContentLikedEvent
type ContentLikedEvent = mq.ContentLikedEvent

// ContentRepostedEvent 内容转发事件
// Deprecated: 请使用 mq.ContentRepostedEvent
type ContentRepostedEvent = mq.ContentRepostedEvent

// ContentBookmarkedEvent 内容收藏事件
// Deprecated: 请使用 mq.ContentBookmarkedEvent
type ContentBookmarkedEvent = mq.ContentBookmarkedEvent

// UserFollowedEvent 用户关注事件
// Deprecated: 请使用 mq.UserFollowedEvent
type UserFollowedEvent = mq.UserFollowedEvent

// UserMentionedEvent 用户被 @ 事件
// Deprecated: 请使用 mq.UserMentionedEvent
type UserMentionedEvent = mq.UserMentionedEvent

// ContentIndexEvent 内容索引事件
// Deprecated: 请使用 mq.ContentIndexEvent
type ContentIndexEvent = mq.ContentIndexEvent
