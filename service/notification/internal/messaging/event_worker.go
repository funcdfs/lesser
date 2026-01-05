// Package messaging 提供 RabbitMQ 事件消费者
package messaging

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"

	"github.com/funcdfs/lesser/notification/internal/logic"
	"github.com/funcdfs/lesser/pkg/mq"
	"github.com/funcdfs/lesser/pkg/log"
)

// EventWorker 事件消费者
// 负责消费 RabbitMQ 中的事件并创建相应的通知
type EventWorker struct {
	notifService *logic.NotificationService
	worker       *mq.Worker
	log          *log.Logger
}

// NewEventWorker 创建事件消费者实例
func NewEventWorker(notifService *logic.NotificationService, rabbitURL string, log *log.Logger) *EventWorker {
	return &EventWorker{
		notifService: notifService,
		worker:       mq.NewWorker(rabbitURL, log),
		log:          log,
	}
}

// Start 启动事件消费者
// 订阅所有需要处理的事件队列
func (w *EventWorker) Start(ctx context.Context) error {
	configs := []mq.Config{
		{
			Queue:      "notification.content.liked",
			RoutingKey: mq.EventContentLiked,
			Handler:    w.handleContentLiked,
		},
		{
			Queue:      "notification.content.bookmarked",
			RoutingKey: mq.EventContentBookmarked,
			Handler:    w.handleContentBookmarked,
		},
		{
			Queue:      "notification.content.reposted",
			RoutingKey: mq.EventContentReposted,
			Handler:    w.handleContentReposted,
		},
		{
			Queue:      "notification.comment.created",
			RoutingKey: mq.EventCommentCreated,
			Handler:    w.handleCommentCreated,
		},
		{
			Queue:      "notification.comment.liked",
			RoutingKey: mq.EventCommentLiked,
			Handler:    w.handleCommentLiked,
		},
		{
			Queue:      "notification.user.followed",
			RoutingKey: mq.EventUserFollowed,
			Handler:    w.handleUserFollowed,
		},
		{
			Queue:      "notification.user.mentioned",
			RoutingKey: mq.EventUserMentioned,
			Handler:    w.handleUserMentioned,
		},
	}

	return w.worker.Start(ctx, configs...)
}

// Stop 停止事件消费者
func (w *EventWorker) Stop() {
	w.worker.Stop()
}

// handleContentLiked 处理内容点赞事件
func (w *EventWorker) handleContentLiked(ctx context.Context, body []byte) error {
	var event mq.ContentLikedEvent
	if err := json.Unmarshal(body, &event); err != nil {
		w.log.WithContext(ctx).Error("解析 ContentLikedEvent 失败",
			slog.Any("error", err),
			slog.String("body", string(body)))
		return nil // 返回 nil 避免重试，因为消息格式错误无法修复
	}

	w.log.WithContext(ctx).Debug("处理内容点赞事件",
		slog.String("content_id", event.ContentID),
		slog.String("liker_id", event.LikerID))

	_, err := w.notifService.CreateLikeNotification(ctx, event.ContentAuthorID, event.LikerID, event.ContentID)
	if err != nil {
		w.log.WithContext(ctx).Error("创建点赞通知失败",
			slog.Any("error", err),
			slog.String("content_id", event.ContentID))
		return fmt.Errorf("创建点赞通知失败: %w", err)
	}

	return nil
}

// handleContentBookmarked 处理内容收藏事件
func (w *EventWorker) handleContentBookmarked(ctx context.Context, body []byte) error {
	var event mq.ContentBookmarkedEvent
	if err := json.Unmarshal(body, &event); err != nil {
		w.log.WithContext(ctx).Error("解析 ContentBookmarkedEvent 失败",
			slog.Any("error", err),
			slog.String("body", string(body)))
		return nil
	}

	w.log.WithContext(ctx).Debug("处理内容收藏事件",
		slog.String("content_id", event.ContentID),
		slog.String("bookmarker_id", event.BookmarkerID))

	_, err := w.notifService.CreateBookmarkNotification(ctx, event.ContentAuthorID, event.BookmarkerID, event.ContentID)
	if err != nil {
		w.log.WithContext(ctx).Error("创建收藏通知失败",
			slog.Any("error", err),
			slog.String("content_id", event.ContentID))
		return fmt.Errorf("创建收藏通知失败: %w", err)
	}

	return nil
}

// handleContentReposted 处理内容转发事件
func (w *EventWorker) handleContentReposted(ctx context.Context, body []byte) error {
	var event mq.ContentRepostedEvent
	if err := json.Unmarshal(body, &event); err != nil {
		w.log.WithContext(ctx).Error("解析 ContentRepostedEvent 失败",
			slog.Any("error", err),
			slog.String("body", string(body)))
		return nil
	}

	w.log.WithContext(ctx).Debug("处理内容转发事件",
		slog.String("content_id", event.ContentID),
		slog.String("reposter_id", event.ReposterID))

	_, err := w.notifService.CreateRepostNotification(ctx, event.ContentAuthorID, event.ReposterID, event.ContentID)
	if err != nil {
		w.log.WithContext(ctx).Error("创建转发通知失败",
			slog.Any("error", err),
			slog.String("content_id", event.ContentID))
		return fmt.Errorf("创建转发通知失败: %w", err)
	}

	return nil
}

// handleCommentCreated 处理评论创建事件
func (w *EventWorker) handleCommentCreated(ctx context.Context, body []byte) error {
	var event mq.CommentCreatedEvent
	if err := json.Unmarshal(body, &event); err != nil {
		w.log.WithContext(ctx).Error("解析 CommentCreatedEvent 失败",
			slog.Any("error", err),
			slog.String("body", string(body)))
		return nil
	}

	w.log.WithContext(ctx).Debug("处理评论创建事件",
		slog.String("comment_id", event.CommentID),
		slog.String("author_id", event.AuthorID))

	// 如果是回复，通知父评论作者
	if event.ParentID != "" && event.ParentAuthorID != "" {
		_, err := w.notifService.CreateReplyNotification(ctx, event.ParentAuthorID, event.AuthorID, event.CommentID, event.Text)
		if err != nil {
			w.log.WithContext(ctx).Error("创建回复通知失败",
				slog.Any("error", err),
				slog.String("comment_id", event.CommentID))
			return fmt.Errorf("创建回复通知失败: %w", err)
		}
	}

	// 通知内容作者（如果不是回复自己的评论）
	if event.ContentAuthorID != "" && event.ContentAuthorID != event.ParentAuthorID {
		_, err := w.notifService.CreateCommentNotification(ctx, event.ContentAuthorID, event.AuthorID, event.ContentID, event.Text)
		if err != nil {
			w.log.WithContext(ctx).Error("创建评论通知失败",
				slog.Any("error", err),
				slog.String("content_id", event.ContentID))
			return fmt.Errorf("创建评论通知失败: %w", err)
		}
	}

	return nil
}

// handleCommentLiked 处理评论点赞事件
func (w *EventWorker) handleCommentLiked(ctx context.Context, body []byte) error {
	var event mq.CommentLikedEvent
	if err := json.Unmarshal(body, &event); err != nil {
		w.log.WithContext(ctx).Error("解析 CommentLikedEvent 失败",
			slog.Any("error", err),
			slog.String("body", string(body)))
		return nil
	}

	w.log.WithContext(ctx).Debug("处理评论点赞事件",
		slog.String("comment_id", event.CommentID),
		slog.String("liker_id", event.LikerID))

	// 使用 CreateLikeNotification 但 target_type 为 comment
	_, err := w.notifService.Create(ctx, event.CommentAuthorID, 1, event.LikerID, "comment", event.CommentID, "")
	if err != nil {
		w.log.WithContext(ctx).Error("创建评论点赞通知失败",
			slog.Any("error", err),
			slog.String("comment_id", event.CommentID))
		return fmt.Errorf("创建评论点赞通知失败: %w", err)
	}

	return nil
}

// handleUserFollowed 处理用户关注事件
func (w *EventWorker) handleUserFollowed(ctx context.Context, body []byte) error {
	var event mq.UserFollowedEvent
	if err := json.Unmarshal(body, &event); err != nil {
		w.log.WithContext(ctx).Error("解析 UserFollowedEvent 失败",
			slog.Any("error", err),
			slog.String("body", string(body)))
		return nil
	}

	w.log.WithContext(ctx).Debug("处理用户关注事件",
		slog.String("follower_id", event.FollowerID),
		slog.String("following_id", event.FollowingID))

	_, err := w.notifService.CreateFollowNotification(ctx, event.FollowingID, event.FollowerID)
	if err != nil {
		w.log.WithContext(ctx).Error("创建关注通知失败",
			slog.Any("error", err),
			slog.String("following_id", event.FollowingID))
		return fmt.Errorf("创建关注通知失败: %w", err)
	}

	return nil
}

// handleUserMentioned 处理用户被 @ 事件
func (w *EventWorker) handleUserMentioned(ctx context.Context, body []byte) error {
	var event mq.UserMentionedEvent
	if err := json.Unmarshal(body, &event); err != nil {
		w.log.WithContext(ctx).Error("解析 UserMentionedEvent 失败",
			slog.Any("error", err),
			slog.String("body", string(body)))
		return nil
	}

	w.log.WithContext(ctx).Debug("处理用户被 @ 事件",
		slog.String("mentioned_user_id", event.MentionedUserID),
		slog.String("mentioner_id", event.MentionerID))

	_, err := w.notifService.CreateMentionNotification(ctx, event.MentionedUserID, event.MentionerID, event.ContentType, event.ContentID)
	if err != nil {
		w.log.WithContext(ctx).Error("创建 @ 通知失败",
			slog.Any("error", err),
			slog.String("mentioned_user_id", event.MentionedUserID))
		return fmt.Errorf("创建 @ 通知失败: %w", err)
	}

	return nil
}
