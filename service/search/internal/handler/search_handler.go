// Package handler 提供搜索服务的 gRPC 处理器
package handler

import (
	"context"
	"sync"

	"github.com/funcdfs/lesser/pkg/gen_protos/common"
	"github.com/funcdfs/lesser/pkg/log"
	"github.com/funcdfs/lesser/pkg/page"
	pb "github.com/funcdfs/lesser/search/gen_protos/search"
	"github.com/funcdfs/lesser/search/internal/data_access"
	"github.com/funcdfs/lesser/search/internal/logic"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// SearchHandler 搜索服务 gRPC 处理器
type SearchHandler struct {
	pb.UnimplementedSearchServiceServer
	svc *logic.SearchService
	log *log.Logger
}

// NewSearchHandler 创建搜索处理器
func NewSearchHandler(svc *logic.SearchService, logger *log.Logger) *SearchHandler {
	if logger == nil {
		logger = log.Global()
	}
	return &SearchHandler{
		svc: svc,
		log: logger.With(log.String("component", "handler")),
	}
}

// SearchPosts 搜索内容
func (h *SearchHandler) SearchPosts(ctx context.Context, req *pb.SearchPostsRequest) (*pb.SearchPostsResponse, error) {
	if req.Query == "" {
		return nil, status.Error(codes.InvalidArgument, "搜索关键词不能为空")
	}

	pageReq := page.FromProto(req.Pagination)
	limit, offset := int(pageReq.Limit()), int(pageReq.Offset())

	// TODO: 集成 embedding 服务后启用语义搜索
	contents, total, err := h.svc.SearchContents(ctx, req.Query, limit, offset)
	if err != nil {
		h.log.WithContext(ctx).Error("搜索内容失败",
			log.String("query", req.Query),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.SearchPostsResponse{
		Posts:      contentsToProto(contents),
		Pagination: &common.Pagination{Page: pageReq.Page, PageSize: pageReq.PageSize, Total: int32(total)},
	}, nil
}

// SearchUsers 搜索用户
func (h *SearchHandler) SearchUsers(ctx context.Context, req *pb.SearchUsersRequest) (*pb.SearchUsersResponse, error) {
	if req.Query == "" {
		return nil, status.Error(codes.InvalidArgument, "搜索关键词不能为空")
	}

	pageReq := page.FromProto(req.Pagination)
	limit, offset := int(pageReq.Limit()), int(pageReq.Offset())

	users, total, err := h.svc.SearchUsers(ctx, req.Query, limit, offset)
	if err != nil {
		h.log.WithContext(ctx).Error("搜索用户失败",
			log.String("query", req.Query),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.SearchUsersResponse{
		Users:      usersToProto(users),
		Pagination: &common.Pagination{Page: pageReq.Page, PageSize: pageReq.PageSize, Total: int32(total)},
	}, nil
}

// SearchComments 搜索评论
func (h *SearchHandler) SearchComments(ctx context.Context, req *pb.SearchCommentsRequest) (*pb.SearchCommentsResponse, error) {
	if req.Query == "" {
		return nil, status.Error(codes.InvalidArgument, "搜索关键词不能为空")
	}

	pageReq := page.FromProto(req.Pagination)
	limit, offset := int(pageReq.Limit()), int(pageReq.Offset())

	comments, total, err := h.svc.SearchComments(ctx, req.Query, req.PostId, limit, offset)
	if err != nil {
		h.log.WithContext(ctx).Error("搜索评论失败",
			log.String("query", req.Query),
			log.String("post_id", req.PostId),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.SearchCommentsResponse{
		Comments:   commentsToProto(comments),
		Pagination: &common.Pagination{Page: pageReq.Page, PageSize: pageReq.PageSize, Total: int32(total)},
	}, nil
}

// SearchAll 综合搜索（并行执行）
func (h *SearchHandler) SearchAll(ctx context.Context, req *pb.SearchAllRequest) (*pb.SearchAllResponse, error) {
	if req.Query == "" {
		return nil, status.Error(codes.InvalidArgument, "搜索关键词不能为空")
	}

	limit := int(req.Limit)
	if limit <= 0 {
		limit = 5 // 每种类型默认返回 5 条
	}
	if limit > 20 {
		limit = 20 // 综合搜索每种类型最多 20 条
	}

	// 并行搜索内容、评论、用户
	var (
		wg       sync.WaitGroup
		contents []*data_access.Content
		comments []*data_access.Comment
		users    []*data_access.User
	)

	wg.Add(3)

	go func() {
		defer wg.Done()
		contents, _, _ = h.svc.SearchContents(ctx, req.Query, limit, 0)
	}()

	go func() {
		defer wg.Done()
		comments, _, _ = h.svc.SearchComments(ctx, req.Query, "", limit, 0)
	}()

	go func() {
		defer wg.Done()
		users, _, _ = h.svc.SearchUsers(ctx, req.Query, limit, 0)
	}()

	wg.Wait()

	return &pb.SearchAllResponse{
		Posts:    contentsToProto(contents),
		Comments: commentsToProto(comments),
		Users:    usersToProto(users),
	}, nil
}

// ============================================================================
// 辅助函数
// ============================================================================

// contentsToProto 将 Content 实体转换为 proto 消息
func contentsToProto(contents []*data_access.Content) []*pb.PostResult {
	if len(contents) == 0 {
		return []*pb.PostResult{}
	}
	result := make([]*pb.PostResult, len(contents))
	for i, c := range contents {
		result[i] = &pb.PostResult{
			Id:        c.ID,
			AuthorId:  c.AuthorID,
			Title:     c.Title,
			Content:   c.Text,
			MediaUrls: c.MediaURLs,
			CreatedAt: &common.Timestamp{Seconds: c.CreatedAt.Unix()},
			Score:     float32(c.Score),
		}
	}
	return result
}

// usersToProto 将 User 实体转换为 proto 消息
func usersToProto(users []*data_access.User) []*pb.UserResult {
	if len(users) == 0 {
		return []*pb.UserResult{}
	}
	result := make([]*pb.UserResult, len(users))
	for i, u := range users {
		result[i] = &pb.UserResult{
			Id:          u.ID,
			Username:    u.Username,
			DisplayName: u.DisplayName,
			AvatarUrl:   u.AvatarURL,
			Bio:         u.Bio,
			Score:       float32(u.Score),
		}
	}
	return result
}

// commentsToProto 将 Comment 实体转换为 proto 消息
func commentsToProto(comments []*data_access.Comment) []*pb.CommentResult {
	if len(comments) == 0 {
		return []*pb.CommentResult{}
	}
	result := make([]*pb.CommentResult, len(comments))
	for i, c := range comments {
		result[i] = &pb.CommentResult{
			Id:        c.ID,
			AuthorId:  c.AuthorID,
			PostId:    c.PostID,
			Content:   c.Content,
			CreatedAt: &common.Timestamp{Seconds: c.CreatedAt.Unix()},
			Score:     float32(c.Score),
		}
	}
	return result
}
