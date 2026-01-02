package handler

import (
	"context"

	"github.com/lesser/search/internal/repository"
	"github.com/lesser/search/internal/service"
	"github.com/lesser/search/proto/common"
	pb "github.com/lesser/search/proto/search"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type SearchHandler struct {
	pb.UnimplementedSearchServiceServer
	searchService *service.SearchService
}

func NewSearchHandler(searchService *service.SearchService) *SearchHandler {
	return &SearchHandler{searchService: searchService}
}

func (h *SearchHandler) SearchPosts(ctx context.Context, req *pb.SearchPostsRequest) (*pb.SearchPostsResponse, error) {
	if req.Query == "" {
		return nil, status.Error(codes.InvalidArgument, "query is required")
	}
	limit, offset := 20, 0
	if req.Pagination != nil {
		limit = int(req.Pagination.Limit)
		offset = int(req.Pagination.Offset)
	}
	posts, total, err := h.searchService.SearchPosts(req.Query, limit, offset)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	return &pb.SearchPostsResponse{
		Posts:      postsToProto(posts),
		Pagination: &common.Pagination{Limit: int32(limit), Offset: int32(offset), Total: int32(total)},
	}, nil
}

func (h *SearchHandler) SearchUsers(ctx context.Context, req *pb.SearchUsersRequest) (*pb.SearchUsersResponse, error) {
	if req.Query == "" {
		return nil, status.Error(codes.InvalidArgument, "query is required")
	}
	limit, offset := 20, 0
	if req.Pagination != nil {
		limit = int(req.Pagination.Limit)
		offset = int(req.Pagination.Offset)
	}
	users, total, err := h.searchService.SearchUsers(req.Query, limit, offset)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	return &pb.SearchUsersResponse{
		Users:      usersToProto(users),
		Pagination: &common.Pagination{Limit: int32(limit), Offset: int32(offset), Total: int32(total)},
	}, nil
}

func postsToProto(posts []*repository.Post) []*pb.PostResult {
	result := make([]*pb.PostResult, len(posts))
	for i, p := range posts {
		result[i] = &pb.PostResult{
			Id:        p.ID,
			AuthorId:  p.AuthorID,
			Title:     p.Title,
			Content:   p.Content,
			MediaUrls: p.MediaURLs,
			CreatedAt: &common.Timestamp{Seconds: p.CreatedAt.Unix()},
		}
	}
	return result
}

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
