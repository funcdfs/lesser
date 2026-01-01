package model

import (
	"time"

	"github.com/google/uuid"
)

type ConversationType string

const (
	ConversationTypePrivate ConversationType = "private"
	ConversationTypeGroup   ConversationType = "group"
	ConversationTypeChannel ConversationType = "channel"
)

type Conversation struct {
	ID        uuid.UUID        `json:"id" gorm:"type:uuid;primary_key;default:gen_random_uuid()"`
	Type      ConversationType `json:"type" gorm:"type:varchar(20);not null"`
	Name      string           `json:"name" gorm:"type:varchar(100)"`
	CreatorID uuid.UUID        `json:"creator_id" gorm:"type:uuid;not null"`
	CreatedAt time.Time        `json:"created_at" gorm:"autoCreateTime"`
	UpdatedAt time.Time        `json:"updated_at" gorm:"autoUpdateTime"`

	Members     []ConversationMember `json:"members,omitempty" gorm:"foreignKey:ConversationID"`
	LastMessage *Message             `json:"last_message,omitempty" gorm:"-"`
	UnreadCount int                  `json:"unread_count" gorm:"-"`
}

func (Conversation) TableName() string {
	return "chat_conversations"
}

type ConversationMember struct {
	ConversationID uuid.UUID `json:"-" gorm:"type:uuid;primaryKey"`
	UserID         uuid.UUID `json:"id" gorm:"type:uuid;primaryKey"`
	Role           string    `json:"role" gorm:"type:varchar(20);default:'member'"`
	JoinedAt       time.Time `json:"-" gorm:"autoCreateTime"`
	LastReadAt     time.Time `json:"last_read_at" gorm:"default:null"`

	Username    string  `json:"username,omitempty" gorm:"-"`
	Email       string  `json:"email,omitempty" gorm:"-"`
	DisplayName *string `json:"display_name,omitempty" gorm:"-"`
	AvatarURL   *string `json:"avatar_url,omitempty" gorm:"-"`
}

func (ConversationMember) TableName() string {
	return "chat_conversation_members"
}

const (
	MemberRoleOwner  = "owner"
	MemberRoleAdmin  = "admin"
	MemberRoleMember = "member"
)

func (c *Conversation) GetMemberIDs() []uuid.UUID {
	ids := make([]uuid.UUID, len(c.Members))
	for i, m := range c.Members {
		ids[i] = m.UserID
	}
	return ids
}

func (c *Conversation) HasMember(userID uuid.UUID) bool {
	for _, m := range c.Members {
		if m.UserID == userID {
			return true
		}
	}
	return false
}
