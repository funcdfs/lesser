package handler

import (
	"context"

	"github.com/lesser/feed/internal/repository"
	"github.com/lesser/feed/internal/service"
	"github.com/lesser/feed/proto/common"
	pb "github.com/lesser/feed/proto/feed"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type FeedHandler struct {
	pb.UnimplementedFeedServiceServer
	feedService *service.FeedService
}

func NewFeedHandler(feedService *service.FeedService) *FeedHandler {
	return &FeedHandler{feedService: feedService}
}

func (h *FeedHandler) Like(ctx context.Context, req *pb.LikeRequest) (*common.Empty, error) {
	if req.UserId == "" || req.PostId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id and post_id are required")
	}
	if err := h.feedService.Like(req.UserId, req.PostId); err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	return &common.Empty{}, nil
}

func (h *FeedHandler) Unlike(ctx context.Context, req *pb.UnlikeRequest) (*common.Empty, error) {
	if req.UserId == "" || req.PostId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id and post_id are required")
	}
	if err := h.feedService.Unlike(req.UserId, req.PostId); err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	return &common.Empty{}, nil
}

func (h *FeedHandler) CreateComment(ctx context.Context, req *pb.CreateCommentRequest) (*pb.Comment, error) {
	if req.AuthorId == "" || req.PostId == "" || req.Content == "" {
		return nil, status.Error(codes.InvalidArgument, "author_id, post_id and content are required")
	}
	comment, err := h.feedService.CreateComment(req.AuthorId, req.PostId, req.ParentId, req.Content)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	return commentToProto(comment), nil
}

func (h *FeedHandler) DeleteComment(ctx context.Context, req *pb.DeleteCommentRequest) (*common.Empty, error) {
	if req.CommentId == "" || req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "comment_id and user_id are required")
	}
	if err := h.feedService.DeleteComment(req.CommentId, req.UserId); err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	return &common.Empty{}, nil
}

func (h *FeedHandler) ListComments(ctx context.Context, req *pb.ListCommentsRequest) (*pb.ListCommentsResponse, error) {
	if req.PostId == "" {
		return nil, status.Error(codes.InvalidArgument, "post_id is required")
	}
	limit, offset := 20, 0
	if req.Pagination != nil {
		limit = int(req.Pagination.Limit)
		offset = int(req.Pagination.Offset)
	}
	comments, total, err := h.feedService.ListComments(req.PostId, req.ParentId, limit, offset)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	return &pb.ListCommentsResponse{
		Comments:   commentsToProto(comments),
		Pagination: &common.Pagination{Limit: int32(limit), Offset: int32(offset), Total: int32(total)},
	}, nil
}

func (h *FeedHandler) CreateRepost(ctx context.Context, req *pb.RepostRequest) (*pb.Repost, error) {
	// TODO: 实现转发逻辑
	return nil, status.Error(codes.Unimplemented, "not implemented")
}

func (h *FeedHandler) Bookmark(ctx context.Context, req *pb.BookmarkRequest) (*common.Empty, error) {
	if req.UserId == "" || req.PostId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id and post_id are required")
	}
	if err := h.feedService.Bookmark(req.UserId, req.PostId); err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	return &common.Empty{}, nil
}

func (h *FeedHandler) Unbookmark(ctx context.Context, req *pb.UnbookmarkRequest) (*common.Empty, error) {
	if req.UserId == "" || req.PostId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id and post_id are required")
	}
	if err := h.feedService.Unbookmark(req.UserId, req.PostId); err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	return &common.Empty{}, nil
}

func (h *FeedHandler) ListBookmarks(ctx context.Context, req *pb.ListBookmarksRequest) (*pb.ListBookmarksResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id is required")
	}
	limit, offset := 20, 0
	if req.Pagination != nil {
		limit = int(req.Pagination.Limit)
		offset = int(req.Pagination.Offset)
	}
	bookmarks, total, err := h.feedService.ListBookmarks(req.UserId, limit, offset)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	return &pb.ListBookmarksResponse{
		Bookmarks:  bookmarksToProto(bookmarks),
		Pagination: &common.Pagination{Limit: int32(limit), Offset: int32(offset), Total: int32(total)},
	}, nil
}

func commentToProto(c *repository.Comment) *pb.Comment {
	return &pb.Comment{
		Id:         c.ID,
		AuthorId:   c.AuthorID,
		PostId:     c.PostID,
		ParentId:   c.ParentID,
		Content:    c.Content,
		IsDeleted:  c.IsDeleted,
		CreatedAt:  &common.Timestamp{Seconds: c.CreatedAt.Unix()},
		UpdatedAt:  &common.Timestamp{Seconds: c.UpdatedAt.Unix()},
		ReplyCount: c.ReplyCount,
	}
}

func commentsToProto(comments []*repository.Comment) []*pb.Comment {
	result := make([]*pb.Comment, len(comments))
	for i, c := range comments {
		result[i] = commentToProto(c)
	}
	return result
}

func bookmarksToProto(bookmarks []*repository.Bookmark) []*pb.Bookmark {
	result := make([]*pb.Bookmark, len(bookmarks))
	for i, b := range bookmarks {
		result[i] = &pb.Bookmark{
			Id:        b.ID,
			UserId:    b.UserID,
			PostId:    b.PostID,
			CreatedAt: &common.Timestamp{Seconds: b.CreatedAt.Unix()},
		}
	}
	return result
}
