// Package service 提供 Interaction 服务的业务逻辑层
package service

import (
	"context"
	"errors"

	"github.com/funcdfs/lesser/interaction/internal/repository"
	contentpb "github.com/funcdfs/lesser/interaction/proto/content"
	"github.com/funcdfs/lesser/pkg/broker"
)

// 业务错误定义
var (
	ErrContentNotFound = errors.New("内容不存在")
)

// ContentClient Content 服务客户端接口
type ContentClient interface {
	UpdateCounter(ctx context.Context, contentID string, counterType contentpb.CounterType, delta int32) (int32, error)
	CheckContentExists(ctx context.Context, contentID string) (exists bool, commentsDisabled bool, err error)
	// GetContentAuthorID 获取内容作者 ID（用于发送通知）
	GetContentAuthorID(ctx context.Context, contentID string) (string, error)
}

// Publisher 消息发布者接口
type Publisher interface {
	PublishAsync(ctx context.Context, routingKey string, event interface{})
}

// InteractionService 交互服务
type InteractionService struct {
	likeRepo      repository.LikeRepositoryInterface
	bookmarkRepo  repository.BookmarkRepositoryInterface
	repostRepo    repository.RepostRepositoryInterface
	contentClient ContentClient
	publisher     Publisher // RabbitMQ 消息发布者（可选）
}

// NewInteractionService 创建交互服务实例
func NewInteractionService(
	likeRepo repository.LikeRepositoryInterface,
	bookmarkRepo repository.BookmarkRepositoryInterface,
	repostRepo repository.RepostRepositoryInterface,
	contentClient ContentClient,
) *InteractionService {
	return &InteractionService{
		likeRepo:      likeRepo,
		bookmarkRepo:  bookmarkRepo,
		repostRepo:    repostRepo,
		contentClient: contentClient,
	}
}

// SetPublisher 设置消息发布者（可选依赖）
func (s *InteractionService) SetPublisher(publisher Publisher) {
	s.publisher = publisher
}

// ============================================================================
// 点赞
// ============================================================================

// Like 点赞
func (s *InteractionService) Like(ctx context.Context, userID, contentID string) (int32, error) {
	// 检查内容是否存在
	exists, _, err := s.contentClient.CheckContentExists(ctx, contentID)
	if err != nil {
		return 0, err
	}
	if !exists {
		return 0, ErrContentNotFound
	}

	// 创建点赞记录
	created, err := s.likeRepo.Create(userID, contentID)
	if err != nil {
		return 0, err
	}

	// 只有实际创建了新记录才更新计数和发布事件
	if created {
		count, err := s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_LIKE, 1)
		if err != nil {
			return 0, err
		}

		// 异步发布点赞事件（用于通知）
		s.publishLikeEvent(ctx, userID, contentID)

		return count, nil
	}

	// 已经点赞过，返回当前计数（通过 delta=0 获取）
	return s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_LIKE, 0)
}

// publishLikeEvent 发布点赞事件
func (s *InteractionService) publishLikeEvent(ctx context.Context, userID, contentID string) {
	if s.publisher == nil {
		return
	}

	// 获取内容作者 ID
	authorID, err := s.contentClient.GetContentAuthorID(ctx, contentID)
	if err != nil || authorID == "" || authorID == userID {
		// 获取失败、作者为空、或自己点赞自己的内容，不发送通知
		return
	}

	event := broker.ContentLikedEvent{
		ContentID:       contentID,
		ContentAuthorID: authorID,
		LikerID:         userID,
	}
	s.publisher.PublishAsync(ctx, broker.EventContentLiked, event)
}

// Unlike 取消点赞
func (s *InteractionService) Unlike(ctx context.Context, userID, contentID string) (int32, error) {
	// 删除点赞记录
	deleted, err := s.likeRepo.Delete(userID, contentID)
	if err != nil {
		return 0, err
	}

	// 只有实际删除了记录才更新计数
	if deleted {
		return s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_LIKE, -1)
	}

	return s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_LIKE, 0)
}

// CheckLiked 检查是否已点赞
func (s *InteractionService) CheckLiked(userID, contentID string) (bool, error) {
	return s.likeRepo.Exists(userID, contentID)
}

// ============================================================================
// 收藏
// ============================================================================

// Bookmark 收藏
func (s *InteractionService) Bookmark(ctx context.Context, userID, contentID string) (int32, error) {
	// 检查内容是否存在
	exists, _, err := s.contentClient.CheckContentExists(ctx, contentID)
	if err != nil {
		return 0, err
	}
	if !exists {
		return 0, ErrContentNotFound
	}

	// 创建收藏记录
	created, err := s.bookmarkRepo.Create(userID, contentID)
	if err != nil {
		return 0, err
	}

	if created {
		count, err := s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_BOOKMARK, 1)
		if err != nil {
			return 0, err
		}

		// 异步发布收藏事件（用于通知）
		s.publishBookmarkEvent(ctx, userID, contentID)

		return count, nil
	}

	return s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_BOOKMARK, 0)
}

// publishBookmarkEvent 发布收藏事件
func (s *InteractionService) publishBookmarkEvent(ctx context.Context, userID, contentID string) {
	if s.publisher == nil {
		return
	}

	// 获取内容作者 ID
	authorID, err := s.contentClient.GetContentAuthorID(ctx, contentID)
	if err != nil || authorID == "" || authorID == userID {
		// 获取失败、作者为空、或自己收藏自己的内容，不发送通知
		return
	}

	event := broker.ContentBookmarkedEvent{
		ContentID:       contentID,
		ContentAuthorID: authorID,
		BookmarkerID:    userID,
	}
	s.publisher.PublishAsync(ctx, broker.EventContentBookmarked, event)
}

// Unbookmark 取消收藏
func (s *InteractionService) Unbookmark(ctx context.Context, userID, contentID string) (int32, error) {
	deleted, err := s.bookmarkRepo.Delete(userID, contentID)
	if err != nil {
		return 0, err
	}

	if deleted {
		return s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_BOOKMARK, -1)
	}

	return s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_BOOKMARK, 0)
}

// ListBookmarks 获取收藏列表
func (s *InteractionService) ListBookmarks(userID string, limit, offset int) ([]*repository.Bookmark, int, error) {
	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}
	return s.bookmarkRepo.List(userID, limit, offset)
}

// ============================================================================
// 转发
// ============================================================================

// CreateRepost 创建转发
func (s *InteractionService) CreateRepost(ctx context.Context, userID, contentID, quote string) (*repository.Repost, int32, error) {
	// 检查内容是否存在
	exists, _, err := s.contentClient.CheckContentExists(ctx, contentID)
	if err != nil {
		return nil, 0, err
	}
	if !exists {
		return nil, 0, ErrContentNotFound
	}

	// 创建转发记录
	repost, created, err := s.repostRepo.Create(userID, contentID, quote)
	if err != nil {
		return nil, 0, err
	}

	var count int32
	if created {
		count, _ = s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_REPOST, 1)

		// 异步发布转发事件（用于通知）
		s.publishRepostEvent(ctx, userID, contentID, repost.ID)
	} else {
		count, _ = s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_REPOST, 0)
	}

	return repost, count, nil
}

// publishRepostEvent 发布转发事件
func (s *InteractionService) publishRepostEvent(ctx context.Context, userID, contentID, repostID string) {
	if s.publisher == nil {
		return
	}

	// 获取内容作者 ID
	authorID, err := s.contentClient.GetContentAuthorID(ctx, contentID)
	if err != nil || authorID == "" || authorID == userID {
		// 获取失败、作者为空、或自己转发自己的内容，不发送通知
		return
	}

	event := broker.ContentRepostedEvent{
		ContentID:       contentID,
		ContentAuthorID: authorID,
		ReposterID:      userID,
		RepostID:        repostID,
	}
	s.publisher.PublishAsync(ctx, broker.EventContentReposted, event)
}

// DeleteRepost 删除转发
func (s *InteractionService) DeleteRepost(ctx context.Context, userID, contentID string) (int32, error) {
	deleted, err := s.repostRepo.Delete(userID, contentID)
	if err != nil {
		return 0, err
	}

	if deleted {
		return s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_REPOST, -1)
	}

	return s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_REPOST, 0)
}

// ============================================================================
// 批量查询
// ============================================================================

// InteractionStatus 用户对内容的交互状态
type InteractionStatus struct {
	ContentID    string
	IsLiked      bool
	IsBookmarked bool
	IsReposted   bool
}

// BatchGetInteractionStatus 批量获取用户对内容的交互状态
func (s *InteractionService) BatchGetInteractionStatus(userID string, contentIDs []string) ([]*InteractionStatus, error) {
	if len(contentIDs) == 0 {
		return []*InteractionStatus{}, nil
	}

	// 批量查询点赞状态
	likedMap, err := s.likeRepo.BatchExists(userID, contentIDs)
	if err != nil {
		return nil, err
	}

	// 批量查询收藏状态
	bookmarkedMap, err := s.bookmarkRepo.BatchExists(userID, contentIDs)
	if err != nil {
		return nil, err
	}

	// 批量查询转发状态
	repostedMap, err := s.repostRepo.BatchExists(userID, contentIDs)
	if err != nil {
		return nil, err
	}

	// 组装结果
	result := make([]*InteractionStatus, len(contentIDs))
	for i, contentID := range contentIDs {
		result[i] = &InteractionStatus{
			ContentID:    contentID,
			IsLiked:      likedMap[contentID],
			IsBookmarked: bookmarkedMap[contentID],
			IsReposted:   repostedMap[contentID],
		}
	}

	return result, nil
}
