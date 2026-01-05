// Package logic 提供频道业务逻辑属性测试
// Feature: service-refactoring, Property 6: Channel Broadcast
// Validates: Requirements 3.6
// 对于任何管理员发布的频道内容，该内容应对所有订阅者可见
package logic

import (
	"context"
	"testing"

	"github.com/funcdfs/lesser/channel/internal/data_access"
	"github.com/funcdfs/lesser/pkg/log"
	"github.com/leanovate/gopter"
	"github.com/leanovate/gopter/gen"
	"github.com/leanovate/gopter/prop"
)

// TestProperty6_ChannelBroadcast 属性测试：频道广播
// Feature: service-refactoring, Property 6: Channel Broadcast
// Validates: Requirements 3.6
// 对于任何管理员发布的频道内容，该内容应对所有订阅者可见
func TestProperty6_ChannelBroadcast(t *testing.T) {
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

	// 生成订阅者数量的生成器（1-10 个订阅者）
	genSubscriberCount := func() gopter.Gen {
		return gen.IntRange(1, 10)
	}

	// 属性 1: 所有者发布的内容对所有订阅者可见
	properties.Property("所有者发布的内容对所有订阅者可见", prop.ForAll(
		func(ownerID, channelName, postContent string, subscriberCount int) bool {
			ctx := context.Background()
			svc, channelDA, subscriptionDA, _ := createBroadcastTestService()

			// 创建频道
			channel := &data_access.Channel{
				ID:      "channel-" + ownerID,
				Name:    channelName,
				OwnerID: ownerID,
			}
			_ = channelDA.Create(ctx, channel)

			// 创建多个订阅者并订阅频道
			subscribers := make([]string, subscriberCount)
			for i := 0; i < subscriberCount; i++ {
				subscriberID := ownerID + "_sub_" + string(rune('a'+i))
				subscribers[i] = subscriberID
				_ = subscriptionDA.Subscribe(ctx, channel.ID, subscriberID)
			}

			// 所有者发布内容
			post, err := svc.PublishPost(ctx, ownerID, &PublishPostRequest{
				ChannelID: channel.ID,
				Content:   postContent,
			})
			if err != nil {
				return false
			}

			// 验证所有订阅者都能看到该内容
			for _, subscriberID := range subscribers {
				// 检查订阅者是否已订阅
				isSubscribed, err := subscriptionDA.IsSubscribed(ctx, channel.ID, subscriberID)
				if err != nil || !isSubscribed {
					return false
				}

				// 订阅者获取内容列表
				posts, _, err := svc.GetPosts(ctx, channel.ID, 10, 0)
				if err != nil {
					return false
				}

				// 验证内容存在且内容正确
				found := false
				for _, p := range posts {
					if p.ID == post.ID && p.Content == postContent {
						found = true
						break
					}
				}
				if !found {
					return false
				}
			}

			return true
		},
		genNonEmptyString(),
		genNonEmptyString(),
		genContentString(),
		genSubscriberCount(),
	))

	// 属性 2: 管理员发布的内容对所有订阅者可见
	properties.Property("管理员发布的内容对所有订阅者可见", prop.ForAll(
		func(ownerID, adminID, channelName, postContent string, subscriberCount int) bool {
			// 确保 ownerID 和 adminID 不同
			if ownerID == adminID {
				adminID = adminID + "_admin"
			}

			ctx := context.Background()
			svc, channelDA, subscriptionDA, _ := createBroadcastTestService()

			// 创建频道
			channel := &data_access.Channel{
				ID:      "channel-" + ownerID,
				Name:    channelName,
				OwnerID: ownerID,
			}
			_ = channelDA.Create(ctx, channel)

			// 添加管理员
			_ = channelDA.AddAdmin(ctx, channel.ID, adminID)

			// 创建多个订阅者并订阅频道
			subscribers := make([]string, subscriberCount)
			for i := 0; i < subscriberCount; i++ {
				subscriberID := ownerID + "_sub_" + string(rune('a'+i))
				subscribers[i] = subscriberID
				_ = subscriptionDA.Subscribe(ctx, channel.ID, subscriberID)
			}

			// 管理员发布内容
			post, err := svc.PublishPost(ctx, adminID, &PublishPostRequest{
				ChannelID: channel.ID,
				Content:   postContent,
			})
			if err != nil {
				return false
			}

			// 验证所有订阅者都能看到该内容
			for range subscribers {
				// 订阅者获取内容列表
				posts, _, err := svc.GetPosts(ctx, channel.ID, 10, 0)
				if err != nil {
					return false
				}

				// 验证内容存在且内容正确
				found := false
				for _, p := range posts {
					if p.ID == post.ID && p.Content == postContent {
						found = true
						break
					}
				}
				if !found {
					return false
				}
			}

			return true
		},
		genNonEmptyString(),
		genNonEmptyString(),
		genNonEmptyString(),
		genContentString(),
		genSubscriberCount(),
	))

	// 属性 3: 多个管理员发布的内容都对所有订阅者可见
	properties.Property("多个管理员发布的内容都对所有订阅者可见", prop.ForAll(
		func(ownerID, channelName string, adminCount, subscriberCount int) bool {
			ctx := context.Background()
			svc, channelDA, subscriptionDA, _ := createBroadcastTestService()

			// 创建频道
			channel := &data_access.Channel{
				ID:      "channel-" + ownerID,
				Name:    channelName,
				OwnerID: ownerID,
			}
			_ = channelDA.Create(ctx, channel)

			// 创建多个管理员
			admins := make([]string, adminCount)
			for i := 0; i < adminCount; i++ {
				adminID := ownerID + "_admin_" + string(rune('a'+i))
				admins[i] = adminID
				_ = channelDA.AddAdmin(ctx, channel.ID, adminID)
			}

			// 创建多个订阅者并订阅频道
			subscribers := make([]string, subscriberCount)
			for i := 0; i < subscriberCount; i++ {
				subscriberID := ownerID + "_sub_" + string(rune('a'+i))
				subscribers[i] = subscriberID
				_ = subscriptionDA.Subscribe(ctx, channel.ID, subscriberID)
			}

			// 每个管理员发布一条内容
			publishedPosts := make([]*data_access.ChannelPost, 0, adminCount+1)

			// 所有者发布内容
			ownerPost, err := svc.PublishPost(ctx, ownerID, &PublishPostRequest{
				ChannelID: channel.ID,
				Content:   "owner_content",
			})
			if err != nil {
				return false
			}
			publishedPosts = append(publishedPosts, ownerPost)

			// 管理员发布内容
			for i, adminID := range admins {
				post, err := svc.PublishPost(ctx, adminID, &PublishPostRequest{
					ChannelID: channel.ID,
					Content:   "admin_content_" + string(rune('a'+i)),
				})
				if err != nil {
					return false
				}
				publishedPosts = append(publishedPosts, post)
			}

			// 验证所有订阅者都能看到所有内容
			for _, subID := range subscribers {
				// 检查订阅者是否已订阅
				isSubscribed, _ := subscriptionDA.IsSubscribed(ctx, channel.ID, subID)
				if !isSubscribed {
					return false
				}

				// 订阅者获取内容列表
				posts, _, err := svc.GetPosts(ctx, channel.ID, 100, 0)
				if err != nil {
					return false
				}

				// 验证所有发布的内容都存在
				for _, publishedPost := range publishedPosts {
					found := false
					for _, p := range posts {
						if p.ID == publishedPost.ID {
							found = true
							break
						}
					}
					if !found {
						return false
					}
				}
			}

			return true
		},
		genNonEmptyString(),
		genNonEmptyString(),
		gen.IntRange(1, 5), // 1-5 个管理员
		genSubscriberCount(),
	))

	// 属性 4: 发布的内容对新订阅者也可见
	properties.Property("发布的内容对新订阅者也可见", prop.ForAll(
		func(ownerID, channelName, postContent, newSubscriberID string) bool {
			// 确保 ownerID 和 newSubscriberID 不同
			if ownerID == newSubscriberID {
				newSubscriberID = newSubscriberID + "_new"
			}

			ctx := context.Background()
			svc, channelDA, subscriptionDA, _ := createBroadcastTestService()

			// 创建频道
			channel := &data_access.Channel{
				ID:      "channel-" + ownerID,
				Name:    channelName,
				OwnerID: ownerID,
			}
			_ = channelDA.Create(ctx, channel)

			// 所有者发布内容（在新订阅者订阅之前）
			post, err := svc.PublishPost(ctx, ownerID, &PublishPostRequest{
				ChannelID: channel.ID,
				Content:   postContent,
			})
			if err != nil {
				return false
			}

			// 新订阅者订阅频道
			_ = subscriptionDA.Subscribe(ctx, channel.ID, newSubscriberID)

			// 新订阅者获取内容列表
			posts, _, err := svc.GetPosts(ctx, channel.ID, 10, 0)
			if err != nil {
				return false
			}

			// 验证新订阅者能看到之前发布的内容
			found := false
			for _, p := range posts {
				if p.ID == post.ID && p.Content == postContent {
					found = true
					break
				}
			}

			return found
		},
		genNonEmptyString(),
		genNonEmptyString(),
		genContentString(),
		genNonEmptyString(),
	))

	// 属性 5: 内容对所有订阅者的可见性是一致的
	properties.Property("内容对所有订阅者的可见性是一致的", prop.ForAll(
		func(ownerID, channelName, postContent string, subscriberCount int) bool {
			ctx := context.Background()
			svc, channelDA, subscriptionDA, _ := createBroadcastTestService()

			// 创建频道
			channel := &data_access.Channel{
				ID:      "channel-" + ownerID,
				Name:    channelName,
				OwnerID: ownerID,
			}
			_ = channelDA.Create(ctx, channel)

			// 创建多个订阅者并订阅频道
			subscribers := make([]string, subscriberCount)
			for i := 0; i < subscriberCount; i++ {
				subscriberID := ownerID + "_sub_" + string(rune('a'+i))
				subscribers[i] = subscriberID
				_ = subscriptionDA.Subscribe(ctx, channel.ID, subscriberID)
			}

			// 所有者发布内容
			_, err := svc.PublishPost(ctx, ownerID, &PublishPostRequest{
				ChannelID: channel.ID,
				Content:   postContent,
			})
			if err != nil {
				return false
			}

			// 获取第一个订阅者看到的内容列表
			firstPosts, _, err := svc.GetPosts(ctx, channel.ID, 10, 0)
			if err != nil {
				return false
			}

			// 验证所有订阅者看到的内容列表一致
			for _, subscriberID := range subscribers {
				// 检查订阅者是否已订阅
				isSubscribed, _ := subscriptionDA.IsSubscribed(ctx, channel.ID, subscriberID)
				if !isSubscribed {
					return false
				}

				// 获取该订阅者看到的内容列表
				posts, _, err := svc.GetPosts(ctx, channel.ID, 10, 0)
				if err != nil {
					return false
				}

				// 验证内容数量一致
				if len(posts) != len(firstPosts) {
					return false
				}

				// 验证内容 ID 一致
				for i, p := range posts {
					if p.ID != firstPosts[i].ID {
						return false
					}
				}
			}

			return true
		},
		genNonEmptyString(),
		genNonEmptyString(),
		genContentString(),
		genSubscriberCount(),
	))

	properties.TestingRun(t)
}

// createBroadcastTestService 创建广播测试服务
func createBroadcastTestService() (*channelService, *mockChannelRepo, *mockSubscriptionRepo, *mockPostRepo) {
	channelDA := newMockChannelRepo()
	subscriptionDA := newMockSubscriptionRepo()
	postDA := newMockPostRepo()

	// 创建一个测试用的 logger
	testLogger := log.New("channel-broadcast-test")

	svc := &channelService{
		channelDA:      channelDA,
		subscriptionDA: subscriptionDA,
		postDA:         postDA,
		log:              testLogger,
	}

	return svc, channelDA, subscriptionDA, postDA
}
