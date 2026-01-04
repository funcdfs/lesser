// Package logic 提供 Comment 服务的业务逻辑层
package logic

import (
	"context"
	"errors"

	"github.com/funcdfs/lesser/comment/internal/data_access"
	contentpb "github.com/funcdfs/lesser/comment/gen_protos/content"
)

// 业务错误定义
var (
	ErrContentNotFound  = errors.New("内容不存在")
	ErrCommentsDisabled = errors.New("该内容已禁止评论")
	ErrUnauthorized     = errors.New("无权限操作")
	ErrCommentNotFound  = errors.New("评论不存在")
	ErrInvalidParent    = errors.New("父评论不存在或已删除")
	ErrEmptyText        = errors.New("评论内容不能为空")
	ErrTextTooLong      = errors.New("评论内容超出长度限制")
	ErrAlreadyLiked     = errors.New("已经点赞过")
	ErrNotLiked         = errors.New("未点赞")
)

// 评论长度限制
const MaxCommentLength = 2000

// SortBy 排序方式（与 proto 对应）
type SortBy int32

const (
	SortByUnspecified SortBy = 0
	SortByOldest      SortBy = 1
	SortByNewest      SortBy = 2
	SortByHottest     SortBy = 3
	SortByRecommended SortBy = 4
)

// ContentClient Content 服务客户端接口
type ContentClient interface {
	UpdateCounter(ctx context.Context, contentID string, counterType contentpb.CounterType, delta int32) (int32, error)
	CheckContentExists(ctx context.Context, contentID string) (exists bool, commentsDisabled bool, err error)
	// GetContentAuthorID 获取内容作者 ID（用于通知）
	GetContentAuthorID(ctx context.Context, contentID string) (string, error)
}

// EventPublisher 事件发布接口
// 由 messaging 层实现
type EventPublisher interface {
	PublishCommentCreated(ctx context.Context, commentID, authorID, contentID, contentAuthorID, parentID, parentAuthorID, text string)
	PublishCommentLiked(ctx context.Context, commentID, commentAuthorID, likerID string)
}

// CommentRepository 评论仓库接口
type CommentRepository interface {
	Create(ctx context.Context, comment *data_access.Comment) error
	GetByID(ctx context.Context, id string) (*data_access.Comment, error)
	Delete(ctx context.Context, id string) (*data_access.Comment, error)
	List(ctx context.Context, contentID, parentID string, sortBy data_access.SortBy, limit, offset int) ([]*data_access.Comment, int, error)
	GetCount(ctx context.Context, contentID string) (int32, error)
	BatchGetCount(ctx context.Context, contentIDs []string) (map[string]int32, error)
	LikeComment(ctx context.Context, userID, commentID string) (int32, error)
	UnlikeComment(ctx context.Context, userID, commentID string) (int32, error)
	CheckLiked(ctx context.Context, userID, commentID string) (bool, error)
	BatchCheckLiked(ctx context.Context, userID string, commentIDs []string) (map[string]bool, error)
}

// CommentService 评论服务
type CommentService struct {
	commentRepo   CommentRepository
	contentClient ContentClient
	publisher     EventPublisher // 可选，为 nil 时不发布事件
}

// NewCommentService 创建评论服务实例
func NewCommentService(commentRepo CommentRepository, contentClient ContentClient) *CommentService {
	return &CommentService{
		commentRepo:   commentRepo,
		contentClient: contentClient,
	}
}

// SetPublisher 设置事件发布者（可选）
func (s *CommentService) SetPublisher(publisher EventPublisher) {
	s.publisher = publisher
}


// CreateComment 创建评论
func (s *CommentService) CreateComment(ctx context.Context, authorID, contentID, parentID, text string) (*data_access.Comment, int32, error) {
	if text == "" {
		return nil, 0, ErrEmptyText
	}
	if len(text) > MaxCommentLength {
		return nil, 0, ErrTextTooLong
	}

	exists, commentsDisabled, err := s.contentClient.CheckContentExists(ctx, contentID)
	if err != nil {
		return nil, 0, err
	}
	if !exists {
		return nil, 0, ErrContentNotFound
	}
	if commentsDisabled {
		return nil, 0, ErrCommentsDisabled
	}

	// 如果是回复，获取父评论信息
	var parentAuthorID string
	if parentID != "" {
		parentComment, err := s.commentRepo.GetByID(ctx, parentID)
		if err != nil {
			return nil, 0, ErrInvalidParent
		}
		parentAuthorID = parentComment.AuthorID
	}

	comment := &data_access.Comment{
		AuthorID:  authorID,
		ContentID: contentID,
		ParentID:  parentID,
		Text:      text,
	}
	if err := s.commentRepo.Create(ctx, comment); err != nil {
		if err == data_access.ErrInvalidParent {
			return nil, 0, ErrInvalidParent
		}
		return nil, 0, err
	}

	count, _ := s.contentClient.UpdateCounter(ctx, contentID, contentpb.CounterType_COUNTER_COMMENT, 1)

	createdComment, err := s.commentRepo.GetByID(ctx, comment.ID)
	if err != nil {
		createdComment = comment
	}

	// 发布评论创建事件（异步，不阻塞主流程）
	if s.publisher != nil {
		// 获取内容作者 ID
		contentAuthorID, _ := s.contentClient.GetContentAuthorID(ctx, contentID)
		s.publisher.PublishCommentCreated(ctx, createdComment.ID, authorID, contentID, contentAuthorID, parentID, parentAuthorID, truncateText(text, 100))
	}

	return createdComment, count, nil
}

// GetComment 获取单条评论
func (s *CommentService) GetComment(ctx context.Context, commentID string) (*data_access.Comment, error) {
	comment, err := s.commentRepo.GetByID(ctx, commentID)
	if err != nil {
		if err == data_access.ErrCommentNotFound {
			return nil, ErrCommentNotFound
		}
		return nil, err
	}

	if comment.IsDeleted {
		return nil, ErrCommentNotFound
	}

	return comment, nil
}

// DeleteComment 删除评论
func (s *CommentService) DeleteComment(ctx context.Context, commentID, userID string) (int32, error) {
	comment, err := s.commentRepo.GetByID(ctx, commentID)
	if err != nil {
		if err == data_access.ErrCommentNotFound {
			return 0, ErrCommentNotFound
		}
		return 0, err
	}

	if comment.AuthorID != userID {
		return 0, ErrUnauthorized
	}

	if comment.IsDeleted {
		return 0, ErrCommentNotFound
	}

	deletedComment, err := s.commentRepo.Delete(ctx, commentID)
	if err != nil {
		return 0, err
	}

	count, _ := s.contentClient.UpdateCounter(ctx, deletedComment.ContentID, contentpb.CounterType_COUNTER_COMMENT, -1)

	return count, nil
}


// ListComments 获取评论列表（支持排序）
func (s *CommentService) ListComments(ctx context.Context, contentID, parentID string, sortBy SortBy, limit, offset int) ([]*data_access.Comment, int, error) {
	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}
	if offset < 0 {
		offset = 0
	}

	return s.commentRepo.List(ctx, contentID, parentID, data_access.SortBy(sortBy), limit, offset)
}

// GetCommentCount 获取评论数量
func (s *CommentService) GetCommentCount(ctx context.Context, contentID string) (int32, error) {
	return s.commentRepo.GetCount(ctx, contentID)
}

// BatchGetCommentCount 批量获取评论数量
func (s *CommentService) BatchGetCommentCount(ctx context.Context, contentIDs []string) (map[string]int32, error) {
	return s.commentRepo.BatchGetCount(ctx, contentIDs)
}

// ============================================================================
// 评论点赞
// ============================================================================

// LikeComment 点赞评论
func (s *CommentService) LikeComment(ctx context.Context, userID, commentID string) (int32, error) {
	// 先获取评论信息（用于发送通知）
	comment, err := s.commentRepo.GetByID(ctx, commentID)
	if err != nil {
		if err == data_access.ErrCommentNotFound {
			return 0, ErrCommentNotFound
		}
		return 0, err
	}

	count, err := s.commentRepo.LikeComment(ctx, userID, commentID)
	if err != nil {
		if err == data_access.ErrCommentNotFound {
			return 0, ErrCommentNotFound
		}
		if err == data_access.ErrAlreadyLiked {
			return 0, ErrAlreadyLiked
		}
		return 0, err
	}

	// 发布评论点赞事件（异步）
	if s.publisher != nil && comment.AuthorID != userID {
		// 不给自己发通知
		s.publisher.PublishCommentLiked(ctx, commentID, comment.AuthorID, userID)
	}

	return count, nil
}

// UnlikeComment 取消点赞评论
func (s *CommentService) UnlikeComment(ctx context.Context, userID, commentID string) (int32, error) {
	count, err := s.commentRepo.UnlikeComment(ctx, userID, commentID)
	if err != nil {
		if err == data_access.ErrNotLiked {
			return 0, ErrNotLiked
		}
		return 0, err
	}
	return count, nil
}

// CheckLiked 检查用户是否已点赞评论
func (s *CommentService) CheckLiked(ctx context.Context, userID, commentID string) (bool, error) {
	return s.commentRepo.CheckLiked(ctx, userID, commentID)
}

// BatchCheckLiked 批量检查用户是否已点赞评论
func (s *CommentService) BatchCheckLiked(ctx context.Context, userID string, commentIDs []string) (map[string]bool, error) {
	return s.commentRepo.BatchCheckLiked(ctx, userID, commentIDs)
}


// ============================================================================
// 辅助函数
// ============================================================================

// truncateText 截断文本
func truncateText(text string, maxLen int) string {
	runes := []rune(text)
	if len(runes) <= maxLen {
		return text
	}
	return string(runes[:maxLen]) + "..."
}
