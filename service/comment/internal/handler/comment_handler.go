// Package handler 提供 Comment 服务的 gRPC 处理器
package handler

import (
	"context"
	

	pb "github.com/funcdfs/lesser/comment/gen_protos/comment"
	"github.com/funcdfs/lesser/comment/internal/data_access"
	"github.com/funcdfs/lesser/comment/internal/logic"
	"github.com/funcdfs/lesser/pkg/gen_protos/common"
	"github.com/funcdfs/lesser/pkg/log"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// CommentHandler gRPC 处理器
type CommentHandler struct {
	pb.UnimplementedCommentServiceServer
	svc *logic.CommentService
	log *log.Logger
}

// NewCommentHandler 创建处理器
func NewCommentHandler(svc *logic.CommentService, logger *log.Logger) *CommentHandler {
	if logger == nil {
		logger = log.Global()
	}
	return &CommentHandler{
		svc: svc,
		log: logger.With(log.String("component", "handler")),
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
		log.String("author_id", req.AuthorId),
		log.String("content_id", req.ContentId),
	)

	comment, count, err := h.svc.CreateComment(ctx, req.AuthorId, req.ContentId, req.ParentId, req.Text, req.MentionedUserIds)
	if err != nil {
		h.log.Error("创建评论失败",
			log.String("author_id", req.AuthorId),
			log.String("content_id", req.ContentId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
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
		log.String("comment_id", req.CommentId),
		log.String("user_id", req.UserId),
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
		log.String("content_id", req.ContentId),
		log.String("parent_id", req.ParentId),
		log.Int("sort_by", int(sortBy)),
	)

	comments, total, err := h.svc.ListComments(ctx, req.ContentId, req.ParentId, sortBy, int(pageSize), int((page-1)*pageSize))
	if err != nil {
		h.log.Error("获取评论列表失败",
			log.String("content_id", req.ContentId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, mapError(err)
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
		h.log.Error("获取评论数量失败",
			log.String("content_id", req.ContentId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, mapError(err)
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
		h.log.Error("批量获取评论数量失败",
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, mapError(err)
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
		log.String("user_id", req.UserId),
		log.String("comment_id", req.CommentId),
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
		log.String("user_id", req.UserId),
		log.String("comment_id", req.CommentId),
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
	return logic.ToGRPCError(err)
}
