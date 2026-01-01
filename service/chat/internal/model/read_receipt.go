package model

import (
	"time"

	"github.com/google/uuid"
)

type ReadReceipt struct {
	MessageID      int64     `json:"message_id"`
	ConversationID uuid.UUID `json:"conversation_id"`
	ReaderID       uuid.UUID `json:"reader_id"`
	ReadAt         time.Time `json:"read_at"`
}

type BatchReadReceipt struct {
	ConversationID uuid.UUID `json:"conversation_id"`
	ReaderID       uuid.UUID `json:"reader_id"`
	MessageIDs     []int64   `json:"message_ids"`
	ReadAt         time.Time `json:"read_at"`
}
