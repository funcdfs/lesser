// Package messaging 提供 RabbitMQ 消息发布/订阅功能
package messaging

import (
	"context"

	"github.com/funcdfs/lesser/pkg/broker"
)

// EventPublisher 事件发布者
// 实现 logic 层定义的 EventPublisher 接口
type EventPublisher struct {
	publisher *broker.Publisher
}

// NewEventPublisher 创建事件发布者
func NewEventPublisher(publisher *broker.Publisher) *EventPublisher {
	return &EventPublisher{
		publisher: publisher,
	}
}

// PublishCommentCreated 发布评论创建事件
func (p *EventPublisher) PublishCommentCreated(ctx context.Context, commentID, authorID, contentID, contentAuthorID, parentID, parentAuthorID, text string) {
	if p.publisher == nil {
		return
	}

	event := broker.CommentCreatedEvent{
		CommentID:       commentID,
		AuthorID:        authorID,
		ContentID:       contentID,
		ContentAuthorID: contentAuthorID,
		ParentID:        parentID,
		ParentAuthorID:  parentAuthorID,
		Text:            text,
	}
	p.publisher.PublishAsync(ctx, broker.EventCommentCreated, event)
}

// PublishCommentLiked 发布评论点赞事件
func (p *EventPublisher) PublishCommentLiked(ctx context.Context, commentID, commentAuthorID, likerID string) {
	if p.publisher == nil {
		return
	}

	event := broker.CommentLikedEvent{
		CommentID:       commentID,
		CommentAuthorID: commentAuthorID,
		LikerID:         likerID,
	}
	p.publisher.PublishAsync(ctx, broker.EventCommentLiked, event)
}

// PublishUserMentioned 发布用户被 @ 事件（评论中的 @）
func (p *EventPublisher) PublishUserMentioned(ctx context.Context, mentionedUserID, mentionerID, commentID string) {
	if p.publisher == nil {
		return
	}

	event := broker.UserMentionedEvent{
		MentionedUserID: mentionedUserID,
		MentionerID:     mentionerID,
		ContentID:       commentID,
		ContentType:     "comment",
	}
	p.publisher.PublishAsync(ctx, broker.EventUserMentioned, event)
}
