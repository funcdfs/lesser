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

// IsReadByRecipient 判断消息是否已被接收方读取
// 对于发送方：返回 true 表示对方已读我发的消息
// 对于接收方：返回 true 表示我已读这条消息
func (m *Message) IsReadByRecipient() bool {
	return m.ReadAt != nil
}

// IsReadBy 判断消息是否已被指定用户读取
// 如果 userID 是发送者，返回 false（发送者不需要"读"自己的消息）
// 如果 userID 是接收者，返回 ReadAt != nil
func (m *Message) IsReadBy(userID uuid.UUID) bool {
	if m.SenderID == userID {
		return false // 发送者不需要读自己的消息
	}
	return m.ReadAt != nil
}

// NeedsReadReceipt 判断是否需要向发送方发送已读回执
// 当消息被接收方读取时，需要通知发送方
func (m *Message) NeedsReadReceipt(readerID uuid.UUID) bool {
	return m.SenderID != readerID && m.ReadAt != nil
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
