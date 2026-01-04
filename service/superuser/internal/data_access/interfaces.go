// Package repository SuperUser 仓库接口定义
package data_access

import (
	"context"
	"time"

	"github.com/google/uuid"
)

// SuperUser 超级管理员实体
type SuperUser struct {
	ID          uuid.UUID
	Username    string
	Email       string
	Password    string
	DisplayName string
	IsActive    bool
	LastLoginAt *time.Time
	LastLoginIP *string
	LoginCount  int
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

// AuditLog 审计日志实体
type AuditLog struct {
	ID                uuid.UUID
	SuperUserID       uuid.UUID
	SuperUserUsername string
	Action            string
	TargetType        *string
	TargetID          *uuid.UUID
	Details           map[string]interface{}
	IPAddress         *string
	UserAgent         *string
	CreatedAt         time.Time
}

// Session 会话实体
type Session struct {
	ID          uuid.UUID
	SuperUserID uuid.UUID
	TokenHash   string
	IPAddress   *string
	UserAgent   *string
	ExpiresAt   time.Time
	CreatedAt   time.Time
	RevokedAt   *time.Time
}

// SuperUserRepository 超级管理员仓库接口
type SuperUserRepository interface {
	// 创建超级管理员
	Create(ctx context.Context, su *SuperUser) error
	// 根据 ID 获取
	GetByID(ctx context.Context, id uuid.UUID) (*SuperUser, error)
	// 根据用户名获取
	GetByUsername(ctx context.Context, username string) (*SuperUser, error)
	// 根据邮箱获取
	GetByEmail(ctx context.Context, email string) (*SuperUser, error)
	// 更新超级管理员
	Update(ctx context.Context, su *SuperUser) error
	// 更新登录信息
	UpdateLoginInfo(ctx context.Context, id uuid.UUID, ip string) error
	// 检查用户名是否存在
	ExistsByUsername(ctx context.Context, username string) (bool, error)
	// 检查邮箱是否存在
	ExistsByEmail(ctx context.Context, email string) (bool, error)
}

// AuditLogRepository 审计日志仓库接口
type AuditLogRepository interface {
	// 创建审计日志
	Create(ctx context.Context, log *AuditLog) error
	// 获取审计日志列表
	List(ctx context.Context, filter AuditLogFilter) ([]*AuditLog, int, error)
}

// AuditLogFilter 审计日志过滤条件
type AuditLogFilter struct {
	SuperUserID *uuid.UUID
	Action      *string
	StartTime   *time.Time
	EndTime     *time.Time
	Page        int
	PageSize    int
}

// SessionRepository 会话仓库接口
type SessionRepository interface {
	// 创建会话
	Create(ctx context.Context, session *Session) error
	// 根据 Token 哈希获取会话
	GetByTokenHash(ctx context.Context, tokenHash string) (*Session, error)
	// 撤销会话
	Revoke(ctx context.Context, tokenHash string) error
	// 撤销用户所有会话
	RevokeAllByUserID(ctx context.Context, userID uuid.UUID) error
	// 清理过期会话
	CleanExpired(ctx context.Context) error
}

// UserRepository 用户仓库接口（用于管理普通用户）
type UserRepository interface {
	// 获取用户列表
	List(ctx context.Context, filter UserFilter) ([]*User, int, error)
	// 根据 ID 获取用户
	GetByID(ctx context.Context, id uuid.UUID) (*User, error)
	// 更新用户
	Update(ctx context.Context, user *User) error
	// 删除用户（软删除）
	SoftDelete(ctx context.Context, id uuid.UUID) error
	// 删除用户（硬删除）
	HardDelete(ctx context.Context, id uuid.UUID) error
	// 封禁用户
	Ban(ctx context.Context, id uuid.UUID, reason string, expiresAt *time.Time, operatorID uuid.UUID) error
	// 解封用户
	Unban(ctx context.Context, id uuid.UUID) error
}

// User 普通用户实体（用于管理）
type User struct {
	ID             uuid.UUID
	Username       string
	Email          string
	DisplayName    string
	Bio            string
	AvatarURL      *string
	IsActive       bool
	IsBanned       bool
	BanReason      *string
	BanExpiresAt   *time.Time
	FollowersCount int
	FollowingCount int
	PostsCount     int
	CreatedAt      time.Time
	UpdatedAt      time.Time
}

// UserFilter 用户过滤条件
type UserFilter struct {
	Search    *string
	Status    *string // all, active, banned
	SortBy    string
	SortOrder string
	Page      int
	PageSize  int
}

// ContentRepository 内容仓库接口（用于管理内容）
type ContentRepository interface {
	// 获取内容列表
	List(ctx context.Context, filter ContentFilter) ([]*Content, int, error)
	// 根据 ID 获取内容
	GetByID(ctx context.Context, id uuid.UUID) (*Content, error)
	// 删除内容（软删除）
	SoftDelete(ctx context.Context, id uuid.UUID) error
	// 删除内容（硬删除）
	HardDelete(ctx context.Context, id uuid.UUID) error
	// 批量删除内容
	BatchDelete(ctx context.Context, ids []uuid.UUID, hard bool) (int, []uuid.UUID, error)
}

// Content 内容实体
type Content struct {
	ID             uuid.UUID
	AuthorID       uuid.UUID
	AuthorUsername string
	Type           int
	Status         int
	Title          *string
	Text           string
	MediaURLs      []string
	Tags           []string
	LikeCount      int
	CommentCount   int
	RepostCount    int
	ViewCount      int
	CreatedAt      time.Time
	PublishedAt    *time.Time
}

// ContentFilter 内容过滤条件
type ContentFilter struct {
	AuthorID  *uuid.UUID
	Type      *int
	Status    *int
	Search    *string
	SortBy    string
	SortOrder string
	Page      int
	PageSize  int
}
