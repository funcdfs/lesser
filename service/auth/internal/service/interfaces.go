// Package service 定义业务逻辑层接口
package service

import (
	"context"
	"errors"
	"time"

	"github.com/funcdfs/lesser/auth/internal/repository"
)

// 业务错误定义
var (
	ErrInvalidCredentials = errors.New("邮箱或密码错误")
	ErrUserBanned         = errors.New("用户已被封禁")
	ErrAccountLocked      = errors.New("账户已被锁定，请稍后再试")
	ErrInvalidToken       = errors.New("无效的令牌")
	ErrTokenExpired       = errors.New("令牌已过期")
	ErrTokenBlacklisted   = errors.New("令牌已失效")
	ErrPasswordTooWeak    = errors.New("密码强度不足")
	ErrUserNotActive      = errors.New("用户账户未激活")
)

// AuthResult 认证结果
type AuthResult struct {
	User         *repository.User
	AccessToken  string
	RefreshToken string
}

// PublicKeyInfo 公钥信息
type PublicKeyInfo struct {
	PublicKey string
	KeyID     string
	Algorithm string
	ExpiresAt int64
}

// BanInfo 封禁信息
type BanInfo struct {
	Banned    bool
	Reason    string
	ExpiresAt int64 // Unix 时间戳，0 表示永久
}

// AuthService 认证服务接口
type AuthService interface {
	// Register 用户注册
	Register(ctx context.Context, username, email, password, displayName string) (*AuthResult, error)
	// Login 用户登录
	Login(ctx context.Context, email, password string) (*AuthResult, error)
	// Logout 用户登出（使 Token 失效）
	Logout(ctx context.Context, accessToken string) error
	// RefreshToken 刷新 Token
	RefreshToken(ctx context.Context, refreshToken string) (*AuthResult, error)
	// GetPublicKey 获取公钥信息
	GetPublicKey() *PublicKeyInfo
	// BanUser 封禁用户
	BanUser(ctx context.Context, userID, reason string, duration time.Duration, operatorID string) error
	// UnbanUser 解封用户
	UnbanUser(ctx context.Context, userID string) error
	// CheckBanned 检查用户封禁状态
	CheckBanned(ctx context.Context, userID string) (*BanInfo, error)
	// GetUser 获取用户信息
	GetUser(ctx context.Context, userID string) (*repository.User, error)
}
