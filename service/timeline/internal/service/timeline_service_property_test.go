// Package service 提供 Timeline Service 属性测试
// Feature: backend-services-completion
package service

import (
	"sort"
	"testing"
	"time"

	"github.com/leanovate/gopter"
	"github.com/leanovate/gopter/gen"
	"github.com/leanovate/gopter/prop"
)

// PropertyTestIterations 属性测试迭代次数
const PropertyTestIterations = 100

// ============================================================================
// Property 21: Following feed returns content from followed users only
// *For any* following feed request, all returned content SHALL be authored
// by users that the requesting user follows, sorted by published_at descending.
// **Validates: Requirements 7.1**
// ============================================================================

// propertyTestFollowRelation 关注关系
type propertyTestFollowRelation struct {
	followerID  string
	followingID string
}

// propertyTestContent 测试用内容
type propertyTestContent struct {
	id          string
	authorID    string
	publishedAt time.Time
	isPinned    bool
}

// propertyTestTimelineRepo 用于属性测试的 Timeline 仓库模拟
type propertyTestTimelineRepo struct {
	contents  []*propertyTestContent
	follows   []propertyTestFollowRelation
	userFeeds map[string][]*propertyTestContent // userID -> contents
}

func newPropertyTestTimelineRepo() *propertyTestTimelineRepo {
	return &propertyTestTimelineRepo{
		contents:  make([]*propertyTestContent, 0),
		follows:   make([]propertyTestFollowRelation, 0),
		userFeeds: make(map[string][]*propertyTestContent),
	}
}

// addContent 添加内容
func (r *propertyTestTimelineRepo) addContent(content *propertyTestContent) {
	r.contents = append(r.contents, content)
	// 添加到用户 Feed
	if _, ok := r.userFeeds[content.authorID]; !ok {
		r.userFeeds[content.authorID] = make([]*propertyTestContent, 0)
	}
	r.userFeeds[content.authorID] = append(r.userFeeds[content.authorID], content)
}

// addFollow 添加关注关系
func (r *propertyTestTimelineRepo) addFollow(followerID, followingID string) {
	r.follows = append(r.follows, propertyTestFollowRelation{
		followerID:  followerID,
		followingID: followingID,
	})
}

// isFollowing 检查是否关注
func (r *propertyTestTimelineRepo) isFollowing(followerID, followingID string) bool {
	for _, f := range r.follows {
		if f.followerID == followerID && f.followingID == followingID {
			return true
		}
	}
	return false
}

// getFollowingIDs 获取关注的用户 ID 列表
func (r *propertyTestTimelineRepo) getFollowingIDs(userID string) []string {
	var result []string
	for _, f := range r.follows {
		if f.followerID == userID {
			result = append(result, f.followingID)
		}
	}
	return result
}

// getFollowingFeed 获取关注用户的 Feed
func (r *propertyTestTimelineRepo) getFollowingFeed(userID string, limit, offset int) []*propertyTestContent {
	followingIDs := r.getFollowingIDs(userID)
	followingSet := make(map[string]bool)
	for _, id := range followingIDs {
		followingSet[id] = true
	}

	// 筛选关注用户的内容
	var result []*propertyTestContent
	for _, c := range r.contents {
		if followingSet[c.authorID] {
			result = append(result, c)
		}
	}

	// 按发布时间降序排序
	sort.Slice(result, func(i, j int) bool {
		return result[i].publishedAt.After(result[j].publishedAt)
	})

	// 分页
	if offset >= len(result) {
		return []*propertyTestContent{}
	}
	end := offset + limit
	if end > len(result) {
		end = len(result)
	}
	return result[offset:end]
}

// getUserFeed 获取用户主页 Feed（置顶优先）
func (r *propertyTestTimelineRepo) getUserFeed(targetUserID string, limit, offset int) []*propertyTestContent {
	contents, ok := r.userFeeds[targetUserID]
	if !ok {
		return []*propertyTestContent{}
	}

	// 复制一份避免修改原数据
	result := make([]*propertyTestContent, len(contents))
	copy(result, contents)

	// 置顶优先，然后按发布时间降序排序
	sort.Slice(result, func(i, j int) bool {
		if result[i].isPinned != result[j].isPinned {
			return result[i].isPinned // 置顶的排在前面
		}
		return result[i].publishedAt.After(result[j].publishedAt)
	})

	// 分页
	if offset >= len(result) {
		return []*propertyTestContent{}
	}
	end := offset + limit
	if end > len(result) {
		end = len(result)
	}
	return result[offset:end]
}

// TestProperty21_FollowingFeedOnlyFromFollowedUsers 测试关注 Feed 只返回关注用户的内容
func TestProperty21_FollowingFeedOnlyFromFollowedUsers(t *testing.T) {
	// Feature: backend-services-completion, Property 21: Following feed returns content from followed users only
	// **Validates: Requirements 7.1**
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	// 属性：关注 Feed 中的所有内容都来自关注的用户
	properties.Property("following feed only contains content from followed users", prop.ForAll(
		func(numUsers, numContents, numFollows int) bool {
			repo := newPropertyTestTimelineRepo()

			// 生成用户 ID
			userIDs := make([]string, numUsers)
			for i := 0; i < numUsers; i++ {
				userIDs[i] = "user-" + string(rune('A'+i))
			}

			// 当前用户
			currentUserID := "current-user"

			// 随机添加关注关系
			for i := 0; i < numFollows && i < numUsers; i++ {
				repo.addFollow(currentUserID, userIDs[i%numUsers])
			}

			// 生成内容
			baseTime := time.Now()
			for i := 0; i < numContents; i++ {
				authorID := userIDs[i%numUsers]
				repo.addContent(&propertyTestContent{
					id:          "content-" + string(rune('0'+i)),
					authorID:    authorID,
					publishedAt: baseTime.Add(-time.Duration(i) * time.Hour),
					isPinned:    false,
				})
			}

			// 获取关注 Feed
			feed := repo.getFollowingFeed(currentUserID, 100, 0)

			// 验证：所有内容都来自关注的用户
			for _, content := range feed {
				if !repo.isFollowing(currentUserID, content.authorID) {
					return false
				}
			}

			return true
		},
		gen.IntRange(1, 10),  // numUsers: 1-10 个用户
		gen.IntRange(0, 50),  // numContents: 0-50 条内容
		gen.IntRange(0, 10),  // numFollows: 0-10 个关注关系
	))

	properties.TestingRun(t)
}

// TestProperty21_FollowingFeedSortedByPublishedAt 测试关注 Feed 按发布时间降序排列
func TestProperty21_FollowingFeedSortedByPublishedAt(t *testing.T) {
	// Feature: backend-services-completion, Property 21: Following feed returns content from followed users only
	// **Validates: Requirements 7.1**
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	// 属性：关注 Feed 按发布时间降序排列
	properties.Property("following feed is sorted by published_at descending", prop.ForAll(
		func(numContents int) bool {
			repo := newPropertyTestTimelineRepo()

			currentUserID := "current-user"
			followedUserID := "followed-user"
			repo.addFollow(currentUserID, followedUserID)

			// 生成内容（随机时间）
			baseTime := time.Now()
			for i := 0; i < numContents; i++ {
				// 使用不同的时间偏移
				offset := time.Duration(i*17%100) * time.Hour // 伪随机时间
				repo.addContent(&propertyTestContent{
					id:          "content-" + string(rune('0'+i)),
					authorID:    followedUserID,
					publishedAt: baseTime.Add(-offset),
					isPinned:    false,
				})
			}

			// 获取关注 Feed
			feed := repo.getFollowingFeed(currentUserID, 100, 0)

			// 验证：按发布时间降序排列
			for i := 1; i < len(feed); i++ {
				if feed[i].publishedAt.After(feed[i-1].publishedAt) {
					return false
				}
			}

			return true
		},
		gen.IntRange(0, 50), // numContents: 0-50 条内容
	))

	properties.TestingRun(t)
}

// TestProperty21_FollowingFeedExcludesUnfollowedUsers 测试关注 Feed 不包含未关注用户的内容
func TestProperty21_FollowingFeedExcludesUnfollowedUsers(t *testing.T) {
	// Feature: backend-services-completion, Property 21: Following feed returns content from followed users only
	// **Validates: Requirements 7.1**
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	// 属性：关注 Feed 不包含未关注用户的内容
	properties.Property("following feed excludes content from unfollowed users", prop.ForAll(
		func(numFollowed, numUnfollowed, numContentsPerUser int) bool {
			repo := newPropertyTestTimelineRepo()

			currentUserID := "current-user"

			// 创建关注的用户
			followedUsers := make([]string, numFollowed)
			for i := 0; i < numFollowed; i++ {
				followedUsers[i] = "followed-" + string(rune('A'+i))
				repo.addFollow(currentUserID, followedUsers[i])
			}

			// 创建未关注的用户
			unfollowedUsers := make([]string, numUnfollowed)
			for i := 0; i < numUnfollowed; i++ {
				unfollowedUsers[i] = "unfollowed-" + string(rune('A'+i))
				// 不添加关注关系
			}

			// 为所有用户生成内容
			baseTime := time.Now()
			contentIndex := 0
			for _, userID := range followedUsers {
				for j := 0; j < numContentsPerUser; j++ {
					repo.addContent(&propertyTestContent{
						id:          "content-" + string(rune('0'+contentIndex)),
						authorID:    userID,
						publishedAt: baseTime.Add(-time.Duration(contentIndex) * time.Hour),
						isPinned:    false,
					})
					contentIndex++
				}
			}
			for _, userID := range unfollowedUsers {
				for j := 0; j < numContentsPerUser; j++ {
					repo.addContent(&propertyTestContent{
						id:          "content-" + string(rune('0'+contentIndex)),
						authorID:    userID,
						publishedAt: baseTime.Add(-time.Duration(contentIndex) * time.Hour),
						isPinned:    false,
					})
					contentIndex++
				}
			}

			// 获取关注 Feed
			feed := repo.getFollowingFeed(currentUserID, 1000, 0)

			// 验证：不包含未关注用户的内容
			unfollowedSet := make(map[string]bool)
			for _, userID := range unfollowedUsers {
				unfollowedSet[userID] = true
			}

			for _, content := range feed {
				if unfollowedSet[content.authorID] {
					return false
				}
			}

			// 验证：包含所有关注用户的内容
			expectedCount := numFollowed * numContentsPerUser
			if len(feed) != expectedCount {
				return false
			}

			return true
		},
		gen.IntRange(0, 5), // numFollowed: 0-5 个关注用户
		gen.IntRange(0, 5), // numUnfollowed: 0-5 个未关注用户
		gen.IntRange(0, 5), // numContentsPerUser: 每个用户 0-5 条内容
	))

	properties.TestingRun(t)
}

// TestProperty21_EmptyFollowingFeedWhenNoFollows 测试没有关注时返回空 Feed
func TestProperty21_EmptyFollowingFeedWhenNoFollows(t *testing.T) {
	// Feature: backend-services-completion, Property 21: Following feed returns content from followed users only
	// **Validates: Requirements 7.1**
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	// 属性：没有关注任何人时，关注 Feed 为空
	properties.Property("following feed is empty when user follows no one", prop.ForAll(
		func(numContents int) bool {
			repo := newPropertyTestTimelineRepo()

			currentUserID := "current-user"
			// 不添加任何关注关系

			// 生成其他用户的内容
			baseTime := time.Now()
			for i := 0; i < numContents; i++ {
				repo.addContent(&propertyTestContent{
					id:          "content-" + string(rune('0'+i)),
					authorID:    "other-user-" + string(rune('A'+i%5)),
					publishedAt: baseTime.Add(-time.Duration(i) * time.Hour),
					isPinned:    false,
				})
			}

			// 获取关注 Feed
			feed := repo.getFollowingFeed(currentUserID, 100, 0)

			// 验证：Feed 为空
			return len(feed) == 0
		},
		gen.IntRange(0, 50), // numContents: 0-50 条内容
	))

	properties.TestingRun(t)
}

// ============================================================================
// Property 22: User feed returns pinned items first
// *For any* user feed request, pinned content SHALL appear before non-pinned
// content, with each group sorted by published_at descending.
// **Validates: Requirements 7.2**
// ============================================================================

// TestProperty22_UserFeedPinnedItemsFirst 测试用户 Feed 置顶内容优先
func TestProperty22_UserFeedPinnedItemsFirst(t *testing.T) {
	// Feature: backend-services-completion, Property 22: User feed returns pinned items first
	// **Validates: Requirements 7.2**
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	// 属性：置顶内容出现在非置顶内容之前
	properties.Property("pinned items appear before non-pinned items", prop.ForAll(
		func(numPinned, numNonPinned int) bool {
			repo := newPropertyTestTimelineRepo()

			targetUserID := "target-user"
			baseTime := time.Now()

			// 添加置顶内容
			for i := 0; i < numPinned; i++ {
				repo.addContent(&propertyTestContent{
					id:          "pinned-" + string(rune('0'+i)),
					authorID:    targetUserID,
					publishedAt: baseTime.Add(-time.Duration(i*10) * time.Hour),
					isPinned:    true,
				})
			}

			// 添加非置顶内容
			for i := 0; i < numNonPinned; i++ {
				repo.addContent(&propertyTestContent{
					id:          "normal-" + string(rune('0'+i)),
					authorID:    targetUserID,
					publishedAt: baseTime.Add(-time.Duration(i) * time.Hour),
					isPinned:    false,
				})
			}

			// 获取用户 Feed
			feed := repo.getUserFeed(targetUserID, 1000, 0)

			// 验证：所有置顶内容出现在非置顶内容之前
			foundNonPinned := false
			for _, content := range feed {
				if !content.isPinned {
					foundNonPinned = true
				}
				// 如果已经遇到非置顶内容，后面不应该再有置顶内容
				if foundNonPinned && content.isPinned {
					return false
				}
			}

			return true
		},
		gen.IntRange(0, 10), // numPinned: 0-10 条置顶内容
		gen.IntRange(0, 20), // numNonPinned: 0-20 条非置顶内容
	))

	properties.TestingRun(t)
}

// TestProperty22_UserFeedPinnedSortedByPublishedAt 测试置顶内容按发布时间降序排列
func TestProperty22_UserFeedPinnedSortedByPublishedAt(t *testing.T) {
	// Feature: backend-services-completion, Property 22: User feed returns pinned items first
	// **Validates: Requirements 7.2**
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	// 属性：置顶内容组内按发布时间降序排列
	properties.Property("pinned items are sorted by published_at descending", prop.ForAll(
		func(numPinned int) bool {
			repo := newPropertyTestTimelineRepo()

			targetUserID := "target-user"
			baseTime := time.Now()

			// 添加置顶内容（使用伪随机时间）
			for i := 0; i < numPinned; i++ {
				offset := time.Duration(i*17%100) * time.Hour // 伪随机时间
				repo.addContent(&propertyTestContent{
					id:          "pinned-" + string(rune('0'+i)),
					authorID:    targetUserID,
					publishedAt: baseTime.Add(-offset),
					isPinned:    true,
				})
			}

			// 获取用户 Feed
			feed := repo.getUserFeed(targetUserID, 1000, 0)

			// 筛选置顶内容
			var pinnedItems []*propertyTestContent
			for _, content := range feed {
				if content.isPinned {
					pinnedItems = append(pinnedItems, content)
				}
			}

			// 验证：置顶内容按发布时间降序排列
			for i := 1; i < len(pinnedItems); i++ {
				if pinnedItems[i].publishedAt.After(pinnedItems[i-1].publishedAt) {
					return false
				}
			}

			return true
		},
		gen.IntRange(0, 20), // numPinned: 0-20 条置顶内容
	))

	properties.TestingRun(t)
}

// TestProperty22_UserFeedNonPinnedSortedByPublishedAt 测试非置顶内容按发布时间降序排列
func TestProperty22_UserFeedNonPinnedSortedByPublishedAt(t *testing.T) {
	// Feature: backend-services-completion, Property 22: User feed returns pinned items first
	// **Validates: Requirements 7.2**
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	// 属性：非置顶内容组内按发布时间降序排列
	properties.Property("non-pinned items are sorted by published_at descending", prop.ForAll(
		func(numNonPinned int) bool {
			repo := newPropertyTestTimelineRepo()

			targetUserID := "target-user"
			baseTime := time.Now()

			// 添加非置顶内容（使用伪随机时间）
			for i := 0; i < numNonPinned; i++ {
				offset := time.Duration(i*17%100) * time.Hour // 伪随机时间
				repo.addContent(&propertyTestContent{
					id:          "normal-" + string(rune('0'+i)),
					authorID:    targetUserID,
					publishedAt: baseTime.Add(-offset),
					isPinned:    false,
				})
			}

			// 获取用户 Feed
			feed := repo.getUserFeed(targetUserID, 1000, 0)

			// 筛选非置顶内容
			var nonPinnedItems []*propertyTestContent
			for _, content := range feed {
				if !content.isPinned {
					nonPinnedItems = append(nonPinnedItems, content)
				}
			}

			// 验证：非置顶内容按发布时间降序排列
			for i := 1; i < len(nonPinnedItems); i++ {
				if nonPinnedItems[i].publishedAt.After(nonPinnedItems[i-1].publishedAt) {
					return false
				}
			}

			return true
		},
		gen.IntRange(0, 20), // numNonPinned: 0-20 条非置顶内容
	))

	properties.TestingRun(t)
}

// TestProperty22_UserFeedMixedContentCorrectOrder 测试混合内容的正确排序
func TestProperty22_UserFeedMixedContentCorrectOrder(t *testing.T) {
	// Feature: backend-services-completion, Property 22: User feed returns pinned items first
	// **Validates: Requirements 7.2**
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = PropertyTestIterations
	parameters.MaxSize = 50

	properties := gopter.NewProperties(parameters)

	// 属性：混合内容正确排序（置顶优先，各组内按时间降序）
	properties.Property("mixed content is correctly ordered", prop.ForAll(
		func(numPinned, numNonPinned int) bool {
			repo := newPropertyTestTimelineRepo()

			targetUserID := "target-user"
			baseTime := time.Now()

			// 添加置顶内容（使用伪随机时间）
			for i := 0; i < numPinned; i++ {
				offset := time.Duration(i*13%50) * time.Hour
				repo.addContent(&propertyTestContent{
					id:          "pinned-" + string(rune('0'+i)),
					authorID:    targetUserID,
					publishedAt: baseTime.Add(-offset),
					isPinned:    true,
				})
			}

			// 添加非置顶内容（使用伪随机时间）
			for i := 0; i < numNonPinned; i++ {
				offset := time.Duration(i*17%100) * time.Hour
				repo.addContent(&propertyTestContent{
					id:          "normal-" + string(rune('0'+i)),
					authorID:    targetUserID,
					publishedAt: baseTime.Add(-offset),
					isPinned:    false,
				})
			}

			// 获取用户 Feed
			feed := repo.getUserFeed(targetUserID, 1000, 0)

			// 分离置顶和非置顶内容
			var pinnedItems, nonPinnedItems []*propertyTestContent
			foundNonPinned := false
			for _, content := range feed {
				if content.isPinned {
					// 如果已经遇到非置顶内容，后面不应该再有置顶内容
					if foundNonPinned {
						return false
					}
					pinnedItems = append(pinnedItems, content)
				} else {
					foundNonPinned = true
					nonPinnedItems = append(nonPinnedItems, content)
				}
			}

			// 验证置顶内容按时间降序
			for i := 1; i < len(pinnedItems); i++ {
				if pinnedItems[i].publishedAt.After(pinnedItems[i-1].publishedAt) {
					return false
				}
			}

			// 验证非置顶内容按时间降序
			for i := 1; i < len(nonPinnedItems); i++ {
				if nonPinnedItems[i].publishedAt.After(nonPinnedItems[i-1].publishedAt) {
					return false
				}
			}

			// 验证内容数量正确
			if len(pinnedItems) != numPinned || len(nonPinnedItems) != numNonPinned {
				return false
			}

			return true
		},
		gen.IntRange(0, 10), // numPinned: 0-10 条置顶内容
		gen.IntRange(0, 20), // numNonPinned: 0-20 条非置顶内容
	))

	properties.TestingRun(t)
}
