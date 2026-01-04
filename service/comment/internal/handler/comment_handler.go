// Package handler 提供 Comment 服务的 gRPC 处理器
package handler

import (
	"context"
	"log/slog"

	"github.com/funcdfs/lesser/comment/internal/data_access"
	"github.com/funcdfs/lesser/comment/internal/logic"
	pb "github.com/funcdfs/lesser/comment/gen_protos/comment"
	"github.com/funcdfs/lesser/pkg/gen_protos/common"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// CommentHandler gRPC 处理器
type CommentHandler struct {
	pb.UnimplementedCommentServiceServer
	svc *logic.CommentService
	log *slog.Logger
}

// NewCommentHandler 创建处理器
func NewCommentHandler(svc *logic.CommentService, log *slog.Logger) *CommentHandler {
	if log == nil {
		log = slog.Default()
	}
	return &CommentHandler{
		svc: svc,
		log: log.With(slog.String("component", "handler")),
	}
}

// CreateComment 创建评论
func (h *CommentHandler) CreateComment(ctx context.Context, req *pb.CreateCommentRequest) (*pb.CreateCommentResponse, error) {
	if req.AuthorId == "" {
		return nil, status.Error(codes.InvalidArgument, "author_id 不能为空")
	}
	if req.ContentId == "" {
		return nil, status.Error(codes.InvalidArgument, "content_id 不能为空")
	}
	if req.Text == "" {
		return nil, status.Error(codes.InvalidArgument, "text 不能为空")
	}

	h.log.Debug("创建评论",
		slog.String("author_id", req.AuthorId),
		slog.String("content_id", req.ContentId),
	)

	comment, count, err := h.svc.CreateComment(ctx, req.AuthorId, req.ContentId, req.ParentId, req.Text)
	if err != nil {
		return nil, mapError(err)
	}

	return &pb.CreateCommentResponse{
		Comment:      commentToProto(comment),
		CommentCount: count,
	}, nil
}

// GetComment 获取单条评论
func (h *CommentHandler) GetComment(ctx context.Context, req *pb.GetCommentRequest) (*pb.GetCommentResponse, error) {
	if req.CommentId == "" {
		return nil, status.Error(codes.InvalidArgument, "comment_id 不能为空")
	}

	comment, err := h.svc.GetComment(ctx, req.CommentId)
	if err != nil {
		return nil, mapError(err)
	}

	return &pb.GetCommentResponse{Comment: commentToProto(comment)}, nil
}

// DeleteComment 删除评论
func (h *CommentHandler) DeleteComment(ctx context.Context, req *pb.DeleteCommentRequest) (*pb.DeleteCommentResponse, error) {
	if req.CommentId == "" {
		return nil, status.Error(codes.InvalidArgument, "comment_id 不能为空")
	}
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 不能为空")
	}

	h.log.Debug("删除评论",
		slog.String("comment_id", req.CommentId),
		slog.String("user_id", req.UserId),
	)

	count, err := h.svc.DeleteComment(ctx, req.CommentId, req.UserId)
	if err != nil {
		return nil, mapError(err)
	}

	return &pb.DeleteCommentResponse{Success: true, CommentCount: count}, nil
}


// ListComments 获取评论列表（支持排序）
func (h *CommentHandler) ListComments(ctx context.Context, req *pb.ListCommentsRequest) (*pb.ListCommentsResponse, error) {
	if req.ContentId == "" {
		return nil, status.Error(codes.InvalidArgument, "content_id 不能为空")
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

	// 转换排序方式
	sortBy := logic.SortBy(req.SortBy)

	h.log.Debug("获取评论列表",
		slog.String("content_id", req.ContentId),
		slog.String("parent_id", req.ParentId),
		slog.Int("sort_by", int(sortBy)),
	)

	comments, total, err := h.svc.ListComments(ctx, req.ContentId, req.ParentId, sortBy, int(pageSize), int((page-1)*pageSize))
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	return &pb.ListCommentsResponse{
		Comments:   commentsToProto(comments),
		Pagination: &common.Pagination{Page: page, PageSize: pageSize, Total: int32(total)},
	}, nil
}

// GetCommentCount 获取评论数量
func (h *CommentHandler) GetCommentCount(ctx context.Context, req *pb.GetCommentCountRequest) (*pb.GetCommentCountResponse, error) {
	if req.ContentId == "" {
		return nil, status.Error(codes.InvalidArgument, "content_id 不能为空")
	}

	count, err := h.svc.GetCommentCount(ctx, req.ContentId)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	return &pb.GetCommentCountResponse{Count: count}, nil
}

// BatchGetCommentCount 批量获取评论数量
func (h *CommentHandler) BatchGetCommentCount(ctx context.Context, req *pb.BatchGetCommentCountRequest) (*pb.BatchGetCommentCountResponse, error) {
	if len(req.ContentIds) == 0 {
		return &pb.BatchGetCommentCountResponse{Counts: []*pb.CommentCount{}}, nil
	}
	if len(req.ContentIds) > 100 {
		return nil, status.Error(codes.InvalidArgument, "批量查询数量不能超过 100")
	}

	countMap, err := h.svc.BatchGetCommentCount(ctx, req.ContentIds)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	counts := make([]*pb.CommentCount, 0, len(countMap))
	for contentID, count := range countMap {
		counts = append(counts, &pb.CommentCount{
			ContentId: contentID,
			Count:     count,
		})
	}

	return &pb.BatchGetCommentCountResponse{Counts: counts}, nil
}


// ============================================================================
// 评论点赞
// ============================================================================

// LikeComment 点赞评论
func (h *CommentHandler) LikeComment(ctx context.Context, req *pb.LikeCommentRequest) (*pb.LikeCommentResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 不能为空")
	}
	if req.CommentId == "" {
		return nil, status.Error(codes.InvalidArgument, "comment_id 不能为空")
	}

	h.log.Debug("点赞评论",
		slog.String("user_id", req.UserId),
		slog.String("comment_id", req.CommentId),
	)

	count, err := h.svc.LikeComment(ctx, req.UserId, req.CommentId)
	if err != nil {
		return nil, mapError(err)
	}

	return &pb.LikeCommentResponse{Success: true, LikeCount: count}, nil
}

// UnlikeComment 取消点赞评论
func (h *CommentHandler) UnlikeComment(ctx context.Context, req *pb.UnlikeCommentRequest) (*pb.UnlikeCommentResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 不能为空")
	}
	if req.CommentId == "" {
		return nil, status.Error(codes.InvalidArgument, "comment_id 不能为空")
	}

	h.log.Debug("取消点赞评论",
		slog.String("user_id", req.UserId),
		slog.String("comment_id", req.CommentId),
	)

	count, err := h.svc.UnlikeComment(ctx, req.UserId, req.CommentId)
	if err != nil {
		return nil, mapError(err)
	}

	return &pb.UnlikeCommentResponse{Success: true, LikeCount: count}, nil
}

// ============================================================================
// 转换函数
// ============================================================================

func commentToProto(c *data_access.Comment) *pb.Comment {
	if c == nil {
		return nil
	}
	return &pb.Comment{
		Id:         c.ID,
		AuthorId:   c.AuthorID,
		ContentId:  c.ContentID,
		ParentId:   c.ParentID,
		Text:       c.Text,
		IsDeleted:  c.IsDeleted,
		CreatedAt:  &common.Timestamp{Seconds: c.CreatedAt.Unix()},
		UpdatedAt:  &common.Timestamp{Seconds: c.UpdatedAt.Unix()},
		ReplyCount: c.ReplyCount,
		LikeCount:  c.LikeCount,
	}
}

func commentsToProto(comments []*data_access.Comment) []*pb.Comment {
	result := make([]*pb.Comment, len(comments))
	for i, c := range comments {
		result[i] = commentToProto(c)
	}
	return result
}

func mapError(err error) error {
	switch err {
	case logic.ErrContentNotFound:
		return status.Error(codes.NotFound, "内容不存在")
	case logic.ErrCommentsDisabled:
		return status.Error(codes.FailedPrecondition, "该内容已禁止评论")
	case logic.ErrUnauthorized:
		return status.Error(codes.PermissionDenied, "无权限操作")
	case logic.ErrCommentNotFound, data_access.ErrCommentNotFound:
		return status.Error(codes.NotFound, "评论不存在")
	case logic.ErrInvalidParent, data_access.ErrInvalidParent:
		return status.Error(codes.InvalidArgument, "父评论不存在或已删除")
	case logic.ErrEmptyText:
		return status.Error(codes.InvalidArgument, "评论内容不能为空")
	case logic.ErrTextTooLong:
		return status.Error(codes.InvalidArgument, "评论内容超出长度限制")
	case logic.ErrAlreadyLiked:
		return status.Error(codes.AlreadyExists, "已经点赞过")
	case logic.ErrNotLiked:
		return status.Error(codes.FailedPrecondition, "未点赞")
	default:
		return status.Error(codes.Internal, err.Error())
	}
}
