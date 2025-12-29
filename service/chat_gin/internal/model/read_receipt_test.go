package model

import (
	"testing"
	"time"

	"github.com/google/uuid"
)

func TestMessage_IsReadByRecipient(t *testing.T) {
	now := time.Now()

	tests := []struct {
		name   string
		readAt *time.Time
		want   bool
	}{
		{"unread", nil, false},
		{"read", &now, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			msg := &Message{ReadAt: tt.readAt}
			if got := msg.IsReadByRecipient(); got != tt.want {
				t.Errorf("IsReadByRecipient() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestMessage_IsReadBy(t *testing.T) {
	senderID := uuid.New()
	readerID := uuid.New()
	now := time.Now()

	tests := []struct {
		name   string
		msg    *Message
		userID uuid.UUID
		want   bool
	}{
		{
			name:   "sender checking own message",
			msg:    &Message{SenderID: senderID, ReadAt: &now},
			userID: senderID,
			want:   false,
		},
		{
			name:   "reader checking unread message",
			msg:    &Message{SenderID: senderID, ReadAt: nil},
			userID: readerID,
			want:   false,
		},
		{
			name:   "reader checking read message",
			msg:    &Message{SenderID: senderID, ReadAt: &now},
			userID: readerID,
			want:   true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := tt.msg.IsReadBy(tt.userID); got != tt.want {
				t.Errorf("IsReadBy() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestMessage_NeedsReadReceipt(t *testing.T) {
	senderID := uuid.New()
	readerID := uuid.New()
	now := time.Now()

	tests := []struct {
		name     string
		msg      *Message
		readerID uuid.UUID
		want     bool
	}{
		{
			name:     "sender reading own message",
			msg:      &Message{SenderID: senderID, ReadAt: &now},
			readerID: senderID,
			want:     false,
		},
		{
			name:     "reader reading unread message",
			msg:      &Message{SenderID: senderID, ReadAt: nil},
			readerID: readerID,
			want:     false,
		},
		{
			name:     "reader reading read message",
			msg:      &Message{SenderID: senderID, ReadAt: &now},
			readerID: readerID,
			want:     true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := tt.msg.NeedsReadReceipt(tt.readerID); got != tt.want {
				t.Errorf("NeedsReadReceipt() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestReadReceipt(t *testing.T) {
	msgID := uuid.New()
	convID := uuid.New()
	readerID := uuid.New()
	now := time.Now()

	receipt := &ReadReceipt{
		MessageID:      msgID,
		ConversationID: convID,
		ReaderID:       readerID,
		ReadAt:         now,
	}

	if receipt.MessageID != msgID {
		t.Errorf("ReadReceipt.MessageID = %v, want %v", receipt.MessageID, msgID)
	}
	if receipt.ConversationID != convID {
		t.Errorf("ReadReceipt.ConversationID = %v, want %v", receipt.ConversationID, convID)
	}
	if receipt.ReaderID != readerID {
		t.Errorf("ReadReceipt.ReaderID = %v, want %v", receipt.ReaderID, readerID)
	}
	if !receipt.ReadAt.Equal(now) {
		t.Errorf("ReadReceipt.ReadAt = %v, want %v", receipt.ReadAt, now)
	}
}

func TestBatchReadReceipt(t *testing.T) {
	convID := uuid.New()
	readerID := uuid.New()
	msgIDs := []uuid.UUID{uuid.New(), uuid.New(), uuid.New()}
	now := time.Now()

	receipt := &BatchReadReceipt{
		ConversationID: convID,
		ReaderID:       readerID,
		MessageIDs:     msgIDs,
		ReadAt:         now,
	}

	if receipt.ConversationID != convID {
		t.Errorf("BatchReadReceipt.ConversationID = %v, want %v", receipt.ConversationID, convID)
	}
	if receipt.ReaderID != readerID {
		t.Errorf("BatchReadReceipt.ReaderID = %v, want %v", receipt.ReaderID, readerID)
	}
	if len(receipt.MessageIDs) != 3 {
		t.Errorf("BatchReadReceipt.MessageIDs length = %v, want 3", len(receipt.MessageIDs))
	}
	if !receipt.ReadAt.Equal(now) {
		t.Errorf("BatchReadReceipt.ReadAt = %v, want %v", receipt.ReadAt, now)
	}
}
