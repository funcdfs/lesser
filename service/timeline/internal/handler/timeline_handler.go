// Package handler 提供 Timeline 服务的 gRPC 处理器
package handler

import (
	"context"
	"log/slog"

	"github.com/funcdfs/lesser/pkg/proto/common"
	"github.com/funcdfs/lesser/timeline/internal/service"
	contentpb "github.com/funcdfs/lesser/timeline/proto/content"
	pb "github.com/funcdfs/lesser/timeline/proto/timeline"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// TimelineHandler gRPC 处理器
type TimelineHandler struct {
	pb.UnimplementedTimelineServiceServer
	svc *service.TimelineService
	log *slog.Logger
}

// NewTimelineHandler 创建处理器
func NewTimelineHandler(svc *service.TimelineService, log *slog.Logger) *TimelineHandler {
	if log == nil {
		log = slog.Default()
	}
	return &TimelineHandler{
		svc: svc,
		log: log.With(slog.String("component", "handler")),
	}
}

// GetFollowingFeed 获取关注用户的 Feed 流
func (h *TimelineHandler) GetFollowingFeed(ctx context.Context, req *pb.GetFollowingFeedRequest) (*pb.GetFollowingFeedResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 不能为空")
	}

	page, pageSize := int32(1), int32(20)
	if req.Pagination != nil {
		if req.Pagination.Page > 0 {
			page = req.Pagination.Page
		}
		if req.Pagination.PageSize > 0 {
			pageSize = req.Pagination.PageSize
		}
	}

	items, total, err := h.svc.GetFollowingFeed(ctx, req.UserId, int(pageSize), int((page-1)*pageSize))
	if err != nil {
		return nil, status.Errorf(codes.Internal, "获取关注 Feed 失败: %v", err)
	}

	return &pb.GetFollowingFeedResponse{
		Items:      feedItemsToProto(items),
		Pagination: &common.Pagination{Page: page, PageSize: pageSize, Total: int32(total)},
	}, nil
}

// GetRecommendFeed 获取推荐 Feed 流（预留）
func (h *TimelineHandler) GetRecommendFeed(ctx context.Context, req *pb.GetRecommendFeedRequest) (*pb.GetRecommendFeedResponse, error) {
	return nil, status.Error(codes.Unimplemented, "推荐 Feed 功能暂未实现")
}

// GetUserFeed 获取指定用户的 Feed（用户主页）
func (h *TimelineHandler) GetUserFeed(ctx context.Context, req *pb.GetUserFeedRequest) (*pb.GetUserFeedResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 不能为空")
	}

	page, pageSize := int32(1), int32(20)
	if req.Pagination != nil {
		if req.Pagination.Page > 0 {
			page = req.Pagination.Page
		}
		if req.Pagination.PageSize > 0 {
			pageSize = req.Pagination.PageSize
		}
	}

	items, total, err := h.svc.GetUserFeed(ctx, req.UserId, req.ViewerId, int(pageSize), int((page-1)*pageSize))
	if err != nil {
		return nil, status.Errorf(codes.Internal, "获取用户 Feed 失败: %v", err)
	}

	return &pb.GetUserFeedResponse{
		Items:      feedItemsToProto(items),
		Pagination: &common.Pagination{Page: page, PageSize: pageSize, Total: int32(total)},
	}, nil
}

// GetHotFeed 获取热门 Feed
func (h *TimelineHandler) GetHotFeed(ctx context.Context, req *pb.GetHotFeedRequest) (*pb.GetHotFeedResponse, error) {
	page, pageSize := int32(1), int32(20)
	if req.Pagination != nil {
		if req.Pagination.Page > 0 {
			page = req.Pagination.Page
		}
		if req.Pagination.PageSize > 0 {
			pageSize = req.Pagination.PageSize
		}
	}

	timeRange := req.TimeRange
	if timeRange == "" {
		timeRange = "week"
	}

	items, total, err := h.svc.GetHotFeed(ctx, req.UserId, timeRange, int(pageSize), int((page-1)*pageSize))
	if err != nil {
		return nil, status.Errorf(codes.Internal, "获取热门 Feed 失败: %v", err)
	}

	return &pb.GetHotFeedResponse{
		Items:      feedItemsToProto(items),
		Pagination: &common.Pagination{Page: page, PageSize: pageSize, Total: int32(total)},
	}, nil
}

// GetContentDetail 获取内容详情（包含交互状态）
func (h *TimelineHandler) GetContentDetail(ctx context.Context, req *pb.GetContentDetailRequest) (*pb.GetContentDetailResponse, error) {
	if req.ContentId == "" {
		return nil, status.Error(codes.InvalidArgument, "content_id 不能为空")
	}

	item, err := h.svc.GetContentDetail(ctx, req.ContentId, req.ViewerId)
	if err != nil {
		if err == service.ErrContentNotFound {
			return nil, status.Error(codes.NotFound, "内容不存在")
		}
		return nil, status.Errorf(codes.Internal, "获取内容详情失败: %v", err)
	}

	return &pb.GetContentDetailResponse{
		Item: feedItemToProto(item),
	}, nil
}

// ============================================================================
// 转换函数
// ============================================================================

func feedItemsToProto(items []*service.FeedItemWithStatus) []*pb.FeedItem {
	result := make([]*pb.FeedItem, len(items))
	for i, item := range items {
		result[i] = feedItemToProto(item)
	}
	return result
}

func feedItemToProto(item *service.FeedItemWithStatus) *pb.FeedItem {
	if item == nil || item.FeedItem == nil {
		return nil
	}

	content := &contentpb.Content{
		Id:               item.ContentID,
		AuthorId:         item.AuthorID,
		Type:             contentpb.ContentType(item.ContentType),
		Status:           contentpb.ContentStatus(item.Status),
		Title:            item.Title,
		Text:             item.Text,
		Summary:          item.Summary,
		Tags:             item.Tags,
		ReplyToId:        item.ReplyToID,
		QuoteId:          item.QuoteID,
		LikeCount:        item.LikeCount,
		CommentCount:     item.CommentCount,
		RepostCount:      item.RepostCount,
		BookmarkCount:    item.BookmarkCount,
		ViewCount:        item.ViewCount,
		CreatedAt:        &common.Timestamp{Seconds: item.CreatedAt.Unix()},
		UpdatedAt:        &common.Timestamp{Seconds: item.UpdatedAt.Unix()},
		IsPinned:         item.IsPinned,
		CommentsDisabled: item.CommentsDisabled,
		Language:         item.Language,
	}

	// 设置媒体 URL
	for _, url := range item.MediaURLs {
		content.Media = append(content.Media, &contentpb.Media{Url: url})
	}

	if item.PublishedAt != nil {
		content.PublishedAt = &common.Timestamp{Seconds: item.PublishedAt.Unix()}
	}
	if item.ExpiresAt != nil {
		content.ExpiresAt = &common.Timestamp{Seconds: item.ExpiresAt.Unix()}
	}

	return &pb.FeedItem{
		Content:      content,
		IsLiked:      item.IsLiked,
		IsBookmarked: item.IsBookmarked,
		IsReposted:   item.IsReposted,
	}
}
