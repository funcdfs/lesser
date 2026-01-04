package logic

import (
	"context"

	"github.com/funcdfs/lesser/search/internal/data_access"
)

// SearchService 搜索服务
type SearchService struct {
	searchRepo *data_access.SearchRepository
}

// NewSearchService 创建搜索服务
func NewSearchService(searchRepo *data_access.SearchRepository) *SearchService {
	return &SearchService{searchRepo: searchRepo}
}

// SearchContents 搜索内容（关键词匹配）
func (s *SearchService) SearchContents(query string, limit, offset int) ([]*data_access.Content, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.searchRepo.SearchContents(query, limit, offset)
}

// SearchContentsSemantic 语义搜索内容（使用 pgvector）
func (s *SearchService) SearchContentsSemantic(embedding []float32, limit, offset int) ([]*data_access.Content, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.searchRepo.SearchContentsSemantic(embedding, limit, offset)
}

// SearchUsers 搜索用户（关键词匹配）
func (s *SearchService) SearchUsers(query string, limit, offset int) ([]*data_access.User, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.searchRepo.SearchUsers(query, limit, offset)
}

// SearchUsersSemantic 语义搜索用户
func (s *SearchService) SearchUsersSemantic(embedding []float32, limit, offset int) ([]*data_access.User, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.searchRepo.SearchUsersSemantic(embedding, limit, offset)
}

// SearchComments 搜索评论（关键词匹配）
func (s *SearchService) SearchComments(query string, postID string, limit, offset int) ([]*data_access.Comment, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.searchRepo.SearchComments(query, postID, limit, offset)
}

// SearchCommentsSemantic 语义搜索评论
func (s *SearchService) SearchCommentsSemantic(embedding []float32, postID string, limit, offset int) ([]*data_access.Comment, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.searchRepo.SearchCommentsSemantic(embedding, postID, limit, offset)
}

// UpsertContentEmbedding 更新内容向量
func (s *SearchService) UpsertContentEmbedding(contentID string, embedding []float32, text string) error {
	return s.searchRepo.UpsertContentEmbedding(contentID, embedding, text)
}

// UpsertCommentEmbedding 更新评论向量
func (s *SearchService) UpsertCommentEmbedding(commentID string, embedding []float32, text string) error {
	return s.searchRepo.UpsertCommentEmbedding(commentID, embedding, text)
}

// UpsertUserEmbedding 更新用户向量
func (s *SearchService) UpsertUserEmbedding(userID string, embedding []float32, text string) error {
	return s.searchRepo.UpsertUserEmbedding(userID, embedding, text)
}

// ============================================================================
// 索引管理（供 MQ 消费者调用）
// ============================================================================

// IndexContent 索引内容（用于搜索）
func (s *SearchService) IndexContent(ctx context.Context, contentID, authorID, title, text, contentType string) error {
	return s.searchRepo.IndexContent(ctx, contentID, authorID, title, text, contentType)
}

// DeleteContentIndex 删除内容索引
func (s *SearchService) DeleteContentIndex(ctx context.Context, contentID string) error {
	return s.searchRepo.DeleteContentIndex(ctx, contentID)
}
