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
				ConversationID: uuid.New(),
				SenderID:       uuid.New(),
				Content:        "Hello, world!",
				MessageType:    MessageTypeText,
			},
			want: true,
		},
		{
			name: "nil conversation ID",
			msg: Message{
				ConversationID: uuid.Nil,
				SenderID:       uuid.New(),
				Content:        "Hello",
				MessageType:    MessageTypeText,
			},
			want: false,
		},
		{
			name: "nil sender ID",
			msg: Message{
				ConversationID: uuid.New(),
				SenderID:       uuid.Nil,
				Content:        "Hello",
				MessageType:    MessageTypeText,
			},
			want: false,
		},
		{
			name: "empty content",
			msg: Message{
				ConversationID: uuid.New(),
				SenderID:       uuid.New(),
				Content:        "",
				MessageType:    MessageTypeText,
			},
			want: false,
		},
		{
			name: "empty message type",
			msg: Message{
				ConversationID: uuid.New(),
				SenderID:       uuid.New(),
				Content:        "Hello",
				MessageType:    "",
			},
			want: false,
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
	// Verify message type constants are defined correctly
	if MessageTypeText != "text" {
		t.Errorf("MessageTypeText = %v, want text", MessageTypeText)
	}
	if MessageTypeImage != "image" {
		t.Errorf("MessageTypeImage = %v, want image", MessageTypeImage)
	}
	if MessageTypeFile != "file" {
		t.Errorf("MessageTypeFile = %v, want file", MessageTypeFile)
	}
	if MessageTypeSystem != "system" {
		t.Errorf("MessageTypeSystem = %v, want system", MessageTypeSystem)
	}
}
