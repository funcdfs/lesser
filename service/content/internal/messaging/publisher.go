// Package messaging 提供 RabbitMQ 消息发布功能
package messaging

import (
	"context"

	"github.com/funcdfs/lesser/pkg/mq"
)

// EventPublisher 事件发布者
// 实现 logic 层定义的 EventPublisher 接口
type EventPublisher struct {
	publisher *mq.Publisher
}

// NewEventPublisher 创建事件发布者
func NewEventPublisher(publisher *mq.Publisher) *EventPublisher {
	return &EventPublisher{
		publisher: publisher,
	}
}

// PublishContentCreated 发布内容创建事件（用于搜索索引）
func (p *EventPublisher) PublishContentCreated(ctx context.Context, contentID, authorID, title, text, contentType string) {
	if p.publisher == nil {
		return
	}

	event := mq.ContentIndexEvent{
		ContentID:   contentID,
		AuthorID:    authorID,
		Title:       title,
		Text:        text,
		ContentType: contentType,
		Action:      "create",
	}
	p.publisher.PublishAsync(ctx, mq.EventContentCreated, event)
}

// PublishContentUpdated 发布内容更新事件（用于搜索索引）
func (p *EventPublisher) PublishContentUpdated(ctx context.Context, contentID, authorID, title, text, contentType string) {
	if p.publisher == nil {
		return
	}

	event := mq.ContentIndexEvent{
		ContentID:   contentID,
		AuthorID:    authorID,
		Title:       title,
		Text:        text,
		ContentType: contentType,
		Action:      "update",
	}
	p.publisher.PublishAsync(ctx, mq.EventContentUpdated, event)
}

// PublishContentDeleted 发布内容删除事件（用于搜索索引）
func (p *EventPublisher) PublishContentDeleted(ctx context.Context, contentID string) {
	if p.publisher == nil {
		return
	}

	event := mq.ContentIndexEvent{
		ContentID: contentID,
		Action:    "delete",
	}
	p.publisher.PublishAsync(ctx, mq.EventContentDeleted, event)
}

// PublishUserMentioned 发布用户被 @ 事件
func (p *EventPublisher) PublishUserMentioned(ctx context.Context, mentionedUserID, mentionerID, contentID string) {
	if p.publisher == nil {
		return
	}

	event := mq.UserMentionedEvent{
		MentionedUserID: mentionedUserID,
		MentionerID:     mentionerID,
		ContentID:       contentID,
		ContentType:     "content",
	}
	p.publisher.PublishAsync(ctx, mq.EventUserMentioned, event)
}
