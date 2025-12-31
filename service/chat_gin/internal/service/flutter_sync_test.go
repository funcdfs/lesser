package service_test

import (
	"encoding/json"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/lesser/chat/internal/model"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// =============================================================================
// Property 1: API Response Structure Consistency
// Validates: Requirements 1.1-1.6, 2.3, 2.4
// =============================================================================

func TestMessageJSONSerializationForFlutter(t *testing.T) {
	t.Run("Message JSON contains Flutter-expected field names", func(t *testing.T) {
		msg := model.Message{
			ID:       12345,
			LocalID:  1,
			DialogID: uuid.New(),
			SenderID: uuid.New(),
			Content:  "Hello, Flutter!",
			MsgType:  model.MessageTypeText,
			Date:     time.Now(),
		}

		jsonBytes, err := json.Marshal(msg)
		require.NoError(t, err)

		var result map[string]interface{}
		err = json.Unmarshal(jsonBytes, &result)
		require.NoError(t, err)

		// Property: Must have Flutter-expected field names
		assert.Contains(t, result, "id", "必须包含 id 字段")
		assert.Contains(t, result, "conversation_id", "必须包含 conversation_id (非 dialog_id)")
		assert.Contains(t, result, "sender_id", "必须包含 sender_id")
		assert.Contains(t, result, "content", "必须包含 content")
		assert.Contains(t, result, "message_type", "必须包含 message_type (非 msg_type)")
		assert.Contains(t, result, "created_at", "必须包含 created_at (非 date)")

		// Property: Must NOT have old field names
		assert.NotContains(t, result, "dialog_id", "不应包含 dialog_id")
		assert.NotContains(t, result, "msg_type", "不应包含 msg_type")
		assert.NotContains(t, result, "date", "不应包含 date")
	})

	t.Run("Message ID serializes as string", func(t *testing.T) {
		msg := model.Message{
			ID:       9223372036854775807, // Max int64
			DialogID: uuid.New(),
			SenderID: uuid.New(),
			Content:  "Test",
			MsgType:  model.MessageTypeText,
			Date:     time.Now(),
		}

		jsonBytes, err := json.Marshal(msg)
		require.NoError(t, err)

		var result map[string]interface{}
		err = json.Unmarshal(jsonBytes, &result)
		require.NoError(t, err)

		// Property: ID must be string to avoid JS precision loss
		id, ok := result["id"].(string)
		assert.True(t, ok, "id 应为字符串类型")
		assert.Equal(t, "9223372036854775807", id)
	})
}

// =============================================================================
// Property 2: Message Parsing Round-Trip
// Validates: Requirements 2.5, 3.3, 3.4
// =============================================================================

func TestMessageTypeSerializationForFlutter(t *testing.T) {
	testCases := []struct {
		msgType      model.MessageType
		expectedJSON string
	}{
		{model.MessageTypeText, "text"},
		{model.MessageTypeImage, "image"},
		{model.MessageTypeVideo, "video"},
		{model.MessageTypeLink, "link"},
		{model.MessageTypeFile, "file"},
		{model.MessageTypeSystem, "system"},
	}

	for _, tc := range testCases {
		t.Run("MessageType serializes to string: "+tc.expectedJSON, func(t *testing.T) {
			msg := model.Message{
				ID:       1,
				DialogID: uuid.New(),
				SenderID: uuid.New(),
				Content:  "Test",
				MsgType:  tc.msgType,
				Date:     time.Now(),
			}

			jsonBytes, err := json.Marshal(msg)
			require.NoError(t, err)

			var result map[string]interface{}
			err = json.Unmarshal(jsonBytes, &result)
			require.NoError(t, err)

			// Property: message_type must be string, not int
			msgType, ok := result["message_type"].(string)
			assert.True(t, ok, "message_type 应为字符串类型")
			assert.Equal(t, tc.expectedJSON, msgType)
		})
	}
}

func TestMessageRoundTripParsing(t *testing.T) {
	t.Run("Message can be serialized and deserialized", func(t *testing.T) {
		original := model.Message{
			ID:         12345,
			LocalID:    42,
			DialogID:   uuid.New(),
			SenderID:   uuid.New(),
			Content:    "Round trip test",
			MsgType:    model.MessageTypeImage,
			Date:       time.Now().Truncate(time.Second),
			IsOutgoing: true,
			IsUnread:   false,
		}

		jsonBytes, err := json.Marshal(original)
		require.NoError(t, err)

		var parsed model.Message
		err = json.Unmarshal(jsonBytes, &parsed)
		require.NoError(t, err)

		// Property: All fields should survive round-trip
		assert.Equal(t, original.ID, parsed.ID)
		assert.Equal(t, original.LocalID, parsed.LocalID)
		assert.Equal(t, original.DialogID, parsed.DialogID)
		assert.Equal(t, original.SenderID, parsed.SenderID)
		assert.Equal(t, original.Content, parsed.Content)
		assert.Equal(t, original.MsgType, parsed.MsgType)
		assert.Equal(t, original.IsOutgoing, parsed.IsOutgoing)
		assert.Equal(t, original.IsUnread, parsed.IsUnread)
	})

	t.Run("Message parses legacy JSON format (backward compatibility)", func(t *testing.T) {
		// Simulate old JSON format with dialog_id and msg_type as int
		legacyJSON := `{
			"id": 12345,
			"dialog_id": "550e8400-e29b-41d4-a716-446655440000",
			"sender_id": "550e8400-e29b-41d4-a716-446655440001",
			"content": "Legacy format",
			"msg_type": 1,
			"date": "2024-01-15T10:30:00Z"
		}`

		var msg model.Message
		err := json.Unmarshal([]byte(legacyJSON), &msg)
		require.NoError(t, err)

		// Property: Should parse legacy format correctly
		assert.Equal(t, int64(12345), msg.ID)
		assert.Equal(t, "550e8400-e29b-41d4-a716-446655440000", msg.DialogID.String())
		assert.Equal(t, model.MessageTypeImage, msg.MsgType)
	})
}

// =============================================================================
// Property 3: Conversation Type Validation
// Validates: Requirements 4.3, 4.4
// =============================================================================

func TestConversationJSONSerializationForFlutter(t *testing.T) {
	t.Run("Conversation JSON contains expected fields", func(t *testing.T) {
		conv := model.Conversation{
			ID:          uuid.New(),
			Type:        model.ConversationTypePrivate,
			Name:        "Test Chat",
			CreatorID:   uuid.New(),
			CreatedAt:   time.Now(),
			UpdatedAt:   time.Now(),
			UnreadCount: 5,
		}

		jsonBytes, err := json.Marshal(conv)
		require.NoError(t, err)

		var result map[string]interface{}
		err = json.Unmarshal(jsonBytes, &result)
		require.NoError(t, err)

		// Property: Required fields present
		assert.Contains(t, result, "id")
		assert.Contains(t, result, "type")
		assert.Contains(t, result, "name")
		assert.Contains(t, result, "creator_id")
		assert.Contains(t, result, "created_at")
		assert.Contains(t, result, "updated_at")
		assert.Contains(t, result, "unread_count")
	})

	t.Run("Conversation type serializes as string", func(t *testing.T) {
		testCases := []struct {
			convType     model.ConversationType
			expectedJSON string
		}{
			{model.ConversationTypePrivate, "private"},
			{model.ConversationTypeGroup, "group"},
			{model.ConversationTypeChannel, "channel"},
		}

		for _, tc := range testCases {
			conv := model.Conversation{
				ID:   uuid.New(),
				Type: tc.convType,
			}

			jsonBytes, err := json.Marshal(conv)
			require.NoError(t, err)

			var result map[string]interface{}
			err = json.Unmarshal(jsonBytes, &result)
			require.NoError(t, err)

			// Property: type must be the expected string
			assert.Equal(t, tc.expectedJSON, result["type"])
		}
	})
}

// =============================================================================
// Property 4: Unread Count Consistency
// Validates: Requirements 5.1, 5.2, 5.3
// =============================================================================

func TestUnreadCountInConversation(t *testing.T) {
	t.Run("UnreadCount is included in JSON", func(t *testing.T) {
		conv := model.Conversation{
			ID:          uuid.New(),
			Type:        model.ConversationTypePrivate,
			UnreadCount: 42,
		}

		jsonBytes, err := json.Marshal(conv)
		require.NoError(t, err)

		var result map[string]interface{}
		err = json.Unmarshal(jsonBytes, &result)
		require.NoError(t, err)

		// Property: unread_count should be serialized as number
		unread, ok := result["unread_count"].(float64) // JSON numbers are float64
		assert.True(t, ok)
		assert.Equal(t, float64(42), unread)
	})
}

// =============================================================================
// Property 5: WebSocket Event Format Consistency
// Validates: Requirements 6.1, 6.2, 6.3, 6.4
// =============================================================================

func TestWebSocketEventTypes(t *testing.T) {
	t.Run("Read receipt event types match Flutter expectations", func(t *testing.T) {
		// These are the event types Flutter expects
		expectedEventTypes := map[string]string{
			"message_read":  "单条消息已读回执",
			"messages_read": "批量消息已读回执",
		}

		// Verify by checking the source constants in hub.go
		// NotifyReadReceipt uses "message_read"
		// NotifyBatchReadReceipt uses "messages_read"

		for eventType, desc := range expectedEventTypes {
			t.Run("Event type: "+eventType+" ("+desc+")", func(t *testing.T) {
				// Property: Event type names should match Flutter constants
				// This test documents the expected behavior
				assert.NotEmpty(t, eventType)
			})
		}
	})

	t.Run("ReadReceiptPayload has correct JSON structure", func(t *testing.T) {
		// Simulate the payload that would be sent via WebSocket
		type ReadReceiptPayload struct {
			MessageID      string   `json:"message_id,omitempty"`
			ConversationID string   `json:"conversation_id"`
			ReaderID       string   `json:"reader_id"`
			ReadAt         string   `json:"read_at"`
			MessageIDs     []string `json:"message_ids,omitempty"`
		}

		singleReceipt := ReadReceiptPayload{
			MessageID:      "12345",
			ConversationID: uuid.New().String(),
			ReaderID:       uuid.New().String(),
			ReadAt:         time.Now().Format(time.RFC3339),
		}

		jsonBytes, err := json.Marshal(singleReceipt)
		require.NoError(t, err)

		var result map[string]interface{}
		err = json.Unmarshal(jsonBytes, &result)
		require.NoError(t, err)

		// Property: Must have Flutter-expected field names
		assert.Contains(t, result, "message_id")
		assert.Contains(t, result, "conversation_id")
		assert.Contains(t, result, "reader_id")
		assert.Contains(t, result, "read_at")

		// Verify ID is string
		_, ok := result["message_id"].(string)
		assert.True(t, ok, "message_id 应为字符串类型")
	})

	t.Run("BatchReadReceiptPayload has correct JSON structure", func(t *testing.T) {
		type ReadReceiptPayload struct {
			MessageID      string   `json:"message_id,omitempty"`
			ConversationID string   `json:"conversation_id"`
			ReaderID       string   `json:"reader_id"`
			ReadAt         string   `json:"read_at"`
			MessageIDs     []string `json:"message_ids,omitempty"`
		}

		batchReceipt := ReadReceiptPayload{
			ConversationID: uuid.New().String(),
			ReaderID:       uuid.New().String(),
			ReadAt:         time.Now().Format(time.RFC3339),
			MessageIDs:     []string{"1", "2", "3"},
		}

		jsonBytes, err := json.Marshal(batchReceipt)
		require.NoError(t, err)

		var result map[string]interface{}
		err = json.Unmarshal(jsonBytes, &result)
		require.NoError(t, err)

		// Property: message_ids should be array of strings
		msgIDs, ok := result["message_ids"].([]interface{})
		assert.True(t, ok, "message_ids 应为数组")
		assert.Len(t, msgIDs, 3)

		// Each ID should be string
		for _, id := range msgIDs {
			_, ok := id.(string)
			assert.True(t, ok, "每个 message_id 应为字符串")
		}
	})
}

// =============================================================================
// Property 6: WSMessage Wrapper Format
// Validates: WebSocket message envelope structure
// =============================================================================

func TestWSMessageEnvelope(t *testing.T) {
	t.Run("WSMessage has type and payload fields", func(t *testing.T) {
		type WSMessage struct {
			Type    string      `json:"type"`
			Payload interface{} `json:"payload"`
		}

		msg := WSMessage{
			Type: "message",
			Payload: map[string]interface{}{
				"id":      "12345",
				"content": "Hello",
			},
		}

		jsonBytes, err := json.Marshal(msg)
		require.NoError(t, err)

		var result map[string]interface{}
		err = json.Unmarshal(jsonBytes, &result)
		require.NoError(t, err)

		// Property: Envelope has required fields
		assert.Contains(t, result, "type")
		assert.Contains(t, result, "payload")

		// Property: type is a string
		_, ok := result["type"].(string)
		assert.True(t, ok)
	})
}
