// Package messaging 提供 RabbitMQ 事件消费者
package messaging

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"

	"github.com/funcdfs/lesser/pkg/mq"
	"github.com/funcdfs/lesser/pkg/log"
	"github.com/funcdfs/lesser/search/internal/logic"
)

// EventWorker 事件消费者
// 负责消费 RabbitMQ 中的内容索引事件
type EventWorker struct {
	searchService *logic.SearchService
	worker        *mq.Worker
	log           *log.Logger
}

// NewEventWorker 创建事件消费者实例
func NewEventWorker(searchService *logic.SearchService, rabbitURL string, log *log.Logger) *EventWorker {
	return &EventWorker{
		searchService: searchService,
		worker:        mq.NewWorker(rabbitURL, log),
		log:           log,
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
	var event mq.ContentIndexEvent
	if err := json.Unmarshal(body, &event); err != nil {
		w.log.WithContext(ctx).Error("解析 ContentIndexEvent 失败",
			slog.Any("error", err),
			slog.String("body", string(body)))
		return nil // 返回 nil 避免重试，因为消息格式错误无法修复
	}

	w.log.WithContext(ctx).Debug("处理内容创建事件",
		slog.String("content_id", event.ContentID),
		slog.String("content_type", event.ContentType))

	// 更新搜索索引（这里简化处理，实际可能需要生成向量嵌入）
	text := event.Title + " " + event.Text
	if err := w.searchService.IndexContent(ctx, event.ContentID, event.AuthorID, event.Title, event.Text, event.ContentType); err != nil {
		w.log.WithContext(ctx).Error("索引内容失败",
			slog.Any("error", err),
			slog.String("content_id", event.ContentID))
		return fmt.Errorf("索引内容失败: %w", err)
	}

	w.log.WithContext(ctx).Info("内容已索引",
		slog.String("content_id", event.ContentID),
		slog.Int("text_length", len(text)))

	return nil
}

// handleContentUpdated 处理内容更新事件
func (w *EventWorker) handleContentUpdated(ctx context.Context, body []byte) error {
	var event mq.ContentIndexEvent
	if err := json.Unmarshal(body, &event); err != nil {
		w.log.WithContext(ctx).Error("解析 ContentIndexEvent 失败",
			slog.Any("error", err),
			slog.String("body", string(body)))
		return nil
	}

	w.log.WithContext(ctx).Debug("处理内容更新事件",
		slog.String("content_id", event.ContentID))

	// 更新搜索索引
	if err := w.searchService.IndexContent(ctx, event.ContentID, event.AuthorID, event.Title, event.Text, event.ContentType); err != nil {
		w.log.WithContext(ctx).Error("更新索引失败",
			slog.Any("error", err),
			slog.String("content_id", event.ContentID))
		return fmt.Errorf("更新索引失败: %w", err)
	}

	w.log.WithContext(ctx).Info("内容索引已更新",
		slog.String("content_id", event.ContentID))

	return nil
}

// handleContentDeleted 处理内容删除事件
func (w *EventWorker) handleContentDeleted(ctx context.Context, body []byte) error {
	var event mq.ContentIndexEvent
	if err := json.Unmarshal(body, &event); err != nil {
		w.log.WithContext(ctx).Error("解析 ContentIndexEvent 失败",
			slog.Any("error", err),
			slog.String("body", string(body)))
		return nil
	}

	w.log.WithContext(ctx).Debug("处理内容删除事件",
		slog.String("content_id", event.ContentID))

	// 从搜索索引中删除
	if err := w.searchService.DeleteContentIndex(ctx, event.ContentID); err != nil {
		w.log.WithContext(ctx).Error("删除索引失败",
			slog.Any("error", err),
			slog.String("content_id", event.ContentID))
		return fmt.Errorf("删除索引失败: %w", err)
	}

	w.log.WithContext(ctx).Info("内容索引已删除",
		slog.String("content_id", event.ContentID))

	return nil
}
