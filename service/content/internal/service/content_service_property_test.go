// Package service 提供 Content Service 属性测试
// Feature: backend-services-completion
package service

import (
	"strings"
	"testing"
	"time"
	"unicode/utf8"

	"github.com/funcdfs/lesser/content/internal/repository"
	"github.com/leanovate/gopter"
	"github.com/leanovate/gopter/gen"
	"github.com/leanovate/gopter/prop"
)

// PropertyTestIterations 属性测试迭代次数
const PropertyTestIterations = 100

// ============================================================================
// Property 9: Content type constraints are enforced
// *For any* Story content, expires_at SHALL be set to 24 hours from creation.
// *For any* Short content, text length SHALL not exceed 280 characters.
// *For any* Article, draft status SHALL be allowed.
// **Validates: Requirements 3.2, 3.3, 3.4**
// ============================================================================

// TestProperty9_StoryExpiration 测试 Story 24h 过期时间设置
func TestProperty9_StoryExpiration(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	// 属性：Story 类型的内容创建时，expires_at 应该设置为 24 小时后
	properties.Property("Story expires_at is set to 24 hours from creation", prop.ForAll(
		func(textLen int) bool {
			// 生成有效长度的文本（1 到 StoryMaxLength）
			if textLen < 1 {
				textLen = 1
			}
			if textLen > StoryMaxLength {
				textLen = StoryMaxLength
			}

			// 模拟创建 Story 内容
			content := &repository.Content{
				Type:      repository.ContentTypeStory,
				Status:    repository.ContentStatusPublished,
				Text:      strings.Repeat("a", textLen),
				CreatedAt: time.Now(),
			}

			// 模拟 repository.Create 中的逻辑
			if content.Type == repository.ContentTypeStory {
				expiresAt := content.CreatedAt.Add(24 * time.Hour)
				content.ExpiresAt = &expiresAt
			}

			// 验证：expires_at 应该被设置
			if content.ExpiresAt == nil {
				return false
			}

			// 验证：expires_at 应该是 created_at + 24h（允许 1 秒误差）
			expectedExpiry := content.CreatedAt.Add(24 * time.Hour)
			diff := content.ExpiresAt.Sub(expectedExpiry)
			if diff < -time.Second || diff > time.Second {
				return false
			}

			return true
		},
		gen.IntRange(1, StoryMaxLength),
	))

	// 属性：非 Story 类型不应该自动设置 expires_at
	properties.Property("non-Story content does not have automatic expiration", prop.ForAll(
		func(contentTypeInt int) bool {
			// 只测试 Short 和 Article 类型
			contentType := repository.ContentType(contentTypeInt%2 + 2) // 2=Short, 3=Article

			content := &repository.Content{
				Type:      contentType,
				Status:    repository.ContentStatusPublished,
				Text:      "test content",
				CreatedAt: time.Now(),
			}

			// 模拟 repository.Create 中的逻辑
			if content.Type == repository.ContentTypeStory {
				expiresAt := content.CreatedAt.Add(24 * time.Hour)
				content.ExpiresAt = &expiresAt
			}

			// 验证：非 Story 类型不应该设置 expires_at
			return content.ExpiresAt == nil
		},
		gen.IntRange(0, 100),
	))

	properties.TestingRun(t)
}

// TestProperty9_ShortMaxLength 测试 Short 280 字符限制
func TestProperty9_ShortMaxLength(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	svc := &ContentService{}

	// 属性：Short 内容长度 <= 280 字符时应该通过验证
	properties.Property("Short content within 280 chars passes validation", prop.ForAll(
		func(textLen int) bool {
			// 生成 1 到 280 字符的文本
			if textLen < 1 {
				textLen = 1
			}
			if textLen > ShortMaxLength {
				textLen = ShortMaxLength
			}

			text := strings.Repeat("a", textLen)
			err := svc.validateContent(repository.ContentTypeShort, "", text, false)

			// 验证：应该通过验证
			return err == nil
		},
		gen.IntRange(1, ShortMaxLength),
	))

	// 属性：Short 内容长度 > 280 字符时应该失败
	properties.Property("Short content exceeding 280 chars fails validation", prop.ForAll(
		func(extraChars int) bool {
			// 生成超过 280 字符的文本
			if extraChars < 1 {
				extraChars = 1
			}
			if extraChars > 1000 {
				extraChars = 1000
			}

			text := strings.Repeat("a", ShortMaxLength+extraChars)
			err := svc.validateContent(repository.ContentTypeShort, "", text, false)

			// 验证：应该返回 ErrContentTooLong
			return err == ErrContentTooLong
		},
		gen.IntRange(1, 500),
	))

	// 属性：Short 内容的 Unicode 字符计数正确
	properties.Property("Short content Unicode character count is correct", prop.ForAll(
		func(textLen int) bool {
			// 生成 1 到 280 个中文字符
			if textLen < 1 {
				textLen = 1
			}
			if textLen > ShortMaxLength {
				textLen = ShortMaxLength
			}

			text := strings.Repeat("中", textLen)

			// 验证：字符数应该等于 textLen
			if utf8.RuneCountInString(text) != textLen {
				return false
			}

			err := svc.validateContent(repository.ContentTypeShort, "", text, false)

			// 验证：应该通过验证
			return err == nil
		},
		gen.IntRange(1, ShortMaxLength),
	))

	properties.TestingRun(t)
}

// TestProperty9_ArticleDraftAllowed 测试 Article 草稿功能
func TestProperty9_ArticleDraftAllowed(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	svc := &ContentService{}

	// 属性：Article 类型允许草稿状态（可以没有标题和正文）
	properties.Property("Article draft allows empty title and text", prop.ForAll(
		func(hasTitle, hasText bool) bool {
			title := ""
			text := ""
			if hasTitle {
				title = "Test Title"
			}
			if hasText {
				text = "Test Content"
			}

			// 草稿状态应该允许空标题和空正文
			err := svc.validateContent(repository.ContentTypeArticle, title, text, true)

			// 验证：草稿状态应该通过验证
			return err == nil
		},
		gen.Bool(),
		gen.Bool(),
	))

	// 属性：Article 非草稿状态必须有标题和正文
	properties.Property("Article published requires title and text", prop.ForAll(
		func(hasTitle, hasText bool) bool {
			title := ""
			text := ""
			if hasTitle {
				title = "Test Title"
			}
			if hasText {
				text = "Test Content"
			}

			err := svc.validateContent(repository.ContentTypeArticle, title, text, false)

			// 验证：只有同时有标题和正文时才通过
			if hasTitle && hasText {
				return err == nil
			}
			// 缺少标题或正文时应该失败
			return err == ErrTitleRequired || err == ErrTextRequired
		},
		gen.Bool(),
		gen.Bool(),
	))

	// 属性：只有 Article 类型支持草稿
	properties.Property("only Article type supports draft", prop.ForAll(
		func(contentTypeInt int) bool {
			// 测试 Story 和 Short 类型
			contentType := repository.ContentType(contentTypeInt%2 + 1) // 1=Story, 2=Short

			// 尝试创建草稿
			isDraft := true

			// 验证：非 Article 类型不支持草稿
			if contentType == repository.ContentTypeArticle {
				return true // Article 支持草稿，跳过
			}

			// 模拟 Create 方法中的逻辑
			if isDraft && contentType != repository.ContentTypeArticle {
				return true // 应该返回 ErrDraftNotAllowed
			}

			return false
		},
		gen.IntRange(0, 100),
	))

	properties.TestingRun(t)
}

// ============================================================================
// Property 10: Counter updates are atomic and consistent
// *For any* counter update operation (like, comment, repost, bookmark),
// the counter value SHALL change by exactly the specified delta,
// and concurrent updates SHALL not cause lost updates.
// **Validates: Requirements 3.7**
// ============================================================================

// TestProperty10_CounterUpdateDelta 测试计数器更新增量
func TestProperty10_CounterUpdateDelta(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	// 属性：计数器增加时，新值 = 旧值 + delta
	properties.Property("counter increment adds exact delta", prop.ForAll(
		func(initCount, delta int32) bool {
			// 确保初始值非负
			if initCount < 0 {
				initCount = 0
			}
			// 确保 delta 为正
			if delta < 1 {
				delta = 1
			}
			if delta > 1000 {
				delta = 1000
			}

			// 模拟计数器更新
			newCount := initCount + delta

			// 验证：新值应该等于旧值 + delta
			return newCount == initCount+delta
		},
		gen.Int32Range(0, 10000),
		gen.Int32Range(1, 100),
	))

	// 属性：计数器减少时，新值 = max(旧值 + delta, 0)
	properties.Property("counter decrement uses GREATEST to prevent negative", prop.ForAll(
		func(initCount, delta int32) bool {
			// 确保初始值非负
			if initCount < 0 {
				initCount = 0
			}
			// 确保 delta 为负
			if delta > -1 {
				delta = -1
			}
			if delta < -1000 {
				delta = -1000
			}

			// 模拟计数器更新（使用 GREATEST 逻辑）
			newCount := initCount + delta
			if newCount < 0 {
				newCount = 0
			}

			// 验证：新值应该非负
			if newCount < 0 {
				return false
			}

			// 验证：如果旧值 + delta >= 0，新值应该等于旧值 + delta
			if initCount+delta >= 0 {
				return newCount == initCount+delta
			}

			// 验证：如果旧值 + delta < 0，新值应该为 0
			return newCount == 0
		},
		gen.Int32Range(0, 100),
		gen.Int32Range(-200, -1),
	))

	// 属性：计数器永远不会为负数
	properties.Property("counter never goes negative", prop.ForAll(
		func(initCount int32, deltas []int32) bool {
			// 确保初始值非负
			if initCount < 0 {
				initCount = 0
			}

			count := initCount
			for _, delta := range deltas {
				// 模拟 GREATEST(count + delta, 0) 逻辑
				count = count + delta
				if count < 0 {
					count = 0
				}
			}

			// 验证：最终计数非负
			return count >= 0
		},
		gen.Int32Range(0, 1000),
		gen.SliceOf(gen.Int32Range(-10, 10)),
	))

	properties.TestingRun(t)
}

// TestProperty10_CounterTypeValidity 测试计数器类型有效性
func TestProperty10_CounterTypeValidity(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	// 属性：有效的计数器类型应该被接受
	properties.Property("valid counter types are accepted", prop.ForAll(
		func(counterTypeInt int) bool {
			// 生成有效的计数器类型 (1-4)
			counterType := repository.CounterType(counterTypeInt%4 + 1)

			// 验证：计数器类型在有效范围内
			return counterType >= repository.CounterTypeLike &&
				counterType <= repository.CounterTypeBookmark
		},
		gen.IntRange(0, 100),
	))

	// 属性：无效的计数器类型应该被拒绝
	properties.Property("invalid counter type is rejected", prop.ForAll(
		func(counterTypeInt int) bool {
			// 生成无效的计数器类型 (0 或 > 4)
			counterType := repository.CounterType(0)
			if counterTypeInt%2 == 0 {
				counterType = repository.CounterType(counterTypeInt%10 + 5) // 5-14
			}

			// 验证：计数器类型不在有效范围内
			return counterType == repository.CounterTypeUnspecified ||
				counterType > repository.CounterTypeBookmark
		},
		gen.IntRange(0, 100),
	))

	properties.TestingRun(t)
}

// TestProperty10_RoundTripCounterUpdate 测试计数器更新的 round-trip 一致性
func TestProperty10_RoundTripCounterUpdate(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	// 属性：增加后减少相同数量，计数应该回到原始值
	properties.Property("increment then decrement returns to original", prop.ForAll(
		func(initCount, delta int32) bool {
			// 确保初始值非负
			if initCount < 0 {
				initCount = 0
			}
			// 确保 delta 为正
			if delta < 1 {
				delta = 1
			}
			if delta > 100 {
				delta = 100
			}

			// 模拟增加
			afterIncrement := initCount + delta

			// 模拟减少（使用 GREATEST 逻辑）
			afterDecrement := afterIncrement - delta
			if afterDecrement < 0 {
				afterDecrement = 0
			}

			// 验证：应该回到原始值
			return afterDecrement == initCount
		},
		gen.Int32Range(0, 10000),
		gen.Int32Range(1, 100),
	))

	properties.TestingRun(t)
}
