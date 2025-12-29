package model

import (
	"testing"
	"time"

	"github.com/google/uuid"
)

func TestMessageType_Values(t *testing.T) {
	tests := []struct {
		name string
		mt   MessageType
		want string
	}{
		{"text", MessageTypeText, "text"},
		{"image", MessageTypeImage, "image"},
		{"file", MessageTypeFile, "file"},
		{"system", MessageTypeSystem, "system"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if string(tt.mt) != tt.want {
				t.Errorf("MessageType = %v, want %v", tt.mt, tt.want)
			}
		})
	}
}

func TestMessage_Fields(t *testing.T) {
	msgID := uuid.New()
	convID := uuid.New()
	senderID := uuid.New()
	now := time.Now()
	readAt := now.Add(time.Hour)

	msg := Message{
		ID:             msgID,
		ConversationID: convID,
		SenderID:       senderID,
		Content:        "Test content",
		MessageType:    MessageTypeText,
		CreatedAt:      now,
		ReadAt:         &readAt,
		Metadata:       map[string]interface{}{"key": "value"},
	}

	if msg.ID != msgID {
		t.Errorf("ID = %v, want %v", msg.ID, msgID)
	}
	if msg.ConversationID != convID {
		t.Errorf("ConversationID = %v, want %v", msg.ConversationID, convID)
	}
	if msg.SenderID != senderID {
		t.Errorf("SenderID = %v, want %v", msg.SenderID, senderID)
	}
	if msg.Content != "Test content" {
		t.Errorf("Content = %v, want 'Test content'", msg.Content)
	}
	if msg.MessageType != MessageTypeText {
		t.Errorf("MessageType = %v, want %v", msg.MessageType, MessageTypeText)
	}
	if msg.ReadAt == nil {
		t.Error("ReadAt should not be nil")
	}
	if msg.Metadata["key"] != "value" {
		t.Errorf("Metadata[key] = %v, want 'value'", msg.Metadata["key"])
	}
}

func TestMessage_IsValid_AllTypes(t *testing.T) {
	baseMsg := func() Message {
		return Message{
			ConversationID: uuid.New(),
			SenderID:       uuid.New(),
			Content:        "Test",
			MessageType:    MessageTypeText,
		}
	}

	tests := []struct {
		name    string
		modify  func(*Message)
		isValid bool
	}{
		{"valid text", func(m *Message) { m.MessageType = MessageTypeText }, true},
		{"valid image", func(m *Message) { m.MessageType = MessageTypeImage }, true},
		{"valid file", func(m *Message) { m.MessageType = MessageTypeFile }, true},
		{"valid system", func(m *Message) { m.MessageType = MessageTypeSystem }, true},
		{"invalid empty type", func(m *Message) { m.MessageType = "" }, false},
		{"invalid nil conv", func(m *Message) { m.ConversationID = uuid.Nil }, false},
		{"invalid nil sender", func(m *Message) { m.SenderID = uuid.Nil }, false},
		{"invalid empty content", func(m *Message) { m.Content = "" }, false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			msg := baseMsg()
			tt.modify(&msg)
			if got := msg.IsValid(); got != tt.isValid {
				t.Errorf("IsValid() = %v, want %v", got, tt.isValid)
			}
		})
	}
}

func TestMessageFilter_Fields(t *testing.T) {
	convID := uuid.New()
	senderID := uuid.New()
	msgType := MessageTypeText
	before := time.Now()
	after := time.Now().Add(-time.Hour)

	filter := MessageFilter{
		ConversationID: convID,
		SenderID:       &senderID,
		MessageType:    &msgType,
		Before:         &before,
		After:          &after,
	}

	if filter.ConversationID != convID {
		t.Errorf("ConversationID = %v, want %v", filter.ConversationID, convID)
	}
	if *filter.SenderID != senderID {
		t.Errorf("SenderID = %v, want %v", *filter.SenderID, senderID)
	}
	if *filter.MessageType != msgType {
		t.Errorf("MessageType = %v, want %v", *filter.MessageType, msgType)
	}
	if filter.Before == nil || filter.After == nil {
		t.Error("Before and After should not be nil")
	}
}

func TestMessageFilter_NilFields(t *testing.T) {
	filter := MessageFilter{
		ConversationID: uuid.New(),
	}

	if filter.SenderID != nil {
		t.Error("SenderID should be nil")
	}
	if filter.MessageType != nil {
		t.Error("MessageType should be nil")
	}
	if filter.Before != nil {
		t.Error("Before should be nil")
	}
	if filter.After != nil {
		t.Error("After should be nil")
	}
}
