// Package messaging 提供 RabbitMQ 消息发布/订阅功能
package messaging

import (
	"context"

	"github.com/funcdfs/lesser/pkg/broker"
)

// EventPublisher 事件发布者
// 实现 logic 层定义的 Publisher 接口
type EventPublisher struct {
	publisher *broker.Publisher
}

// NewEventPublisher 创建事件发布者
func NewEventPublisher(publisher *broker.Publisher) *EventPublisher {
	return &EventPublisher{
		publisher: publisher,
	}
}

// PublishContentLiked 发布内容点赞事件
func (p *EventPublisher) PublishContentLiked(ctx context.Context, contentID, contentAuthorID, likerID string) {
	if p.publisher == nil {
		return
	}

	event := broker.ContentLikedEvent{
		ContentID:       contentID,
		ContentAuthorID: contentAuthorID,
		LikerID:         likerID,
	}
	p.publisher.PublishAsync(ctx, broker.EventContentLiked, event)
}

// PublishContentBookmarked 发布内容收藏事件
func (p *EventPublisher) PublishContentBookmarked(ctx context.Context, contentID, contentAuthorID, bookmarkerID string) {
	if p.publisher == nil {
		return
	}

	event := broker.ContentBookmarkedEvent{
		ContentID:       contentID,
		ContentAuthorID: contentAuthorID,
		BookmarkerID:    bookmarkerID,
	}
	p.publisher.PublishAsync(ctx, broker.EventContentBookmarked, event)
}

// PublishContentReposted 发布内容转发事件
func (p *EventPublisher) PublishContentReposted(ctx context.Context, contentID, contentAuthorID, reposterID, repostID string) {
	if p.publisher == nil {
		return
	}

	event := broker.ContentRepostedEvent{
		ContentID:       contentID,
		ContentAuthorID: contentAuthorID,
		ReposterID:      reposterID,
		RepostID:        repostID,
	}
	p.publisher.PublishAsync(ctx, broker.EventContentReposted, event)
}
