// Package handler 提供 Interaction 服务的 gRPC 处理器
package handler

import (
	"context"
	"log/slog"

	"github.com/funcdfs/lesser/interaction/internal/data_access"
	"github.com/funcdfs/lesser/interaction/internal/logic"
	pb "github.com/funcdfs/lesser/interaction/gen_protos/interaction"
	"github.com/funcdfs/lesser/pkg/gen_protos/common"
	"github.com/funcdfs/lesser/pkg/log"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// InteractionHandler gRPC 处理器
type InteractionHandler struct {
	pb.UnimplementedInteractionServiceServer
	svc *logic.InteractionService
	log *slog.Logger
}

// NewInteractionHandler 创建处理器
func NewInteractionHandler(svc *logic.InteractionService, log *slog.Logger) *InteractionHandler {
	if log == nil {
		log = slog.Default()
	}
	return &InteractionHandler{
		svc: svc,
		log: log.With(slog.String("component", "handler")),
	}
}

// ============================================================================
// 点赞
// ============================================================================

// Like 点赞
func (h *InteractionHandler) Like(ctx context.Context, req *pb.LikeRequest) (*pb.LikeResponse, error) {
	if req.UserId == "" || req.ContentId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 和 content_id 不能为空")
	}

	h.log.Debug("点赞", slog.String("user_id", req.UserId), slog.String("content_id", req.ContentId))

	count, err := h.svc.Like(ctx, req.UserId, req.ContentId)
	if err != nil {
		h.log.Error("点赞失败",
			slog.String("user_id", req.UserId),
			slog.String("content_id", req.ContentId),
			slog.String("trace_id", log.TraceIDFromContext(ctx)),
			slog.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.LikeResponse{Success: true, LikeCount: count}, nil
}

// Unlike 取消点赞
func (h *InteractionHandler) Unlike(ctx context.Context, req *pb.UnlikeRequest) (*pb.UnlikeResponse, error) {
	if req.UserId == "" || req.ContentId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 和 content_id 不能为空")
	}

	h.log.Debug("取消点赞", slog.String("user_id", req.UserId), slog.String("content_id", req.ContentId))

	count, err := h.svc.Unlike(ctx, req.UserId, req.ContentId)
	if err != nil {
		h.log.Error("取消点赞失败",
			slog.String("user_id", req.UserId),
			slog.String("content_id", req.ContentId),
			slog.String("trace_id", log.TraceIDFromContext(ctx)),
			slog.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.UnlikeResponse{Success: true, LikeCount: count}, nil
}

// CheckLiked 检查是否已点赞
func (h *InteractionHandler) CheckLiked(ctx context.Context, req *pb.CheckLikedRequest) (*pb.CheckLikedResponse, error) {
	if req.UserId == "" || req.ContentId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 和 content_id 不能为空")
	}

	isLiked, err := h.svc.CheckLiked(req.UserId, req.ContentId)
	if err != nil {
		h.log.Error("检查是否已点赞失败",
			slog.String("user_id", req.UserId),
			slog.String("content_id", req.ContentId),
			slog.String("trace_id", log.TraceIDFromContext(ctx)),
			slog.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.CheckLikedResponse{IsLiked: isLiked}, nil
}

// ============================================================================
// 收藏
// ============================================================================

// Bookmark 收藏
func (h *InteractionHandler) Bookmark(ctx context.Context, req *pb.BookmarkRequest) (*pb.BookmarkResponse, error) {
	if req.UserId == "" || req.ContentId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 和 content_id 不能为空")
	}

	h.log.Debug("收藏", slog.String("user_id", req.UserId), slog.String("content_id", req.ContentId))

	count, err := h.svc.Bookmark(ctx, req.UserId, req.ContentId)
	if err != nil {
		h.log.Error("收藏失败",
			slog.String("user_id", req.UserId),
			slog.String("content_id", req.ContentId),
			slog.String("trace_id", log.TraceIDFromContext(ctx)),
			slog.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.BookmarkResponse{Success: true, BookmarkCount: count}, nil
}

// Unbookmark 取消收藏
func (h *InteractionHandler) Unbookmark(ctx context.Context, req *pb.UnbookmarkRequest) (*pb.UnbookmarkResponse, error) {
	if req.UserId == "" || req.ContentId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 和 content_id 不能为空")
	}

	h.log.Debug("取消收藏", slog.String("user_id", req.UserId), slog.String("content_id", req.ContentId))

	count, err := h.svc.Unbookmark(ctx, req.UserId, req.ContentId)
	if err != nil {
		h.log.Error("取消收藏失败",
			slog.String("user_id", req.UserId),
			slog.String("content_id", req.ContentId),
			slog.String("trace_id", log.TraceIDFromContext(ctx)),
			slog.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.UnbookmarkResponse{Success: true, BookmarkCount: count}, nil
}

// ListBookmarks 获取收藏列表
func (h *InteractionHandler) ListBookmarks(ctx context.Context, req *pb.ListBookmarksRequest) (*pb.ListBookmarksResponse, error) {
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

	bookmarks, total, err := h.svc.ListBookmarks(req.UserId, int(pageSize), int((page-1)*pageSize))
	if err != nil {
		h.log.Error("获取收藏列表失败",
			slog.String("user_id", req.UserId),
			slog.String("trace_id", log.TraceIDFromContext(ctx)),
			slog.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.ListBookmarksResponse{
		Bookmarks:  bookmarksToProto(bookmarks),
		Pagination: &common.Pagination{Page: page, PageSize: pageSize, Total: int32(total)},
	}, nil
}

// ============================================================================
// 转发
// ============================================================================

// CreateRepost 创建转发
func (h *InteractionHandler) CreateRepost(ctx context.Context, req *pb.CreateRepostRequest) (*pb.CreateRepostResponse, error) {
	if req.UserId == "" || req.ContentId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 和 content_id 不能为空")
	}

	h.log.Debug("转发", slog.String("user_id", req.UserId), slog.String("content_id", req.ContentId))

	repost, count, err := h.svc.CreateRepost(ctx, req.UserId, req.ContentId, req.Quote)
	if err != nil {
		h.log.Error("转发失败",
			slog.String("user_id", req.UserId),
			slog.String("content_id", req.ContentId),
			slog.String("trace_id", log.TraceIDFromContext(ctx)),
			slog.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.CreateRepostResponse{
		Repost:      repostToProto(repost),
		RepostCount: count,
	}, nil
}

// DeleteRepost 删除转发
func (h *InteractionHandler) DeleteRepost(ctx context.Context, req *pb.DeleteRepostRequest) (*pb.DeleteRepostResponse, error) {
	if req.UserId == "" || req.ContentId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 和 content_id 不能为空")
	}

	h.log.Debug("删除转发", slog.String("user_id", req.UserId), slog.String("content_id", req.ContentId))

	count, err := h.svc.DeleteRepost(ctx, req.UserId, req.ContentId)
	if err != nil {
		h.log.Error("删除转发失败",
			slog.String("user_id", req.UserId),
			slog.String("content_id", req.ContentId),
			slog.String("trace_id", log.TraceIDFromContext(ctx)),
			slog.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.DeleteRepostResponse{Success: true, RepostCount: count}, nil
}

// ============================================================================
// 批量查询
// ============================================================================

// BatchGetInteractionStatus 批量获取交互状态
func (h *InteractionHandler) BatchGetInteractionStatus(ctx context.Context, req *pb.BatchGetInteractionStatusRequest) (*pb.BatchGetInteractionStatusResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 不能为空")
	}

	statuses, err := h.svc.BatchGetInteractionStatus(req.UserId, req.ContentIds)
	if err != nil {
		h.log.Error("批量获取交互状态失败",
			slog.String("user_id", req.UserId),
			slog.String("trace_id", log.TraceIDFromContext(ctx)),
			slog.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.BatchGetInteractionStatusResponse{
		Statuses: statusesToProto(statuses),
	}, nil
}

// ============================================================================
// 转换函数
// ============================================================================

func bookmarksToProto(bookmarks []*data_access.Bookmark) []*pb.Bookmark {
	result := make([]*pb.Bookmark, len(bookmarks))
	for i, b := range bookmarks {
		result[i] = &pb.Bookmark{
			Id:        b.ID,
			UserId:    b.UserID,
			ContentId: b.ContentID,
			CreatedAt: &common.Timestamp{Seconds: b.CreatedAt.Unix()},
		}
	}
	return result
}

func repostToProto(r *data_access.Repost) *pb.Repost {
	if r == nil {
		return nil
	}
	return &pb.Repost{
		Id:        r.ID,
		UserId:    r.UserID,
		ContentId: r.ContentID,
		Quote:     r.Quote,
		CreatedAt: &common.Timestamp{Seconds: r.CreatedAt.Unix()},
	}
}

func statusesToProto(statuses []*logic.InteractionStatus) []*pb.UserInteractionStatus {
	result := make([]*pb.UserInteractionStatus, len(statuses))
	for i, s := range statuses {
		result[i] = &pb.UserInteractionStatus{
			ContentId:    s.ContentID,
			IsLiked:      s.IsLiked,
			IsBookmarked: s.IsBookmarked,
			IsReposted:   s.IsReposted,
		}
	}
	return result
}
