// +build integration

package service_test

import (
	"context"
	"os"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/lesser/chat/internal/model"
	"github.com/lesser/chat/internal/repository"
	"github.com/lesser/chat/internal/service"
	"github.com/lesser/chat/pkg/cache"
	"github.com/lesser/chat/pkg/database"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestChatIntegration 测试两个用户之间的完整聊天流程
// 此测试需要运行中的 PostgreSQL 和 Redis 实例
// 运行命令: go test -tags=integration ./internal/service/...
//
// 功能: chat-integration-demo
// 属性 1: 消息往返完整性
// 属性 2: 会话成员一致性
// 验证: 需求 4.1, 4.2, 4.3, 4.4
func TestChatIntegration(t *testing.T) {
	if os.Getenv("INTEGRATION_TEST") != "true" {
		t.Skip("跳过集成测试。设置 INTEGRATION_TEST=true 以运行。")
	}

	// 设置数据库连接
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		dbURL = "postgres://lesser:lesser_dev_password@localhost:5432/lesser_db?sslmode=disable"
	}

	db, err := database.NewPostgresDB(dbURL)
	require.NoError(t, err, "连接数据库失败")
	defer db.Close()

	// 设置 Redis 连接
	redisURL := os.Getenv("REDIS_URL")
	if redisURL == "" {
		redisURL = "redis://localhost:6379/1"
	}

	redisClient, err := cache.NewRedisClient(redisURL)
	if err != nil {
		t.Logf("警告: Redis 不可用，部分功能可能无法工作: %v", err)
		redisClient = nil
	}

	// 创建仓库和服务
	convRepo := repository.NewConversationRepository(db)
	msgRepo := repository.NewMessageRepository(db)
	var unreadCacheService *service.UnreadCacheService
	if redisClient != nil {
		unreadCacheService = service.NewUnreadCacheService(redisClient, msgRepo)
	}
	chatService := service.NewChatService(convRepo, msgRepo, redisClient, nil, unreadCacheService)

	ctx := context.Background()

	// 生成测试用户ID（实际场景中这些会来自 Django）
	test1ID := uuid.New()
	test2ID := uuid.New()

	t.Logf("测试用户 1 ID: %s", test1ID)
	t.Logf("测试用户 2 ID: %s", test2ID)

	// 测试 1: 创建私聊会话
	// 属性 2: 会话成员一致性
	t.Run("创建私聊会话", func(t *testing.T) {
		conv, err := chatService.CreateConversation(ctx, service.CreateConversationRequest{
			Type:      model.ConversationTypePrivate,
			MemberIDs: []uuid.UUID{test1ID, test2ID},
			CreatorID: test1ID,
		})
		require.NoError(t, err, "创建会话失败")
		require.NotNil(t, conv, "会话不应为空")

		// 验证会话属性
		assert.Equal(t, model.ConversationTypePrivate, conv.Type, "会话类型应为私聊")
		assert.Equal(t, test1ID, conv.CreatorID, "创建者ID应匹配")
		assert.Len(t, conv.Members, 2, "私聊会话应有且仅有2个成员")

		// 验证两个用户都是成员
		memberIDs := make(map[uuid.UUID]bool)
		for _, m := range conv.Members {
			memberIDs[m.UserID] = true
		}
		assert.True(t, memberIDs[test1ID], "test1 应是成员")
		assert.True(t, memberIDs[test2ID], "test2 应是成员")

		// 保存会话ID供后续测试使用
		t.Logf("创建的会话ID: %s", conv.ID)
	})

	// 测试 2: 发送消息并验证往返完整性
	// 属性 1: 消息往返完整性
	t.Run("消息往返测试", func(t *testing.T) {
		// 首先创建会话
		conv, err := chatService.CreateConversation(ctx, service.CreateConversationRequest{
			Type:      model.ConversationTypePrivate,
			MemberIDs: []uuid.UUID{test1ID, test2ID},
			CreatorID: test1ID,
		})
		require.NoError(t, err)

		// 测试各种内容的消息
		testMessages := []struct {
			senderID uuid.UUID
			content  string
		}{
			{test1ID, "来自 test1 的问候！"},
			{test2ID, "来自 test2 的问候！"},
			{test1ID, "你好吗？"},
			{test2ID, "我很好，谢谢！"},
			{test1ID, "特殊字符: 你好世界 🎉 émojis"},
		}

		// 发送所有消息
		sentMessages := make([]*model.Message, len(testMessages))
		for i, tm := range testMessages {
			msg, err := chatService.SendMessage(ctx, service.SendMessageRequest{
				ConversationID: conv.ID,
				SenderID:       tm.senderID,
				Content:        tm.content,
				MessageType:    model.MessageTypeText,
			})
			require.NoError(t, err, "发送消息 %d 失败", i)
			require.NotNil(t, msg, "消息不应为空")
			assert.NotEqual(t, uuid.Nil, msg.ID, "消息应有有效ID")
			assert.Equal(t, tm.content, msg.Content, "消息内容应匹配")
			sentMessages[i] = msg
		}

		// 获取消息并验证完整性
		result, err := chatService.GetMessages(ctx, conv.ID, test1ID, 1, 50)
		require.NoError(t, err, "获取消息失败")
		assert.Equal(t, int64(len(testMessages)), result.Total, "消息总数应匹配")

		// 验证所有发送的消息都能正确获取
		retrievedContents := make(map[string]bool)
		for _, msg := range result.Messages {
			retrievedContents[msg.Content] = true
		}

		for _, tm := range testMessages {
			assert.True(t, retrievedContents[tm.content],
				"消息内容 '%s' 应在获取的消息中", tm.content)
		}
	})

	// 测试 3: 验证会话获取
	t.Run("获取会话", func(t *testing.T) {
		// 创建会话
		conv, err := chatService.CreateConversation(ctx, service.CreateConversationRequest{
			Type:      model.ConversationTypePrivate,
			MemberIDs: []uuid.UUID{test1ID, test2ID},
			CreatorID: test1ID,
		})
		require.NoError(t, err)

		// 获取会话
		retrieved, err := chatService.GetConversation(ctx, conv.ID)
		require.NoError(t, err)
		assert.Equal(t, conv.ID, retrieved.ID)
		assert.Equal(t, conv.Type, retrieved.Type)
	})

	// 测试 4: 验证用户会话列表
	t.Run("获取用户会话列表", func(t *testing.T) {
		// 创建多个会话
		for i := 0; i < 3; i++ {
			otherUser := uuid.New()
			_, err := chatService.CreateConversation(ctx, service.CreateConversationRequest{
				Type:      model.ConversationTypePrivate,
				MemberIDs: []uuid.UUID{test1ID, otherUser},
				CreatorID: test1ID,
			})
			require.NoError(t, err)
		}

		// 获取用户的会话
		result, err := chatService.GetUserConversations(ctx, test1ID, 1, 20)
		require.NoError(t, err)
		assert.GreaterOrEqual(t, len(result.Conversations), 3,
			"用户应至少有3个会话")
	})

	// 测试 5: 非成员不能发送消息
	t.Run("非成员不能发送消息", func(t *testing.T) {
		// 创建 test1 和 test2 之间的会话
		conv, err := chatService.CreateConversation(ctx, service.CreateConversationRequest{
			Type:      model.ConversationTypePrivate,
			MemberIDs: []uuid.UUID{test1ID, test2ID},
			CreatorID: test1ID,
		})
		require.NoError(t, err)

		// 尝试以非成员身份发送消息
		nonMember := uuid.New()
		_, err = chatService.SendMessage(ctx, service.SendMessageRequest{
			ConversationID: conv.ID,
			SenderID:       nonMember,
			Content:        "我不应该能发送这条消息",
			MessageType:    model.MessageTypeText,
		})
		assert.Error(t, err, "非成员不应能发送消息")
		assert.Equal(t, service.ErrNotMember, err)
	})
}

// TestMessageContentIntegrity 消息内容完整性的属性测试
// 功能: chat-integration-demo, 属性 1: 消息往返完整性
// 验证: 需求 4.2, 4.3, 4.4
func TestMessageContentIntegrity(t *testing.T) {
	if os.Getenv("INTEGRATION_TEST") != "true" {
		t.Skip("跳过集成测试。设置 INTEGRATION_TEST=true 以运行。")
	}

	// 设置（同上）
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		dbURL = "postgres://lesser:lesser_dev_password@localhost:5432/lesser_db?sslmode=disable"
	}

	db, err := database.NewPostgresDB(dbURL)
	require.NoError(t, err)
	defer db.Close()

	convRepo := repository.NewConversationRepository(db)
	msgRepo := repository.NewMessageRepository(db)
	chatService := service.NewChatService(convRepo, msgRepo, nil, nil, nil)

	ctx := context.Background()
	test1ID := uuid.New()
	test2ID := uuid.New()

	// 创建会话
	conv, err := chatService.CreateConversation(ctx, service.CreateConversationRequest{
		Type:      model.ConversationTypePrivate,
		MemberIDs: []uuid.UUID{test1ID, test2ID},
		CreatorID: test1ID,
	})
	require.NoError(t, err)

	// 属性: 对于任何消息内容，发送后获取应返回相同内容
	testContents := []string{
		"简单文本",
		"带数字的文本 12345",
		"特殊字符: !@#$%^&*()",
		"Unicode: 你好世界 🎉 émojis 日本語",
		"换行符:\n第1行\n第2行",
		"制表符:\t标签1\t标签2",
		"长文本: " + string(make([]byte, 1000)),
		"近空白:    ",
	}

	for _, content := range testContents {
		if content == "" {
			continue // 跳过空内容（无效）
		}

		t.Run("内容_"+content[:min(20, len(content))], func(t *testing.T) {
			// 发送消息
			sent, err := chatService.SendMessage(ctx, service.SendMessageRequest{
				ConversationID: conv.ID,
				SenderID:       test1ID,
				Content:        content,
				MessageType:    model.MessageTypeText,
			})
			require.NoError(t, err)

			// 短暂延迟确保持久化
			time.Sleep(10 * time.Millisecond)

			// 获取并验证
			result, err := chatService.GetMessages(ctx, conv.ID, test1ID, 1, 100)
			require.NoError(t, err)

			found := false
			for _, msg := range result.Messages {
				if msg.ID == sent.ID {
					assert.Equal(t, content, msg.Content,
						"获取的内容应与发送的内容匹配")
					found = true
					break
				}
			}
			assert.True(t, found, "发送的消息应在获取的消息中找到")
		})
	}
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
