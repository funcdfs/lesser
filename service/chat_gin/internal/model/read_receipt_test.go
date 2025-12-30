package model

import (
	"testing"
	"time"

	"github.com/google/uuid"
)

func TestReadReceipt(t *testing.T) {
	var msgID int64 = 123
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
	msgIDs := []int64{1, 2, 3}
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
