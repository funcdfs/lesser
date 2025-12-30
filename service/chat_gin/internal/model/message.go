package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// MessageType 消息类型枚举 (改为 int 映射)
type MessageType int

const (
	MessageTypeText   MessageType = 0 // 文本
	MessageTypeImage  MessageType = 1 // 图片
	MessageTypeVideo  MessageType = 2 // 视频
	MessageTypeLink   MessageType = 3 // 链接
	MessageTypeFile   MessageType = 4 // 文件
	MessageTypeSystem MessageType = 9 // 系统消息
)

// Message 消息实体模型 (Telegram 风格)
type Message struct {
	// 基础 ID
	ID      int64 `json:"id" gorm:"primaryKey;autoIncrement"`                   // 消息的全局唯一 ID
	LocalID int32 `json:"local_id" gorm:"type:int;not null;index:idx_local_id"` // 在该会话内的递增 ID

	// 关联 ID
	DialogID uuid.UUID `json:"dialog_id" gorm:"type:uuid;column:dialog_id;not null;index"` // 会话 ID
	SenderID uuid.UUID `json:"sender_id" gorm:"type:uuid;column:sender_id;not null;index"` // 发送者 ID

	// 内容与类型
	Content string      `json:"content" gorm:"type:text"`                      // 消息纯文本内容
	MsgType MessageType `json:"msg_type" gorm:"type:smallint;default:0"`       // 消息类型
	Entities interface{} `json:"entities,omitempty" gorm:"type:jsonb"`    // 格式化信息
	MediaInfo interface{} `json:"media_info,omitempty" gorm:"type:jsonb"` // 媒体详细元数据

	// 引用与回复
	ReplyToID *int64 `json:"reply_to_id,omitempty" gorm:"index"` // 被回复的消息 ID

	// 状态与时间
	Date       time.Time      `json:"date" gorm:"not null;index"`          // 消息发送时间
	EditDate   *time.Time     `json:"edit_date,omitempty"`                 // 最后修改时间
	IsOutgoing bool           `json:"is_outgoing" gorm:"default:true"`     // 是否为发送出去的消息
	IsUnread   bool           `json:"is_unread" gorm:"default:true"`       // 是否未读
	Flags      int32          `json:"flags" gorm:"type:int"`               // 内部状态位掩码
	DeletedAt  gorm.DeletedAt `json:"-" gorm:"index"`                      // 软删除支持
}

// TableName 返回消息表名
func (Message) TableName() string {
	return "chat_messages"
}

// IsValid 检查消息是否有效
func (m *Message) IsValid() bool {
	return m.DialogID != uuid.Nil &&
		m.SenderID != uuid.Nil &&
		(m.Content != "" || m.MediaInfo != nil)
}

// MessageFilter 消息查询过滤器
type MessageFilter struct {
	DialogID *uuid.UUID
	SenderID *uuid.UUID
	MsgType  *MessageType
	Before   *time.Time
	After    *time.Time
}
