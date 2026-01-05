// Package logic 提供 Interaction 服务的业务逻辑层
// 负责点赞、收藏、转发等交互功能的核心业务规则
package logic

import (
	"context"

	contentpb "github.com/funcdfs/lesser/interaction/gen_protos/content"
	"github.com/funcdfs/lesser/interaction/internal/data_access"
)

// ============================================================================
// 接口定义
// ============================================================================

// ContentClient Content 服务客户端接口
// 用于与 Content 服务通信，获取内容信息和更新计数器
type ContentClient interface {
	// UpdateCounter 更新内容计数器（点赞数、收藏数、转发数）
	UpdateCounter(ctx context.Context, contentID string, counterType contentpb.CounterType, delta int32) (int32, error)
	// CheckContentExists 检查内容是否存在
	CheckContentExists(ctx context.Context, contentID string) (exists bool, commentsDisabled bool, err error)
	// GetContentAuthorID 获取内容作者 ID（用于发送通知）
	GetContentAuthorID(ctx context.Context, contentID string) (string, error)
}

// EventPublisher 事件发布接口
// 由 messaging 层实现，用于发布交互事件到消息队列
type EventPublisher interface {
	// PublishContentLiked 发布内容点赞事件
	PublishContentLiked(ctx context.Context, contentID, contentAuthorID, likerID string)
	// PublishContentBookmarked 发布内容收藏事件
	PublishContentBookmarked(ctx context.Context, contentID, contentAuthorID, bookmarkerID string)
	// PublishContentReposted 发布内容转发事件
	PublishContentReposted(ctx context.Context, contentID, contentAuthorID, reposterID, repostID string)
}

// ============================================================================
// 服务实现
// ============================================================================

// InteractionService 交互服务
// 提供点赞、收藏、转发等交互功能的业务逻辑
type InteractionService struct {
	likeDA        data_access.LikeDataAccessInterface     // 点赞数据访问
	bookmarkDA    data_access.BookmarkDataAccessInterface // 收藏数据访问
	repostDA      data_access.RepostDataAccessInterface   // 转发数据访问
	contentClient ContentClient                           // Content 服务客户端
	publisher     EventPublisher                          // 事件发布者（可选）
}

// NewInteractionService 创建交互服务实例
func NewInteractionService(
	likeDA data_access.LikeDataAccessInterface,
	bookmarkDA data_access.BookmarkDataAccessInterface,
	repostDA data_access.RepostDataAccessInterface,
	contentClient ContentClient,
) *InteractionService {
	return &InteractionService{
		likeDA:        likeDA,
		bookmarkDA:    bookmarkDA,
		repostDA:      repostDA,
		contentClient: contentClient,
	}
}

// SetPublisher 设置事件发布者（可选依赖）
// 如果不设置，交互操作仍可正常执行，但不会发送通知
func (s *InteractionService) SetPublisher(publisher EventPublisher) {
	s.publisher = publisher
}

// ============================================================================
// 点赞
// ============================================================================

// Like 点赞内容
// 幂等操作：重复点赞不会增加计数，返回当前计数
// 成功点赞后会异步发布事件用于通知内容作者
func (s *InteractionService) Like(ctx context.Context, userID, contentID string) (int32, error) {
	if userID == "" || contentID == "" {
		return 0, ErrInvalidInput
	}

	// 检查内容是否存在
	exists, _, err := s.contentClient.CheckContentExists(ctx, contentID)
	if err != nil {
		return 0, err
	}
	if !exists {
		return 0, ErrContentNotFound
	}

	// 创建点赞记录（使用 ON CONFLICT DO NOTHING 保证幂等）
	created, err := s.likeDA.Create(userID, contentID)
	if err != nil {
		return 0, err
	}

	// 只有实际创建了新记录才更新计数和发布事件
	if created {
		count, err := s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_LIKE, 1)
		if err != nil {
			return 0, err
		}

		// 异步发布点赞事件（用于通知内容作者）
		s.publishLikeEvent(ctx, userID, contentID)

		return count, nil
	}

	// 已经点赞过，返回当前计数（通过 delta=0 获取）
	return s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_LIKE, 0)
}

// publishLikeEvent 发布点赞事件到消息队列
// 内部方法，不对外暴露
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

	s.publisher.PublishContentLiked(ctx, contentID, authorID, userID)
}

// Unlike 取消点赞
// 幂等操作：未点赞的内容取消点赞不会报错
func (s *InteractionService) Unlike(ctx context.Context, userID, contentID string) (int32, error) {
	if userID == "" || contentID == "" {
		return 0, ErrInvalidInput
	}

	// 删除点赞记录
	deleted, err := s.likeDA.Delete(userID, contentID)
	if err != nil {
		return 0, err
	}

	// 只有实际删除了记录才更新计数
	if deleted {
		return s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_LIKE, -1)
	}

	// 未点赞过，返回当前计数
	return s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_LIKE, 0)
}

// CheckLiked 检查是否已点赞
func (s *InteractionService) CheckLiked(userID, contentID string) (bool, error) {
	if userID == "" || contentID == "" {
		return false, ErrInvalidInput
	}
	return s.likeDA.Exists(userID, contentID)
}

// ============================================================================
// 收藏
// ============================================================================

// Bookmark 收藏内容
// 幂等操作：重复收藏不会增加计数，返回当前计数
// 成功收藏后会异步发布事件用于通知内容作者
func (s *InteractionService) Bookmark(ctx context.Context, userID, contentID string) (int32, error) {
	if userID == "" || contentID == "" {
		return 0, ErrInvalidInput
	}

	// 检查内容是否存在
	exists, _, err := s.contentClient.CheckContentExists(ctx, contentID)
	if err != nil {
		return 0, err
	}
	if !exists {
		return 0, ErrContentNotFound
	}

	// 创建收藏记录（使用 ON CONFLICT DO NOTHING 保证幂等）
	created, err := s.bookmarkDA.Create(userID, contentID)
	if err != nil {
		return 0, err
	}

	if created {
		count, err := s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_BOOKMARK, 1)
		if err != nil {
			return 0, err
		}

		// 异步发布收藏事件（用于通知内容作者）
		s.publishBookmarkEvent(ctx, userID, contentID)

		return count, nil
	}

	// 已经收藏过，返回当前计数
	return s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_BOOKMARK, 0)
}

// publishBookmarkEvent 发布收藏事件到消息队列
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

	s.publisher.PublishContentBookmarked(ctx, contentID, authorID, userID)
}

// Unbookmark 取消收藏
// 幂等操作：未收藏的内容取消收藏不会报错
func (s *InteractionService) Unbookmark(ctx context.Context, userID, contentID string) (int32, error) {
	if userID == "" || contentID == "" {
		return 0, ErrInvalidInput
	}

	deleted, err := s.bookmarkDA.Delete(userID, contentID)
	if err != nil {
		return 0, err
	}

	if deleted {
		return s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_BOOKMARK, -1)
	}

	// 未收藏过，返回当前计数
	return s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_BOOKMARK, 0)
}

// ListBookmarks 获取用户收藏列表
// limit: 每页数量，默认 20，最大 100
// offset: 偏移量
func (s *InteractionService) ListBookmarks(userID string, limit, offset int) ([]*data_access.Bookmark, int, error) {
	if userID == "" {
		return nil, 0, ErrInvalidInput
	}

	// 参数边界处理
	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}
	if offset < 0 {
		offset = 0
	}

	return s.bookmarkDA.List(userID, limit, offset)
}

// ============================================================================
// 转发
// ============================================================================

// CreateRepost 创建转发
// 幂等操作：重复转发返回已存在的转发记录，不会增加计数
// quote: 可选的引用文字
func (s *InteractionService) CreateRepost(ctx context.Context, userID, contentID, quote string) (*data_access.Repost, int32, error) {
	if userID == "" || contentID == "" {
		return nil, 0, ErrInvalidInput
	}

	// 检查内容是否存在
	exists, _, err := s.contentClient.CheckContentExists(ctx, contentID)
	if err != nil {
		return nil, 0, err
	}
	if !exists {
		return nil, 0, ErrContentNotFound
	}

	// 创建转发记录（使用 ON CONFLICT DO NOTHING 保证幂等）
	repost, created, err := s.repostDA.Create(userID, contentID, quote)
	if err != nil {
		return nil, 0, err
	}

	var count int32
	if created {
		count, _ = s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_REPOST, 1)

		// 异步发布转发事件（用于通知内容作者）
		s.publishRepostEvent(ctx, userID, contentID, repost.ID)
	} else {
		// 已经转发过，返回当前计数
		count, _ = s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_REPOST, 0)
	}

	return repost, count, nil
}

// publishRepostEvent 发布转发事件到消息队列
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

	s.publisher.PublishContentReposted(ctx, contentID, authorID, userID, repostID)
}

// DeleteRepost 删除转发
// 幂等操作：未转发的内容删除转发不会报错
func (s *InteractionService) DeleteRepost(ctx context.Context, userID, contentID string) (int32, error) {
	if userID == "" || contentID == "" {
		return 0, ErrInvalidInput
	}

	deleted, err := s.repostDA.Delete(userID, contentID)
	if err != nil {
		return 0, err
	}

	if deleted {
		return s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_REPOST, -1)
	}

	// 未转发过，返回当前计数
	return s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_REPOST, 0)
}

// ============================================================================
// 批量查询
// ============================================================================

// InteractionStatus 用户对内容的交互状态
type InteractionStatus struct {
	ContentID    string // 内容 ID
	IsLiked      bool   // 是否已点赞
	IsBookmarked bool   // 是否已收藏
	IsReposted   bool   // 是否已转发
}

// BatchGetInteractionStatus 批量获取用户对内容的交互状态
// 用于 Feed 列表展示时一次性获取多个内容的交互状态，减少 N+1 查询
func (s *InteractionService) BatchGetInteractionStatus(userID string, contentIDs []string) ([]*InteractionStatus, error) {
	if userID == "" {
		return nil, ErrInvalidInput
	}
	if len(contentIDs) == 0 {
		return []*InteractionStatus{}, nil
	}

	// 限制批量查询数量，防止内存溢出
	const maxBatchSize = 100
	if len(contentIDs) > maxBatchSize {
		contentIDs = contentIDs[:maxBatchSize]
	}

	// 批量查询点赞状态
	likedMap, err := s.likeDA.BatchExists(userID, contentIDs)
	if err != nil {
		return nil, err
	}

	// 批量查询收藏状态
	bookmarkedMap, err := s.bookmarkDA.BatchExists(userID, contentIDs)
	if err != nil {
		return nil, err
	}

	// 批量查询转发状态
	repostedMap, err := s.repostDA.BatchExists(userID, contentIDs)
	if err != nil {
		return nil, err
	}

	// 组装结果，保持与输入顺序一致
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
