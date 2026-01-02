package handler

import (
	"context"

	"github.com/lesser/post/internal/repository"
	"github.com/lesser/post/internal/service"
	"github.com/lesser/pkg/proto/common"
	pb "github.com/lesser/post/proto/post"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type PostHandler struct {
	pb.UnimplementedPostServiceServer
	postService *service.PostService
}

func NewPostHandler(postService *service.PostService) *PostHandler {
	return &PostHandler{postService: postService}
}

func (h *PostHandler) Create(ctx context.Context, req *pb.CreatePostRequest) (*pb.Post, error) {
	if req.AuthorId == "" || req.Content == "" {
		return nil, status.Error(codes.InvalidArgument, "author_id and content are required")
	}

	post, err := h.postService.Create(req.AuthorId, int32(req.PostType), req.Title, req.Content, req.MediaUrls)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	return postToProto(post), nil
}

func (h *PostHandler) Get(ctx context.Context, req *pb.GetPostRequest) (*pb.Post, error) {
	if req.PostId == "" {
		return nil, status.Error(codes.InvalidArgument, "post_id is required")
	}

	post, err := h.postService.Get(req.PostId)
	if err != nil {
		if err == repository.ErrPostNotFound {
			return nil, status.Error(codes.NotFound, "post not found")
		}
		return nil, status.Error(codes.Internal, err.Error())
	}

	return postToProto(post), nil
}

func (h *PostHandler) List(ctx context.Context, req *pb.ListPostsRequest) (*pb.ListPostsResponse, error) {
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

	posts, total, err := h.postService.List(req.AuthorId, int32(req.PostType), limit, offset)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	return &pb.ListPostsResponse{
		Posts:      postsToProto(posts),
		Pagination: &common.Pagination{Page: page, PageSize: pageSize, Total: int32(total)},
	}, nil
}

func (h *PostHandler) Update(ctx context.Context, req *pb.UpdatePostRequest) (*pb.Post, error) {
	if req.PostId == "" || req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "post_id and user_id are required")
	}

	post, err := h.postService.Update(req.PostId, req.UserId, req.Title, req.Content, req.MediaUrls)
	if err != nil {
		if err == repository.ErrPostNotFound {
			return nil, status.Error(codes.NotFound, "post not found")
		}
		if err == service.ErrUnauthorized {
			return nil, status.Error(codes.PermissionDenied, "unauthorized")
		}
		return nil, status.Error(codes.Internal, err.Error())
	}

	return postToProto(post), nil
}

func (h *PostHandler) Delete(ctx context.Context, req *pb.DeletePostRequest) (*common.Empty, error) {
	if req.PostId == "" || req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "post_id and user_id are required")
	}

	if err := h.postService.Delete(req.PostId, req.UserId); err != nil {
		if err == repository.ErrPostNotFound {
			return nil, status.Error(codes.NotFound, "post not found")
		}
		if err == service.ErrUnauthorized {
			return nil, status.Error(codes.PermissionDenied, "unauthorized")
		}
		return nil, status.Error(codes.Internal, err.Error())
	}

	return &common.Empty{}, nil
}

func postToProto(post *repository.Post) *pb.Post {
	p := &pb.Post{
		Id:            post.ID,
		AuthorId:      post.AuthorID,
		PostType:      pb.PostType(post.PostType),
		Title:         post.Title,
		Content:       post.Content,
		MediaUrls:     post.MediaURLs,
		CreatedAt:     &common.Timestamp{Seconds: post.CreatedAt.Unix()},
		UpdatedAt:     &common.Timestamp{Seconds: post.UpdatedAt.Unix()},
		LikeCount:     post.LikeCount,
		CommentCount:  post.CommentCount,
		RepostCount:   post.RepostCount,
		BookmarkCount: post.BookmarkCount,
		IsDeleted:     post.IsDeleted,
	}
	if post.ExpiresAt != nil {
		p.ExpiresAt = &common.Timestamp{Seconds: post.ExpiresAt.Unix()}
	}
	return p
}

func postsToProto(posts []*repository.Post) []*pb.Post {
	result := make([]*pb.Post, len(posts))
	for i, p := range posts {
		result[i] = postToProto(p)
	}
	return result
}
