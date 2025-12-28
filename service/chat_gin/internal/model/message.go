package model

import (
	"time"

	"github.com/google/uuid"
)

// MessageType represents the type of message
type MessageType string

const (
	MessageTypeText  MessageType = "text"
	MessageTypeImage MessageType = "image"
	MessageTypeFile  MessageType = "file"
	MessageTypeSystem MessageType = "system"
)

// Message represents a chat message
type Message struct {
	ID             uuid.UUID   `json:"id" gorm:"type:uuid;primary_key;default:gen_random_uuid()"`
	ConversationID uuid.UUID   `json:"conversation_id" gorm:"type:uuid;not null;index"`
	SenderID       uuid.UUID   `json:"sender_id" gorm:"type:uuid;not null;index"`
	Content        string      `json:"content" gorm:"type:text;not null"`
	MessageType    MessageType `json:"message_type" gorm:"type:varchar(20);not null;default:'text'"`
	CreatedAt      time.Time   `json:"created_at" gorm:"autoCreateTime;index"`

	// Optional metadata for different message types
	Metadata map[string]interface{} `json:"metadata,omitempty" gorm:"type:jsonb"`
}

// TableName returns the table name for Message
func (Message) TableName() string {
	return "chat_messages"
}

// IsValid checks if the message is valid
func (m *Message) IsValid() bool {
	return m.ConversationID != uuid.Nil &&
		m.SenderID != uuid.Nil &&
		m.Content != "" &&
		m.MessageType != ""
}

// MessageFilter represents filters for querying messages
type MessageFilter struct {
	ConversationID uuid.UUID
	SenderID       *uuid.UUID
	MessageType    *MessageType
	Before         *time.Time
	After          *time.Time
}
