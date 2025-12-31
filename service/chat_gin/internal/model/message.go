package model

import (
	"encoding/json"
	"strconv"
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

// String 返回消息类型的字符串表示
func (mt MessageType) String() string {
	switch mt {
	case MessageTypeText:
		return "text"
	case MessageTypeImage:
		return "image"
	case MessageTypeVideo:
		return "video"
	case MessageTypeLink:
		return "link"
	case MessageTypeFile:
		return "file"
	case MessageTypeSystem:
		return "system"
	default:
		return "text"
	}
}

// MarshalJSON 将 MessageType 序列化为 JSON 字符串
func (mt MessageType) MarshalJSON() ([]byte, error) {
	return json.Marshal(mt.String())
}

// UnmarshalJSON 从 JSON 字符串反序列化 MessageType
func (mt *MessageType) UnmarshalJSON(data []byte) error {
	var s string
	if err := json.Unmarshal(data, &s); err != nil {
		// 尝试解析为 int（向后兼容）
		var i int
		if err := json.Unmarshal(data, &i); err != nil {
			return err
		}
		*mt = MessageType(i)
		return nil
	}
	*mt = ParseMessageType(s)
	return nil
}

// ParseMessageType 从字符串解析消息类型
func ParseMessageType(s string) MessageType {
	switch s {
	case "text":
		return MessageTypeText
	case "image":
		return MessageTypeImage
	case "video":
		return MessageTypeVideo
	case "link":
		return MessageTypeLink
	case "file":
		return MessageTypeFile
	case "system":
		return MessageTypeSystem
	default:
		return MessageTypeText
	}
}

// Message 消息实体模型 (Telegram 风格)
type Message struct {
	// 基础 ID
	ID      int64 `json:"-" gorm:"primaryKey;autoIncrement"`                    // 消息的全局唯一 ID (使用自定义序列化)
	LocalID int32 `json:"local_id" gorm:"type:int;not null;index:idx_local_id"` // 在该会话内的递增 ID

	// 关联 ID
	DialogID uuid.UUID `json:"-" gorm:"type:uuid;column:dialog_id;not null;index"`         // 会话 ID (使用自定义序列化)
	SenderID uuid.UUID `json:"sender_id" gorm:"type:uuid;column:sender_id;not null;index"` // 发送者 ID

	// 内容与类型
	Content   string      `json:"content" gorm:"type:text"`                // 消息纯文本内容
	MsgType   MessageType `json:"-" gorm:"type:smallint;default:0"`        // 消息类型 (使用自定义序列化)
	Entities  interface{} `json:"entities,omitempty" gorm:"type:jsonb"`    // 格式化信息
	MediaInfo interface{} `json:"media_info,omitempty" gorm:"type:jsonb"`  // 媒体详细元数据

	// 引用与回复
	ReplyToID *int64 `json:"reply_to_id,omitempty" gorm:"index"` // 被回复的消息 ID

	// 状态与时间
	Date       time.Time      `json:"-" gorm:"not null;index"`         // 消息发送时间 (使用自定义序列化)
	EditDate   *time.Time     `json:"edit_date,omitempty"`             // 最后修改时间
	IsOutgoing bool           `json:"is_outgoing" gorm:"default:true"` // 是否为发送出去的消息
	IsUnread   bool           `json:"is_unread" gorm:"default:true"`   // 是否未读
	Flags      int32          `json:"flags" gorm:"type:int"`           // 内部状态位掩码
	DeletedAt  gorm.DeletedAt `json:"-" gorm:"index"`                  // 软删除支持
}

// messageJSON 用于自定义 JSON 序列化的中间结构
type messageJSON struct {
	ID              string      `json:"id"`
	LocalID         int32       `json:"local_id"`
	ConversationID  string      `json:"conversation_id"`
	SenderID        string      `json:"sender_id"`
	Content         string      `json:"content"`
	MessageType     string      `json:"message_type"`
	Entities        interface{} `json:"entities,omitempty"`
	MediaInfo       interface{} `json:"media_info,omitempty"`
	ReplyToID       *int64      `json:"reply_to_id,omitempty"`
	CreatedAt       time.Time   `json:"created_at"`
	EditDate        *time.Time  `json:"edit_date,omitempty"`
	IsOutgoing      bool        `json:"is_outgoing"`
	IsUnread        bool        `json:"is_unread"`
	Flags           int32       `json:"flags"`
}

// MarshalJSON 自定义 JSON 序列化，确保字段名与 Flutter 客户端一致
func (m Message) MarshalJSON() ([]byte, error) {
	return json.Marshal(messageJSON{
		ID:             strconv.FormatInt(m.ID, 10),
		LocalID:        m.LocalID,
		ConversationID: m.DialogID.String(),
		SenderID:       m.SenderID.String(),
		Content:        m.Content,
		MessageType:    m.MsgType.String(),
		Entities:       m.Entities,
		MediaInfo:      m.MediaInfo,
		ReplyToID:      m.ReplyToID,
		CreatedAt:      m.Date,
		EditDate:       m.EditDate,
		IsOutgoing:     m.IsOutgoing,
		IsUnread:       m.IsUnread,
		Flags:          m.Flags,
	})
}

// UnmarshalJSON 自定义 JSON 反序列化，支持新旧字段名
func (m *Message) UnmarshalJSON(data []byte) error {
	// 使用 map 来支持新旧字段名
	var raw map[string]json.RawMessage
	if err := json.Unmarshal(data, &raw); err != nil {
		return err
	}

	// 解析 ID (支持 string 和 int)
	if idRaw, ok := raw["id"]; ok {
		var idStr string
		if err := json.Unmarshal(idRaw, &idStr); err != nil {
			// 尝试解析为 int
			var idInt int64
			if err := json.Unmarshal(idRaw, &idInt); err != nil {
				return err
			}
			m.ID = idInt
		} else {
			id, err := strconv.ParseInt(idStr, 10, 64)
			if err != nil {
				return err
			}
			m.ID = id
		}
	}

	// 解析 LocalID
	if localIDRaw, ok := raw["local_id"]; ok {
		if err := json.Unmarshal(localIDRaw, &m.LocalID); err != nil {
			return err
		}
	}

	// 解析 DialogID (支持 conversation_id 和 dialog_id)
	if convIDRaw, ok := raw["conversation_id"]; ok {
		var convID string
		if err := json.Unmarshal(convIDRaw, &convID); err != nil {
			return err
		}
		m.DialogID = uuid.MustParse(convID)
	} else if dialogIDRaw, ok := raw["dialog_id"]; ok {
		var dialogID string
		if err := json.Unmarshal(dialogIDRaw, &dialogID); err != nil {
			return err
		}
		m.DialogID = uuid.MustParse(dialogID)
	}

	// 解析 SenderID
	if senderIDRaw, ok := raw["sender_id"]; ok {
		var senderID string
		if err := json.Unmarshal(senderIDRaw, &senderID); err != nil {
			return err
		}
		m.SenderID = uuid.MustParse(senderID)
	}

	// 解析 Content
	if contentRaw, ok := raw["content"]; ok {
		if err := json.Unmarshal(contentRaw, &m.Content); err != nil {
			return err
		}
	}

	// 解析 MsgType (支持 message_type 和 msg_type，支持 string 和 int)
	if msgTypeRaw, ok := raw["message_type"]; ok {
		var msgTypeStr string
		if err := json.Unmarshal(msgTypeRaw, &msgTypeStr); err != nil {
			// 尝试解析为 int
			var msgTypeInt int
			if err := json.Unmarshal(msgTypeRaw, &msgTypeInt); err != nil {
				return err
			}
			m.MsgType = MessageType(msgTypeInt)
		} else {
			m.MsgType = ParseMessageType(msgTypeStr)
		}
	} else if msgTypeRaw, ok := raw["msg_type"]; ok {
		var msgTypeInt int
		if err := json.Unmarshal(msgTypeRaw, &msgTypeInt); err != nil {
			// 尝试解析为 string
			var msgTypeStr string
			if err := json.Unmarshal(msgTypeRaw, &msgTypeStr); err != nil {
				return err
			}
			m.MsgType = ParseMessageType(msgTypeStr)
		} else {
			m.MsgType = MessageType(msgTypeInt)
		}
	}

	// 解析 Entities
	if entitiesRaw, ok := raw["entities"]; ok {
		if err := json.Unmarshal(entitiesRaw, &m.Entities); err != nil {
			return err
		}
	}

	// 解析 MediaInfo
	if mediaInfoRaw, ok := raw["media_info"]; ok {
		if err := json.Unmarshal(mediaInfoRaw, &m.MediaInfo); err != nil {
			return err
		}
	}

	// 解析 ReplyToID
	if replyToIDRaw, ok := raw["reply_to_id"]; ok {
		var replyToID int64
		if err := json.Unmarshal(replyToIDRaw, &replyToID); err == nil {
			m.ReplyToID = &replyToID
		}
	}

	// 解析 Date (支持 created_at 和 date)
	if createdAtRaw, ok := raw["created_at"]; ok {
		if err := json.Unmarshal(createdAtRaw, &m.Date); err != nil {
			return err
		}
	} else if dateRaw, ok := raw["date"]; ok {
		if err := json.Unmarshal(dateRaw, &m.Date); err != nil {
			return err
		}
	}

	// 解析 EditDate
	if editDateRaw, ok := raw["edit_date"]; ok {
		var editDate time.Time
		if err := json.Unmarshal(editDateRaw, &editDate); err == nil {
			m.EditDate = &editDate
		}
	}

	// 解析 IsOutgoing
	if isOutgoingRaw, ok := raw["is_outgoing"]; ok {
		if err := json.Unmarshal(isOutgoingRaw, &m.IsOutgoing); err != nil {
			return err
		}
	}

	// 解析 IsUnread
	if isUnreadRaw, ok := raw["is_unread"]; ok {
		if err := json.Unmarshal(isUnreadRaw, &m.IsUnread); err != nil {
			return err
		}
	}

	// 解析 Flags
	if flagsRaw, ok := raw["flags"]; ok {
		if err := json.Unmarshal(flagsRaw, &m.Flags); err != nil {
			return err
		}
	}

	return nil
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
