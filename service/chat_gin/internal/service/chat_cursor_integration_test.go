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

// TestGroupChatCursorReadStatus 专门测试群聊的 Cursor-based 已读状态逻辑
// 运行命令: go test -v -tags=integration ./internal/service/ -run TestGroupChatCursorReadStatus
func TestGroupChatCursorReadStatus(t *testing.T) {
	if os.Getenv("INTEGRATION_TEST") != "true" {
		t.Skip("跳过集成测试。设置 INTEGRATION_TEST=true 以运行。")
	}

	// 1. Setup Infrastructure
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		dbURL = "postgres://lesser:lesser_dev_password@localhost:5432/lesser_db?sslmode=disable"
	}
	db, err := database.NewPostgres(dbURL)
	require.NoError(t, err, "连接数据库失败")
	sqlDB, _ := db.DB()
	defer sqlDB.Close()

	// 清理数据 (可选，或依赖事务回滚，这里简单起见直接运行)
	// 实际环境最好在独立的测试库运行

	redisURL := os.Getenv("REDIS_URL")
	if redisURL == "" {
		redisURL = "redis://localhost:6379/1"
	}
	redisClient, _ := cache.NewRedis(redisURL) // 允许失败，非关键路径

	// 2. Setup Service
	convRepo := repository.NewConversationRepository(db)
	msgRepo := repository.NewMessageRepository(db)
	var unreadCacheService *service.UnreadCacheService
	if redisClient != nil {
		unreadCacheService = service.NewUnreadCacheService(redisClient, msgRepo)
	}
	svc := service.NewChatService(convRepo, msgRepo, redisClient, nil, unreadCacheService)
	ctx := context.Background()

	// 3. Create Users (IDs only)
	userA := uuid.New()
	userB := uuid.New()
	userC := uuid.New()

	// 4. Create Group Conversation
	t.Log("创建群聊...")
	createReq := service.CreateConversationRequest{
		Type:      model.ConversationTypeGroup,
		Name:      "Cursor Logic Test Group",
		CreatorID: userA,
		MemberIDs: []uuid.UUID{userA, userB, userC},
	}
	conv, err := svc.CreateConversation(ctx, createReq)
	require.NoError(t, err)

	// 5. User A sends a message
	t.Log("用户 A 发送消息...")
	msgReq1 := service.SendMessageRequest{
		ConversationID: conv.ID,
		SenderID:       userA,
		Content:        "Hello Group - Message 1",
		MessageType:    model.MessageTypeText,
	}
	msg1, err := svc.SendMessage(ctx, msgReq1)
	require.NoError(t, err)
	
	// 确保时间推进
	time.Sleep(100 * time.Millisecond)

	// 6. Verify Initial Unread Counts
	// B should have 1 unread
	countB, err := svc.GetUnreadCount(ctx, conv.ID, userB)
	assert.NoError(t, err)
	assert.Equal(t, int64(1), countB, "Initial: User B should have 1 unread message")

	// C should have 1 unread
	countC, err := svc.GetUnreadCount(ctx, conv.ID, userC)
	assert.NoError(t, err)
	assert.Equal(t, int64(1), countC, "Initial: User C should have 1 unread message")

	// 7. User B reads the message
	t.Log("用户 B 阅读消息...")
	receipt, err := svc.MarkMessageAsRead(ctx, msg1.ID, userB)
	assert.NoError(t, err)
	assert.NotNil(t, receipt)

	// 8. Verify Unread Counts After B Reads
	// B should now have 0 unread
	countB, err = svc.GetUnreadCount(ctx, conv.ID, userB)
	assert.NoError(t, err)
	assert.Equal(t, int64(0), countB, "After Read: User B should have 0 unread messages")

	// C should STILL have 1 unread (CRITICAL CHECK for Cursor Logic)
	// If logic was broken (using shared ReadAt field), C would also see it as read (0 unread).
	countC, err = svc.GetUnreadCount(ctx, conv.ID, userC)
	assert.NoError(t, err)
	assert.Equal(t, int64(1), countC, "After Read: User C should still have 1 unread message")

	// 9. User A sends another message
	t.Log("用户 A 发送第二条消息...")
	msgReq2 := service.SendMessageRequest{
		ConversationID: conv.ID,
		SenderID:       userA,
		Content:        "Hello Group - Message 2",
	}
	msg2, err := svc.SendMessage(ctx, msgReq2)
	require.NoError(t, err)

	// B should have 1 unread (msg2)
	countB, err = svc.GetUnreadCount(ctx, conv.ID, userB)
	assert.NoError(t, err)
	assert.Equal(t, int64(1), countB, "Msg2: User B should have 1 unread message")

	// C should have 2 unread (msg1, msg2)
	countC, err = svc.GetUnreadCount(ctx, conv.ID, userC)
	assert.NoError(t, err)
	assert.Equal(t, int64(2), countC, "Msg2: User C should have 2 unread messages")

	// 10. Test MarkMessagesUpToAsRead for C (Read up to msg2)
	t.Log("用户 C 标记到最新消息已读...")
	batchReceipt, err := svc.MarkMessagesUpToAsRead(ctx, conv.ID, userC, msg2.ID)
	assert.NoError(t, err)
	assert.NotNil(t, batchReceipt)
	
	// C should now have 0 unread
	countC, err = svc.GetUnreadCount(ctx, conv.ID, userC)
	assert.NoError(t, err)
	assert.Equal(t, int64(0), countC, "Final: User C should have 0 unread messages")

	t.Log("Cursor Logic Test Passed!")
}
