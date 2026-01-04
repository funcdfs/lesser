package service

import "github.com/funcdfs/lesser/search/internal/repository"

// SearchService 搜索服务
type SearchService struct {
	searchRepo *repository.SearchRepository
}

// NewSearchService 创建搜索服务
func NewSearchService(searchRepo *repository.SearchRepository) *SearchService {
	return &SearchService{searchRepo: searchRepo}
}

// SearchContents 搜索内容（对外接口名保持 SearchPosts 以兼容 proto）
func (s *SearchService) SearchContents(query string, limit, offset int) ([]*repository.Content, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.searchRepo.SearchContents(query, limit, offset)
}

// SearchUsers 搜索用户
func (s *SearchService) SearchUsers(query string, limit, offset int) ([]*repository.User, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.searchRepo.SearchUsers(query, limit, offset)
}
