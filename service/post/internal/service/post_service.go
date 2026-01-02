package service

import (
	"errors"
	"time"

	"github.com/lesser/post/internal/repository"
)

var ErrUnauthorized = errors.New("unauthorized")

type PostService struct {
	postRepo *repository.PostRepository
}

func NewPostService(postRepo *repository.PostRepository) *PostService {
	return &PostService{postRepo: postRepo}
}

func (s *PostService) Create(authorID string, postType int32, title, content string, mediaURLs []string) (*repository.Post, error) {
	post := &repository.Post{
		AuthorID:  authorID,
		PostType:  postType,
		Title:     title,
		Content:   content,
		MediaURLs: mediaURLs,
	}

	// Story 类型 24 小时后过期
	if postType == 1 {
		expiresAt := time.Now().Add(24 * time.Hour)
		post.ExpiresAt = &expiresAt
	}

	if err := s.postRepo.Create(post); err != nil {
		return nil, err
	}

	return s.postRepo.GetByID(post.ID)
}

func (s *PostService) Get(postID string) (*repository.Post, error) {
	return s.postRepo.GetByID(postID)
}

func (s *PostService) List(authorID string, postType int32, limit, offset int) ([]*repository.Post, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.postRepo.List(authorID, postType, limit, offset)
}

func (s *PostService) Update(postID, userID, title, content string, mediaURLs []string) (*repository.Post, error) {
	post, err := s.postRepo.GetByID(postID)
	if err != nil {
		return nil, err
	}

	if post.AuthorID != userID {
		return nil, ErrUnauthorized
	}

	if title != "" {
		post.Title = title
	}
	if content != "" {
		post.Content = content
	}
	if len(mediaURLs) > 0 {
		post.MediaURLs = mediaURLs
	}

	if err := s.postRepo.Update(post); err != nil {
		return nil, err
	}

	return s.postRepo.GetByID(postID)
}

func (s *PostService) Delete(postID, userID string) error {
	post, err := s.postRepo.GetByID(postID)
	if err != nil {
		return err
	}

	if post.AuthorID != userID {
		return ErrUnauthorized
	}

	return s.postRepo.Delete(postID)
}
