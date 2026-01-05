// Package messaging 提供 RabbitMQ 消息发布/订阅功能
package messaging

import (
	"context"

	"github.com/funcdfs/lesser/pkg/mq"
)

// EventPublisher 事件发布者
// 实现 logic 层定义的 Publisher 接口
type EventPublisher struct {
	publisher *mq.Publisher
}

// NewEventPublisher 创建事件发布者
func NewEventPublisher(publisher *mq.Publisher) *EventPublisher {
	return &EventPublisher{
		publisher: publisher,
	}
}

// PublishUserFollowed 发布用户关注事件
func (p *EventPublisher) PublishUserFollowed(ctx context.Context, followerID, followingID string) {
	if p.publisher == nil {
		return
	}

	event := mq.UserFollowedEvent{
		FollowerID:  followerID,
		FollowingID: followingID,
	}
	p.publisher.PublishAsync(ctx, mq.EventUserFollowed, event)
}
