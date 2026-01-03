// Package repository 提供用户服务的数据访问层
package repository

import (
	"database/sql"
	"time"
)

// ============================================================================
// 用户模型
// ============================================================================

// User 用户实体
type User struct {
	ID             string
	Username       string
	Email          string
	DisplayName    string
	AvatarURL      string
	Bio            string
	Location       string
	Website        string
	Birthday       sql.NullTime
	IsVerified     bool
	IsPrivate      bool
	IsActive       bool
	FollowersCount int32
	FollowingCount int32
	PostsCount     int32
	CreatedAt      time.Time
	UpdatedAt      time.Time
}

// ============================================================================
// 关注模型
// ============================================================================

// Follow 关注关系实体
type Follow struct {
	ID          string
	FollowerID  string
	FollowingID string
	CreatedAt   time.Time
}

// FollowRequest 关注请求实体（私密账户审批用）
type FollowRequest struct {
	ID          string
	RequesterID string
	TargetID    string
	Status      FollowRequestStatus
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

// FollowRequestStatus 关注请求状态
type FollowRequestStatus int

const (
	FollowRequestPending  FollowRequestStatus = 0
	FollowRequestApproved FollowRequestStatus = 1
	FollowRequestRejected FollowRequestStatus = 2
)

// ============================================================================
// 屏蔽模型
// ============================================================================

// Block 屏蔽关系实体
type Block struct {
	ID        string
	BlockerID string
	BlockedID string
	BlockType BlockType
	CreatedAt time.Time
}

// BlockType 屏蔽类型
type BlockType int

const (
	BlockTypeUnspecified BlockType = 0
	BlockTypeHidePosts   BlockType = 1 // 不看他：隐藏他的内容
	BlockTypeHideMe      BlockType = 2 // 不让他看我：他看不到我的内容
	BlockTypeBlock       BlockType = 3 // 拉黑：双向屏蔽
)

// BlockedUser 被屏蔽的用户（带资料）
type BlockedUser struct {
	User      *User
	BlockType BlockType
	BlockedAt time.Time
}

// ============================================================================
// 设置模型
// ============================================================================

// PrivacySettings 隐私设置
type PrivacySettings struct {
	UserID                  string
	IsPrivateAccount        bool
	AllowMessageFromAnyone  bool
	ShowOnlineStatus        bool
	ShowLastSeen            bool
	AllowTagging            bool
	ShowActivityStatus      bool
	CreatedAt               time.Time
	UpdatedAt               time.Time
}

// DefaultPrivacySettings 返回默认隐私设置
func DefaultPrivacySettings(userID string) *PrivacySettings {
	return &PrivacySettings{
		UserID:                  userID,
		IsPrivateAccount:        false,
		AllowMessageFromAnyone:  true,
		ShowOnlineStatus:        true,
		ShowLastSeen:            true,
		AllowTagging:            true,
		ShowActivityStatus:      true,
	}
}

// NotificationSettings 通知设置
type NotificationSettings struct {
	UserID            string
	PushEnabled       bool
	EmailEnabled      bool
	NotifyNewFollower bool
	NotifyLike        bool
	NotifyComment     bool
	NotifyMention     bool
	NotifyRepost      bool
	NotifyMessage     bool
	CreatedAt         time.Time
	UpdatedAt         time.Time
}

// DefaultNotificationSettings 返回默认通知设置
func DefaultNotificationSettings(userID string) *NotificationSettings {
	return &NotificationSettings{
		UserID:            userID,
		PushEnabled:       true,
		EmailEnabled:      true,
		NotifyNewFollower: true,
		NotifyLike:        true,
		NotifyComment:     true,
		NotifyMention:     true,
		NotifyRepost:      true,
		NotifyMessage:     true,
	}
}

// UserSettings 用户完整设置
type UserSettings struct {
	UserID       string
	Privacy      *PrivacySettings
	Notification *NotificationSettings
}

// ============================================================================
// 关系状态模型
// ============================================================================

// RelationshipStatus 两用户间的关系状态
type RelationshipStatus struct {
	IsFollowing   bool      // 我是否关注了他
	IsFollowedBy  bool      // 他是否关注了我
	IsMutual      bool      // 是否互关
	IsBlocking    bool      // 我是否屏蔽了他
	IsBlockedBy   bool      // 他是否屏蔽了我
	IsMuting      bool      // 我是否静音了他（不看他的内容）
	IsHidingFrom  bool      // 我是否对他隐藏（不让他看我）
	MyBlockType   BlockType // 我对他的屏蔽类型
	TheirBlockType BlockType // 他对我的屏蔽类型
}

// CanViewProfile 判断是否能查看对方资料
func (r *RelationshipStatus) CanViewProfile() bool {
	// 如果对方拉黑了我，或者对方设置了不让我看
	if r.TheirBlockType == BlockTypeBlock || r.TheirBlockType == BlockTypeHideMe {
		return false
	}
	return true
}

// CanBeViewed 判断对方是否能查看我的资料
func (r *RelationshipStatus) CanBeViewed() bool {
	// 如果我拉黑了对方，或者我设置了不让他看
	if r.MyBlockType == BlockTypeBlock || r.MyBlockType == BlockTypeHideMe {
		return false
	}
	return true
}
