// Package service 提供 Interaction Service 单元测试
package service

import (
	"context"
	"errors"
	"testing"

	"github.com/funcdfs/lesser/interaction/internal/repository"
	contentpb "github.com/funcdfs/lesser/interaction/proto/content"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// ==================== Mock 实现 ====================

// mockContentClient 模拟 Content 服务客户端
type mockContentClient struct {
	existsMap        map[string]bool
	commentsDisabled map[string]bool
	counters         map[string]map[contentpb.CounterType]int32
	authorMap        map[string]string
	checkErr         error
	updateErr        error
}

func newMockContentClient() *mockContentClient {
	return &mockContentClient{
		existsMap:        make(map[string]bool),
		commentsDisabled: make(map[string]bool),
		counters:         make(map[string]map[contentpb.CounterType]int32),
		authorMap:        make(map[string]string),
	}
}

func (m *mockContentClient) CheckContentExists(ctx context.Context, contentID string) (bool, bool, error) {
	if m.checkErr != nil {
		return false, false, m.checkErr
	}
	exists := m.existsMap[contentID]
	disabled := m.commentsDisabled[contentID]
	return exists, disabled, nil
}

func (m *mockContentClient) UpdateCounter(ctx context.Context, contentID string, counterType contentpb.CounterType, delta int32) (int32, error) {
	if m.updateErr != nil {
		return 0, m.updateErr
	}
	if m.counters[contentID] == nil {
		m.counters[contentID] = make(map[contentpb.CounterType]int32)
	}
	m.counters[contentID][counterType] += delta
	return m.counters[contentID][counterType], nil
}

func (m *mockContentClient) GetContentAuthorID(ctx context.Context, contentID string) (string, error) {
	return m.authorMap[contentID], nil
}

func (m *mockContentClient) setContentExists(contentID string, exists bool) {
	m.existsMap[contentID] = exists
}

func (m *mockContentClient) setContentAuthor(contentID, authorID string) {
	m.authorMap[contentID] = authorID
}

// mockLikeRepository 模拟点赞仓库
type mockLikeRepository struct {
	likes    map[string]map[string]bool // userID -> contentID -> liked
	createErr error
	deleteErr error
	existsErr error
	batchErr  error
}

func newMockLikeRepository() *mockLikeRepository {
	return &mockLikeRepository{
		likes: make(map[string]map[string]bool),
	}
}

func (m *mockLikeRepository) Create(userID, contentID string) (bool, error) {
	if m.createErr != nil {
		return false, m.createErr
	}
	if m.likes[userID] == nil {
		m.likes[userID] = make(map[string]bool)
	}
	if m.likes[userID][contentID] {
		return false, nil // 已存在
	}
	m.likes[userID][contentID] = true
	return true, nil
}

func (m *mockLikeRepository) Delete(userID, contentID string) (bool, error) {
	if m.deleteErr != nil {
		return false, m.deleteErr
	}
	if m.likes[userID] == nil || !m.likes[userID][contentID] {
		return false, nil // 不存在
	}
	delete(m.likes[userID], contentID)
	return true, nil
}

func (m *mockLikeRepository) Exists(userID, contentID string) (bool, error) {
	if m.existsErr != nil {
		return false, m.existsErr
	}
	if m.likes[userID] == nil {
		return false, nil
	}
	return m.likes[userID][contentID], nil
}

func (m *mockLikeRepository) BatchExists(userID string, contentIDs []string) (map[string]bool, error) {
	if m.batchErr != nil {
		return nil, m.batchErr
	}
	result := make(map[string]bool)
	if m.likes[userID] == nil {
		return result, nil
	}
	for _, contentID := range contentIDs {
		result[contentID] = m.likes[userID][contentID]
	}
	return result, nil
}


// mockBookmarkRepository 模拟收藏仓库
type mockBookmarkRepository struct {
	bookmarks map[string]map[string]bool
	createErr error
	deleteErr error
	existsErr error
	batchErr  error
	listErr   error
}

func newMockBookmarkRepository() *mockBookmarkRepository {
	return &mockBookmarkRepository{
		bookmarks: make(map[string]map[string]bool),
	}
}

func (m *mockBookmarkRepository) Create(userID, contentID string) (bool, error) {
	if m.createErr != nil {
		return false, m.createErr
	}
	if m.bookmarks[userID] == nil {
		m.bookmarks[userID] = make(map[string]bool)
	}
	if m.bookmarks[userID][contentID] {
		return false, nil
	}
	m.bookmarks[userID][contentID] = true
	return true, nil
}

func (m *mockBookmarkRepository) Delete(userID, contentID string) (bool, error) {
	if m.deleteErr != nil {
		return false, m.deleteErr
	}
	if m.bookmarks[userID] == nil || !m.bookmarks[userID][contentID] {
		return false, nil
	}
	delete(m.bookmarks[userID], contentID)
	return true, nil
}

func (m *mockBookmarkRepository) Exists(userID, contentID string) (bool, error) {
	if m.existsErr != nil {
		return false, m.existsErr
	}
	if m.bookmarks[userID] == nil {
		return false, nil
	}
	return m.bookmarks[userID][contentID], nil
}

func (m *mockBookmarkRepository) BatchExists(userID string, contentIDs []string) (map[string]bool, error) {
	if m.batchErr != nil {
		return nil, m.batchErr
	}
	result := make(map[string]bool)
	if m.bookmarks[userID] == nil {
		return result, nil
	}
	for _, contentID := range contentIDs {
		result[contentID] = m.bookmarks[userID][contentID]
	}
	return result, nil
}

func (m *mockBookmarkRepository) List(userID string, limit, offset int) ([]*repository.Bookmark, int, error) {
	if m.listErr != nil {
		return nil, 0, m.listErr
	}
	// 简单实现：返回空列表
	return []*repository.Bookmark{}, 0, nil
}

// mockRepostRepository 模拟转发仓库
type mockRepostRepository struct {
	reposts   map[string]map[string]*repository.Repost
	createErr error
	deleteErr error
	existsErr error
	batchErr  error
}

func newMockRepostRepository() *mockRepostRepository {
	return &mockRepostRepository{
		reposts: make(map[string]map[string]*repository.Repost),
	}
}

func (m *mockRepostRepository) Create(userID, contentID, quote string) (*repository.Repost, bool, error) {
	if m.createErr != nil {
		return nil, false, m.createErr
	}
	if m.reposts[userID] == nil {
		m.reposts[userID] = make(map[string]*repository.Repost)
	}
	if existing := m.reposts[userID][contentID]; existing != nil {
		return existing, false, nil
	}
	repost := &repository.Repost{
		ID:        "repost-" + userID + "-" + contentID,
		UserID:    userID,
		ContentID: contentID,
		Quote:     quote,
	}
	m.reposts[userID][contentID] = repost
	return repost, true, nil
}

func (m *mockRepostRepository) Delete(userID, contentID string) (bool, error) {
	if m.deleteErr != nil {
		return false, m.deleteErr
	}
	if m.reposts[userID] == nil || m.reposts[userID][contentID] == nil {
		return false, nil
	}
	delete(m.reposts[userID], contentID)
	return true, nil
}

func (m *mockRepostRepository) Exists(userID, contentID string) (bool, error) {
	if m.existsErr != nil {
		return false, m.existsErr
	}
	if m.reposts[userID] == nil {
		return false, nil
	}
	return m.reposts[userID][contentID] != nil, nil
}

func (m *mockRepostRepository) BatchExists(userID string, contentIDs []string) (map[string]bool, error) {
	if m.batchErr != nil {
		return nil, m.batchErr
	}
	result := make(map[string]bool)
	if m.reposts[userID] == nil {
		return result, nil
	}
	for _, contentID := range contentIDs {
		result[contentID] = m.reposts[userID][contentID] != nil
	}
	return result, nil
}

func (m *mockRepostRepository) GetByUserAndContent(userID, contentID string) (*repository.Repost, error) {
	if m.reposts[userID] == nil {
		return nil, errors.New("not found")
	}
	return m.reposts[userID][contentID], nil
}

// mockPublisher 模拟消息发布者
type mockPublisher struct {
	events []publishedEvent
}

type publishedEvent struct {
	routingKey string
	event      interface{}
}

func newMockPublisher() *mockPublisher {
	return &mockPublisher{
		events: make([]publishedEvent, 0),
	}
}

func (m *mockPublisher) PublishAsync(ctx context.Context, routingKey string, event interface{}) {
	m.events = append(m.events, publishedEvent{routingKey: routingKey, event: event})
}


// ==================== 辅助函数 ====================

// testService 测试服务结构
type testService struct {
	svc          *InteractionService
	contentClient *mockContentClient
	likeRepo     *mockLikeRepository
	bookmarkRepo *mockBookmarkRepository
	repostRepo   *mockRepostRepository
	publisher    *mockPublisher
}

// createTestService 创建测试用的服务实例
func createTestService() *testService {
	contentClient := newMockContentClient()
	likeRepo := newMockLikeRepository()
	bookmarkRepo := newMockBookmarkRepository()
	repostRepo := newMockRepostRepository()
	publisher := newMockPublisher()

	svc := NewInteractionService(likeRepo, bookmarkRepo, repostRepo, contentClient)
	svc.SetPublisher(publisher)

	return &testService{
		svc:           svc,
		contentClient: contentClient,
		likeRepo:      likeRepo,
		bookmarkRepo:  bookmarkRepo,
		repostRepo:    repostRepo,
		publisher:     publisher,
	}
}

// ==================== 点赞测试 ====================

func TestLike_Success(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	// 设置内容存在
	ts.contentClient.setContentExists("content-1", true)
	ts.contentClient.setContentAuthor("content-1", "author-1")

	// 点赞
	count, err := ts.svc.Like(ctx, "user-1", "content-1")
	require.NoError(t, err)
	assert.Equal(t, int32(1), count)

	// 验证点赞状态
	liked, err := ts.svc.CheckLiked("user-1", "content-1")
	require.NoError(t, err)
	assert.True(t, liked)

	// 验证事件发布
	assert.Len(t, ts.publisher.events, 1)
}

func TestLike_AlreadyLiked(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 第一次点赞
	count1, err := ts.svc.Like(ctx, "user-1", "content-1")
	require.NoError(t, err)
	assert.Equal(t, int32(1), count1)

	// 第二次点赞（已点赞）
	count2, err := ts.svc.Like(ctx, "user-1", "content-1")
	require.NoError(t, err)
	assert.Equal(t, int32(1), count2) // 计数不变
}

func TestLike_ContentNotFound(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	// 内容不存在
	ts.contentClient.setContentExists("content-1", false)

	_, err := ts.svc.Like(ctx, "user-1", "content-1")
	assert.ErrorIs(t, err, ErrContentNotFound)
}

func TestLike_ContentServiceError(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	// 模拟 Content Service 错误
	ts.contentClient.checkErr = errors.New("service unavailable")

	_, err := ts.svc.Like(ctx, "user-1", "content-1")
	assert.Error(t, err)
}

func TestLike_RepositoryError(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)
	ts.likeRepo.createErr = errors.New("database error")

	_, err := ts.svc.Like(ctx, "user-1", "content-1")
	assert.Error(t, err)
}

func TestUnlike_Success(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 先点赞
	_, err := ts.svc.Like(ctx, "user-1", "content-1")
	require.NoError(t, err)

	// 取消点赞
	count, err := ts.svc.Unlike(ctx, "user-1", "content-1")
	require.NoError(t, err)
	assert.Equal(t, int32(0), count)

	// 验证点赞状态
	liked, err := ts.svc.CheckLiked("user-1", "content-1")
	require.NoError(t, err)
	assert.False(t, liked)
}

func TestUnlike_NotLiked(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	// 未点赞的内容取消点赞
	count, err := ts.svc.Unlike(ctx, "user-1", "content-1")
	require.NoError(t, err)
	assert.Equal(t, int32(0), count)
}

func TestUnlike_RepositoryError(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.likeRepo.deleteErr = errors.New("database error")

	_, err := ts.svc.Unlike(ctx, "user-1", "content-1")
	assert.Error(t, err)
}

func TestCheckLiked_NotLiked(t *testing.T) {
	ts := createTestService()

	liked, err := ts.svc.CheckLiked("user-1", "content-1")
	require.NoError(t, err)
	assert.False(t, liked)
}

func TestCheckLiked_Error(t *testing.T) {
	ts := createTestService()

	ts.likeRepo.existsErr = errors.New("database error")

	_, err := ts.svc.CheckLiked("user-1", "content-1")
	assert.Error(t, err)
}


// ==================== 收藏测试 ====================

func TestBookmark_Success(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)
	ts.contentClient.setContentAuthor("content-1", "author-1")

	// 收藏
	count, err := ts.svc.Bookmark(ctx, "user-1", "content-1")
	require.NoError(t, err)
	assert.Equal(t, int32(1), count)

	// 验证事件发布
	assert.Len(t, ts.publisher.events, 1)
}

func TestBookmark_AlreadyBookmarked(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 第一次收藏
	count1, err := ts.svc.Bookmark(ctx, "user-1", "content-1")
	require.NoError(t, err)
	assert.Equal(t, int32(1), count1)

	// 第二次收藏（已收藏）
	count2, err := ts.svc.Bookmark(ctx, "user-1", "content-1")
	require.NoError(t, err)
	assert.Equal(t, int32(1), count2) // 计数不变
}

func TestBookmark_ContentNotFound(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", false)

	_, err := ts.svc.Bookmark(ctx, "user-1", "content-1")
	assert.ErrorIs(t, err, ErrContentNotFound)
}

func TestBookmark_ContentServiceError(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.checkErr = errors.New("service unavailable")

	_, err := ts.svc.Bookmark(ctx, "user-1", "content-1")
	assert.Error(t, err)
}

func TestBookmark_RepositoryError(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)
	ts.bookmarkRepo.createErr = errors.New("database error")

	_, err := ts.svc.Bookmark(ctx, "user-1", "content-1")
	assert.Error(t, err)
}

func TestUnbookmark_Success(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 先收藏
	_, err := ts.svc.Bookmark(ctx, "user-1", "content-1")
	require.NoError(t, err)

	// 取消收藏
	count, err := ts.svc.Unbookmark(ctx, "user-1", "content-1")
	require.NoError(t, err)
	assert.Equal(t, int32(0), count)
}

func TestUnbookmark_NotBookmarked(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	// 未收藏的内容取消收藏
	count, err := ts.svc.Unbookmark(ctx, "user-1", "content-1")
	require.NoError(t, err)
	assert.Equal(t, int32(0), count)
}

func TestUnbookmark_RepositoryError(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.bookmarkRepo.deleteErr = errors.New("database error")

	_, err := ts.svc.Unbookmark(ctx, "user-1", "content-1")
	assert.Error(t, err)
}

func TestListBookmarks_DefaultPagination(t *testing.T) {
	ts := createTestService()

	// 测试默认分页参数（limit <= 0 时使用默认值 20）
	bookmarks, total, err := ts.svc.ListBookmarks("user-1", 0, 0)
	require.NoError(t, err)
	assert.NotNil(t, bookmarks)
	assert.Equal(t, 0, total)
}

func TestListBookmarks_MaxLimit(t *testing.T) {
	ts := createTestService()

	// 测试超过最大限制（limit > 100 时使用 100）
	bookmarks, total, err := ts.svc.ListBookmarks("user-1", 200, 0)
	require.NoError(t, err)
	assert.NotNil(t, bookmarks)
	assert.Equal(t, 0, total)
}

func TestListBookmarks_RepositoryError(t *testing.T) {
	ts := createTestService()

	ts.bookmarkRepo.listErr = errors.New("database error")

	_, _, err := ts.svc.ListBookmarks("user-1", 10, 0)
	assert.Error(t, err)
}


// ==================== 转发测试 ====================

func TestCreateRepost_Success(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)
	ts.contentClient.setContentAuthor("content-1", "author-1")

	// 创建转发
	repost, count, err := ts.svc.CreateRepost(ctx, "user-1", "content-1", "这是引用")
	require.NoError(t, err)
	assert.NotNil(t, repost)
	assert.Equal(t, "user-1", repost.UserID)
	assert.Equal(t, "content-1", repost.ContentID)
	assert.Equal(t, "这是引用", repost.Quote)
	assert.Equal(t, int32(1), count)

	// 验证事件发布
	assert.Len(t, ts.publisher.events, 1)
}

func TestCreateRepost_WithoutQuote(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 创建无引用的转发
	repost, count, err := ts.svc.CreateRepost(ctx, "user-1", "content-1", "")
	require.NoError(t, err)
	assert.NotNil(t, repost)
	assert.Empty(t, repost.Quote)
	assert.Equal(t, int32(1), count)
}

func TestCreateRepost_AlreadyReposted(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 第一次转发
	repost1, count1, err := ts.svc.CreateRepost(ctx, "user-1", "content-1", "引用1")
	require.NoError(t, err)
	assert.Equal(t, int32(1), count1)

	// 第二次转发（已转发）
	repost2, count2, err := ts.svc.CreateRepost(ctx, "user-1", "content-1", "引用2")
	require.NoError(t, err)
	assert.Equal(t, repost1.ID, repost2.ID) // 返回已存在的转发
	assert.Equal(t, int32(1), count2)       // 计数不变
}

func TestCreateRepost_ContentNotFound(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", false)

	_, _, err := ts.svc.CreateRepost(ctx, "user-1", "content-1", "")
	assert.ErrorIs(t, err, ErrContentNotFound)
}

func TestCreateRepost_ContentServiceError(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.checkErr = errors.New("service unavailable")

	_, _, err := ts.svc.CreateRepost(ctx, "user-1", "content-1", "")
	assert.Error(t, err)
}

func TestCreateRepost_RepositoryError(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)
	ts.repostRepo.createErr = errors.New("database error")

	_, _, err := ts.svc.CreateRepost(ctx, "user-1", "content-1", "")
	assert.Error(t, err)
}

func TestDeleteRepost_Success(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 先创建转发
	_, _, err := ts.svc.CreateRepost(ctx, "user-1", "content-1", "")
	require.NoError(t, err)

	// 删除转发
	count, err := ts.svc.DeleteRepost(ctx, "user-1", "content-1")
	require.NoError(t, err)
	assert.Equal(t, int32(0), count)
}

func TestDeleteRepost_NotReposted(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	// 未转发的内容删除转发
	count, err := ts.svc.DeleteRepost(ctx, "user-1", "content-1")
	require.NoError(t, err)
	assert.Equal(t, int32(0), count)
}

func TestDeleteRepost_RepositoryError(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.repostRepo.deleteErr = errors.New("database error")

	_, err := ts.svc.DeleteRepost(ctx, "user-1", "content-1")
	assert.Error(t, err)
}


// ==================== 批量查询测试 ====================

func TestBatchGetInteractionStatus_EmptyList(t *testing.T) {
	ts := createTestService()

	// 空列表
	statuses, err := ts.svc.BatchGetInteractionStatus("user-1", []string{})
	require.NoError(t, err)
	assert.Empty(t, statuses)
}

func TestBatchGetInteractionStatus_MultipleContents(t *testing.T) {
	ts := createTestService()

	// 多个内容
	contentIDs := []string{"content-1", "content-2", "content-3"}
	statuses, err := ts.svc.BatchGetInteractionStatus("user-1", contentIDs)
	require.NoError(t, err)
	assert.Len(t, statuses, len(contentIDs))

	// 验证每个结果的 ContentID
	for i, status := range statuses {
		assert.Equal(t, contentIDs[i], status.ContentID)
	}
}

func TestBatchGetInteractionStatus_AllFalse(t *testing.T) {
	ts := createTestService()

	// 未进行任何交互
	contentIDs := []string{"content-1", "content-2"}
	statuses, err := ts.svc.BatchGetInteractionStatus("user-1", contentIDs)
	require.NoError(t, err)

	for _, status := range statuses {
		assert.False(t, status.IsLiked)
		assert.False(t, status.IsBookmarked)
		assert.False(t, status.IsReposted)
	}
}

func TestBatchGetInteractionStatus_MixedStatus(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	// 设置内容存在
	ts.contentClient.setContentExists("content-1", true)
	ts.contentClient.setContentExists("content-2", true)
	ts.contentClient.setContentExists("content-3", true)

	// 对 content-1 点赞
	_, err := ts.svc.Like(ctx, "user-1", "content-1")
	require.NoError(t, err)

	// 对 content-2 收藏
	_, err = ts.svc.Bookmark(ctx, "user-1", "content-2")
	require.NoError(t, err)

	// 对 content-3 转发
	_, _, err = ts.svc.CreateRepost(ctx, "user-1", "content-3", "")
	require.NoError(t, err)

	// 批量查询
	contentIDs := []string{"content-1", "content-2", "content-3"}
	statuses, err := ts.svc.BatchGetInteractionStatus("user-1", contentIDs)
	require.NoError(t, err)
	assert.Len(t, statuses, 3)

	// 验证 content-1 只有点赞
	assert.True(t, statuses[0].IsLiked)
	assert.False(t, statuses[0].IsBookmarked)
	assert.False(t, statuses[0].IsReposted)

	// 验证 content-2 只有收藏
	assert.False(t, statuses[1].IsLiked)
	assert.True(t, statuses[1].IsBookmarked)
	assert.False(t, statuses[1].IsReposted)

	// 验证 content-3 只有转发
	assert.False(t, statuses[2].IsLiked)
	assert.False(t, statuses[2].IsBookmarked)
	assert.True(t, statuses[2].IsReposted)
}

func TestBatchGetInteractionStatus_AllInteractions(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	// 设置内容存在
	ts.contentClient.setContentExists("content-1", true)

	// 对 content-1 进行所有交互
	_, err := ts.svc.Like(ctx, "user-1", "content-1")
	require.NoError(t, err)
	_, err = ts.svc.Bookmark(ctx, "user-1", "content-1")
	require.NoError(t, err)
	_, _, err = ts.svc.CreateRepost(ctx, "user-1", "content-1", "")
	require.NoError(t, err)

	// 批量查询
	statuses, err := ts.svc.BatchGetInteractionStatus("user-1", []string{"content-1"})
	require.NoError(t, err)
	assert.Len(t, statuses, 1)

	// 验证所有交互状态都为 true
	assert.True(t, statuses[0].IsLiked)
	assert.True(t, statuses[0].IsBookmarked)
	assert.True(t, statuses[0].IsReposted)
}

func TestBatchGetInteractionStatus_LikeRepoError(t *testing.T) {
	ts := createTestService()

	ts.likeRepo.batchErr = errors.New("database error")

	_, err := ts.svc.BatchGetInteractionStatus("user-1", []string{"content-1"})
	assert.Error(t, err)
}

func TestBatchGetInteractionStatus_BookmarkRepoError(t *testing.T) {
	ts := createTestService()

	ts.bookmarkRepo.batchErr = errors.New("database error")

	_, err := ts.svc.BatchGetInteractionStatus("user-1", []string{"content-1"})
	assert.Error(t, err)
}

func TestBatchGetInteractionStatus_RepostRepoError(t *testing.T) {
	ts := createTestService()

	ts.repostRepo.batchErr = errors.New("database error")

	_, err := ts.svc.BatchGetInteractionStatus("user-1", []string{"content-1"})
	assert.Error(t, err)
}

// ==================== Publisher 测试 ====================

func TestSetPublisher(t *testing.T) {
	ts := createTestService()
	newPublisher := newMockPublisher()

	ts.svc.SetPublisher(newPublisher)
	// 验证 publisher 被设置（通过执行操作验证）
	assert.NotNil(t, ts.svc.publisher)
}

func TestSetPublisher_Nil(t *testing.T) {
	ts := createTestService()

	ts.svc.SetPublisher(nil)
	assert.Nil(t, ts.svc.publisher)
}

func TestLike_NoEventWhenSelfLike(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	// 设置内容存在，作者是自己
	ts.contentClient.setContentExists("content-1", true)
	ts.contentClient.setContentAuthor("content-1", "user-1") // 自己的内容

	// 点赞自己的内容
	_, err := ts.svc.Like(ctx, "user-1", "content-1")
	require.NoError(t, err)

	// 不应该发布事件
	assert.Empty(t, ts.publisher.events)
}

func TestBookmark_NoEventWhenSelfBookmark(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	// 设置内容存在，作者是自己
	ts.contentClient.setContentExists("content-1", true)
	ts.contentClient.setContentAuthor("content-1", "user-1") // 自己的内容

	// 收藏自己的内容
	_, err := ts.svc.Bookmark(ctx, "user-1", "content-1")
	require.NoError(t, err)

	// 不应该发布事件
	assert.Empty(t, ts.publisher.events)
}

func TestCreateRepost_NoEventWhenSelfRepost(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	// 设置内容存在，作者是自己
	ts.contentClient.setContentExists("content-1", true)
	ts.contentClient.setContentAuthor("content-1", "user-1") // 自己的内容

	// 转发自己的内容
	_, _, err := ts.svc.CreateRepost(ctx, "user-1", "content-1", "")
	require.NoError(t, err)

	// 不应该发布事件
	assert.Empty(t, ts.publisher.events)
}

// ==================== InteractionStatus 结构测试 ====================

func TestInteractionStatus_Fields(t *testing.T) {
	status := &InteractionStatus{
		ContentID:    "content-1",
		IsLiked:      true,
		IsBookmarked: false,
		IsReposted:   true,
	}

	assert.Equal(t, "content-1", status.ContentID)
	assert.True(t, status.IsLiked)
	assert.False(t, status.IsBookmarked)
	assert.True(t, status.IsReposted)
}

// ==================== 错误类型测试 ====================

func TestErrorTypes(t *testing.T) {
	assert.NotNil(t, ErrContentNotFound)
	assert.Equal(t, "内容不存在", ErrContentNotFound.Error())
}
