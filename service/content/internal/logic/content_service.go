// Package service 提供内容业务逻辑层
package logic

import (
	"errors"
	"unicode/utf8"

	"github.com/funcdfs/lesser/content/internal/data_access"
)

// 业务错误定义
var (
	ErrUnauthorized     = errors.New("无权限操作")
	ErrInvalidContent   = errors.New("内容无效")
	ErrContentTooLong   = errors.New("内容超出长度限制")
	ErrTitleRequired    = errors.New("标题不能为空")
	ErrTextRequired     = errors.New("正文不能为空")
	ErrCannotEditStory  = errors.New("Story 不支持编辑")
	ErrNotDraft         = errors.New("只能发布草稿状态的内容")
	ErrDraftNotAllowed  = errors.New("该内容类型不支持草稿")
)

// 内容长度限制
const (
	ShortMaxLength   = 280  // 短文本最大字符数
	ArticleMaxLength = 50000 // 文章最大字符数
	StoryMaxLength   = 500  // Story 最大字符数
)

// ContentService 内容服务
type ContentService struct {
	contentRepo *data_access.ContentRepository
}

// NewContentService 创建内容服务
func NewContentService(contentRepo *data_access.ContentRepository) *ContentService {
	return &ContentService{contentRepo: contentRepo}
}

// Create 创建内容
func (s *ContentService) Create(
	authorID string,
	contentType data_access.ContentType,
	title, text, summary string,
	mediaURLs, tags []string,
	replyToID, quoteID string,
	isDraft, commentsDisabled bool,
) (*data_access.Content, error) {
	// 验证内容
	if err := s.validateContent(contentType, title, text, isDraft); err != nil {
		return nil, err
	}

	// 确定状态
	status := data_access.ContentStatusPublished
	if isDraft {
		// 只有 ARTICLE 支持草稿
		if contentType != data_access.ContentTypeArticle {
			return nil, ErrDraftNotAllowed
		}
		status = data_access.ContentStatusDraft
	}

	content := &data_access.Content{
		AuthorID:         authorID,
		Type:             contentType,
		Status:           status,
		Title:            title,
		Text:             text,
		Summary:          summary,
		MediaURLs:        mediaURLs,
		Tags:             tags,
		ReplyToID:        replyToID,
		QuoteID:          quoteID,
		CommentsDisabled: commentsDisabled,
	}

	if err := s.contentRepo.Create(content); err != nil {
		return nil, err
	}

	return s.contentRepo.GetByID(content.ID)
}

// Get 获取内容
func (s *ContentService) Get(contentID, viewerID string) (*data_access.Content, error) {
	content, err := s.contentRepo.GetByID(contentID)
	if err != nil {
		return nil, err
	}

	// 增加浏览量（异步处理更好，这里简化）
	if viewerID != "" && viewerID != content.AuthorID {
		go s.contentRepo.IncrementViewCount(contentID)
	}

	return content, nil
}

// Update 更新内容
func (s *ContentService) Update(
	contentID, userID string,
	title, text, summary string,
	mediaURLs, tags []string,
	commentsDisabled bool,
) (*data_access.Content, error) {
	content, err := s.contentRepo.GetByID(contentID)
	if err != nil {
		return nil, err
	}

	// 权限检查
	if content.AuthorID != userID {
		return nil, ErrUnauthorized
	}

	// Story 不支持编辑
	if content.Type == data_access.ContentTypeStory {
		return nil, ErrCannotEditStory
	}

	// 验证更新内容
	newText := text
	if newText == "" {
		newText = content.Text
	}
	newTitle := title
	if newTitle == "" {
		newTitle = content.Title
	}
	if err := s.validateContent(content.Type, newTitle, newText, content.Status == data_access.ContentStatusDraft); err != nil {
		return nil, err
	}

	// 更新字段
	if title != "" {
		content.Title = title
	}
	if text != "" {
		content.Text = text
	}
	if summary != "" {
		content.Summary = summary
	}
	if len(mediaURLs) > 0 {
		content.MediaURLs = mediaURLs
	}
	if len(tags) > 0 {
		content.Tags = tags
	}
	content.CommentsDisabled = commentsDisabled

	if err := s.contentRepo.Update(content); err != nil {
		return nil, err
	}

	return s.contentRepo.GetByID(contentID)
}

// Delete 删除内容
func (s *ContentService) Delete(contentID, userID string) error {
	content, err := s.contentRepo.GetByID(contentID)
	if err != nil {
		return err
	}

	if content.AuthorID != userID {
		return ErrUnauthorized
	}

	return s.contentRepo.Delete(contentID)
}

// PublishDraft 发布草稿
func (s *ContentService) PublishDraft(contentID, userID string) (*data_access.Content, error) {
	content, err := s.contentRepo.GetByID(contentID)
	if err != nil {
		return nil, err
	}

	if content.AuthorID != userID {
		return nil, ErrUnauthorized
	}

	if content.Status != data_access.ContentStatusDraft {
		return nil, ErrNotDraft
	}

	// 发布前验证
	if err := s.validateContent(content.Type, content.Title, content.Text, false); err != nil {
		return nil, err
	}

	if err := s.contentRepo.Publish(contentID); err != nil {
		return nil, err
	}

	return s.contentRepo.GetByID(contentID)
}

// List 列表查询
func (s *ContentService) List(
	authorID string,
	contentType data_access.ContentType,
	status data_access.ContentStatus,
	tags []string,
	limit, offset int,
	orderBy string,
	desc bool,
) ([]*data_access.Content, int, error) {
	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}
	return s.contentRepo.List(authorID, contentType, status, tags, limit, offset, orderBy, desc)
}

// GetUserDrafts 获取用户草稿
func (s *ContentService) GetUserDrafts(userID string, limit, offset int) ([]*data_access.Content, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.contentRepo.ListDrafts(userID, limit, offset)
}

// GetReplies 获取回复列表
func (s *ContentService) GetReplies(contentID string, limit, offset int) ([]*data_access.Content, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.contentRepo.ListReplies(contentID, limit, offset)
}

// GetUserStories 获取用户 Story
func (s *ContentService) GetUserStories(userID string) ([]*data_access.Content, error) {
	return s.contentRepo.ListUserStories(userID)
}

// BatchGet 批量获取
func (s *ContentService) BatchGet(ids []string) ([]*data_access.Content, error) {
	return s.contentRepo.BatchGet(ids)
}

// PinContent 置顶/取消置顶
func (s *ContentService) PinContent(contentID, userID string, pin bool) error {
	content, err := s.contentRepo.GetByID(contentID)
	if err != nil {
		return err
	}

	if content.AuthorID != userID {
		return ErrUnauthorized
	}

	return s.contentRepo.SetPinned(contentID, pin)
}

// validateContent 验证内容
func (s *ContentService) validateContent(contentType data_access.ContentType, title, text string, isDraft bool) error {
	textLen := utf8.RuneCountInString(text)

	switch contentType {
	case data_access.ContentTypeShort:
		if text == "" && !isDraft {
			return ErrTextRequired
		}
		if textLen > ShortMaxLength {
			return ErrContentTooLong
		}

	case data_access.ContentTypeArticle:
		if !isDraft {
			if title == "" {
				return ErrTitleRequired
			}
			if text == "" {
				return ErrTextRequired
			}
		}
		if textLen > ArticleMaxLength {
			return ErrContentTooLong
		}

	case data_access.ContentTypeStory:
		if text == "" && !isDraft {
			return ErrTextRequired
		}
		if textLen > StoryMaxLength {
			return ErrContentTooLong
		}
	}

	return nil
}

// ============================================================================
// 统计计数管理（供 Feed Service 调用）
// ============================================================================

// UpdateCounter 更新统计计数器
func (s *ContentService) UpdateCounter(contentID string, counterType data_access.CounterType, delta int32) (int32, error) {
	return s.contentRepo.UpdateCounter(contentID, counterType, delta)
}

// CheckContentExists 检查内容是否存在及其评论设置
func (s *ContentService) CheckContentExists(contentID string) (exists bool, commentsDisabled bool, err error) {
	exists, err = s.contentRepo.Exists(contentID)
	if err != nil || !exists {
		return exists, false, err
	}
	commentsDisabled, err = s.contentRepo.GetCommentsDisabled(contentID)
	return exists, commentsDisabled, err
}

// GetAuthorID 获取内容作者 ID（用于通知服务）
func (s *ContentService) GetAuthorID(contentID string) (string, error) {
	return s.contentRepo.GetAuthorID(contentID)
}
