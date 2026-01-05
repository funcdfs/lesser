// Package service 提供 Comment Service 属性测试
// Feature: backend-services-completion
package logic

import (
	"context"
	"sort"
	"testing"
	"time"

	contentpb "github.com/funcdfs/lesser/comment/gen_protos/content"
	"github.com/funcdfs/lesser/comment/internal/data_access"
	"github.com/leanovate/gopter"
	"github.com/leanovate/gopter/gen"
	"github.com/leanovate/gopter/prop"
)

// PropertyTestIterations 属性测试迭代次数
const PropertyTestIterations = 100

// ============================================================================
// Property 17: Comment sorting returns correct order
// *For any* comment list request, sorting by "newest" SHALL return comments
// in descending created_at order, "oldest" in ascending order, and "hottest"
// in descending like_count order.
// **Validates: Requirements 5.4**
// ============================================================================

// propertyTestCommentDA 用于属性测试的评论数据访问
type propertyTestCommentDA struct {
	comments map[string]*data_access.Comment
}

func newPropertyTestCommentRepo() *propertyTestCommentDA {
	return &propertyTestCommentDA{
		comments: make(map[string]*data_access.Comment),
	}
}

func (r *propertyTestCommentDA) Create(ctx context.Context, comment *data_access.Comment) error {
	comment.ID = "comment-" + time.Now().Format("20060102150405.000000000")
	comment.CreatedAt = time.Now()
	comment.UpdatedAt = time.Now()
	r.comments[comment.ID] = comment
	return nil
}

func (r *propertyTestCommentDA) GetByID(ctx context.Context, id string) (*data_access.Comment, error) {
	comment, exists := r.comments[id]
	if !exists {
		return nil, data_access.ErrCommentNotFound
	}
	return comment, nil
}

func (r *propertyTestCommentDA) Delete(ctx context.Context, id string) (*data_access.Comment, error) {
	comment, exists := r.comments[id]
	if !exists {
		return nil, data_access.ErrCommentNotFound
	}
	comment.IsDeleted = true
	return comment, nil
}

func (r *propertyTestCommentDA) List(ctx context.Context, contentID, parentID string, sortBy data_access.SortBy, limit, offset int) ([]*data_access.Comment, int, error) {
	var result []*data_access.Comment
	for _, c := range r.comments {
		if c.ContentID == contentID && !c.IsDeleted {
			if parentID == "" && c.ParentID == "" {
				result = append(result, c)
			} else if parentID != "" && c.ParentID == parentID {
				result = append(result, c)
			}
		}
	}

	// 排序
	switch sortBy {
	case data_access.SortByOldest:
		sort.Slice(result, func(i, j int) bool {
			return result[i].CreatedAt.Before(result[j].CreatedAt)
		})
	case data_access.SortByHottest:
		sort.Slice(result, func(i, j int) bool {
			if result[i].LikeCount != result[j].LikeCount {
				return result[i].LikeCount > result[j].LikeCount
			}
			return result[i].CreatedAt.After(result[j].CreatedAt)
		})
	case data_access.SortByNewest, data_access.SortByUnspecified:
		fallthrough
	default:
		sort.Slice(result, func(i, j int) bool {
			return result[i].CreatedAt.After(result[j].CreatedAt)
		})
	}

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

func (r *propertyTestCommentDA) GetCount(ctx context.Context, contentID string) (int32, error) {
	var count int32
	for _, c := range r.comments {
		if c.ContentID == contentID && !c.IsDeleted {
			count++
		}
	}
	return count, nil
}

func (r *propertyTestCommentDA) BatchGetCount(ctx context.Context, contentIDs []string) (map[string]int32, error) {
	result := make(map[string]int32)
	for _, id := range contentIDs {
		result[id] = 0
	}
	for _, c := range r.comments {
		if !c.IsDeleted {
			if _, ok := result[c.ContentID]; ok {
				result[c.ContentID]++
			}
		}
	}
	return result, nil
}

func (r *propertyTestCommentDA) LikeComment(ctx context.Context, userID, commentID string) (int32, error) {
	comment, exists := r.comments[commentID]
	if !exists {
		return 0, data_access.ErrCommentNotFound
	}
	comment.LikeCount++
	return comment.LikeCount, nil
}

func (r *propertyTestCommentDA) UnlikeComment(ctx context.Context, userID, commentID string) (int32, error) {
	comment, exists := r.comments[commentID]
	if !exists {
		return 0, data_access.ErrCommentNotFound
	}
	if comment.LikeCount > 0 {
		comment.LikeCount--
	}
	return comment.LikeCount, nil
}

func (r *propertyTestCommentDA) CheckLiked(ctx context.Context, userID, commentID string) (bool, error) {
	return false, nil
}

func (r *propertyTestCommentDA) BatchCheckLiked(ctx context.Context, userID string, commentIDs []string) (map[string]bool, error) {
	result := make(map[string]bool)
	for _, id := range commentIDs {
		result[id] = false
	}
	return result, nil
}

// propertyTestContentClient 用于属性测试的 Content 客户端
type propertyTestContentClient struct{}

func (c *propertyTestContentClient) CheckContentExists(ctx context.Context, contentID string) (bool, bool, error) {
	return true, false, nil
}

func (c *propertyTestContentClient) UpdateCounter(ctx context.Context, contentID string, counterType contentpb.CounterType, delta int32) (int32, error) {
	return 0, nil
}

func (c *propertyTestContentClient) GetContentAuthorID(ctx context.Context, contentID string) (string, error) {
	return "author-1", nil
}

// TestProperty17_CommentSortingNewest 测试评论按最新排序
func TestProperty17_CommentSortingNewest(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	// 属性：按 newest 排序时，评论按 created_at 降序排列
	properties.Property("newest sorting returns comments in descending created_at order", prop.ForAll(
		func(numComments int) bool {
			if numComments < 2 {
				numComments = 2
			}
			if numComments > 20 {
				numComments = 20
			}

			repo := newPropertyTestCommentRepo()
			svc := NewCommentService(repo, &propertyTestContentClient{})
			ctx := context.Background()

			// 创建多条评论，每条间隔一点时间
			for i := 0; i < numComments; i++ {
				_, _, err := svc.CreateComment(ctx, "user-1", "content-1", "", "评论内容", nil)
				if err != nil {
					return false
				}
				time.Sleep(time.Millisecond) // 确保时间戳不同
			}

			// 按 newest 排序获取
			comments, _, err := svc.ListComments(ctx, "content-1", "", SortByNewest, 100, 0)
			if err != nil {
				return false
			}

			// 验证：按 created_at 降序排列
			for i := 1; i < len(comments); i++ {
				if comments[i-1].CreatedAt.Before(comments[i].CreatedAt) {
					return false
				}
			}

			return true
		},
		gen.IntRange(2, 20),
	))

	properties.TestingRun(t)
}

// TestProperty17_CommentSortingOldest 测试评论按最早排序
func TestProperty17_CommentSortingOldest(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	// 属性：按 oldest 排序时，评论按 created_at 升序排列
	properties.Property("oldest sorting returns comments in ascending created_at order", prop.ForAll(
		func(numComments int) bool {
			if numComments < 2 {
				numComments = 2
			}
			if numComments > 20 {
				numComments = 20
			}

			repo := newPropertyTestCommentRepo()
			svc := NewCommentService(repo, &propertyTestContentClient{})
			ctx := context.Background()

			// 创建多条评论
			for i := 0; i < numComments; i++ {
				_, _, err := svc.CreateComment(ctx, "user-1", "content-1", "", "评论内容", nil)
				if err != nil {
					return false
				}
				time.Sleep(time.Millisecond)
			}

			// 按 oldest 排序获取
			comments, _, err := svc.ListComments(ctx, "content-1", "", SortByOldest, 100, 0)
			if err != nil {
				return false
			}

			// 验证：按 created_at 升序排列
			for i := 1; i < len(comments); i++ {
				if comments[i-1].CreatedAt.After(comments[i].CreatedAt) {
					return false
				}
			}

			return true
		},
		gen.IntRange(2, 20),
	))

	properties.TestingRun(t)
}

// TestProperty17_CommentSortingHottest 测试评论按最热排序
func TestProperty17_CommentSortingHottest(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	// 属性：按 hottest 排序时，评论按 like_count 降序排列
	properties.Property("hottest sorting returns comments in descending like_count order", prop.ForAll(
		func(numComments int, likeCounts []int32) bool {
			if numComments < 2 {
				numComments = 2
			}
			if numComments > 10 {
				numComments = 10
			}

			repo := newPropertyTestCommentRepo()
			svc := NewCommentService(repo, &propertyTestContentClient{})
			ctx := context.Background()

			// 创建多条评论并设置不同的点赞数
			for i := 0; i < numComments; i++ {
				comment, _, err := svc.CreateComment(ctx, "user-1", "content-1", "", "评论内容", nil)
				if err != nil {
					return false
				}

				// 设置点赞数
				likeCount := int32(0)
				if i < len(likeCounts) {
					likeCount = likeCounts[i]
					if likeCount < 0 {
						likeCount = 0
					}
					if likeCount > 100 {
						likeCount = 100
					}
				}
				repo.comments[comment.ID].LikeCount = likeCount
				time.Sleep(time.Millisecond)
			}

			// 按 hottest 排序获取
			comments, _, err := svc.ListComments(ctx, "content-1", "", SortByHottest, 100, 0)
			if err != nil {
				return false
			}

			// 验证：按 like_count 降序排列
			for i := 1; i < len(comments); i++ {
				if comments[i-1].LikeCount < comments[i].LikeCount {
					return false
				}
			}

			return true
		},
		gen.IntRange(2, 10),
		gen.SliceOf(gen.Int32Range(0, 100)),
	))

	properties.TestingRun(t)
}

// TestProperty17_SortingPreservesAllComments 测试排序不丢失评论
func TestProperty17_SortingPreservesAllComments(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	// 属性：不同排序方式返回相同数量的评论
	properties.Property("different sort orders return same number of comments", prop.ForAll(
		func(numComments int) bool {
			if numComments < 1 {
				numComments = 1
			}
			if numComments > 20 {
				numComments = 20
			}

			repo := newPropertyTestCommentRepo()
			svc := NewCommentService(repo, &propertyTestContentClient{})
			ctx := context.Background()

			// 创建评论
			for i := 0; i < numComments; i++ {
				_, _, err := svc.CreateComment(ctx, "user-1", "content-1", "", "评论内容", nil)
				if err != nil {
					return false
				}
				time.Sleep(time.Millisecond)
			}

			// 获取不同排序的结果
			newestComments, newestTotal, _ := svc.ListComments(ctx, "content-1", "", SortByNewest, 100, 0)
			oldestComments, oldestTotal, _ := svc.ListComments(ctx, "content-1", "", SortByOldest, 100, 0)
			hottestComments, hottestTotal, _ := svc.ListComments(ctx, "content-1", "", SortByHottest, 100, 0)

			// 验证：所有排序方式返回相同数量
			if len(newestComments) != len(oldestComments) || len(newestComments) != len(hottestComments) {
				return false
			}
			if newestTotal != oldestTotal || newestTotal != hottestTotal {
				return false
			}
			if newestTotal != numComments {
				return false
			}

			return true
		},
		gen.IntRange(1, 20),
	))

	properties.TestingRun(t)
}

// ============================================================================
// Property 18: Comment like/unlike round-trip maintains consistency
// *For any* comment, liking then unliking SHALL result in the same like_count
// as before.
// **Validates: Requirements 5.5, 5.6**
// ============================================================================

// propertyTestCommentDAWithLikes 用于属性测试的评论数据访问（支持点赞）
type propertyTestCommentDAWithLikes struct {
	comments     map[string]*data_access.Comment
	commentLikes map[string]map[string]bool // commentID -> userID -> liked
}

func newPropertyTestCommentRepoWithLikes() *propertyTestCommentDAWithLikes {
	return &propertyTestCommentDAWithLikes{
		comments:     make(map[string]*data_access.Comment),
		commentLikes: make(map[string]map[string]bool),
	}
}

func (r *propertyTestCommentDAWithLikes) Create(ctx context.Context, comment *data_access.Comment) error {
	comment.ID = "comment-" + time.Now().Format("20060102150405.000000000")
	comment.CreatedAt = time.Now()
	comment.UpdatedAt = time.Now()
	r.comments[comment.ID] = comment
	return nil
}

func (r *propertyTestCommentDAWithLikes) GetByID(ctx context.Context, id string) (*data_access.Comment, error) {
	comment, exists := r.comments[id]
	if !exists {
		return nil, data_access.ErrCommentNotFound
	}
	return comment, nil
}

func (r *propertyTestCommentDAWithLikes) Delete(ctx context.Context, id string) (*data_access.Comment, error) {
	comment, exists := r.comments[id]
	if !exists {
		return nil, data_access.ErrCommentNotFound
	}
	comment.IsDeleted = true
	return comment, nil
}

func (r *propertyTestCommentDAWithLikes) List(ctx context.Context, contentID, parentID string, sortBy data_access.SortBy, limit, offset int) ([]*data_access.Comment, int, error) {
	var result []*data_access.Comment
	for _, c := range r.comments {
		if c.ContentID == contentID && !c.IsDeleted && c.ParentID == parentID {
			result = append(result, c)
		}
	}
	return result, len(result), nil
}

func (r *propertyTestCommentDAWithLikes) GetCount(ctx context.Context, contentID string) (int32, error) {
	var count int32
	for _, c := range r.comments {
		if c.ContentID == contentID && !c.IsDeleted {
			count++
		}
	}
	return count, nil
}

func (r *propertyTestCommentDAWithLikes) BatchGetCount(ctx context.Context, contentIDs []string) (map[string]int32, error) {
	result := make(map[string]int32)
	for _, id := range contentIDs {
		result[id] = 0
	}
	return result, nil
}

func (r *propertyTestCommentDAWithLikes) LikeComment(ctx context.Context, userID, commentID string) (int32, error) {
	comment, exists := r.comments[commentID]
	if !exists || comment.IsDeleted {
		return 0, data_access.ErrCommentNotFound
	}
	if r.commentLikes[commentID] == nil {
		r.commentLikes[commentID] = make(map[string]bool)
	}
	if r.commentLikes[commentID][userID] {
		return 0, data_access.ErrAlreadyLiked
	}
	r.commentLikes[commentID][userID] = true
	comment.LikeCount++
	return comment.LikeCount, nil
}

func (r *propertyTestCommentDAWithLikes) UnlikeComment(ctx context.Context, userID, commentID string) (int32, error) {
	comment, exists := r.comments[commentID]
	if !exists {
		return 0, data_access.ErrCommentNotFound
	}
	if r.commentLikes[commentID] == nil || !r.commentLikes[commentID][userID] {
		return 0, data_access.ErrNotLiked
	}
	delete(r.commentLikes[commentID], userID)
	if comment.LikeCount > 0 {
		comment.LikeCount--
	}
	return comment.LikeCount, nil
}

func (r *propertyTestCommentDAWithLikes) CheckLiked(ctx context.Context, userID, commentID string) (bool, error) {
	if r.commentLikes[commentID] == nil {
		return false, nil
	}
	return r.commentLikes[commentID][userID], nil
}

func (r *propertyTestCommentDAWithLikes) BatchCheckLiked(ctx context.Context, userID string, commentIDs []string) (map[string]bool, error) {
	result := make(map[string]bool)
	for _, id := range commentIDs {
		if r.commentLikes[id] != nil {
			result[id] = r.commentLikes[id][userID]
		} else {
			result[id] = false
		}
	}
	return result, nil
}

// TestProperty18_LikeUnlikeRoundTrip 测试点赞/取消点赞的 round-trip 一致性
func TestProperty18_LikeUnlikeRoundTrip(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	// 属性：点赞后取消点赞，like_count 应该回到原始值
	properties.Property("like then unlike returns to original like_count", prop.ForAll(
		func(initialLikes int32) bool {
			if initialLikes < 0 {
				initialLikes = 0
			}
			if initialLikes > 1000 {
				initialLikes = 1000
			}

			repo := newPropertyTestCommentRepoWithLikes()
			svc := NewCommentService(repo, &propertyTestContentClient{})
			ctx := context.Background()

			// 创建评论
			comment, _, err := svc.CreateComment(ctx, "author-1", "content-1", "", "测试评论", nil)
			if err != nil {
				return false
			}

			// 设置初始点赞数
			repo.comments[comment.ID].LikeCount = initialLikes

			// 点赞
			afterLike, err := svc.LikeComment(ctx, "user-1", comment.ID)
			if err != nil {
				return false
			}

			// 验证点赞后计数增加
			if afterLike != initialLikes+1 {
				return false
			}

			// 取消点赞
			afterUnlike, err := svc.UnlikeComment(ctx, "user-1", comment.ID)
			if err != nil {
				return false
			}

			// 验证：取消点赞后应该回到原始值
			return afterUnlike == initialLikes
		},
		gen.Int32Range(0, 1000),
	))

	properties.TestingRun(t)
}

// TestProperty18_MultipleLikesRoundTrip 测试多用户点赞的 round-trip 一致性
func TestProperty18_MultipleLikesRoundTrip(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	// 属性：多个用户点赞后全部取消，like_count 应该回到原始值
	properties.Property("multiple likes then unlikes returns to original", prop.ForAll(
		func(numUsers int) bool {
			if numUsers < 1 {
				numUsers = 1
			}
			if numUsers > 20 {
				numUsers = 20
			}

			repo := newPropertyTestCommentRepoWithLikes()
			svc := NewCommentService(repo, &propertyTestContentClient{})
			ctx := context.Background()

			// 创建评论
			comment, _, err := svc.CreateComment(ctx, "author-1", "content-1", "", "测试评论", nil)
			if err != nil {
				return false
			}

			initialCount := repo.comments[comment.ID].LikeCount

			// 多个用户点赞
			for i := 0; i < numUsers; i++ {
				userID := "user-" + string(rune('a'+i))
				_, err := svc.LikeComment(ctx, userID, comment.ID)
				if err != nil {
					return false
				}
			}

			// 验证点赞后计数
			afterLikes := repo.comments[comment.ID].LikeCount
			if afterLikes != initialCount+int32(numUsers) {
				return false
			}

			// 所有用户取消点赞
			for i := 0; i < numUsers; i++ {
				userID := "user-" + string(rune('a'+i))
				_, err := svc.UnlikeComment(ctx, userID, comment.ID)
				if err != nil {
					return false
				}
			}

			// 验证：应该回到原始值
			return repo.comments[comment.ID].LikeCount == initialCount
		},
		gen.IntRange(1, 20),
	))

	properties.TestingRun(t)
}

// TestProperty18_LikeCountNeverNegative 测试点赞计数永不为负
func TestProperty18_LikeCountNeverNegative(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	// 属性：点赞计数永远不会为负数
	properties.Property("like_count never goes negative", prop.ForAll(
		func(numLikes, numUnlikes int) bool {
			if numLikes < 0 {
				numLikes = 0
			}
			if numLikes > 20 {
				numLikes = 20
			}
			if numUnlikes < 0 {
				numUnlikes = 0
			}
			if numUnlikes > 30 {
				numUnlikes = 30
			}

			repo := newPropertyTestCommentRepoWithLikes()
			svc := NewCommentService(repo, &propertyTestContentClient{})
			ctx := context.Background()

			// 创建评论
			comment, _, err := svc.CreateComment(ctx, "author-1", "content-1", "", "测试评论", nil)
			if err != nil {
				return false
			}

			// 点赞
			for i := 0; i < numLikes; i++ {
				userID := "user-like-" + string(rune('a'+i))
				svc.LikeComment(ctx, userID, comment.ID)
			}

			// 取消点赞（可能超过点赞数）
			for i := 0; i < numUnlikes; i++ {
				userID := "user-like-" + string(rune('a'+i))
				svc.UnlikeComment(ctx, userID, comment.ID)
			}

			// 验证：计数永远非负
			return repo.comments[comment.ID].LikeCount >= 0
		},
		gen.IntRange(0, 20),
		gen.IntRange(0, 30),
	))

	properties.TestingRun(t)
}

// TestProperty18_LikeStatusConsistency 测试点赞状态一致性
func TestProperty18_LikeStatusConsistency(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	// 属性：点赞后 CheckLiked 返回 true，取消后返回 false
	properties.Property("like status is consistent with operations", prop.ForAll(
		func(dummy int) bool {
			repo := newPropertyTestCommentRepoWithLikes()
			svc := NewCommentService(repo, &propertyTestContentClient{})
			ctx := context.Background()

			// 创建评论
			comment, _, err := svc.CreateComment(ctx, "author-1", "content-1", "", "测试评论", nil)
			if err != nil {
				return false
			}

			// 初始状态：未点赞
			liked, _ := svc.CheckLiked(ctx, "user-1", comment.ID)
			if liked {
				return false
			}

			// 点赞后：已点赞
			_, err = svc.LikeComment(ctx, "user-1", comment.ID)
			if err != nil {
				return false
			}
			liked, _ = svc.CheckLiked(ctx, "user-1", comment.ID)
			if !liked {
				return false
			}

			// 取消点赞后：未点赞
			_, err = svc.UnlikeComment(ctx, "user-1", comment.ID)
			if err != nil {
				return false
			}
			liked, _ = svc.CheckLiked(ctx, "user-1", comment.ID)
			if liked {
				return false
			}

			return true
		},
		gen.IntRange(0, 100),
	))

	properties.TestingRun(t)
}

// TestProperty18_DuplicateLikePrevented 测试重复点赞被阻止
func TestProperty18_DuplicateLikePrevented(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	// 属性：重复点赞应该返回错误，计数不变
	properties.Property("duplicate like is prevented and count unchanged", prop.ForAll(
		func(numAttempts int) bool {
			if numAttempts < 2 {
				numAttempts = 2
			}
			if numAttempts > 10 {
				numAttempts = 10
			}

			repo := newPropertyTestCommentRepoWithLikes()
			svc := NewCommentService(repo, &propertyTestContentClient{})
			ctx := context.Background()

			// 创建评论
			comment, _, err := svc.CreateComment(ctx, "author-1", "content-1", "", "测试评论", nil)
			if err != nil {
				return false
			}

			// 第一次点赞成功
			count1, err := svc.LikeComment(ctx, "user-1", comment.ID)
			if err != nil {
				return false
			}

			// 后续点赞应该失败，计数不变
			for i := 1; i < numAttempts; i++ {
				count, err := svc.LikeComment(ctx, "user-1", comment.ID)
				if err != ErrAlreadyLiked {
					return false
				}
				// 计数应该保持不变
				if count != 0 { // 错误时返回 0
					return false
				}
			}

			// 最终计数应该等于第一次点赞后的计数
			return repo.comments[comment.ID].LikeCount == count1
		},
		gen.IntRange(2, 10),
	))

	properties.TestingRun(t)
}
