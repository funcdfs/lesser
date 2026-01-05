// Package logic 提供搜索服务的业务逻辑层
package logic

import (
	"context"

	"github.com/funcdfs/lesser/search/internal/data_access"
)

// 分页限制常量
const (
	defaultLimit = 20
	maxLimit     = 100
)

// SearchService 搜索服务
type SearchService struct {
	da *data_access.SearchDataAccess
}

// NewSearchService 创建搜索服务
func NewSearchService(da *data_access.SearchDataAccess) *SearchService {
	return &SearchService{da: da}
}

// SearchContents 搜索内容（关键词匹配）
func (s *SearchService) SearchContents(ctx context.Context, query string, limit, offset int) ([]*data_access.Content, int, error) {
	limit = normalizeLimit(limit)
	return s.da.SearchContents(ctx, query, limit, offset)
}

// SearchContentsSemantic 语义搜索内容（使用 pgvector）
func (s *SearchService) SearchContentsSemantic(ctx context.Context, embedding []float32, limit, offset int) ([]*data_access.Content, int, error) {
	limit = normalizeLimit(limit)
	return s.da.SearchContentsSemantic(ctx, embedding, limit, offset)
}

// SearchUsers 搜索用户（关键词匹配）
func (s *SearchService) SearchUsers(ctx context.Context, query string, limit, offset int) ([]*data_access.User, int, error) {
	limit = normalizeLimit(limit)
	return s.da.SearchUsers(ctx, query, limit, offset)
}

// SearchUsersSemantic 语义搜索用户
func (s *SearchService) SearchUsersSemantic(ctx context.Context, embedding []float32, limit, offset int) ([]*data_access.User, int, error) {
	limit = normalizeLimit(limit)
	return s.da.SearchUsersSemantic(ctx, embedding, limit, offset)
}

// SearchComments 搜索评论（关键词匹配）
func (s *SearchService) SearchComments(ctx context.Context, query, postID string, limit, offset int) ([]*data_access.Comment, int, error) {
	limit = normalizeLimit(limit)
	return s.da.SearchComments(ctx, query, postID, limit, offset)
}

// SearchCommentsSemantic 语义搜索评论
func (s *SearchService) SearchCommentsSemantic(ctx context.Context, embedding []float32, postID string, limit, offset int) ([]*data_access.Comment, int, error) {
	limit = normalizeLimit(limit)
	return s.da.SearchCommentsSemantic(ctx, embedding, postID, limit, offset)
}

// UpsertContentEmbedding 更新内容向量
func (s *SearchService) UpsertContentEmbedding(ctx context.Context, contentID string, embedding []float32, text string) error {
	return s.da.UpsertContentEmbedding(ctx, contentID, embedding, text)
}

// UpsertCommentEmbedding 更新评论向量
func (s *SearchService) UpsertCommentEmbedding(ctx context.Context, commentID string, embedding []float32, text string) error {
	return s.da.UpsertCommentEmbedding(ctx, commentID, embedding, text)
}

// UpsertUserEmbedding 更新用户向量
func (s *SearchService) UpsertUserEmbedding(ctx context.Context, userID string, embedding []float32, text string) error {
	return s.da.UpsertUserEmbedding(ctx, userID, embedding, text)
}

// ============================================================================
// 索引管理（供 MQ 消费者调用）
// ============================================================================

// IndexContent 索引内容（用于搜索）
func (s *SearchService) IndexContent(ctx context.Context, contentID, authorID, title, text, contentType string) error {
	return s.da.IndexContent(ctx, contentID, authorID, title, text, contentType)
}

// DeleteContentIndex 删除内容索引
func (s *SearchService) DeleteContentIndex(ctx context.Context, contentID string) error {
	return s.da.DeleteContentIndex(ctx, contentID)
}

// ============================================================================
// 辅助函数
// ============================================================================

// normalizeLimit 规范化分页限制
func normalizeLimit(limit int) int {
	if limit <= 0 {
		return defaultLimit
	}
	if limit > maxLimit {
		return maxLimit
	}
	return limit
}
