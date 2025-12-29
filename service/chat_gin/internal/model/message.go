package model

import (
	"time"

	"github.com/google/uuid"
)

// MessageType 消息类型枚举
type MessageType string

const (
	MessageTypeText   MessageType = "text"   // 文本消息
	MessageTypeImage  MessageType = "image"  // 图片消息
	MessageTypeFile   MessageType = "file"   // 文件消息
	MessageTypeSystem MessageType = "system" // 系统消息
)

// Message 消息实体模型
type Message struct {
	ID             uuid.UUID   `json:"id" gorm:"type:uuid;primary_key;default:gen_random_uuid()"`
	ConversationID uuid.UUID   `json:"conversation_id" gorm:"type:uuid;not null;index"`
	SenderID       uuid.UUID   `json:"sender_id" gorm:"type:uuid;not null;index"`
	Content        string      `json:"content" gorm:"type:text;not null"`
	MessageType    MessageType `json:"message_type" gorm:"type:varchar(20);not null;default:'text'"`
	CreatedAt      time.Time   `json:"created_at" gorm:"autoCreateTime;index"`
	ReadAt         *time.Time  `json:"read_at,omitempty" gorm:"index"` // 已读时间戳，null 表示未读

	// 不同消息类型的可选元数据
	Metadata map[string]interface{} `json:"metadata,omitempty" gorm:"type:jsonb"`
}

// IsRead 判断消息是否已读
// 返回 true 当 read_at 不为 null，返回 false 当 read_at 为 null
func (m *Message) IsRead() bool {
	return m.ReadAt != nil
}

// TableName 返回消息表名
func (Message) TableName() string {
	return "chat_messages"
}

// IsValid 检查消息是否有效
func (m *Message) IsValid() bool {
	return m.ConversationID != uuid.Nil &&
		m.SenderID != uuid.Nil &&
		m.Content != "" &&
		m.MessageType != ""
}

// MessageFilter 消息查询过滤器
type MessageFilter struct {
	ConversationID uuid.UUID
	SenderID       *uuid.UUID
	MessageType    *MessageType
	Before         *time.Time
	After          *time.Time
}
