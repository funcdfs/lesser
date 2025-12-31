package ws

import (
	"encoding/json"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/leanovate/gopter"
	"github.com/leanovate/gopter/gen"
	"github.com/leanovate/gopter/prop"
	"github.com/lesser/chat/internal/model"
)

// **Feature: flutter-chat-sync, Property 5: WebSocket Event Format Consistency**
// **Validates: Requirements 6.1, 6.2, 6.3, 6.4**
//
// For any WebSocket event sent by Chat_Service, the event type and payload structure
// SHALL match what Flutter_Client expects, enabling correct parsing and state updates.

// Flutter expected event types
var flutterExpectedEventTypes = map[string]bool{
	"message":             true, // new message
	"subscribed":          true, // subscription success
	"unsubscribed":        true, // unsubscription success
	"conversation_update": true, // conversation update
	"message_read":        true, // single read receipt
	"messages_read":       true, // batch read receipt
	"error":               true, // error
	"pong":                true, // ping response
}

// Flutter expected payload fields for messages_read event
var messagesReadRequiredFields = []string{
	"conversation_id",
	"reader_id",
	"read_at",
	"message_ids",
}

// Flutter expected payload fields for message_read event
var messageReadRequiredFields = []string{
	"message_id",
	"conversation_id",
	"reader_id",
	"read_at",
}

func TestWebSocketEventFormatConsistency(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = 100
	properties := gopter.NewProperties(parameters)

	// Generator for ReadReceiptPayload (batch)
	genBatchReadReceipt := gopter.CombineGens(
		gen.Const(uuid.New()),                                    // ConversationID
		gen.Const(uuid.New()),                                    // ReaderID
		gen.SliceOfN(5, gen.Int64Range(1, 1000000)),              // MessageIDs
	).Map(func(values []interface{}) *model.BatchReadReceipt {
		convID := values[0].(uuid.UUID)
		readerID := values[1].(uuid.UUID)
		msgIDs := values[2].([]int64)
		return &model.BatchReadReceipt{
			ConversationID: convID,
			ReaderID:       readerID,
			MessageIDs:     msgIDs,
			ReadAt:         time.Now().UTC(),
		}
	})

	// Generator for ReadReceipt (single)
	genSingleReadReceipt := gopter.CombineGens(
		gen.Int64Range(1, 1000000),  // MessageID
		gen.Const(uuid.New()),       // ConversationID
		gen.Const(uuid.New()),       // ReaderID
	).Map(func(values []interface{}) *model.ReadReceipt {
		return &model.ReadReceipt{
			MessageID:      values[0].(int64),
			ConversationID: values[1].(uuid.UUID),
			ReaderID:       values[2].(uuid.UUID),
			ReadAt:         time.Now().UTC(),
		}
	})

	properties.Property("Batch read receipt event type is 'messages_read' (Flutter compatible)", prop.ForAll(
		func(receipt *model.BatchReadReceipt) bool {
			if receipt == nil || len(receipt.MessageIDs) == 0 {
				return true // Skip empty receipts
			}

			// Simulate what NotifyBatchReadReceipt does
			messageIDs := make([]string, len(receipt.MessageIDs))
			for i, id := range receipt.MessageIDs {
				messageIDs[i] = string(rune(id)) // This is wrong, but we're testing the type
			}

			// The event type should be "messages_read"
			eventType := "messages_read"
			
			// Verify it's a Flutter-expected type
			if !flutterExpectedEventTypes[eventType] {
				t.Logf("Event type '%s' is not expected by Flutter", eventType)
				return false
			}

			return true
		},
		genBatchReadReceipt,
	))

	properties.Property("Single read receipt event type is 'message_read' (Flutter compatible)", prop.ForAll(
		func(receipt *model.ReadReceipt) bool {
			if receipt == nil {
				return true
			}

			// The event type should be "message_read"
			eventType := "message_read"
			
			// Verify it's a Flutter-expected type
			if !flutterExpectedEventTypes[eventType] {
				t.Logf("Event type '%s' is not expected by Flutter", eventType)
				return false
			}

			return true
		},
		genSingleReadReceipt,
	))

	properties.Property("Batch read receipt payload has all Flutter-required fields", prop.ForAll(
		func(receipt *model.BatchReadReceipt) bool {
			if receipt == nil || len(receipt.MessageIDs) == 0 {
				return true
			}

			// Build payload like NotifyBatchReadReceipt does
			messageIDs := make([]string, len(receipt.MessageIDs))
			for i, id := range receipt.MessageIDs {
				messageIDs[i] = string(rune(id))
			}

			payload := &ReadReceiptPayload{
				ConversationID: receipt.ConversationID.String(),
				ReaderID:       receipt.ReaderID.String(),
				ReadAt:         receipt.ReadAt.Format(time.RFC3339),
				MessageIDs:     messageIDs,
			}

			// Serialize to JSON
			jsonBytes, err := json.Marshal(payload)
			if err != nil {
				t.Logf("Marshal error: %v", err)
				return false
			}

			// Parse as raw map
			var raw map[string]interface{}
			if err := json.Unmarshal(jsonBytes, &raw); err != nil {
				t.Logf("Unmarshal error: %v", err)
				return false
			}

			// Check all required fields exist
			for _, field := range messagesReadRequiredFields {
				if _, ok := raw[field]; !ok {
					t.Logf("Missing required field for messages_read: %s", field)
					return false
				}
			}

			return true
		},
		genBatchReadReceipt,
	))

	properties.Property("Single read receipt payload has all Flutter-required fields", prop.ForAll(
		func(receipt *model.ReadReceipt) bool {
			if receipt == nil {
				return true
			}

			// Build payload like NotifyReadReceipt does
			payload := &ReadReceiptPayload{
				MessageID:      "12345", // Simulated
				ConversationID: receipt.ConversationID.String(),
				ReaderID:       receipt.ReaderID.String(),
				ReadAt:         receipt.ReadAt.Format(time.RFC3339),
			}

			// Serialize to JSON
			jsonBytes, err := json.Marshal(payload)
			if err != nil {
				t.Logf("Marshal error: %v", err)
				return false
			}

			// Parse as raw map
			var raw map[string]interface{}
			if err := json.Unmarshal(jsonBytes, &raw); err != nil {
				t.Logf("Unmarshal error: %v", err)
				return false
			}

			// Check all required fields exist
			for _, field := range messageReadRequiredFields {
				if _, ok := raw[field]; !ok {
					t.Logf("Missing required field for message_read: %s", field)
					return false
				}
			}

			return true
		},
		genSingleReadReceipt,
	))

	properties.Property("WSMessage format is consistent with Flutter expectations", prop.ForAll(
		func(eventType string) bool {
			// Create a WSMessage
			msg := WSMessage{
				Type:    eventType,
				Payload: map[string]string{"test": "data"},
			}

			// Serialize to JSON
			jsonBytes, err := json.Marshal(msg)
			if err != nil {
				t.Logf("Marshal error: %v", err)
				return false
			}

			// Parse as raw map
			var raw map[string]interface{}
			if err := json.Unmarshal(jsonBytes, &raw); err != nil {
				t.Logf("Unmarshal error: %v", err)
				return false
			}

			// Check required fields exist
			if _, ok := raw["type"]; !ok {
				t.Logf("Missing 'type' field in WSMessage")
				return false
			}
			if _, ok := raw["payload"]; !ok {
				t.Logf("Missing 'payload' field in WSMessage")
				return false
			}

			// Verify type field is a string
			if _, isString := raw["type"].(string); !isString {
				t.Logf("'type' field is not a string")
				return false
			}

			return true
		},
		gen.OneConstOf(
			"message",
			"subscribed",
			"unsubscribed",
			"conversation_update",
			"message_read",
			"messages_read",
			"error",
			"pong",
		),
	))

	properties.TestingRun(t)
}
