// Package handler 提供 Timeline 服务的 gRPC 处理器
package handler

import (
	"context"

	contentpb "github.com/funcdfs/lesser/content/gen_protos/content"
	"github.com/funcdfs/lesser/pkg/gen_protos/common"
	"github.com/funcdfs/lesser/pkg/log"
	"github.com/funcdfs/lesser/pkg/page"
	pb "github.com/funcdfs/lesser/timeline/gen_protos/timeline"
	"github.com/funcdfs/lesser/timeline/internal/logic"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// TimelineHandler gRPC 处理器
type TimelineHandler struct {
	pb.UnimplementedTimelineServiceServer
	svc *logic.TimelineService
	log *log.Logger
}

// NewTimelineHandler 创建处理器
func NewTimelineHandler(svc *logic.TimelineService, logger *log.Logger) *TimelineHandler {
	if logger == nil {
		logger = log.Global()
	}
	return &TimelineHandler{
		svc: svc,
		log: logger.With(log.String("component", "handler")),
	}
}

// GetFollowingFeed 获取关注用户的 Feed 流
func (h *TimelineHandler) GetFollowingFeed(ctx context.Context, req *pb.GetFollowingFeedRequest) (*pb.GetFollowingFeedResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 不能为空")
	}

	pageReq := extractPagination(req.Pagination)
	limit, offset := int(pageReq.Limit()), int(pageReq.Offset())

	items, total, err := h.svc.GetFollowingFeed(ctx, req.UserId, limit, offset)
	if err != nil {
		h.log.WithContext(ctx).Error("获取关注 Feed 失败",
			log.String("user_id", req.UserId),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.GetFollowingFeedResponse{
		Items:      feedItemsToProto(items),
		Pagination: &common.Pagination{Page: pageReq.Page, PageSize: pageReq.PageSize, Total: int32(total)},
	}, nil
}

// GetRecommendFeed 获取推荐 Feed 流
func (h *TimelineHandler) GetRecommendFeed(ctx context.Context, req *pb.GetRecommendFeedRequest) (*pb.GetRecommendFeedResponse, error) {
	pageReq := extractPagination(req.Pagination)
	limit, offset := int(pageReq.Limit()), int(pageReq.Offset())

	// user_id 可选，用于个性化推荐和排除自己的内容
	userID := req.UserId

	items, total, err := h.svc.GetRecommendFeed(ctx, userID, limit, offset)
	if err != nil {
		h.log.WithContext(ctx).Error("获取推荐 Feed 失败",
			log.String("user_id", userID),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.GetRecommendFeedResponse{
		Items:      feedItemsToProto(items),
		Pagination: &common.Pagination{Page: pageReq.Page, PageSize: pageReq.PageSize, Total: int32(total)},
	}, nil
}

// GetUserFeed 获取指定用户的 Feed（用户主页）
func (h *TimelineHandler) GetUserFeed(ctx context.Context, req *pb.GetUserFeedRequest) (*pb.GetUserFeedResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 不能为空")
	}

	pageReq := extractPagination(req.Pagination)
	limit, offset := int(pageReq.Limit()), int(pageReq.Offset())

	items, total, err := h.svc.GetUserFeed(ctx, req.UserId, req.ViewerId, limit, offset)
	if err != nil {
		h.log.WithContext(ctx).Error("获取用户 Feed 失败",
			log.String("user_id", req.UserId),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.GetUserFeedResponse{
		Items:      feedItemsToProto(items),
		Pagination: &common.Pagination{Page: pageReq.Page, PageSize: pageReq.PageSize, Total: int32(total)},
	}, nil
}

// GetHotFeed 获取热门 Feed
func (h *TimelineHandler) GetHotFeed(ctx context.Context, req *pb.GetHotFeedRequest) (*pb.GetHotFeedResponse, error) {
	pageReq := extractPagination(req.Pagination)
	limit, offset := int(pageReq.Limit()), int(pageReq.Offset())

	timeRange := req.TimeRange
	if timeRange == "" {
		timeRange = "week"
	}

	items, total, err := h.svc.GetHotFeed(ctx, req.UserId, timeRange, limit, offset)
	if err != nil {
		h.log.WithContext(ctx).Error("获取热门 Feed 失败",
			log.String("user_id", req.UserId),
			log.String("time_range", timeRange),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.GetHotFeedResponse{
		Items:      feedItemsToProto(items),
		Pagination: &common.Pagination{Page: pageReq.Page, PageSize: pageReq.PageSize, Total: int32(total)},
	}, nil
}

// GetContentDetail 获取内容详情（包含交互状态）
func (h *TimelineHandler) GetContentDetail(ctx context.Context, req *pb.GetContentDetailRequest) (*pb.GetContentDetailResponse, error) {
	if req.ContentId == "" {
		return nil, status.Error(codes.InvalidArgument, "content_id 不能为空")
	}

	item, err := h.svc.GetContentDetail(ctx, req.ContentId, req.ViewerId)
	if err != nil {
		h.log.WithContext(ctx).Error("获取内容详情失败",
			log.String("content_id", req.ContentId),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.GetContentDetailResponse{
		Item: feedItemToProto(item),
	}, nil
}

// ============================================================================
// 辅助函数
// ============================================================================

// extractPagination 从 proto 分页参数提取并规范化
func extractPagination(pagination *common.Pagination) *page.Request {
	if pagination == nil {
		return page.NewRequest(1, 20)
	}
	return page.NewRequest(pagination.Page, pagination.PageSize)
}

// feedItemsToProto 批量转换 Feed 条目为 proto 消息
func feedItemsToProto(items []*logic.FeedItemWithStatus) []*pb.FeedItem {
	if len(items) == 0 {
		return []*pb.FeedItem{}
	}
	result := make([]*pb.FeedItem, len(items))
	for i, item := range items {
		result[i] = feedItemToProto(item)
	}
	return result
}

// feedItemToProto 转换单个 Feed 条目为 proto 消息
func feedItemToProto(item *logic.FeedItemWithStatus) *pb.FeedItem {
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
