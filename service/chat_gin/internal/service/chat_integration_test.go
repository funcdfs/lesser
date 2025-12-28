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

// TestChatIntegration tests the complete chat flow between two users.
// This test requires a running PostgreSQL and Redis instance.
// Run with: go test -tags=integration ./internal/service/...
//
// Feature: chat-integration-demo
// Property 1: Message Round-Trip Integrity
// Property 2: Conversation Membership Consistency
// Validates: Requirements 4.1, 4.2, 4.3, 4.4
func TestChatIntegration(t *testing.T) {
	if os.Getenv("INTEGRATION_TEST") != "true" {
		t.Skip("Skipping integration test. Set INTEGRATION_TEST=true to run.")
	}

	// Setup database connection
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		dbURL = "postgres://lesser:lesser_dev_password@localhost:5432/lesser_db?sslmode=disable"
	}

	db, err := database.NewPostgresDB(dbURL)
	require.NoError(t, err, "Failed to connect to database")
	defer db.Close()

	// Setup Redis connection
	redisURL := os.Getenv("REDIS_URL")
	if redisURL == "" {
		redisURL = "redis://localhost:6379/1"
	}

	redisClient, err := cache.NewRedisClient(redisURL)
	if err != nil {
		t.Logf("Warning: Redis not available, some features may not work: %v", err)
		redisClient = nil
	}

	// Create repositories and service
	convRepo := repository.NewConversationRepository(db)
	msgRepo := repository.NewMessageRepository(db)
	chatService := service.NewChatService(convRepo, msgRepo, redisClient)

	ctx := context.Background()

	// Generate test user IDs (in real scenario, these would come from Django)
	test1ID := uuid.New()
	test2ID := uuid.New()

	t.Logf("Test User 1 ID: %s", test1ID)
	t.Logf("Test User 2 ID: %s", test2ID)

	// Test 1: Create private conversation
	// Property 2: Conversation Membership Consistency
	t.Run("CreatePrivateConversation", func(t *testing.T) {
		conv, err := chatService.CreateConversation(ctx, service.CreateConversationRequest{
			Type:      model.ConversationTypePrivate,
			MemberIDs: []uuid.UUID{test1ID, test2ID},
			CreatorID: test1ID,
		})
		require.NoError(t, err, "Failed to create conversation")
		require.NotNil(t, conv, "Conversation should not be nil")

		// Verify conversation properties
		assert.Equal(t, model.ConversationTypePrivate, conv.Type, "Conversation type should be private")
		assert.Equal(t, test1ID, conv.CreatorID, "Creator ID should match")
		assert.Len(t, conv.Members, 2, "Private conversation should have exactly 2 members")

		// Verify both users are members
		memberIDs := make(map[uuid.UUID]bool)
		for _, m := range conv.Members {
			memberIDs[m.UserID] = true
		}
		assert.True(t, memberIDs[test1ID], "test1 should be a member")
		assert.True(t, memberIDs[test2ID], "test2 should be a member")

		// Store conversation ID for subsequent tests
		t.Logf("Created conversation ID: %s", conv.ID)
	})

	// Test 2: Send messages and verify round-trip integrity
	// Property 1: Message Round-Trip Integrity
	t.Run("MessageRoundTrip", func(t *testing.T) {
		// First create a conversation
		conv, err := chatService.CreateConversation(ctx, service.CreateConversationRequest{
			Type:      model.ConversationTypePrivate,
			MemberIDs: []uuid.UUID{test1ID, test2ID},
			CreatorID: test1ID,
		})
		require.NoError(t, err)

		// Test messages with various content
		testMessages := []struct {
			senderID uuid.UUID
			content  string
		}{
			{test1ID, "Hello from test1!"},
			{test2ID, "Hello from test2!"},
			{test1ID, "How are you?"},
			{test2ID, "I'm doing great, thanks!"},
			{test1ID, "Special chars: 你好世界 🎉 émojis"},
		}

		// Send all messages
		sentMessages := make([]*model.Message, len(testMessages))
		for i, tm := range testMessages {
			msg, err := chatService.SendMessage(ctx, service.SendMessageRequest{
				ConversationID: conv.ID,
				SenderID:       tm.senderID,
				Content:        tm.content,
				MessageType:    model.MessageTypeText,
			})
			require.NoError(t, err, "Failed to send message %d", i)
			require.NotNil(t, msg, "Message should not be nil")
			assert.NotEqual(t, uuid.Nil, msg.ID, "Message should have a valid ID")
			assert.Equal(t, tm.content, msg.Content, "Message content should match")
			sentMessages[i] = msg
		}

		// Retrieve messages and verify integrity
		result, err := chatService.GetMessages(ctx, conv.ID, test1ID, 1, 50)
		require.NoError(t, err, "Failed to get messages")
		assert.Equal(t, int64(len(testMessages)), result.Total, "Total message count should match")

		// Verify all sent messages are retrieved with correct content
		retrievedContents := make(map[string]bool)
		for _, msg := range result.Messages {
			retrievedContents[msg.Content] = true
		}

		for _, tm := range testMessages {
			assert.True(t, retrievedContents[tm.content],
				"Message content '%s' should be in retrieved messages", tm.content)
		}
	})

	// Test 3: Verify conversation retrieval
	t.Run("GetConversation", func(t *testing.T) {
		// Create a conversation
		conv, err := chatService.CreateConversation(ctx, service.CreateConversationRequest{
			Type:      model.ConversationTypePrivate,
			MemberIDs: []uuid.UUID{test1ID, test2ID},
			CreatorID: test1ID,
		})
		require.NoError(t, err)

		// Retrieve the conversation
		retrieved, err := chatService.GetConversation(ctx, conv.ID)
		require.NoError(t, err)
		assert.Equal(t, conv.ID, retrieved.ID)
		assert.Equal(t, conv.Type, retrieved.Type)
	})

	// Test 4: Verify user conversations list
	t.Run("GetUserConversations", func(t *testing.T) {
		// Create multiple conversations
		for i := 0; i < 3; i++ {
			otherUser := uuid.New()
			_, err := chatService.CreateConversation(ctx, service.CreateConversationRequest{
				Type:      model.ConversationTypePrivate,
				MemberIDs: []uuid.UUID{test1ID, otherUser},
				CreatorID: test1ID,
			})
			require.NoError(t, err)
		}

		// Get user's conversations
		result, err := chatService.GetUserConversations(ctx, test1ID, 1, 20)
		require.NoError(t, err)
		assert.GreaterOrEqual(t, len(result.Conversations), 3,
			"User should have at least 3 conversations")
	})

	// Test 5: Non-member cannot send messages
	t.Run("NonMemberCannotSendMessage", func(t *testing.T) {
		// Create a conversation between test1 and test2
		conv, err := chatService.CreateConversation(ctx, service.CreateConversationRequest{
			Type:      model.ConversationTypePrivate,
			MemberIDs: []uuid.UUID{test1ID, test2ID},
			CreatorID: test1ID,
		})
		require.NoError(t, err)

		// Try to send message as non-member
		nonMember := uuid.New()
		_, err = chatService.SendMessage(ctx, service.SendMessageRequest{
			ConversationID: conv.ID,
			SenderID:       nonMember,
			Content:        "I shouldn't be able to send this",
			MessageType:    model.MessageTypeText,
		})
		assert.Error(t, err, "Non-member should not be able to send messages")
		assert.Equal(t, service.ErrNotMember, err)
	})
}

// TestMessageContentIntegrity is a property-based test for message content integrity.
// Feature: chat-integration-demo, Property 1: Message Round-Trip Integrity
// Validates: Requirements 4.2, 4.3, 4.4
func TestMessageContentIntegrity(t *testing.T) {
	if os.Getenv("INTEGRATION_TEST") != "true" {
		t.Skip("Skipping integration test. Set INTEGRATION_TEST=true to run.")
	}

	// Setup (same as above)
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		dbURL = "postgres://lesser:lesser_dev_password@localhost:5432/lesser_db?sslmode=disable"
	}

	db, err := database.NewPostgresDB(dbURL)
	require.NoError(t, err)
	defer db.Close()

	convRepo := repository.NewConversationRepository(db)
	msgRepo := repository.NewMessageRepository(db)
	chatService := service.NewChatService(convRepo, msgRepo, nil)

	ctx := context.Background()
	test1ID := uuid.New()
	test2ID := uuid.New()

	// Create conversation
	conv, err := chatService.CreateConversation(ctx, service.CreateConversationRequest{
		Type:      model.ConversationTypePrivate,
		MemberIDs: []uuid.UUID{test1ID, test2ID},
		CreatorID: test1ID,
	})
	require.NoError(t, err)

	// Property: For any message content, send then retrieve should return identical content
	testContents := []string{
		"Simple text",
		"Text with numbers 12345",
		"Special chars: !@#$%^&*()",
		"Unicode: 你好世界 🎉 émojis 日本語",
		"Newlines:\nLine 1\nLine 2",
		"Tabs:\tTab1\tTab2",
		"Long text: " + string(make([]byte, 1000)),
		"Empty-ish:    ",
	}

	for _, content := range testContents {
		if content == "" {
			continue // Skip empty content as it's invalid
		}

		t.Run("Content_"+content[:min(20, len(content))], func(t *testing.T) {
			// Send message
			sent, err := chatService.SendMessage(ctx, service.SendMessageRequest{
				ConversationID: conv.ID,
				SenderID:       test1ID,
				Content:        content,
				MessageType:    model.MessageTypeText,
			})
			require.NoError(t, err)

			// Small delay to ensure persistence
			time.Sleep(10 * time.Millisecond)

			// Retrieve and verify
			result, err := chatService.GetMessages(ctx, conv.ID, test1ID, 1, 100)
			require.NoError(t, err)

			found := false
			for _, msg := range result.Messages {
				if msg.ID == sent.ID {
					assert.Equal(t, content, msg.Content,
						"Retrieved content should match sent content")
					found = true
					break
				}
			}
			assert.True(t, found, "Sent message should be found in retrieved messages")
		})
	}
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
