package model

import (
	"encoding/json"
	"strconv"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type MessageType int

const (
	MessageTypeText   MessageType = 0
	MessageTypeImage  MessageType = 1
	MessageTypeVideo  MessageType = 2
	MessageTypeLink   MessageType = 3
	MessageTypeFile   MessageType = 4
	MessageTypeSystem MessageType = 9
)

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

func (mt MessageType) MarshalJSON() ([]byte, error) {
	return json.Marshal(mt.String())
}

func (mt *MessageType) UnmarshalJSON(data []byte) error {
	var s string
	if err := json.Unmarshal(data, &s); err != nil {
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

type Message struct {
	ID      int64 `json:"-" gorm:"primaryKey;autoIncrement"`
	LocalID int32 `json:"local_id" gorm:"type:int;not null;index:idx_local_id"`

	DialogID uuid.UUID `json:"-" gorm:"type:uuid;column:dialog_id;not null;index"`
	SenderID uuid.UUID `json:"sender_id" gorm:"type:uuid;column:sender_id;not null;index"`

	Content   string      `json:"content" gorm:"type:text"`
	MsgType   MessageType `json:"-" gorm:"type:smallint;default:0"`
	Entities  interface{} `json:"entities,omitempty" gorm:"type:jsonb"`
	MediaInfo interface{} `json:"media_info,omitempty" gorm:"type:jsonb"`

	ReplyToID *int64 `json:"reply_to_id,omitempty" gorm:"index"`

	Date       time.Time      `json:"-" gorm:"not null;index"`
	EditDate   *time.Time     `json:"edit_date,omitempty"`
	IsOutgoing bool           `json:"is_outgoing" gorm:"default:true"`
	IsUnread   bool           `json:"is_unread" gorm:"default:true"`
	Flags      int32          `json:"flags" gorm:"type:int"`
	DeletedAt  gorm.DeletedAt `json:"-" gorm:"index"`
}

type messageJSON struct {
	ID             string      `json:"id"`
	LocalID        int32       `json:"local_id"`
	ConversationID string      `json:"conversation_id"`
	SenderID       string      `json:"sender_id"`
	Content        string      `json:"content"`
	MessageType    string      `json:"message_type"`
	Entities       interface{} `json:"entities,omitempty"`
	MediaInfo      interface{} `json:"media_info,omitempty"`
	ReplyToID      *int64      `json:"reply_to_id,omitempty"`
	CreatedAt      time.Time   `json:"created_at"`
	EditDate       *time.Time  `json:"edit_date,omitempty"`
	IsOutgoing     bool        `json:"is_outgoing"`
	IsUnread       bool        `json:"is_unread"`
	Flags          int32       `json:"flags"`
}

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

func (Message) TableName() string {
	return "chat_messages"
}

func (m *Message) IsValid() bool {
	return m.DialogID != uuid.Nil &&
		m.SenderID != uuid.Nil &&
		(m.Content != "" || m.MediaInfo != nil)
}

type MessageFilter struct {
	DialogID *uuid.UUID
	SenderID *uuid.UUID
	MsgType  *MessageType
	Before   *time.Time
	After    *time.Time
}
