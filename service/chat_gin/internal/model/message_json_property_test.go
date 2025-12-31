package model

import (
	"encoding/json"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/leanovate/gopter"
	"github.com/leanovate/gopter/gen"
	"github.com/leanovate/gopter/prop"
)

// **Feature: flutter-chat-sync, Property 2: Message Parsing Round-Trip**
// **Validates: Requirements 2.5, 3.3, 3.4**
//
// For any message created via POST and then retrieved via GET, the Flutter client
// SHALL parse all fields correctly, and the parsed values SHALL match the original
// sent values (content, messageType).

func TestMessageJSONRoundTrip(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = 100
	properties := gopter.NewProperties(parameters)

	// Generator for MessageType
	genMessageType := gen.OneConstOf(
		MessageTypeText,
		MessageTypeImage,
		MessageTypeVideo,
		MessageTypeLink,
		MessageTypeFile,
		MessageTypeSystem,
	)

	// Generator for Message
	genMessage := gopter.CombineGens(
		gen.Int64Range(1, 1000000),           // ID
		gen.Int32Range(1, 10000),             // LocalID
		gen.Const(uuid.New()),                // DialogID
		gen.Const(uuid.New()),                // SenderID
		gen.AlphaString(),                    // Content
		genMessageType,                       // MsgType
	).Map(func(values []interface{}) Message {
		return Message{
			ID:         values[0].(int64),
			LocalID:    values[1].(int32),
			DialogID:   values[2].(uuid.UUID),
			SenderID:   values[3].(uuid.UUID),
			Content:    values[4].(string),
			MsgType:    values[5].(MessageType),
			Date:       time.Now().UTC().Truncate(time.Second),
			IsOutgoing: true,
			IsUnread:   true,
		}
	})

	properties.Property("Message JSON round-trip preserves all fields", prop.ForAll(
		func(original Message) bool {
			// Serialize to JSON
			jsonBytes, err := json.Marshal(original)
			if err != nil {
				t.Logf("Marshal error: %v", err)
				return false
			}

			// Deserialize back
			var parsed Message
			if err := json.Unmarshal(jsonBytes, &parsed); err != nil {
				t.Logf("Unmarshal error: %v", err)
				return false
			}

			// Verify critical fields match
			if original.ID != parsed.ID {
				t.Logf("ID mismatch: %d != %d", original.ID, parsed.ID)
				return false
			}
			if original.LocalID != parsed.LocalID {
				t.Logf("LocalID mismatch: %d != %d", original.LocalID, parsed.LocalID)
				return false
			}
			if original.DialogID != parsed.DialogID {
				t.Logf("DialogID mismatch: %s != %s", original.DialogID, parsed.DialogID)
				return false
			}
			if original.SenderID != parsed.SenderID {
				t.Logf("SenderID mismatch: %s != %s", original.SenderID, parsed.SenderID)
				return false
			}
			if original.Content != parsed.Content {
				t.Logf("Content mismatch: %s != %s", original.Content, parsed.Content)
				return false
			}
			if original.MsgType != parsed.MsgType {
				t.Logf("MsgType mismatch: %d != %d", original.MsgType, parsed.MsgType)
				return false
			}
			if !original.Date.Equal(parsed.Date) {
				t.Logf("Date mismatch: %v != %v", original.Date, parsed.Date)
				return false
			}
			if original.IsOutgoing != parsed.IsOutgoing {
				t.Logf("IsOutgoing mismatch: %v != %v", original.IsOutgoing, parsed.IsOutgoing)
				return false
			}
			if original.IsUnread != parsed.IsUnread {
				t.Logf("IsUnread mismatch: %v != %v", original.IsUnread, parsed.IsUnread)
				return false
			}

			return true
		},
		genMessage,
	))

	properties.Property("Message JSON uses Flutter-compatible field names", prop.ForAll(
		func(original Message) bool {
			jsonBytes, err := json.Marshal(original)
			if err != nil {
				return false
			}

			var raw map[string]interface{}
			if err := json.Unmarshal(jsonBytes, &raw); err != nil {
				return false
			}

			// Check Flutter-expected field names exist
			requiredFields := []string{
				"id",
				"conversation_id",
				"sender_id",
				"content",
				"message_type",
				"created_at",
				"is_outgoing",
				"is_unread",
			}

			for _, field := range requiredFields {
				if _, ok := raw[field]; !ok {
					t.Logf("Missing required field: %s", field)
					return false
				}
			}

			// Check old field names are NOT present
			oldFields := []string{"dialog_id", "date", "msg_type"}
			for _, field := range oldFields {
				if _, ok := raw[field]; ok {
					t.Logf("Old field name still present: %s", field)
					return false
				}
			}

			return true
		},
		genMessage,
	))

	properties.Property("Message ID is serialized as string", prop.ForAll(
		func(id int64) bool {
			msg := Message{
				ID:       id,
				DialogID: uuid.New(),
				SenderID: uuid.New(),
				Content:  "test",
				MsgType:  MessageTypeText,
				Date:     time.Now(),
			}

			jsonBytes, err := json.Marshal(msg)
			if err != nil {
				return false
			}

			var raw map[string]interface{}
			if err := json.Unmarshal(jsonBytes, &raw); err != nil {
				return false
			}

			// ID should be a string
			idVal, ok := raw["id"]
			if !ok {
				return false
			}
			_, isString := idVal.(string)
			return isString
		},
		gen.Int64Range(1, 1000000),
	))

	properties.Property("MessageType is serialized as string", prop.ForAll(
		func(msgType MessageType) bool {
			msg := Message{
				ID:       1,
				DialogID: uuid.New(),
				SenderID: uuid.New(),
				Content:  "test",
				MsgType:  msgType,
				Date:     time.Now(),
			}

			jsonBytes, err := json.Marshal(msg)
			if err != nil {
				return false
			}

			var raw map[string]interface{}
			if err := json.Unmarshal(jsonBytes, &raw); err != nil {
				return false
			}

			// message_type should be a string
			mtVal, ok := raw["message_type"]
			if !ok {
				return false
			}
			mtStr, isString := mtVal.(string)
			if !isString {
				return false
			}

			// Verify it's a valid type string
			validTypes := map[string]bool{
				"text": true, "image": true, "video": true,
				"link": true, "file": true, "system": true,
			}
			return validTypes[mtStr]
		},
		genMessageType,
	))

	properties.TestingRun(t)
}
