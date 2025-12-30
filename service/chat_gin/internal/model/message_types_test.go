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
		want int
	}{
		{"text", MessageTypeText, 0},
		{"image", MessageTypeImage, 1},
		{"video", MessageTypeVideo, 2},
		{"link", MessageTypeLink, 3},
		{"file", MessageTypeFile, 4},
		{"system", MessageTypeSystem, 9},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if int(tt.mt) != tt.want {
				t.Errorf("MessageType = %v, want %v", tt.mt, tt.want)
			}
		})
	}
}

func TestMessage_Fields(t *testing.T) {
	dialogID := uuid.New()
	senderID := uuid.New()
	now := time.Now()

	msg := Message{
		ID:        1,
		LocalID:   100,
		DialogID:  dialogID,
		SenderID:  senderID,
		Content:   "Test content",
		MsgType:   MessageTypeText,
		Date:      now,
		IsUnread:  true,
		IsOutgoing: true,
	}

	if msg.ID != 1 {
		t.Errorf("ID = %v, want 1", msg.ID)
	}
	if msg.LocalID != 100 {
		t.Errorf("LocalID = %v, want 100", msg.LocalID)
	}
	if msg.DialogID != dialogID {
		t.Errorf("DialogID = %v, want %v", msg.DialogID, dialogID)
	}
	if msg.SenderID != senderID {
		t.Errorf("SenderID = %v, want %v", msg.SenderID, senderID)
	}
	if msg.Content != "Test content" {
		t.Errorf("Content = %v, want 'Test content'", msg.Content)
	}
	if msg.MsgType != MessageTypeText {
		t.Errorf("MsgType = %v, want %v", msg.MsgType, MessageTypeText)
	}
	if !msg.IsUnread {
		t.Error("IsUnread should be true")
	}
	if !msg.IsOutgoing {
		t.Error("IsOutgoing should be true")
	}
}

func TestMessage_IsValid_AllTypes(t *testing.T) {
	baseMsg := func() Message {
		return Message{
			DialogID: uuid.New(),
			SenderID: uuid.New(),
			Content:  "Test",
			MsgType:  MessageTypeText,
		}
	}

	tests := []struct {
		name    string
		modify  func(*Message)
		isValid bool
	}{
		{"valid text", func(m *Message) { m.MsgType = MessageTypeText }, true},
		{"valid image", func(m *Message) { m.MsgType = MessageTypeImage }, true},
		{"valid file", func(m *Message) { m.MsgType = MessageTypeFile }, true},
		{"valid system", func(m *Message) { m.MsgType = MessageTypeSystem }, true},
		{"invalid nil dialog", func(m *Message) { m.DialogID = uuid.Nil }, false},
		{"invalid nil sender", func(m *Message) { m.SenderID = uuid.Nil }, false},
		{"invalid empty content no media", func(m *Message) { m.Content = ""; m.MediaInfo = nil }, false},
		{"valid empty content with media", func(m *Message) { m.Content = ""; m.MediaInfo = map[string]interface{}{"url": "test"} }, true},
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
	dialogID := uuid.New()
	senderID := uuid.New()
	msgType := MessageTypeText
	before := time.Now()
	after := time.Now().Add(-time.Hour)

	filter := MessageFilter{
		DialogID: &dialogID,
		SenderID: &senderID,
		MsgType:  &msgType,
		Before:   &before,
		After:    &after,
	}

	if *filter.DialogID != dialogID {
		t.Errorf("DialogID = %v, want %v", *filter.DialogID, dialogID)
	}
	if *filter.SenderID != senderID {
		t.Errorf("SenderID = %v, want %v", *filter.SenderID, senderID)
	}
	if *filter.MsgType != msgType {
		t.Errorf("MsgType = %v, want %v", *filter.MsgType, msgType)
	}
	if filter.Before == nil || filter.After == nil {
		t.Error("Before and After should not be nil")
	}
}

func TestMessageFilter_NilFields(t *testing.T) {
	filter := MessageFilter{}

	if filter.DialogID != nil {
		t.Error("DialogID should be nil")
	}
	if filter.SenderID != nil {
		t.Error("SenderID should be nil")
	}
	if filter.MsgType != nil {
		t.Error("MsgType should be nil")
	}
	if filter.Before != nil {
		t.Error("Before should be nil")
	}
	if filter.After != nil {
		t.Error("After should be nil")
	}
}
