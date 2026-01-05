// Package logic 提供频道业务逻辑属性测试
// Feature: service-refactoring, Property 5: Channel Access Control
// Validates: Requirements 3.5
// 对于任何频道和任何非管理员订阅者，订阅者只能读取频道内容，不能发布内容
package logic

import (
	"context"
	"errors"
	"testing"

	"github.com/funcdfs/lesser/channel/internal/data_access"
	"github.com/funcdfs/lesser/pkg/log"
	"github.com/leanovate/gopter"
	"github.com/leanovate/gopter/gen"
	"github.com/leanovate/gopter/prop"
)

// mockChannelDA 模拟频道数据访问
type mockChannelDA struct {
	channels map[string]*data_access.Channel
	admins   map[string]map[string]bool // channelID -> userID -> isAdmin
}

func newMockChannelRepo() *mockChannelDA {
	return &mockChannelDA{
		channels: make(map[string]*data_access.Channel),
		admins:   make(map[string]map[string]bool),
	}
}

func (m *mockChannelDA) Create(ctx context.Context, channel *data_access.Channel) error {
	m.channels[channel.ID] = channel
	// 自动将所有者添加为管理员
	if m.admins[channel.ID] == nil {
		m.admins[channel.ID] = make(map[string]bool)
	}
	m.admins[channel.ID][channel.OwnerID] = true
	return nil
}

func (m *mockChannelDA) GetByID(ctx context.Context, id string) (*data_access.Channel, error) {
	if ch, ok := m.channels[id]; ok {
		return ch, nil
	}
	return nil, data_access.ErrNotFound
}

func (m *mockChannelDA) Update(ctx context.Context, channel *data_access.Channel) error {
	if _, ok := m.channels[channel.ID]; !ok {
		return data_access.ErrNotFound
	}
	m.channels[channel.ID] = channel
	return nil
}

func (m *mockChannelDA) Delete(ctx context.Context, id string) error {
	delete(m.channels, id)
	return nil
}

func (m *mockChannelDA) List(ctx context.Context, offset, limit int) ([]*data_access.Channel, error) {
	var result []*data_access.Channel
	for _, ch := range m.channels {
		result = append(result, ch)
	}
	return result, nil
}

func (m *mockChannelDA) GetByOwnerID(ctx context.Context, ownerID string, offset, limit int) ([]*data_access.Channel, error) {
	var result []*data_access.Channel
	for _, ch := range m.channels {
		if ch.OwnerID == ownerID {
			result = append(result, ch)
		}
	}
	return result, nil
}

func (m *mockChannelDA) IncrementSubscriberCount(ctx context.Context, channelID string) error {
	if ch, ok := m.channels[channelID]; ok {
		ch.SubscriberCount++
	}
	return nil
}

func (m *mockChannelDA) DecrementSubscriberCount(ctx context.Context, channelID string) error {
	if ch, ok := m.channels[channelID]; ok && ch.SubscriberCount > 0 {
		ch.SubscriberCount--
	}
	return nil
}

func (m *mockChannelDA) IncrementPostCount(ctx context.Context, channelID string) error {
	if ch, ok := m.channels[channelID]; ok {
		ch.PostCount++
	}
	return nil
}

func (m *mockChannelDA) DecrementPostCount(ctx context.Context, channelID string) error {
	if ch, ok := m.channels[channelID]; ok && ch.PostCount > 0 {
		ch.PostCount--
	}
	return nil
}

func (m *mockChannelDA) GetAdmins(ctx context.Context, channelID string) ([]string, error) {
	var result []string
	if admins, ok := m.admins[channelID]; ok {
		for userID := range admins {
			result = append(result, userID)
		}
	}
	return result, nil
}

func (m *mockChannelDA) AddAdmin(ctx context.Context, channelID, userID string) error {
	if m.admins[channelID] == nil {
		m.admins[channelID] = make(map[string]bool)
	}
	m.admins[channelID][userID] = true
	return nil
}

func (m *mockChannelDA) RemoveAdmin(ctx context.Context, channelID, userID string) error {
	if admins, ok := m.admins[channelID]; ok {
		delete(admins, userID)
	}
	return nil
}

func (m *mockChannelDA) IsAdmin(ctx context.Context, channelID, userID string) (bool, error) {
	if admins, ok := m.admins[channelID]; ok {
		return admins[userID], nil
	}
	return false, nil
}

// mockSubscriptionDA 模拟订阅数据访问
type mockSubscriptionDA struct {
	subscriptions map[string]map[string]bool // channelID -> userID -> isSubscribed
}

func newMockSubscriptionRepo() *mockSubscriptionDA {
	return &mockSubscriptionDA{
		subscriptions: make(map[string]map[string]bool),
	}
}

func (m *mockSubscriptionDA) Subscribe(ctx context.Context, channelID, userID string) error {
	if m.subscriptions[channelID] == nil {
		m.subscriptions[channelID] = make(map[string]bool)
	}
	m.subscriptions[channelID][userID] = true
	return nil
}

func (m *mockSubscriptionDA) Unsubscribe(ctx context.Context, channelID, userID string) error {
	if subs, ok := m.subscriptions[channelID]; ok {
		delete(subs, userID)
	}
	return nil
}

func (m *mockSubscriptionDA) GetSubscribers(ctx context.Context, channelID string, offset, limit int) ([]string, error) {
	var result []string
	if subs, ok := m.subscriptions[channelID]; ok {
		for userID := range subs {
			result = append(result, userID)
		}
	}
	return result, nil
}

func (m *mockSubscriptionDA) IsSubscribed(ctx context.Context, channelID, userID string) (bool, error) {
	if subs, ok := m.subscriptions[channelID]; ok {
		return subs[userID], nil
	}
	return false, nil
}

func (m *mockSubscriptionDA) GetSubscribedChannels(ctx context.Context, userID string, offset, limit int) ([]string, error) {
	var result []string
	for channelID, subs := range m.subscriptions {
		if subs[userID] {
			result = append(result, channelID)
		}
	}
	return result, nil
}

func (m *mockSubscriptionDA) GetSubscriberCount(ctx context.Context, channelID string) (int64, error) {
	if subs, ok := m.subscriptions[channelID]; ok {
		return int64(len(subs)), nil
	}
	return 0, nil
}

// mockPostDA 模拟内容数据访问
type mockPostDA struct {
	posts map[string]*data_access.ChannelPost
}

func newMockPostRepo() *mockPostDA {
	return &mockPostDA{
		posts: make(map[string]*data_access.ChannelPost),
	}
}

func (m *mockPostDA) Create(ctx context.Context, post *data_access.ChannelPost) error {
	m.posts[post.ID] = post
	return nil
}

func (m *mockPostDA) GetByID(ctx context.Context, id string) (*data_access.ChannelPost, error) {
	if post, ok := m.posts[id]; ok {
		return post, nil
	}
	return nil, data_access.ErrNotFound
}

func (m *mockPostDA) Delete(ctx context.Context, id string) error {
	delete(m.posts, id)
	return nil
}

func (m *mockPostDA) ListByChannel(ctx context.Context, channelID string, offset, limit int) ([]*data_access.ChannelPost, error) {
	var result []*data_access.ChannelPost
	for _, post := range m.posts {
		if post.ChannelID == channelID {
			result = append(result, post)
		}
	}
	return result, nil
}

func (m *mockPostDA) IncrementViewCount(ctx context.Context, postID string) error {
	if post, ok := m.posts[postID]; ok {
		post.ViewCount++
	}
	return nil
}

func (m *mockPostDA) GetPostCount(ctx context.Context, channelID string) (int64, error) {
	var count int64
	for _, post := range m.posts {
		if post.ChannelID == channelID {
			count++
		}
	}
	return count, nil
}

// createTestService 创建测试服务
func createTestService() (*channelService, *mockChannelDA, *mockSubscriptionDA, *mockPostDA) {
	channelRepo := newMockChannelRepo()
	subscriptionRepo := newMockSubscriptionRepo()
	postRepo := newMockPostRepo()

	// 创建一个测试用的 logger
	testLogger := log.New("channel-test")

	svc := &channelService{
		channelRepo:      channelRepo,
		subscriptionRepo: subscriptionRepo,
		postRepo:         postRepo,
		log:              testLogger,
	}

	return svc, channelRepo, subscriptionRepo, postRepo
}

// TestProperty5_ChannelAccessControl 属性测试：频道访问控制
// Feature: service-refactoring, Property 5: Channel Access Control
// Validates: Requirements 3.5
// 对于任何频道和任何非管理员订阅者，订阅者只能读取频道内容，不能发布内容
func TestProperty5_ChannelAccessControl(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = 100

	properties := gopter.NewProperties(parameters)

	// 生成非空字符串的生成器
	genNonEmptyString := func() gopter.Gen {
		return gen.Identifier().Map(func(s string) string {
			if len(s) > 20 {
				return s[:20]
			}
			return s
		})
	}

	// 生成内容字符串的生成器
	genContentString := func() gopter.Gen {
		return gen.Identifier().Map(func(s string) string {
			if len(s) > 100 {
				return s[:100]
			}
			return s
		})
	}

	// 属性 1: 非管理员订阅者不能发布内容
	properties.Property("非管理员订阅者不能发布内容", prop.ForAll(
		func(ownerID, subscriberID, channelName, postContent string) bool {
			// 确保 ownerID 和 subscriberID 不同
			if ownerID == subscriberID {
				subscriberID = subscriberID + "_sub"
			}

			ctx := context.Background()
			svc, channelRepo, subscriptionRepo, _ := createTestService()

			// 创建频道
			channel := &data_access.Channel{
				ID:      "channel-" + ownerID,
				Name:    channelName,
				OwnerID: ownerID,
			}
			_ = channelRepo.Create(ctx, channel)

			// 订阅者订阅频道
			_ = subscriptionRepo.Subscribe(ctx, channel.ID, subscriberID)

			// 非管理员订阅者尝试发布内容
			_, err := svc.PublishPost(ctx, subscriberID, &PublishPostRequest{
				ChannelID: channel.ID,
				Content:   postContent,
			})

			// 应该返回 ErrNotChannelAdmin 错误
			return errors.Is(err, ErrNotChannelAdmin)
		},
		genNonEmptyString(),
		genNonEmptyString(),
		genNonEmptyString(),
		genContentString(),
	))

	// 属性 2: 频道所有者可以发布内容
	properties.Property("频道所有者可以发布内容", prop.ForAll(
		func(ownerID, channelName, postContent string) bool {
			ctx := context.Background()
			svc, channelRepo, _, _ := createTestService()

			// 创建频道
			channel := &data_access.Channel{
				ID:      "channel-" + ownerID,
				Name:    channelName,
				OwnerID: ownerID,
			}
			_ = channelRepo.Create(ctx, channel)

			// 所有者发布内容
			post, err := svc.PublishPost(ctx, ownerID, &PublishPostRequest{
				ChannelID: channel.ID,
				Content:   postContent,
			})

			// 应该成功
			return err == nil && post != nil && post.Content == postContent
		},
		genNonEmptyString(),
		genNonEmptyString(),
		genContentString(),
	))

	// 属性 3: 管理员可以发布内容
	properties.Property("管理员可以发布内容", prop.ForAll(
		func(ownerID, adminID, channelName, postContent string) bool {
			// 确保 ownerID 和 adminID 不同
			if ownerID == adminID {
				adminID = adminID + "_admin"
			}

			ctx := context.Background()
			svc, channelRepo, _, _ := createTestService()

			// 创建频道
			channel := &data_access.Channel{
				ID:      "channel-" + ownerID,
				Name:    channelName,
				OwnerID: ownerID,
			}
			_ = channelRepo.Create(ctx, channel)

			// 添加管理员
			_ = channelRepo.AddAdmin(ctx, channel.ID, adminID)

			// 管理员发布内容
			post, err := svc.PublishPost(ctx, adminID, &PublishPostRequest{
				ChannelID: channel.ID,
				Content:   postContent,
			})

			// 应该成功
			return err == nil && post != nil && post.Content == postContent
		},
		genNonEmptyString(),
		genNonEmptyString(),
		genNonEmptyString(),
		genContentString(),
	))

	// 属性 4: 非管理员订阅者可以读取内容
	properties.Property("非管理员订阅者可以读取内容", prop.ForAll(
		func(ownerID, subscriberID, channelName, postContent string) bool {
			// 确保 ownerID 和 subscriberID 不同
			if ownerID == subscriberID {
				subscriberID = subscriberID + "_sub"
			}

			ctx := context.Background()
			svc, channelRepo, subscriptionRepo, postRepo := createTestService()

			// 创建频道
			channel := &data_access.Channel{
				ID:      "channel-" + ownerID,
				Name:    channelName,
				OwnerID: ownerID,
			}
			_ = channelRepo.Create(ctx, channel)

			// 订阅者订阅频道
			_ = subscriptionRepo.Subscribe(ctx, channel.ID, subscriberID)

			// 所有者发布内容
			post := &data_access.ChannelPost{
				ID:        "post-1",
				ChannelID: channel.ID,
				AuthorID:  ownerID,
				Content:   postContent,
			}
			_ = postRepo.Create(ctx, post)

			// 订阅者读取内容列表
			posts, _, err := svc.GetPosts(ctx, channel.ID, 10, 0)

			// 应该成功读取
			return err == nil && len(posts) == 1 && posts[0].Content == postContent
		},
		genNonEmptyString(),
		genNonEmptyString(),
		genNonEmptyString(),
		genContentString(),
	))

	// 属性 5: 非管理员订阅者不能删除内容
	properties.Property("非管理员订阅者不能删除内容", prop.ForAll(
		func(ownerID, subscriberID, channelName, postContent string) bool {
			// 确保 ownerID 和 subscriberID 不同
			if ownerID == subscriberID {
				subscriberID = subscriberID + "_sub"
			}

			ctx := context.Background()
			svc, channelRepo, subscriptionRepo, postRepo := createTestService()

			// 创建频道
			channel := &data_access.Channel{
				ID:      "channel-" + ownerID,
				Name:    channelName,
				OwnerID: ownerID,
			}
			_ = channelRepo.Create(ctx, channel)

			// 订阅者订阅频道
			_ = subscriptionRepo.Subscribe(ctx, channel.ID, subscriberID)

			// 所有者发布内容
			post := &data_access.ChannelPost{
				ID:        "post-1",
				ChannelID: channel.ID,
				AuthorID:  ownerID,
				Content:   postContent,
			}
			_ = postRepo.Create(ctx, post)

			// 非管理员订阅者尝试删除内容
			err := svc.DeletePost(ctx, post.ID, subscriberID)

			// 应该返回 ErrNotChannelAdmin 错误
			return errors.Is(err, ErrNotChannelAdmin)
		},
		genNonEmptyString(),
		genNonEmptyString(),
		genNonEmptyString(),
		genContentString(),
	))

	// 属性 6: 非管理员订阅者不能置顶内容
	properties.Property("非管理员订阅者不能置顶内容", prop.ForAll(
		func(ownerID, subscriberID, channelName, postContent string) bool {
			// 确保 ownerID 和 subscriberID 不同
			if ownerID == subscriberID {
				subscriberID = subscriberID + "_sub"
			}

			ctx := context.Background()
			svc, channelRepo, subscriptionRepo, postRepo := createTestService()

			// 创建频道
			channel := &data_access.Channel{
				ID:      "channel-" + ownerID,
				Name:    channelName,
				OwnerID: ownerID,
			}
			_ = channelRepo.Create(ctx, channel)

			// 订阅者订阅频道
			_ = subscriptionRepo.Subscribe(ctx, channel.ID, subscriberID)

			// 所有者发布内容
			post := &data_access.ChannelPost{
				ID:        "post-1",
				ChannelID: channel.ID,
				AuthorID:  ownerID,
				Content:   postContent,
			}
			_ = postRepo.Create(ctx, post)

			// 非管理员订阅者尝试置顶内容
			err := svc.PinPost(ctx, post.ID, subscriberID)

			// 应该返回 ErrNotChannelAdmin 错误
			return errors.Is(err, ErrNotChannelAdmin)
		},
		genNonEmptyString(),
		genNonEmptyString(),
		genNonEmptyString(),
		genContentString(),
	))

	properties.TestingRun(t)
}
