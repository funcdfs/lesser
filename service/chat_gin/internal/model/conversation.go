package model

import (
	"time"

	"github.com/google/uuid"
)

// ConversationType represents the type of conversation
type ConversationType string

const (
	ConversationTypePrivate ConversationType = "private" // 1:1 private chat
	ConversationTypeGroup   ConversationType = "group"   // Group chat with multiple users
	ConversationTypeChannel ConversationType = "channel" // Broadcast channel
)

// Conversation represents a chat conversation
type Conversation struct {
	ID        uuid.UUID        `json:"id" gorm:"type:uuid;primary_key;default:gen_random_uuid()"`
	Type      ConversationType `json:"type" gorm:"type:varchar(20);not null"`
	Name      string           `json:"name" gorm:"type:varchar(100)"`
	CreatorID uuid.UUID        `json:"creator_id" gorm:"type:uuid;not null"`
	CreatedAt time.Time        `json:"created_at" gorm:"autoCreateTime"`
	UpdatedAt time.Time        `json:"updated_at" gorm:"autoUpdateTime"`

	// Relations
	Members     []ConversationMember `json:"members,omitempty" gorm:"foreignKey:ConversationID"`
	LastMessage *Message             `json:"last_message,omitempty" gorm:"-"`
}

// TableName returns the table name for Conversation
func (Conversation) TableName() string {
	return "chat_conversations"
}

// ConversationMember represents a member of a conversation
type ConversationMember struct {
	ConversationID uuid.UUID `json:"conversation_id" gorm:"type:uuid;primaryKey"`
	UserID         uuid.UUID `json:"user_id" gorm:"type:uuid;primaryKey"`
	Role           string    `json:"role" gorm:"type:varchar(20);default:'member'"`
	JoinedAt       time.Time `json:"joined_at" gorm:"autoCreateTime"`
}

// TableName returns the table name for ConversationMember
func (ConversationMember) TableName() string {
	return "chat_conversation_members"
}

// MemberRole constants
const (
	MemberRoleOwner  = "owner"
	MemberRoleAdmin  = "admin"
	MemberRoleMember = "member"
)

// GetMemberIDs returns a slice of member user IDs
func (c *Conversation) GetMemberIDs() []uuid.UUID {
	ids := make([]uuid.UUID, len(c.Members))
	for i, m := range c.Members {
		ids[i] = m.UserID
	}
	return ids
}

// HasMember checks if a user is a member of the conversation
func (c *Conversation) HasMember(userID uuid.UUID) bool {
	for _, m := range c.Members {
		if m.UserID == userID {
			return true
		}
	}
	return false
}
