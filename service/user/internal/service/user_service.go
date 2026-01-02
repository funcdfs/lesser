package service

import (
	"errors"

	"github.com/lesser/user/internal/repository"
)

var ErrCannotFollowSelf = errors.New("cannot follow yourself")

type UserService struct {
	userRepo   *repository.UserRepository
	followRepo *repository.FollowRepository
}

func NewUserService(userRepo *repository.UserRepository, followRepo *repository.FollowRepository) *UserService {
	return &UserService{userRepo: userRepo, followRepo: followRepo}
}

func (s *UserService) GetProfile(userID string) (*repository.User, error) {
	return s.userRepo.GetByID(userID)
}

func (s *UserService) UpdateProfile(userID, displayName, avatarURL, bio string) (*repository.User, error) {
	user, err := s.userRepo.GetByID(userID)
	if err != nil {
		return nil, err
	}

	if displayName != "" {
		user.DisplayName = displayName
	}
	if avatarURL != "" {
		user.AvatarURL = avatarURL
	}
	if bio != "" {
		user.Bio = bio
	}

	if err := s.userRepo.Update(user); err != nil {
		return nil, err
	}

	return s.userRepo.GetByID(userID)
}

func (s *UserService) Follow(followerID, followingID string) error {
	if followerID == followingID {
		return ErrCannotFollowSelf
	}

	exists, err := s.followRepo.Exists(followerID, followingID)
	if err != nil {
		return err
	}
	if exists {
		return nil // 已关注
	}

	if err := s.followRepo.Create(followerID, followingID); err != nil {
		return err
	}

	s.userRepo.IncrementFollowingCount(followerID)
	s.userRepo.IncrementFollowersCount(followingID)
	return nil
}

func (s *UserService) Unfollow(followerID, followingID string) error {
	exists, err := s.followRepo.Exists(followerID, followingID)
	if err != nil {
		return err
	}
	if !exists {
		return nil // 未关注
	}

	if err := s.followRepo.Delete(followerID, followingID); err != nil {
		return err
	}

	s.userRepo.DecrementFollowingCount(followerID)
	s.userRepo.DecrementFollowersCount(followingID)
	return nil
}

func (s *UserService) GetFollowers(userID string, limit, offset int) ([]*repository.User, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.followRepo.GetFollowers(userID, limit, offset)
}

func (s *UserService) GetFollowing(userID string, limit, offset int) ([]*repository.User, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.followRepo.GetFollowing(userID, limit, offset)
}

func (s *UserService) CheckFollowing(followerID, followingID string) (bool, error) {
	return s.followRepo.Exists(followerID, followingID)
}
