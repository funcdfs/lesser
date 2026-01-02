package handler

import (
	"context"

	"github.com/funcdfs/lesser/pkg/proto/common"
	"github.com/funcdfs/lesser/user/internal/repository"
	"github.com/funcdfs/lesser/user/internal/service"
	pb "github.com/funcdfs/lesser/user/proto/user"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type UserHandler struct {
	pb.UnimplementedUserServiceServer
	userService *service.UserService
}

func NewUserHandler(userService *service.UserService) *UserHandler {
	return &UserHandler{userService: userService}
}

func (h *UserHandler) GetProfile(ctx context.Context, req *pb.GetProfileRequest) (*pb.Profile, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id is required")
	}

	user, err := h.userService.GetProfile(req.UserId)
	if err != nil {
		if err == repository.ErrUserNotFound {
			return nil, status.Error(codes.NotFound, "user not found")
		}
		return nil, status.Error(codes.Internal, err.Error())
	}

	return userToProto(user), nil
}

func (h *UserHandler) UpdateProfile(ctx context.Context, req *pb.UpdateProfileRequest) (*pb.Profile, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id is required")
	}

	user, err := h.userService.UpdateProfile(req.UserId, req.DisplayName, req.AvatarUrl, req.Bio)
	if err != nil {
		if err == repository.ErrUserNotFound {
			return nil, status.Error(codes.NotFound, "user not found")
		}
		return nil, status.Error(codes.Internal, err.Error())
	}

	return userToProto(user), nil
}

func (h *UserHandler) Follow(ctx context.Context, req *pb.FollowRequest) (*common.Empty, error) {
	if req.FollowerId == "" || req.FollowingId == "" {
		return nil, status.Error(codes.InvalidArgument, "follower_id and following_id are required")
	}

	if err := h.userService.Follow(req.FollowerId, req.FollowingId); err != nil {
		if err == service.ErrCannotFollowSelf {
			return nil, status.Error(codes.InvalidArgument, "cannot follow yourself")
		}
		return nil, status.Error(codes.Internal, err.Error())
	}

	return &common.Empty{}, nil
}

func (h *UserHandler) Unfollow(ctx context.Context, req *pb.UnfollowRequest) (*common.Empty, error) {
	if req.FollowerId == "" || req.FollowingId == "" {
		return nil, status.Error(codes.InvalidArgument, "follower_id and following_id are required")
	}

	if err := h.userService.Unfollow(req.FollowerId, req.FollowingId); err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	return &common.Empty{}, nil
}

func (h *UserHandler) GetFollowers(ctx context.Context, req *pb.GetFollowersRequest) (*pb.FollowListResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id is required")
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

	users, total, err := h.userService.GetFollowers(req.UserId, limit, offset)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	return &pb.FollowListResponse{
		Users:      usersToProto(users),
		Pagination: &common.Pagination{Page: page, PageSize: pageSize, Total: int32(total)},
	}, nil
}

func (h *UserHandler) GetFollowing(ctx context.Context, req *pb.GetFollowingRequest) (*pb.FollowListResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id is required")
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

	users, total, err := h.userService.GetFollowing(req.UserId, limit, offset)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	return &pb.FollowListResponse{
		Users:      usersToProto(users),
		Pagination: &common.Pagination{Page: page, PageSize: pageSize, Total: int32(total)},
	}, nil
}

func (h *UserHandler) CheckFollowing(ctx context.Context, req *pb.CheckFollowingRequest) (*pb.CheckFollowingResponse, error) {
	if req.FollowerId == "" || req.FollowingId == "" {
		return nil, status.Error(codes.InvalidArgument, "follower_id and following_id are required")
	}

	isFollowing, err := h.userService.CheckFollowing(req.FollowerId, req.FollowingId)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	return &pb.CheckFollowingResponse{IsFollowing: isFollowing}, nil
}

func userToProto(user *repository.User) *pb.Profile {
	return &pb.Profile{
		Id:             user.ID,
		Username:       user.Username,
		Email:          user.Email,
		DisplayName:    user.DisplayName,
		AvatarUrl:      user.AvatarURL,
		Bio:            user.Bio,
		IsVerified:     user.IsVerified,
		FollowersCount: user.FollowersCount,
		FollowingCount: user.FollowingCount,
		PostsCount:     user.PostsCount,
		CreatedAt:      &common.Timestamp{Seconds: user.CreatedAt.Unix()},
		UpdatedAt:      &common.Timestamp{Seconds: user.UpdatedAt.Unix()},
	}
}

func usersToProto(users []*repository.User) []*pb.Profile {
	result := make([]*pb.Profile, len(users))
	for i, u := range users {
		result[i] = userToProto(u)
	}
	return result
}
