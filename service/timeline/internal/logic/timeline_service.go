// Package service 提供 Timeline 服务的业务逻辑层
package logic

import (
	"context"
	"log/slog"

	"github.com/funcdfs/lesser/timeline/internal/data_access"
)

// InteractionStatus 用户对内容的交互状态
type InteractionStatus struct {
	ContentID    string
	IsLiked      bool
	IsBookmarked bool
	IsReposted   bool
}

// InteractionClient Interaction 服务客户端接口
type InteractionClient interface {
	BatchGetInteractionStatus(ctx context.Context, userID string, contentIDs []string) ([]*InteractionStatus, error)
}

// FeedItemWithStatus 带交互状态的 Feed 条目
type FeedItemWithStatus struct {
	*data_access.FeedItem
	IsLiked      bool
	IsBookmarked bool
	IsReposted   bool
}

// TimelineService 时间线服务
type TimelineService struct {
	timelineRepo      *data_access.TimelineRepository
	interactionClient InteractionClient
	log               *slog.Logger
}

// NewTimelineService 创建时间线服务实例
func NewTimelineService(timelineRepo *data_access.TimelineRepository, interactionClient InteractionClient) *TimelineService {
	return &TimelineService{
		timelineRepo:      timelineRepo,
		interactionClient: interactionClient,
		log:               slog.Default().With(slog.String("component", "timeline_service")),
	}
}

// GetFollowingFeed 获取关注用户的 Feed 流
// 返回当前用户关注的所有用户发布的内容，按发布时间降序排列
func (s *TimelineService) GetFollowingFeed(ctx context.Context, userID string, limit, offset int) ([]*FeedItemWithStatus, int, error) {
	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}

	items, total, err := s.timelineRepo.GetFollowingFeed(ctx, userID, limit, offset)
	if err != nil {
		s.log.Error("获取关注 Feed 失败", slog.String("user_id", userID), slog.Any("error", err))
		return nil, 0, err
	}

	s.log.Debug("获取关注 Feed 成功", slog.String("user_id", userID), slog.Int("count", len(items)), slog.Int("total", total))
	return s.enrichWithInteractionStatus(ctx, userID, items), total, nil
}

// GetUserFeed 获取指定用户的 Feed（用户主页）
// 置顶内容优先显示，然后按发布时间降序排列
func (s *TimelineService) GetUserFeed(ctx context.Context, targetUserID, viewerID string, limit, offset int) ([]*FeedItemWithStatus, int, error) {
	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}

	items, total, err := s.timelineRepo.GetUserFeed(ctx, targetUserID, limit, offset)
	if err != nil {
		s.log.Error("获取用户 Feed 失败", slog.String("target_user_id", targetUserID), slog.Any("error", err))
		return nil, 0, err
	}

	s.log.Debug("获取用户 Feed 成功", slog.String("target_user_id", targetUserID), slog.Int("count", len(items)), slog.Int("total", total))
	return s.enrichWithInteractionStatus(ctx, viewerID, items), total, nil
}

// GetHotFeed 获取热门 Feed
// 按互动量排序（like_count + comment_count*2 + repost_count*3）
func (s *TimelineService) GetHotFeed(ctx context.Context, userID, timeRange string, limit, offset int) ([]*FeedItemWithStatus, int, error) {
	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}

	items, total, err := s.timelineRepo.GetHotFeed(ctx, timeRange, limit, offset)
	if err != nil {
		s.log.Error("获取热门 Feed 失败", slog.String("time_range", timeRange), slog.Any("error", err))
		return nil, 0, err
	}

	s.log.Debug("获取热门 Feed 成功", slog.String("time_range", timeRange), slog.Int("count", len(items)), slog.Int("total", total))
	return s.enrichWithInteractionStatus(ctx, userID, items), total, nil
}

// GetContentDetail 获取内容详情（包含交互状态）
func (s *TimelineService) GetContentDetail(ctx context.Context, contentID, viewerID string) (*FeedItemWithStatus, error) {
	item, err := s.timelineRepo.GetContentByID(ctx, contentID)
	if err != nil {
		s.log.Error("获取内容详情失败", slog.String("content_id", contentID), slog.Any("error", err))
		return nil, err
	}
	if item == nil {
		return nil, ErrContentNotFound
	}

	result := &FeedItemWithStatus{FeedItem: item}

	// 获取交互状态
	if viewerID != "" && s.interactionClient != nil {
		statuses, err := s.interactionClient.BatchGetInteractionStatus(ctx, viewerID, []string{contentID})
		if err != nil {
			// 获取交互状态失败不影响主流程，只记录日志
			s.log.Warn("获取内容交互状态失败", slog.String("content_id", contentID), slog.String("viewer_id", viewerID), slog.Any("error", err))
		} else if len(statuses) > 0 {
			result.IsLiked = statuses[0].IsLiked
			result.IsBookmarked = statuses[0].IsBookmarked
			result.IsReposted = statuses[0].IsReposted
		}
	}

	s.log.Debug("获取内容详情成功", slog.String("content_id", contentID))
	return result, nil
}

// enrichWithInteractionStatus 为 Feed 条目添加交互状态
// 调用 Interaction Service 批量获取用户对内容的点赞、收藏、转发状态
func (s *TimelineService) enrichWithInteractionStatus(ctx context.Context, userID string, items []*data_access.FeedItem) []*FeedItemWithStatus {
	result := make([]*FeedItemWithStatus, len(items))
	for i, item := range items {
		result[i] = &FeedItemWithStatus{FeedItem: item}
	}

	// 如果没有用户 ID 或没有交互客户端，直接返回
	if userID == "" || s.interactionClient == nil || len(items) == 0 {
		return result
	}

	// 批量获取交互状态
	contentIDs := data_access.GetContentIDs(items)
	statuses, err := s.interactionClient.BatchGetInteractionStatus(ctx, userID, contentIDs)
	if err != nil {
		// 获取失败不影响主流程，只记录日志
		s.log.Warn("批量获取交互状态失败", slog.String("user_id", userID), slog.Int("content_count", len(contentIDs)), slog.Any("error", err))
		return result
	}

	// 构建状态映射
	statusMap := make(map[string]*InteractionStatus)
	for _, status := range statuses {
		statusMap[status.ContentID] = status
	}

	// 填充交互状态
	for i, item := range items {
		if status, ok := statusMap[item.ContentID]; ok {
			result[i].IsLiked = status.IsLiked
			result[i].IsBookmarked = status.IsBookmarked
			result[i].IsReposted = status.IsReposted
		}
	}

	s.log.Debug("批量获取交互状态成功", slog.String("user_id", userID), slog.Int("content_count", len(contentIDs)))
	return result
}
