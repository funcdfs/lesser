package model

import (
	"time"

	"github.com/google/uuid"
)

// ReadReceipt 已读回执
// 用于记录单条消息的已读状态并通知发送者
type ReadReceipt struct {
	MessageID      uuid.UUID `json:"message_id"`
	ConversationID uuid.UUID `json:"conversation_id"`
	ReaderID       uuid.UUID `json:"reader_id"`
	ReadAt         time.Time `json:"read_at"`
}

// BatchReadReceipt 批量已读回执
// 用于记录多条消息同时被标记为已读的情况
type BatchReadReceipt struct {
	ConversationID uuid.UUID   `json:"conversation_id"`
	ReaderID       uuid.UUID   `json:"reader_id"`
	MessageIDs     []uuid.UUID `json:"message_ids"`
	ReadAt         time.Time   `json:"read_at"`
}
