// Package service 提供 Comment Service 单元测试
package logic

import (
	"context"
	"errors"
	"testing"
	"time"

	contentpb "github.com/funcdfs/lesser/comment/gen_protos/content"
	"github.com/funcdfs/lesser/comment/internal/data_access"
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
	getAuthorErr     error
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
	if m.getAuthorErr != nil {
		return "", m.getAuthorErr
	}
	return m.authorMap[contentID], nil
}

func (m *mockContentClient) setContentExists(contentID string, exists bool) {
	m.existsMap[contentID] = exists
}

func (m *mockContentClient) setCommentsDisabled(contentID string, disabled bool) {
	m.commentsDisabled[contentID] = disabled
}

func (m *mockContentClient) setContentAuthor(contentID, authorID string) {
	m.authorMap[contentID] = authorID
}

// mockCommentDataAccess 模拟评论数据访问
type mockCommentDataAccess struct {
	comments     map[string]*data_access.Comment
	commentLikes map[string]map[string]bool // commentID -> userID -> liked
	createErr    error
	getErr       error
	deleteErr    error
	listErr      error
	likeErr      error
	unlikeErr    error
}

func newMockCommentDataAccess() *mockCommentDataAccess {
	return &mockCommentDataAccess{
		comments:     make(map[string]*data_access.Comment),
		commentLikes: make(map[string]map[string]bool),
	}
}

func (m *mockCommentDataAccess) Create(ctx context.Context, comment *data_access.Comment) error {
	if m.createErr != nil {
		return m.createErr
	}
	// 验证父评论
	if comment.ParentID != "" {
		parent, exists := m.comments[comment.ParentID]
		if !exists || parent.IsDeleted {
			return data_access.ErrInvalidParent
		}
		parent.ReplyCount++
	}
	comment.ID = "comment-" + time.Now().Format("20060102150405.000000000")
	comment.CreatedAt = time.Now()
	comment.UpdatedAt = time.Now()
	m.comments[comment.ID] = comment
	return nil
}

func (m *mockCommentDataAccess) GetByID(ctx context.Context, id string) (*data_access.Comment, error) {
	if m.getErr != nil {
		return nil, m.getErr
	}
	comment, exists := m.comments[id]
	if !exists {
		return nil, data_access.ErrCommentNotFound
	}
	return comment, nil
}

func (m *mockCommentDataAccess) Delete(ctx context.Context, id string) (*data_access.Comment, error) {
	if m.deleteErr != nil {
		return nil, m.deleteErr
	}
	comment, exists := m.comments[id]
	if !exists {
		return nil, data_access.ErrCommentNotFound
	}
	if comment.IsDeleted {
		return nil, data_access.ErrCommentNotFound
	}
	comment.IsDeleted = true
	// 更新父评论的回复计数
	if comment.ParentID != "" {
		if parent, ok := m.comments[comment.ParentID]; ok {
			if parent.ReplyCount > 0 {
				parent.ReplyCount--
			}
		}
	}
	return comment, nil
}

func (m *mockCommentDataAccess) List(ctx context.Context, contentID, parentID string, sortBy data_access.SortBy, limit, offset int) ([]*data_access.Comment, int, error) {
	if m.listErr != nil {
		return nil, 0, m.listErr
	}
	var result []*data_access.Comment
	for _, c := range m.comments {
		if c.ContentID == contentID && !c.IsDeleted {
			if parentID == "" && c.ParentID == "" {
				result = append(result, c)
			} else if parentID != "" && c.ParentID == parentID {
				result = append(result, c)
			}
		}
	}
	// 简单排序实现
	total := len(result)
	if offset >= total {
		return []*data_access.Comment{}, total, nil
	}
	end := offset + limit
	if end > total {
		end = total
	}
	return result[offset:end], total, nil
}

func (m *mockCommentDataAccess) GetCount(ctx context.Context, contentID string) (int32, error) {
	var count int32
	for _, c := range m.comments {
		if c.ContentID == contentID && !c.IsDeleted {
			count++
		}
	}
	return count, nil
}

func (m *mockCommentDataAccess) BatchGetCount(ctx context.Context, contentIDs []string) (map[string]int32, error) {
	result := make(map[string]int32)
	for _, id := range contentIDs {
		result[id] = 0
	}
	for _, c := range m.comments {
		if !c.IsDeleted {
			if _, ok := result[c.ContentID]; ok {
				result[c.ContentID]++
			}
		}
	}
	return result, nil
}

func (m *mockCommentDataAccess) LikeComment(ctx context.Context, userID, commentID string) (int32, error) {
	if m.likeErr != nil {
		return 0, m.likeErr
	}
	comment, exists := m.comments[commentID]
	if !exists || comment.IsDeleted {
		return 0, data_access.ErrCommentNotFound
	}
	if m.commentLikes[commentID] == nil {
		m.commentLikes[commentID] = make(map[string]bool)
	}
	if m.commentLikes[commentID][userID] {
		return 0, data_access.ErrAlreadyLiked
	}
	m.commentLikes[commentID][userID] = true
	comment.LikeCount++
	return comment.LikeCount, nil
}

func (m *mockCommentDataAccess) UnlikeComment(ctx context.Context, userID, commentID string) (int32, error) {
	if m.unlikeErr != nil {
		return 0, m.unlikeErr
	}
	comment, exists := m.comments[commentID]
	if !exists {
		return 0, data_access.ErrCommentNotFound
	}
	if m.commentLikes[commentID] == nil || !m.commentLikes[commentID][userID] {
		return 0, data_access.ErrNotLiked
	}
	delete(m.commentLikes[commentID], userID)
	if comment.LikeCount > 0 {
		comment.LikeCount--
	}
	return comment.LikeCount, nil
}

func (m *mockCommentDataAccess) CheckLiked(ctx context.Context, userID, commentID string) (bool, error) {
	if m.commentLikes[commentID] == nil {
		return false, nil
	}
	return m.commentLikes[commentID][userID], nil
}

func (m *mockCommentDataAccess) BatchCheckLiked(ctx context.Context, userID string, commentIDs []string) (map[string]bool, error) {
	result := make(map[string]bool)
	for _, id := range commentIDs {
		if m.commentLikes[id] != nil {
			result[id] = m.commentLikes[id][userID]
		} else {
			result[id] = false
		}
	}
	return result, nil
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

func (m *mockPublisher) PublishCommentCreated(ctx context.Context, commentID, authorID, contentID, contentAuthorID, parentID, parentAuthorID, text string) {
	m.events = append(m.events, publishedEvent{routingKey: "comment.created", event: map[string]string{
		"comment_id": commentID,
		"author_id":  authorID,
		"content_id": contentID,
	}})
}

func (m *mockPublisher) PublishCommentLiked(ctx context.Context, commentID, commentAuthorID, likerID string) {
	m.events = append(m.events, publishedEvent{routingKey: "comment.liked", event: map[string]string{
		"comment_id":        commentID,
		"comment_author_id": commentAuthorID,
		"liker_id":          likerID,
	}})
}

func (m *mockPublisher) PublishUserMentioned(ctx context.Context, mentionedUserID, mentionerID, commentID string) {
	m.events = append(m.events, publishedEvent{routingKey: "user.mentioned", event: map[string]string{
		"mentioned_user_id": mentionedUserID,
		"mentioner_id":      mentionerID,
		"comment_id":        commentID,
	}})
}

// ==================== 辅助函数 ====================

// testService 测试服务结构
type testService struct {
	svc           *CommentService
	contentClient *mockContentClient
	commentRepo   *mockCommentDataAccess
	publisher     *mockPublisher
}

// createTestService 创建测试用的服务实例
func createTestService() *testService {
	contentClient := newMockContentClient()
	commentRepo := newMockCommentDataAccess()
	publisher := newMockPublisher()

	svc := NewCommentService(commentRepo, contentClient)
	svc.SetPublisher(publisher)

	return &testService{
		svc:           svc,
		contentClient: contentClient,
		commentRepo:   commentRepo,
		publisher:     publisher,
	}
}

// ==================== 创建评论测试 ====================

func TestCreateComment_Success(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	// 设置内容存在
	ts.contentClient.setContentExists("content-1", true)
	ts.contentClient.setContentAuthor("content-1", "author-1")

	// 创建评论
	comment, count, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "这是一条评论", nil)
	require.NoError(t, err)
	assert.NotNil(t, comment)
	assert.Equal(t, "user-1", comment.AuthorID)
	assert.Equal(t, "content-1", comment.ContentID)
	assert.Equal(t, "这是一条评论", comment.Text)
	assert.Equal(t, int32(1), count)

	// 验证事件发布
	assert.Len(t, ts.publisher.events, 1)
}

func TestCreateComment_EmptyText(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 空文本
	_, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "", nil)
	assert.ErrorIs(t, err, ErrEmptyText)
}

func TestCreateComment_TextTooLong(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 超长文本
	longText := make([]byte, MaxCommentLength+1)
	for i := range longText {
		longText[i] = 'a'
	}
	_, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", string(longText), nil)
	assert.ErrorIs(t, err, ErrTextTooLong)
}

func TestCreateComment_ContentNotFound(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	// 内容不存在
	ts.contentClient.setContentExists("content-1", false)

	_, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "评论", nil)
	assert.ErrorIs(t, err, ErrContentNotFound)
}

func TestCreateComment_CommentsDisabled(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	// 内容存在但禁止评论
	ts.contentClient.setContentExists("content-1", true)
	ts.contentClient.setCommentsDisabled("content-1", true)

	_, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "评论", nil)
	assert.ErrorIs(t, err, ErrCommentsDisabled)
}

func TestCreateComment_ContentServiceError(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.checkErr = errors.New("service unavailable")

	_, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "评论", nil)
	assert.Error(t, err)
}

func TestCreateComment_DataAccessError(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)
	ts.commentRepo.createErr = errors.New("database error")

	_, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "评论", nil)
	assert.Error(t, err)
}

// ==================== 回复评论测试 ====================

func TestCreateReply_Success(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)
	ts.contentClient.setContentAuthor("content-1", "author-1")

	// 先创建父评论
	parentComment, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "父评论", nil)
	require.NoError(t, err)

	// 创建回复
	reply, count, err := ts.svc.CreateComment(ctx, "user-2", "content-1", parentComment.ID, "这是回复", nil)
	require.NoError(t, err)
	assert.NotNil(t, reply)
	assert.Equal(t, parentComment.ID, reply.ParentID)
	assert.Equal(t, "这是回复", reply.Text)
	assert.Equal(t, int32(2), count)

	// 验证事件发布（父评论 + 回复 = 2 个事件）
	assert.Len(t, ts.publisher.events, 2)
}

func TestCreateReply_InvalidParent(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 父评论不存在
	_, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "nonexistent-parent", "回复", nil)
	assert.ErrorIs(t, err, ErrInvalidParent)
}

func TestCreateReply_DeletedParent(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 创建父评论
	parentComment, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "父评论", nil)
	require.NoError(t, err)

	// 删除父评论
	_, err = ts.svc.DeleteComment(ctx, parentComment.ID, "user-1")
	require.NoError(t, err)

	// 尝试回复已删除的评论
	_, _, err = ts.svc.CreateComment(ctx, "user-2", "content-1", parentComment.ID, "回复", nil)
	assert.ErrorIs(t, err, ErrInvalidParent)
}

// ==================== 获取评论测试 ====================

func TestGetComment_Success(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 创建评论
	created, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "测试评论", nil)
	require.NoError(t, err)

	// 获取评论
	comment, err := ts.svc.GetComment(ctx, created.ID)
	require.NoError(t, err)
	assert.Equal(t, created.ID, comment.ID)
	assert.Equal(t, "测试评论", comment.Text)
}

func TestGetComment_NotFound(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	_, err := ts.svc.GetComment(ctx, "nonexistent")
	assert.ErrorIs(t, err, ErrCommentNotFound)
}

func TestGetComment_Deleted(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 创建并删除评论
	created, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "测试评论", nil)
	require.NoError(t, err)
	_, err = ts.svc.DeleteComment(ctx, created.ID, "user-1")
	require.NoError(t, err)

	// 获取已删除的评论
	_, err = ts.svc.GetComment(ctx, created.ID)
	assert.ErrorIs(t, err, ErrCommentNotFound)
}

// ==================== 删除评论测试 ====================

func TestDeleteComment_Success(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 创建评论
	created, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "测试评论", nil)
	require.NoError(t, err)

	// 删除评论
	count, err := ts.svc.DeleteComment(ctx, created.ID, "user-1")
	require.NoError(t, err)
	assert.Equal(t, int32(0), count)
}

func TestDeleteComment_NotFound(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	_, err := ts.svc.DeleteComment(ctx, "nonexistent", "user-1")
	assert.ErrorIs(t, err, ErrCommentNotFound)
}

func TestDeleteComment_Unauthorized(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 创建评论
	created, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "测试评论", nil)
	require.NoError(t, err)

	// 其他用户尝试删除
	_, err = ts.svc.DeleteComment(ctx, created.ID, "user-2")
	assert.ErrorIs(t, err, ErrUnauthorized)
}

func TestDeleteComment_AlreadyDeleted(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 创建并删除评论
	created, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "测试评论", nil)
	require.NoError(t, err)
	_, err = ts.svc.DeleteComment(ctx, created.ID, "user-1")
	require.NoError(t, err)

	// 再次删除
	_, err = ts.svc.DeleteComment(ctx, created.ID, "user-1")
	assert.ErrorIs(t, err, ErrCommentNotFound)
}

// ==================== 评论列表测试 ====================

func TestListComments_Success(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 创建多条评论
	_, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "评论1", nil)
	require.NoError(t, err)
	_, _, err = ts.svc.CreateComment(ctx, "user-2", "content-1", "", "评论2", nil)
	require.NoError(t, err)

	// 获取列表
	comments, total, err := ts.svc.ListComments(ctx, "content-1", "", SortByNewest, 10, 0)
	require.NoError(t, err)
	assert.Len(t, comments, 2)
	assert.Equal(t, 2, total)
}

func TestListComments_WithPagination(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 创建多条评论
	for i := 0; i < 5; i++ {
		_, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "评论", nil)
		require.NoError(t, err)
	}

	// 分页获取
	comments, total, err := ts.svc.ListComments(ctx, "content-1", "", SortByNewest, 2, 0)
	require.NoError(t, err)
	assert.Len(t, comments, 2)
	assert.Equal(t, 5, total)
}

func TestListComments_DefaultLimit(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	// limit <= 0 时使用默认值 20
	comments, _, err := ts.svc.ListComments(ctx, "content-1", "", SortByNewest, 0, 0)
	require.NoError(t, err)
	assert.NotNil(t, comments)
}

func TestListComments_MaxLimit(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	// limit > 100 时使用 100
	comments, _, err := ts.svc.ListComments(ctx, "content-1", "", SortByNewest, 200, 0)
	require.NoError(t, err)
	assert.NotNil(t, comments)
}

func TestListComments_Replies(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 创建父评论
	parent, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "父评论", nil)
	require.NoError(t, err)

	// 创建回复
	_, _, err = ts.svc.CreateComment(ctx, "user-2", "content-1", parent.ID, "回复1", nil)
	require.NoError(t, err)
	_, _, err = ts.svc.CreateComment(ctx, "user-3", "content-1", parent.ID, "回复2", nil)
	require.NoError(t, err)

	// 获取回复列表
	replies, total, err := ts.svc.ListComments(ctx, "content-1", parent.ID, SortByOldest, 10, 0)
	require.NoError(t, err)
	assert.Len(t, replies, 2)
	assert.Equal(t, 2, total)
}

func TestListComments_DataAccessError(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.commentRepo.listErr = errors.New("database error")

	_, _, err := ts.svc.ListComments(ctx, "content-1", "", SortByNewest, 10, 0)
	assert.Error(t, err)
}

// ==================== 评论计数测试 ====================

func TestGetCommentCount_Success(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 创建评论
	_, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "评论1", nil)
	require.NoError(t, err)
	_, _, err = ts.svc.CreateComment(ctx, "user-2", "content-1", "", "评论2", nil)
	require.NoError(t, err)

	// 获取计数
	count, err := ts.svc.GetCommentCount(ctx, "content-1")
	require.NoError(t, err)
	assert.Equal(t, int32(2), count)
}

func TestBatchGetCommentCount_Success(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)
	ts.contentClient.setContentExists("content-2", true)

	// 创建评论
	_, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "评论1", nil)
	require.NoError(t, err)
	_, _, err = ts.svc.CreateComment(ctx, "user-2", "content-1", "", "评论2", nil)
	require.NoError(t, err)
	_, _, err = ts.svc.CreateComment(ctx, "user-1", "content-2", "", "评论3", nil)
	require.NoError(t, err)

	// 批量获取计数
	counts, err := ts.svc.BatchGetCommentCount(ctx, []string{"content-1", "content-2", "content-3"})
	require.NoError(t, err)
	assert.Equal(t, int32(2), counts["content-1"])
	assert.Equal(t, int32(1), counts["content-2"])
	assert.Equal(t, int32(0), counts["content-3"])
}

// ==================== 评论点赞测试 ====================

func TestLikeComment_Success(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 创建评论
	comment, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "测试评论", nil)
	require.NoError(t, err)

	// 点赞
	count, err := ts.svc.LikeComment(ctx, "user-2", comment.ID)
	require.NoError(t, err)
	assert.Equal(t, int32(1), count)

	// 验证点赞状态
	liked, err := ts.svc.CheckLiked(ctx, "user-2", comment.ID)
	require.NoError(t, err)
	assert.True(t, liked)

	// 验证事件发布（创建评论 + 点赞 = 2 个事件）
	assert.Len(t, ts.publisher.events, 2)
}

func TestLikeComment_AlreadyLiked(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 创建评论
	comment, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "测试评论", nil)
	require.NoError(t, err)

	// 第一次点赞
	_, err = ts.svc.LikeComment(ctx, "user-2", comment.ID)
	require.NoError(t, err)

	// 第二次点赞
	_, err = ts.svc.LikeComment(ctx, "user-2", comment.ID)
	assert.ErrorIs(t, err, ErrAlreadyLiked)
}

func TestLikeComment_CommentNotFound(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	_, err := ts.svc.LikeComment(ctx, "user-1", "nonexistent")
	assert.ErrorIs(t, err, ErrCommentNotFound)
}

func TestLikeComment_NoEventWhenSelfLike(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 创建评论
	comment, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "测试评论", nil)
	require.NoError(t, err)

	// 清空事件
	ts.publisher.events = nil

	// 自己点赞自己的评论
	_, err = ts.svc.LikeComment(ctx, "user-1", comment.ID)
	require.NoError(t, err)

	// 不应该发布事件
	assert.Empty(t, ts.publisher.events)
}

func TestUnlikeComment_Success(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 创建评论
	comment, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "测试评论", nil)
	require.NoError(t, err)

	// 点赞
	_, err = ts.svc.LikeComment(ctx, "user-2", comment.ID)
	require.NoError(t, err)

	// 取消点赞
	count, err := ts.svc.UnlikeComment(ctx, "user-2", comment.ID)
	require.NoError(t, err)
	assert.Equal(t, int32(0), count)

	// 验证点赞状态
	liked, err := ts.svc.CheckLiked(ctx, "user-2", comment.ID)
	require.NoError(t, err)
	assert.False(t, liked)
}

func TestUnlikeComment_NotLiked(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 创建评论
	comment, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "测试评论", nil)
	require.NoError(t, err)

	// 未点赞就取消
	_, err = ts.svc.UnlikeComment(ctx, "user-2", comment.ID)
	assert.ErrorIs(t, err, ErrNotLiked)
}

func TestCheckLiked_NotLiked(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 创建评论
	comment, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "测试评论", nil)
	require.NoError(t, err)

	// 检查未点赞状态
	liked, err := ts.svc.CheckLiked(ctx, "user-2", comment.ID)
	require.NoError(t, err)
	assert.False(t, liked)
}

func TestBatchCheckLiked_Success(t *testing.T) {
	ts := createTestService()
	ctx := context.Background()

	ts.contentClient.setContentExists("content-1", true)

	// 创建评论
	comment1, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "评论1", nil)
	require.NoError(t, err)
	comment2, _, err := ts.svc.CreateComment(ctx, "user-1", "content-1", "", "评论2", nil)
	require.NoError(t, err)

	// 点赞第一条
	_, err = ts.svc.LikeComment(ctx, "user-2", comment1.ID)
	require.NoError(t, err)

	// 批量检查
	result, err := ts.svc.BatchCheckLiked(ctx, "user-2", []string{comment1.ID, comment2.ID})
	require.NoError(t, err)
	assert.True(t, result[comment1.ID])
	assert.False(t, result[comment2.ID])
}

// ==================== Publisher 测试 ====================

func TestSetPublisher(t *testing.T) {
	ts := createTestService()
	newPublisher := newMockPublisher()

	ts.svc.SetPublisher(newPublisher)
	assert.NotNil(t, ts.svc.publisher)
}

func TestSetPublisher_Nil(t *testing.T) {
	ts := createTestService()

	ts.svc.SetPublisher(nil)
	assert.Nil(t, ts.svc.publisher)
}

// ==================== 辅助函数测试 ====================

func TestTruncateText(t *testing.T) {
	// 短文本不截断
	short := "短文本"
	assert.Equal(t, short, truncateText(short, 10))

	// 长文本截断
	long := "这是一段很长的文本内容"
	truncated := truncateText(long, 5)
	assert.Contains(t, truncated, "...")
}

// ==================== 错误类型测试 ====================

func TestErrorTypes(t *testing.T) {
	assert.NotNil(t, ErrContentNotFound)
	assert.NotNil(t, ErrCommentsDisabled)
	assert.NotNil(t, ErrUnauthorized)
	assert.NotNil(t, ErrCommentNotFound)
	assert.NotNil(t, ErrInvalidParent)
	assert.NotNil(t, ErrEmptyText)
	assert.NotNil(t, ErrTextTooLong)
	assert.NotNil(t, ErrAlreadyLiked)
	assert.NotNil(t, ErrNotLiked)
}
