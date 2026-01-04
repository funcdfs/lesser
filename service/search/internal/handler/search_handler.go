package handler

import (
	"context"

	"github.com/funcdfs/lesser/pkg/proto/common"
	"github.com/funcdfs/lesser/search/internal/repository"
	"github.com/funcdfs/lesser/search/internal/service"
	pb "github.com/funcdfs/lesser/search/proto/search"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// SearchHandler 搜索服务 gRPC 处理器
type SearchHandler struct {
	pb.UnimplementedSearchServiceServer
	searchService *service.SearchService
}

// NewSearchHandler 创建搜索处理器
func NewSearchHandler(searchService *service.SearchService) *SearchHandler {
	return &SearchHandler{searchService: searchService}
}

// SearchPosts 搜索内容
func (h *SearchHandler) SearchPosts(ctx context.Context, req *pb.SearchPostsRequest) (*pb.SearchPostsResponse, error) {
	if req.Query == "" {
		return nil, status.Error(codes.InvalidArgument, "搜索关键词不能为空")
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
	limit := int(pageSize)
	offset := int((page - 1) * pageSize)

	// 目前仅支持关键词搜索，语义搜索需要外部 embedding 服务
	// TODO: 集成 embedding 服务后启用语义搜索
	contents, total, err := h.searchService.SearchContents(req.Query, limit, offset)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	return &pb.SearchPostsResponse{
		Posts:      contentsToProto(contents),
		Pagination: &common.Pagination{Page: page, PageSize: pageSize, Total: int32(total)},
	}, nil
}

// SearchUsers 搜索用户
func (h *SearchHandler) SearchUsers(ctx context.Context, req *pb.SearchUsersRequest) (*pb.SearchUsersResponse, error) {
	if req.Query == "" {
		return nil, status.Error(codes.InvalidArgument, "搜索关键词不能为空")
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
	limit := int(pageSize)
	offset := int((page - 1) * pageSize)

	users, total, err := h.searchService.SearchUsers(req.Query, limit, offset)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	return &pb.SearchUsersResponse{
		Users:      usersToProto(users),
		Pagination: &common.Pagination{Page: page, PageSize: pageSize, Total: int32(total)},
	}, nil
}

// SearchComments 搜索评论
func (h *SearchHandler) SearchComments(ctx context.Context, req *pb.SearchCommentsRequest) (*pb.SearchCommentsResponse, error) {
	if req.Query == "" {
		return nil, status.Error(codes.InvalidArgument, "搜索关键词不能为空")
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
	limit := int(pageSize)
	offset := int((page - 1) * pageSize)

	comments, total, err := h.searchService.SearchComments(req.Query, req.PostId, limit, offset)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	return &pb.SearchCommentsResponse{
		Comments:   commentsToProto(comments),
		Pagination: &common.Pagination{Page: page, PageSize: pageSize, Total: int32(total)},
	}, nil
}

// SearchAll 综合搜索
func (h *SearchHandler) SearchAll(ctx context.Context, req *pb.SearchAllRequest) (*pb.SearchAllResponse, error) {
	if req.Query == "" {
		return nil, status.Error(codes.InvalidArgument, "搜索关键词不能为空")
	}

	limit := int(req.Limit)
	if limit <= 0 {
		limit = 5 // 每种类型默认返回 5 条
	}

	// 并行搜索内容、评论、用户
	contents, _, _ := h.searchService.SearchContents(req.Query, limit, 0)
	comments, _, _ := h.searchService.SearchComments(req.Query, "", limit, 0)
	users, _, _ := h.searchService.SearchUsers(req.Query, limit, 0)

	return &pb.SearchAllResponse{
		Posts:    contentsToProto(contents),
		Comments: commentsToProto(comments),
		Users:    usersToProto(users),
	}, nil
}

// contentsToProto 将 Content 实体转换为 proto 消息
func contentsToProto(contents []*repository.Content) []*pb.PostResult {
	if contents == nil {
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
func usersToProto(users []*repository.User) []*pb.UserResult {
	if users == nil {
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
func commentsToProto(comments []*repository.Comment) []*pb.CommentResult {
	if comments == nil {
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
