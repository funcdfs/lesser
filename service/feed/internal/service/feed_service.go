package service

import (
	"github.com/funcdfs/lesser/feed/internal/repository"
)

type FeedService struct {
	likeRepo     *repository.LikeRepository
	commentRepo  *repository.CommentRepository
	bookmarkRepo *repository.BookmarkRepository
}

func NewFeedService(likeRepo *repository.LikeRepository, commentRepo *repository.CommentRepository, bookmarkRepo *repository.BookmarkRepository) *FeedService {
	return &FeedService{likeRepo: likeRepo, commentRepo: commentRepo, bookmarkRepo: bookmarkRepo}
}

func (s *FeedService) Like(userID, postID string) error {
	return s.likeRepo.Create(userID, postID)
}

func (s *FeedService) Unlike(userID, postID string) error {
	return s.likeRepo.Delete(userID, postID)
}

func (s *FeedService) CreateComment(authorID, postID, parentID, content string) (*repository.Comment, error) {
	comment := &repository.Comment{
		AuthorID: authorID,
		PostID:   postID,
		ParentID: parentID,
		Content:  content,
	}
	if err := s.commentRepo.Create(comment); err != nil {
		return nil, err
	}
	return s.commentRepo.GetByID(comment.ID)
}

func (s *FeedService) DeleteComment(commentID, userID string) error {
	comment, err := s.commentRepo.GetByID(commentID)
	if err != nil {
		return err
	}
	if comment.AuthorID != userID {
		return repository.ErrCommentNotFound // 简化处理
	}
	return s.commentRepo.Delete(commentID)
}

func (s *FeedService) ListComments(postID, parentID string, limit, offset int) ([]*repository.Comment, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.commentRepo.List(postID, parentID, limit, offset)
}

func (s *FeedService) Bookmark(userID, postID string) error {
	return s.bookmarkRepo.Create(userID, postID)
}

func (s *FeedService) Unbookmark(userID, postID string) error {
	return s.bookmarkRepo.Delete(userID, postID)
}

func (s *FeedService) ListBookmarks(userID string, limit, offset int) ([]*repository.Bookmark, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.bookmarkRepo.List(userID, limit, offset)
}
