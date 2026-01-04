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

// SearchPosts 搜索内容（proto 接口名保持 SearchPosts 以兼容客户端）
func (h *SearchHandler) SearchPosts(ctx context.Context, req *pb.SearchPostsRequest) (*pb.SearchPostsResponse, error) {
	if req.Query == "" {
		return nil, status.Error(codes.InvalidArgument, "搜索关键词不能为空")
	}

	// 分页参数处理
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

	// 调用 service 层搜索内容
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

	// 分页参数处理
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

	// 调用 service 层搜索用户
	users, total, err := h.searchService.SearchUsers(req.Query, limit, offset)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	return &pb.SearchUsersResponse{
		Users:      usersToProto(users),
		Pagination: &common.Pagination{Page: page, PageSize: pageSize, Total: int32(total)},
	}, nil
}

// contentsToProto 将 Content 实体转换为 proto 消息
func contentsToProto(contents []*repository.Content) []*pb.PostResult {
	result := make([]*pb.PostResult, len(contents))
	for i, c := range contents {
		result[i] = &pb.PostResult{
			Id:        c.ID,
			AuthorId:  c.AuthorID,
			Title:     c.Title,
			Content:   c.Text, // Content.Text 对应 proto 的 Content 字段
			MediaUrls: c.MediaURLs,
			CreatedAt: &common.Timestamp{Seconds: c.CreatedAt.Unix()},
		}
	}
	return result
}

// usersToProto 将 User 实体转换为 proto 消息
func usersToProto(users []*repository.User) []*pb.UserResult {
	result := make([]*pb.UserResult, len(users))
	for i, u := range users {
		result[i] = &pb.UserResult{
			Id:          u.ID,
			Username:    u.Username,
			DisplayName: u.DisplayName,
			AvatarUrl:   u.AvatarURL,
			Bio:         u.Bio,
		}
	}
	return result
}
