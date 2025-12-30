package model

import (
	"testing"

	"github.com/google/uuid"
)

func TestMessage_IsValid(t *testing.T) {
	tests := []struct {
		name string
		msg  Message
		want bool
	}{
		{
			name: "valid message",
			msg: Message{
				DialogID: uuid.New(),
				SenderID: uuid.New(),
				Content:  "Hello, world!",
				MsgType:  MessageTypeText,
			},
			want: true,
		},
		{
			name: "nil dialog ID",
			msg: Message{
				DialogID: uuid.Nil,
				SenderID: uuid.New(),
				Content:  "Hello",
				MsgType:  MessageTypeText,
			},
			want: false,
		},
		{
			name: "nil sender ID",
			msg: Message{
				DialogID: uuid.New(),
				SenderID: uuid.Nil,
				Content:  "Hello",
				MsgType:  MessageTypeText,
			},
			want: false,
		},
		{
			name: "empty content no media",
			msg: Message{
				DialogID:  uuid.New(),
				SenderID:  uuid.New(),
				Content:   "",
				MsgType:   MessageTypeText,
				MediaInfo: nil,
			},
			want: false,
		},
		{
			name: "empty content with media",
			msg: Message{
				DialogID:  uuid.New(),
				SenderID:  uuid.New(),
				Content:   "",
				MsgType:   MessageTypeImage,
				MediaInfo: map[string]interface{}{"url": "http://example.com/img.jpg"},
			},
			want: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := tt.msg.IsValid(); got != tt.want {
				t.Errorf("IsValid() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestMessage_TableName(t *testing.T) {
	msg := Message{}
	if got := msg.TableName(); got != "chat_messages" {
		t.Errorf("TableName() = %v, want chat_messages", got)
	}
}

func TestMessageType_Constants(t *testing.T) {
	// Verify message type constants are defined correctly (now int)
	if MessageTypeText != 0 {
		t.Errorf("MessageTypeText = %v, want 0", MessageTypeText)
	}
	if MessageTypeImage != 1 {
		t.Errorf("MessageTypeImage = %v, want 1", MessageTypeImage)
	}
	if MessageTypeVideo != 2 {
		t.Errorf("MessageTypeVideo = %v, want 2", MessageTypeVideo)
	}
	if MessageTypeLink != 3 {
		t.Errorf("MessageTypeLink = %v, want 3", MessageTypeLink)
	}
	if MessageTypeFile != 4 {
		t.Errorf("MessageTypeFile = %v, want 4", MessageTypeFile)
	}
	if MessageTypeSystem != 9 {
		t.Errorf("MessageTypeSystem = %v, want 9", MessageTypeSystem)
	}
}
