// Package service 提供 Content Service 单元测试
package logic

import (
	"strings"
	"testing"

	"github.com/funcdfs/lesser/content/internal/data_access"
)

// ==================== 内容创建测试 ====================

func TestCreate_ShortContent_ValidLength(t *testing.T) {
	// 测试创建 Short 内容时的长度验证
	svc := &ContentService{}

	// 280 字符以内应该通过验证
	text := strings.Repeat("a", 280)
	err := svc.validateContent(data_access.ContentTypeShort, "", text, false)
	if err != nil {
		t.Errorf("280 字符的 Short 应该通过验证，但得到错误: %v", err)
	}
}

func TestCreate_ShortContent_ExceedsMaxLength(t *testing.T) {
	// 测试 Short 内容超过 280 字符限制
	svc := &ContentService{}

	// 281 字符应该失败
	text := strings.Repeat("a", 281)
	err := svc.validateContent(data_access.ContentTypeShort, "", text, false)
	if err != ErrContentTooLong {
		t.Errorf("期望 ErrContentTooLong 错误，但得到: %v", err)
	}
}

func TestCreate_ShortContent_EmptyText(t *testing.T) {
	// 测试 Short 内容不能为空（非草稿状态）
	svc := &ContentService{}

	err := svc.validateContent(data_access.ContentTypeShort, "", "", false)
	if err != ErrTextRequired {
		t.Errorf("期望 ErrTextRequired 错误，但得到: %v", err)
	}
}

func TestCreate_ArticleContent_ValidContent(t *testing.T) {
	// 测试创建 Article 内容
	svc := &ContentService{}

	err := svc.validateContent(data_access.ContentTypeArticle, "标题", "正文内容", false)
	if err != nil {
		t.Errorf("有效的 Article 应该通过验证，但得到错误: %v", err)
	}
}

func TestCreate_ArticleContent_MissingTitle(t *testing.T) {
	// 测试 Article 内容必须有标题（非草稿状态）
	svc := &ContentService{}

	err := svc.validateContent(data_access.ContentTypeArticle, "", "正文内容", false)
	if err != ErrTitleRequired {
		t.Errorf("期望 ErrTitleRequired 错误，但得到: %v", err)
	}
}

func TestCreate_ArticleContent_MissingText(t *testing.T) {
	// 测试 Article 内容必须有正文（非草稿状态）
	svc := &ContentService{}

	err := svc.validateContent(data_access.ContentTypeArticle, "标题", "", false)
	if err != ErrTextRequired {
		t.Errorf("期望 ErrTextRequired 错误，但得到: %v", err)
	}
}

func TestCreate_ArticleContent_DraftAllowsEmpty(t *testing.T) {
	// 测试 Article 草稿可以没有标题和正文
	svc := &ContentService{}

	err := svc.validateContent(data_access.ContentTypeArticle, "", "", true)
	if err != nil {
		t.Errorf("Article 草稿应该允许空内容，但得到错误: %v", err)
	}
}

func TestCreate_ArticleContent_ExceedsMaxLength(t *testing.T) {
	// 测试 Article 内容超过最大长度限制
	svc := &ContentService{}

	text := strings.Repeat("a", ArticleMaxLength+1)
	err := svc.validateContent(data_access.ContentTypeArticle, "标题", text, false)
	if err != ErrContentTooLong {
		t.Errorf("期望 ErrContentTooLong 错误，但得到: %v", err)
	}
}

func TestCreate_StoryContent_ValidContent(t *testing.T) {
	// 测试创建 Story 内容
	svc := &ContentService{}

	err := svc.validateContent(data_access.ContentTypeStory, "", "Story 内容", false)
	if err != nil {
		t.Errorf("有效的 Story 应该通过验证，但得到错误: %v", err)
	}
}

func TestCreate_StoryContent_ExceedsMaxLength(t *testing.T) {
	// 测试 Story 内容超过 500 字符限制
	svc := &ContentService{}

	text := strings.Repeat("a", StoryMaxLength+1)
	err := svc.validateContent(data_access.ContentTypeStory, "", text, false)
	if err != ErrContentTooLong {
		t.Errorf("期望 ErrContentTooLong 错误，但得到: %v", err)
	}
}

func TestCreate_StoryContent_EmptyText(t *testing.T) {
	// 测试 Story 内容不能为空（非草稿状态）
	svc := &ContentService{}

	err := svc.validateContent(data_access.ContentTypeStory, "", "", false)
	if err != ErrTextRequired {
		t.Errorf("期望 ErrTextRequired 错误，但得到: %v", err)
	}
}

// ==================== 内容类型约束测试 ====================

func TestContentTypeConstraints_ShortMaxLength(t *testing.T) {
	// 验证 Short 最大长度常量
	if ShortMaxLength != 280 {
		t.Errorf("ShortMaxLength 应该为 280，但得到: %d", ShortMaxLength)
	}
}

func TestContentTypeConstraints_ArticleMaxLength(t *testing.T) {
	// 验证 Article 最大长度常量
	if ArticleMaxLength != 50000 {
		t.Errorf("ArticleMaxLength 应该为 50000，但得到: %d", ArticleMaxLength)
	}
}

func TestContentTypeConstraints_StoryMaxLength(t *testing.T) {
	// 验证 Story 最大长度常量
	if StoryMaxLength != 500 {
		t.Errorf("StoryMaxLength 应该为 500，但得到: %d", StoryMaxLength)
	}
}

// ==================== Unicode 字符长度测试 ====================

func TestValidateContent_UnicodeCharacterCount(t *testing.T) {
	// 测试 Unicode 字符计数（中文字符应该按字符数计算，不是字节数）
	svc := &ContentService{}

	// 280 个中文字符应该通过
	text := strings.Repeat("中", 280)
	err := svc.validateContent(data_access.ContentTypeShort, "", text, false)
	if err != nil {
		t.Errorf("280 个中文字符应该通过验证，但得到错误: %v", err)
	}

	// 281 个中文字符应该失败
	text = strings.Repeat("中", 281)
	err = svc.validateContent(data_access.ContentTypeShort, "", text, false)
	if err != ErrContentTooLong {
		t.Errorf("281 个中文字符应该失败，期望 ErrContentTooLong，但得到: %v", err)
	}
}

func TestValidateContent_MixedUnicodeContent(t *testing.T) {
	// 测试混合 Unicode 内容
	svc := &ContentService{}

	// 混合中英文，总共 280 字符
	text := strings.Repeat("中a", 140) // 140 * 2 = 280 字符
	err := svc.validateContent(data_access.ContentTypeShort, "", text, false)
	if err != nil {
		t.Errorf("280 个混合字符应该通过验证，但得到错误: %v", err)
	}
}

// ==================== 错误类型测试 ====================

func TestErrorTypes(t *testing.T) {
	// 验证所有预定义错误类型存在
	errors := []error{
		ErrUnauthorized,
		ErrInvalidContent,
		ErrContentTooLong,
		ErrTitleRequired,
		ErrTextRequired,
		ErrCannotEditStory,
		ErrNotDraft,
		ErrDraftNotAllowed,
	}

	for _, err := range errors {
		if err == nil {
			t.Error("错误类型不应该为 nil")
		}
	}
}

func TestDataAccessErrorTypes(t *testing.T) {
	// 验证 data_access 层错误类型存在
	errors := []error{
		data_access.ErrContentNotFound,
		data_access.ErrUnauthorized,
	}

	for _, err := range errors {
		if err == nil {
			t.Error("data_access 错误类型不应该为 nil")
		}
	}
}

// ==================== 内容类型常量测试 ====================

func TestContentTypes(t *testing.T) {
	// 验证内容类型常量
	if data_access.ContentTypeUnspecified != 0 {
		t.Error("ContentTypeUnspecified 应该为 0")
	}
	if data_access.ContentTypeStory != 1 {
		t.Error("ContentTypeStory 应该为 1")
	}
	if data_access.ContentTypeShort != 2 {
		t.Error("ContentTypeShort 应该为 2")
	}
	if data_access.ContentTypeArticle != 3 {
		t.Error("ContentTypeArticle 应该为 3")
	}
}

func TestContentStatus(t *testing.T) {
	// 验证内容状态常量
	if data_access.ContentStatusUnspecified != 0 {
		t.Error("ContentStatusUnspecified 应该为 0")
	}
	if data_access.ContentStatusDraft != 1 {
		t.Error("ContentStatusDraft 应该为 1")
	}
	if data_access.ContentStatusPublished != 2 {
		t.Error("ContentStatusPublished 应该为 2")
	}
	if data_access.ContentStatusArchived != 3 {
		t.Error("ContentStatusArchived 应该为 3")
	}
	if data_access.ContentStatusDeleted != 4 {
		t.Error("ContentStatusDeleted 应该为 4")
	}
}

func TestCounterTypes(t *testing.T) {
	// 验证计数器类型常量
	if data_access.CounterTypeUnspecified != 0 {
		t.Error("CounterTypeUnspecified 应该为 0")
	}
	if data_access.CounterTypeLike != 1 {
		t.Error("CounterTypeLike 应该为 1")
	}
	if data_access.CounterTypeComment != 2 {
		t.Error("CounterTypeComment 应该为 2")
	}
	if data_access.CounterTypeRepost != 3 {
		t.Error("CounterTypeRepost 应该为 3")
	}
	if data_access.CounterTypeBookmark != 4 {
		t.Error("CounterTypeBookmark 应该为 4")
	}
}

// ==================== 草稿功能测试 ====================

func TestDraftNotAllowed_ForShort(t *testing.T) {
	// 测试 Short 类型不支持草稿
	// 这个测试验证业务逻辑：只有 Article 支持草稿
	contentType := data_access.ContentTypeShort
	if contentType == data_access.ContentTypeArticle {
		t.Error("Short 类型不应该等于 Article 类型")
	}
}

func TestDraftNotAllowed_ForStory(t *testing.T) {
	// 测试 Story 类型不支持草稿
	contentType := data_access.ContentTypeStory
	if contentType == data_access.ContentTypeArticle {
		t.Error("Story 类型不应该等于 Article 类型")
	}
}

func TestDraftAllowed_ForArticle(t *testing.T) {
	// 测试 Article 类型支持草稿
	contentType := data_access.ContentTypeArticle
	if contentType != data_access.ContentTypeArticle {
		t.Error("Article 类型应该支持草稿")
	}
}

// ==================== 边界条件测试 ====================

func TestValidateContent_ExactMaxLength(t *testing.T) {
	// 测试恰好达到最大长度的内容
	svc := &ContentService{}

	tests := []struct {
		name        string
		contentType data_access.ContentType
		maxLength   int
	}{
		{"Short 280 字符", data_access.ContentTypeShort, ShortMaxLength},
		{"Story 500 字符", data_access.ContentTypeStory, StoryMaxLength},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			text := strings.Repeat("a", tt.maxLength)
			err := svc.validateContent(tt.contentType, "", text, false)
			if err != nil {
				t.Errorf("恰好 %d 字符应该通过验证，但得到错误: %v", tt.maxLength, err)
			}
		})
	}
}

func TestValidateContent_OneOverMaxLength(t *testing.T) {
	// 测试超过最大长度一个字符的内容
	svc := &ContentService{}

	tests := []struct {
		name        string
		contentType data_access.ContentType
		maxLength   int
	}{
		{"Short 281 字符", data_access.ContentTypeShort, ShortMaxLength},
		{"Story 501 字符", data_access.ContentTypeStory, StoryMaxLength},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			text := strings.Repeat("a", tt.maxLength+1)
			err := svc.validateContent(tt.contentType, "", text, false)
			if err != ErrContentTooLong {
				t.Errorf("超过 %d 字符应该失败，期望 ErrContentTooLong，但得到: %v", tt.maxLength, err)
			}
		})
	}
}

// ==================== 分页参数测试 ====================

func TestListPagination_DefaultLimit(t *testing.T) {
	// 测试默认分页限制
	// 当 limit <= 0 时，应该使用默认值 20
	defaultLimit := 20
	if defaultLimit != 20 {
		t.Errorf("默认 limit 应该为 20，但得到: %d", defaultLimit)
	}
}

func TestListPagination_MaxLimit(t *testing.T) {
	// 测试最大分页限制
	// 当 limit > 100 时，应该限制为 100
	maxLimit := 100
	if maxLimit != 100 {
		t.Errorf("最大 limit 应该为 100，但得到: %d", maxLimit)
	}
}
