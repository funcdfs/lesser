// Package messaging 提供 RabbitMQ 事件消费者
package messaging

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/funcdfs/lesser/pkg/log"
	"github.com/funcdfs/lesser/pkg/mq"
	"github.com/funcdfs/lesser/search/internal/logic"
)

// EventWorker 事件消费者
// 负责消费 RabbitMQ 中的内容索引事件
type EventWorker struct {
	svc    *logic.SearchService
	worker *mq.Worker
	log    *log.Logger
}

// NewEventWorker 创建事件消费者实例
func NewEventWorker(svc *logic.SearchService, rabbitURL string, logger *log.Logger) *EventWorker {
	return &EventWorker{
		svc:    svc,
		worker: mq.NewWorker(rabbitURL, logger),
		log:    logger.With(log.String("component", "event_worker")),
	}
}

// Start 启动事件消费者
// 订阅内容索引相关的事件队列
func (w *EventWorker) Start(ctx context.Context) error {
	configs := []mq.Config{
		{
			Queue:      "search.content.created",
			RoutingKey: mq.EventContentCreated,
			Handler:    w.handleContentCreated,
		},
		{
			Queue:      "search.content.updated",
			RoutingKey: mq.EventContentUpdated,
			Handler:    w.handleContentUpdated,
		},
		{
			Queue:      "search.content.deleted",
			RoutingKey: mq.EventContentDeleted,
			Handler:    w.handleContentDeleted,
		},
	}

	return w.worker.Start(ctx, configs...)
}

// Stop 停止事件消费者
func (w *EventWorker) Stop() {
	w.worker.Stop()
}

// handleContentCreated 处理内容创建事件
func (w *EventWorker) handleContentCreated(ctx context.Context, body []byte) error {
	event, err := w.parseContentEvent(ctx, body)
	if err != nil {
		return nil // 消息格式错误，不重试
	}

	w.log.WithContext(ctx).Debug("处理内容创建事件",
		log.String("content_id", event.ContentID),
		log.String("content_type", event.ContentType))

	if err := w.svc.IndexContent(ctx, event.ContentID, event.AuthorID, event.Title, event.Text, event.ContentType); err != nil {
		w.log.WithContext(ctx).Error("索引内容失败",
			log.String("content_id", event.ContentID),
			log.Any("error", err))
		return fmt.Errorf("索引内容失败: %w", err)
	}

	w.log.WithContext(ctx).Info("内容已索引", log.String("content_id", event.ContentID))
	return nil
}

// handleContentUpdated 处理内容更新事件
func (w *EventWorker) handleContentUpdated(ctx context.Context, body []byte) error {
	event, err := w.parseContentEvent(ctx, body)
	if err != nil {
		return nil
	}

	w.log.WithContext(ctx).Debug("处理内容更新事件", log.String("content_id", event.ContentID))

	if err := w.svc.IndexContent(ctx, event.ContentID, event.AuthorID, event.Title, event.Text, event.ContentType); err != nil {
		w.log.WithContext(ctx).Error("更新索引失败",
			log.String("content_id", event.ContentID),
			log.Any("error", err))
		return fmt.Errorf("更新索引失败: %w", err)
	}

	w.log.WithContext(ctx).Info("内容索引已更新", log.String("content_id", event.ContentID))
	return nil
}

// handleContentDeleted 处理内容删除事件
func (w *EventWorker) handleContentDeleted(ctx context.Context, body []byte) error {
	event, err := w.parseContentEvent(ctx, body)
	if err != nil {
		return nil
	}

	w.log.WithContext(ctx).Debug("处理内容删除事件", log.String("content_id", event.ContentID))

	if err := w.svc.DeleteContentIndex(ctx, event.ContentID); err != nil {
		w.log.WithContext(ctx).Error("删除索引失败",
			log.String("content_id", event.ContentID),
			log.Any("error", err))
		return fmt.Errorf("删除索引失败: %w", err)
	}

	w.log.WithContext(ctx).Info("内容索引已删除", log.String("content_id", event.ContentID))
	return nil
}

// parseContentEvent 解析内容索引事件
func (w *EventWorker) parseContentEvent(ctx context.Context, body []byte) (*mq.ContentIndexEvent, error) {
	var event mq.ContentIndexEvent
	if err := json.Unmarshal(body, &event); err != nil {
		w.log.WithContext(ctx).Error("解析 ContentIndexEvent 失败",
			log.Any("error", err),
			log.String("body", string(body)))
		return nil, err
	}
	return &event, nil
}
