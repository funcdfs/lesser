package model

import (
	"time"

	"github.com/google/uuid"
)

// ConversationType 会话类型枚举
type ConversationType string

const (
	ConversationTypePrivate ConversationType = "private" // 私聊（一对一）
	ConversationTypeGroup   ConversationType = "group"   // 群聊（多人）
	ConversationTypeChannel ConversationType = "channel" // 频道（广播模式）
)

// Conversation 会话实体模型
type Conversation struct {
	ID        uuid.UUID        `json:"id" gorm:"type:uuid;primary_key;default:gen_random_uuid()"`
	Type      ConversationType `json:"type" gorm:"type:varchar(20);not null"`
	Name      string           `json:"name" gorm:"type:varchar(100)"`
	CreatorID uuid.UUID        `json:"creator_id" gorm:"type:uuid;not null"`
	CreatedAt time.Time        `json:"created_at" gorm:"autoCreateTime"`
	UpdatedAt time.Time        `json:"updated_at" gorm:"autoUpdateTime"`

	// 关联关系
	Members     []ConversationMember `json:"members,omitempty" gorm:"foreignKey:ConversationID"`
	LastMessage *Message             `json:"last_message,omitempty" gorm:"-"` // 最后一条消息（不存储在数据库）
	UnreadCount int                  `json:"unread_count" gorm:"-"`           // 未读消息数（不存储在数据库，动态计算）
}

// TableName 返回会话表名
func (Conversation) TableName() string {
	return "chat_conversations"
}

// ConversationMember 会话成员实体模型
type ConversationMember struct {
	ConversationID uuid.UUID `json:"-" gorm:"type:uuid;primaryKey"`
	UserID         uuid.UUID `json:"id" gorm:"type:uuid;primaryKey"`
	Role           string    `json:"role" gorm:"type:varchar(20);default:'member'"`
	JoinedAt       time.Time `json:"-" gorm:"autoCreateTime"`
	LastReadAt     time.Time `json:"last_read_at" gorm:"default:null"`

	// 用户信息（从认证服务获取，不存储在数据库）
	Username    string  `json:"username,omitempty" gorm:"-"`
	Email       string  `json:"email,omitempty" gorm:"-"`
	DisplayName *string `json:"display_name,omitempty" gorm:"-"`
	AvatarURL   *string `json:"avatar_url,omitempty" gorm:"-"`
}

// TableName 返回会话成员表名
func (ConversationMember) TableName() string {
	return "chat_conversation_members"
}

// 成员角色常量
const (
	MemberRoleOwner  = "owner"  // 群主
	MemberRoleAdmin  = "admin"  // 管理员
	MemberRoleMember = "member" // 普通成员
)

// GetMemberIDs 获取所有成员的用户ID列表
func (c *Conversation) GetMemberIDs() []uuid.UUID {
	ids := make([]uuid.UUID, len(c.Members))
	for i, m := range c.Members {
		ids[i] = m.UserID
	}
	return ids
}

// HasMember 检查用户是否是会话成员
func (c *Conversation) HasMember(userID uuid.UUID) bool {
	for _, m := range c.Members {
		if m.UserID == userID {
			return true
		}
	}
	return false
}
