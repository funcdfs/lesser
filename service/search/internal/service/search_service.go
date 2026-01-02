package service

import "github.com/funcdfs/lesser/search/internal/repository"

type SearchService struct {
	searchRepo *repository.SearchRepository
}

func NewSearchService(searchRepo *repository.SearchRepository) *SearchService {
	return &SearchService{searchRepo: searchRepo}
}

func (s *SearchService) SearchPosts(query string, limit, offset int) ([]*repository.Post, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.searchRepo.SearchPosts(query, limit, offset)
}

func (s *SearchService) SearchUsers(query string, limit, offset int) ([]*repository.User, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.searchRepo.SearchUsers(query, limit, offset)
}
