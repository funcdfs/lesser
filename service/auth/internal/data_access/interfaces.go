// Package data_access 定义数据访问层接口
// 遵循依赖倒置原则，便于测试和替换实现
package data_access

import (
	"context"
	"time"
)

// User 用户实体
type User struct {
	ID          string
	Username    string
	Email       string
	Password    string // Argon2id 哈希
	DisplayName string
	AvatarURL   string
	Bio         string
	IsActive    bool
	IsVerified  bool
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

// Ban 封禁记录
type Ban struct {
	ID        string
	UserID    string
	Reason    string
	ExpiresAt *time.Time // nil 表示永久封禁
	CreatedAt time.Time
	CreatedBy string // 操作者 ID
}

// LoginAttempt 登录尝试记录
type LoginAttempt struct {
	UserID    string
	IP        string
	Success   bool
	CreatedAt time.Time
}

// UserDataAccess 用户数据访问接口
type UserDataAccess interface {
	// Create 创建用户
	Create(ctx context.Context, user *User) error
	// GetByID 根据 ID 获取用户
	GetByID(ctx context.Context, id string) (*User, error)
	// GetByEmail 根据邮箱获取用户
	GetByEmail(ctx context.Context, email string) (*User, error)
	// GetByUsername 根据用户名获取用户
	GetByUsername(ctx context.Context, username string) (*User, error)
	// ExistsByEmailOrUsername 检查邮箱或用户名是否已存在
	ExistsByEmailOrUsername(ctx context.Context, email, username string) (bool, error)
	// UpdatePassword 更新密码
	UpdatePassword(ctx context.Context, userID, hashedPassword string) error
	// UpdateLastLogin 更新最后登录时间
	UpdateLastLogin(ctx context.Context, userID string) error
}

// BanDataAccess 封禁数据访问接口
type BanDataAccess interface {
	// Create 创建封禁记录
	Create(ctx context.Context, ban *Ban) error
	// GetByUserID 获取用户的封禁记录
	GetByUserID(ctx context.Context, userID string) (*Ban, error)
	// Delete 删除封禁记录（解封）
	Delete(ctx context.Context, userID string) error
	// IsUserBanned 检查用户是否被封禁（自动清理过期记录）
	IsUserBanned(ctx context.Context, userID string) (bool, *Ban, error)
}

// TokenBlacklistDataAccess Token 黑名单接口
type TokenBlacklistDataAccess interface {
	// Add 添加 Token 到黑名单
	Add(ctx context.Context, tokenID string, expiresAt time.Time) error
	// IsBlacklisted 检查 Token 是否在黑名单中
	IsBlacklisted(ctx context.Context, tokenID string) (bool, error)
}

// LoginAttemptDataAccess 登录尝试记录接口
type LoginAttemptDataAccess interface {
	// Record 记录登录尝试
	Record(ctx context.Context, attempt *LoginAttempt) error
	// GetRecentFailures 获取最近的失败次数
	GetRecentFailures(ctx context.Context, userID string, since time.Time) (int, error)
	// ClearFailures 清除失败记录（登录成功后）
	ClearFailures(ctx context.Context, userID string) error
}
