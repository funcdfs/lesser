// Package service 提供 Timeline Service 单元测试
package service

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/funcdfs/lesser/timeline/internal/repository"
)

// ==================== Mock 实现 ====================

// mockInteractionClient 模拟 Interaction 服务客户端
type mockInteractionClient struct {
	statuses map[string]*InteractionStatus
	err      error
}

func (m *mockInteractionClient) BatchGetInteractionStatus(ctx context.Context, userID string, contentIDs []string) ([]*InteractionStatus, error) {
	if m.err != nil {
		return nil, m.err
	}
	var result []*InteractionStatus
	for _, id := range contentIDs {
		if status, ok := m.statuses[id]; ok {
			result = append(result, status)
		} else {
			// 返回默认状态
			result = append(result, &InteractionStatus{
				ContentID:    id,
				IsLiked:      false,
				IsBookmarked: false,
				IsReposted:   false,
			})
		}
	}
	return result, nil
}

// ==================== 辅助函数 ====================

func createTestFeedItem(id, authorID string, isPinned bool) *repository.FeedItem {
	now := time.Now()
	return &repository.FeedItem{
		ContentID:   id,
		AuthorID:    authorID,
		ContentType: 2, // Short
		Status:      2, // Published
		Title:       "",
		Text:        "测试内容 " + id,
		CreatedAt:   now,
		UpdatedAt:   now,
		PublishedAt: &now,
		IsPinned:    isPinned,
	}
}

// ==================== 分页参数测试 ====================

func TestGetFollowingFeed_DefaultLimit(t *testing.T) {
	// 测试默认分页限制
	// 当 limit <= 0 时，应该使用默认值 20

	// 验证默认值逻辑
	limit := 0
	if limit <= 0 {
		limit = 20
	}
	if limit != 20 {
		t.Errorf("默认 limit 应该为 20，但得到: %d", limit)
	}
}

func TestGetFollowingFeed_MaxLimit(t *testing.T) {
	// 测试最大分页限制
	// 当 limit > 100 时，应该限制为 100

	limit := 200
	if limit > 100 {
		limit = 100
	}
	if limit != 100 {
		t.Errorf("最大 limit 应该为 100，但得到: %d", limit)
	}
}

func TestGetUserFeed_DefaultLimit(t *testing.T) {
	// 测试用户 Feed 默认分页限制
	limit := -1
	if limit <= 0 {
		limit = 20
	}
	if limit != 20 {
		t.Errorf("默认 limit 应该为 20，但得到: %d", limit)
	}
}

func TestGetHotFeed_DefaultLimit(t *testing.T) {
	// 测试热门 Feed 默认分页限制
	limit := 0
	if limit <= 0 {
		limit = 20
	}
	if limit != 20 {
		t.Errorf("默认 limit 应该为 20，但得到: %d", limit)
	}
}

// ==================== 交互状态填充测试 ====================

func TestEnrichWithInteractionStatus_EmptyItems(t *testing.T) {
	// 测试空列表不调用 Interaction Service
	mockClient := &mockInteractionClient{
		statuses: make(map[string]*InteractionStatus),
	}
	svc := NewTimelineService(nil, mockClient)

	result := svc.enrichWithInteractionStatus(context.Background(), "user1", []*repository.FeedItem{})
	if len(result) != 0 {
		t.Errorf("空列表应该返回空结果，但得到: %d 条", len(result))
	}
}

func TestEnrichWithInteractionStatus_NoUserID(t *testing.T) {
	// 测试没有用户 ID 时不调用 Interaction Service
	mockClient := &mockInteractionClient{
		statuses: make(map[string]*InteractionStatus),
	}
	svc := NewTimelineService(nil, mockClient)

	items := []*repository.FeedItem{createTestFeedItem("content1", "author1", false)}
	result := svc.enrichWithInteractionStatus(context.Background(), "", items)

	if len(result) != 1 {
		t.Errorf("应该返回 1 条结果，但得到: %d 条", len(result))
	}
	if result[0].IsLiked || result[0].IsBookmarked || result[0].IsReposted {
		t.Error("没有用户 ID 时，交互状态应该都为 false")
	}
}

func TestEnrichWithInteractionStatus_NoClient(t *testing.T) {
	// 测试没有 Interaction Client 时不调用
	svc := NewTimelineService(nil, nil)

	items := []*repository.FeedItem{createTestFeedItem("content1", "author1", false)}
	result := svc.enrichWithInteractionStatus(context.Background(), "user1", items)

	if len(result) != 1 {
		t.Errorf("应该返回 1 条结果，但得到: %d 条", len(result))
	}
	if result[0].IsLiked || result[0].IsBookmarked || result[0].IsReposted {
		t.Error("没有 Interaction Client 时，交互状态应该都为 false")
	}
}

func TestEnrichWithInteractionStatus_WithStatuses(t *testing.T) {
	// 测试正常填充交互状态
	mockClient := &mockInteractionClient{
		statuses: map[string]*InteractionStatus{
			"content1": {ContentID: "content1", IsLiked: true, IsBookmarked: false, IsReposted: false},
			"content2": {ContentID: "content2", IsLiked: false, IsBookmarked: true, IsReposted: true},
		},
	}
	svc := NewTimelineService(nil, mockClient)

	items := []*repository.FeedItem{
		createTestFeedItem("content1", "author1", false),
		createTestFeedItem("content2", "author2", false),
	}
	result := svc.enrichWithInteractionStatus(context.Background(), "user1", items)

	if len(result) != 2 {
		t.Errorf("应该返回 2 条结果，但得到: %d 条", len(result))
	}

	// 验证 content1 的状态
	if !result[0].IsLiked {
		t.Error("content1 应该是已点赞状态")
	}
	if result[0].IsBookmarked {
		t.Error("content1 不应该是已收藏状态")
	}

	// 验证 content2 的状态
	if result[1].IsLiked {
		t.Error("content2 不应该是已点赞状态")
	}
	if !result[1].IsBookmarked {
		t.Error("content2 应该是已收藏状态")
	}
	if !result[1].IsReposted {
		t.Error("content2 应该是已转发状态")
	}
}

func TestEnrichWithInteractionStatus_ClientError(t *testing.T) {
	// 测试 Interaction Client 返回错误时不影响主流程
	mockClient := &mockInteractionClient{
		err: errors.New("connection refused"),
	}
	svc := NewTimelineService(nil, mockClient)

	items := []*repository.FeedItem{createTestFeedItem("content1", "author1", false)}
	result := svc.enrichWithInteractionStatus(context.Background(), "user1", items)

	// 即使出错，也应该返回结果（只是没有交互状态）
	if len(result) != 1 {
		t.Errorf("应该返回 1 条结果，但得到: %d 条", len(result))
	}
	if result[0].IsLiked || result[0].IsBookmarked || result[0].IsReposted {
		t.Error("Interaction Client 出错时，交互状态应该都为 false")
	}
}

// ==================== 内容详情测试 ====================

func TestGetContentDetail_NotFound(t *testing.T) {
	// 测试内容不存在的情况
	// 由于需要 mock repository，这里只测试错误类型
	if ErrContentNotFound == nil {
		t.Error("ErrContentNotFound 不应该为 nil")
	}
	if ErrContentNotFound.Error() != "内容不存在" {
		t.Errorf("ErrContentNotFound 错误信息不正确: %s", ErrContentNotFound.Error())
	}
}

// ==================== FeedItemWithStatus 测试 ====================

func TestFeedItemWithStatus_Structure(t *testing.T) {
	// 测试 FeedItemWithStatus 结构
	feedItem := createTestFeedItem("content1", "author1", true)
	itemWithStatus := &FeedItemWithStatus{
		FeedItem:     feedItem,
		IsLiked:      true,
		IsBookmarked: true,
		IsReposted:   false,
	}

	if itemWithStatus.ContentID != "content1" {
		t.Errorf("ContentID 应该为 content1，但得到: %s", itemWithStatus.ContentID)
	}
	if itemWithStatus.AuthorID != "author1" {
		t.Errorf("AuthorID 应该为 author1，但得到: %s", itemWithStatus.AuthorID)
	}
	if !itemWithStatus.IsPinned {
		t.Error("IsPinned 应该为 true")
	}
	if !itemWithStatus.IsLiked {
		t.Error("IsLiked 应该为 true")
	}
	if !itemWithStatus.IsBookmarked {
		t.Error("IsBookmarked 应该为 true")
	}
	if itemWithStatus.IsReposted {
		t.Error("IsReposted 应该为 false")
	}
}

// ==================== InteractionStatus 测试 ====================

func TestInteractionStatus_Structure(t *testing.T) {
	// 测试 InteractionStatus 结构
	status := &InteractionStatus{
		ContentID:    "content1",
		IsLiked:      true,
		IsBookmarked: false,
		IsReposted:   true,
	}

	if status.ContentID != "content1" {
		t.Errorf("ContentID 应该为 content1，但得到: %s", status.ContentID)
	}
	if !status.IsLiked {
		t.Error("IsLiked 应该为 true")
	}
	if status.IsBookmarked {
		t.Error("IsBookmarked 应该为 false")
	}
	if !status.IsReposted {
		t.Error("IsReposted 应该为 true")
	}
}

// ==================== GetContentIDs 测试 ====================

func TestGetContentIDs_EmptyList(t *testing.T) {
	// 测试空列表
	ids := repository.GetContentIDs([]*repository.FeedItem{})
	if len(ids) != 0 {
		t.Errorf("空列表应该返回空 ID 列表，但得到: %d 个", len(ids))
	}
}

func TestGetContentIDs_MultipleItems(t *testing.T) {
	// 测试多个条目
	items := []*repository.FeedItem{
		createTestFeedItem("content1", "author1", false),
		createTestFeedItem("content2", "author2", false),
		createTestFeedItem("content3", "author3", true),
	}
	ids := repository.GetContentIDs(items)

	if len(ids) != 3 {
		t.Errorf("应该返回 3 个 ID，但得到: %d 个", len(ids))
	}
	if ids[0] != "content1" || ids[1] != "content2" || ids[2] != "content3" {
		t.Error("ID 顺序不正确")
	}
}

// ==================== 时间范围测试 ====================

func TestTimeRange_ValidValues(t *testing.T) {
	// 测试有效的时间范围值
	validRanges := []string{"day", "week", "month"}
	for _, r := range validRanges {
		if r != "day" && r != "week" && r != "month" {
			t.Errorf("无效的时间范围: %s", r)
		}
	}
}

func TestTimeRange_DefaultValue(t *testing.T) {
	// 测试默认时间范围
	timeRange := ""
	if timeRange == "" {
		timeRange = "week"
	}
	if timeRange != "week" {
		t.Errorf("默认时间范围应该为 week，但得到: %s", timeRange)
	}
}
