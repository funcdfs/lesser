// Package service 提供认证业务逻辑实现
package service

import (
	"context"
	"fmt"
	"log/slog"
	"time"

	"github.com/google/uuid"

	"github.com/funcdfs/lesser/auth/internal/config"
	"github.com/funcdfs/lesser/auth/internal/crypto"
	"github.com/funcdfs/lesser/auth/internal/repository"
	"github.com/funcdfs/lesser/auth/internal/repository/redis"
)

// authServiceImpl 认证服务实现
type authServiceImpl struct {
	// 仓库依赖
	userRepo       repository.UserRepository
	banRepo        repository.BanRepository
	tokenBlacklist repository.TokenBlacklistRepository

	// 缓存依赖
	banCache          *redis.BanCache
	loginAttemptCache *redis.LoginAttemptCache

	// 加密组件
	passwordHasher    *crypto.PasswordHasher
	passwordValidator *crypto.PasswordValidator
	jwtManager        *crypto.JWTManager

	// 配置
	cfg *config.Config

	// 日志
	log *slog.Logger
}

// AuthServiceDeps 认证服务依赖
type AuthServiceDeps struct {
	UserRepo          repository.UserRepository
	BanRepo           repository.BanRepository
	TokenBlacklist    repository.TokenBlacklistRepository
	BanCache          *redis.BanCache
	LoginAttemptCache *redis.LoginAttemptCache
	PasswordHasher    *crypto.PasswordHasher
	PasswordValidator *crypto.PasswordValidator
	JWTManager        *crypto.JWTManager
	Config            *config.Config
	Logger            *slog.Logger
}

// NewAuthService 创建认证服务
func NewAuthService(deps AuthServiceDeps) AuthService {
	return &authServiceImpl{
		userRepo:          deps.UserRepo,
		banRepo:           deps.BanRepo,
		tokenBlacklist:    deps.TokenBlacklist,
		banCache:          deps.BanCache,
		loginAttemptCache: deps.LoginAttemptCache,
		passwordHasher:    deps.PasswordHasher,
		passwordValidator: deps.PasswordValidator,
		jwtManager:        deps.JWTManager,
		cfg:               deps.Config,
		log:               deps.Logger,
	}
}

// Register 用户注册
func (s *authServiceImpl) Register(ctx context.Context, username, email, password, displayName string) (*AuthResult, error) {
	// 验证密码强度
	if err := s.passwordValidator.Validate(password); err != nil {
		return nil, fmt.Errorf("%w: %v", ErrPasswordTooWeak, err)
	}

	// 检查用户是否已存在
	exists, err := s.userRepo.ExistsByEmailOrUsername(ctx, email, username)
	if err != nil {
		s.log.Error("检查用户存在性失败", slog.Any("error", err))
		return nil, fmt.Errorf("检查用户失败: %w", err)
	}
	if exists {
		return nil, repository.ErrUserExists
	}

	// 哈希密码
	hashedPassword, err := s.passwordHasher.Hash(password)
	if err != nil {
		s.log.Error("密码哈希失败", slog.Any("error", err))
		return nil, fmt.Errorf("密码处理失败: %w", err)
	}

	// 创建用户
	now := time.Now()
	user := &repository.User{
		ID:          uuid.New().String(),
		Username:    username,
		Email:       email,
		Password:    hashedPassword,
		DisplayName: displayName,
		IsActive:    true,
		CreatedAt:   now,
		UpdatedAt:   now,
	}

	if err := s.userRepo.Create(ctx, user); err != nil {
		s.log.Error("创建用户失败", slog.Any("error", err), slog.String("email", email))
		return nil, fmt.Errorf("创建用户失败: %w", err)
	}

	s.log.Info("用户注册成功", slog.String("user_id", user.ID), slog.String("username", username))

	// 生成 Token
	return s.generateTokens(user)
}

// Login 用户登录
func (s *authServiceImpl) Login(ctx context.Context, email, password string) (*AuthResult, error) {
	// 获取用户
	user, err := s.userRepo.GetByEmail(ctx, email)
	if err != nil {
		if err == repository.ErrUserNotFound {
			return nil, ErrInvalidCredentials
		}
		s.log.Error("获取用户失败", slog.Any("error", err), slog.String("email", email))
		return nil, fmt.Errorf("获取用户失败: %w", err)
	}

	// 检查账户锁定状态
	if s.loginAttemptCache != nil {
		locked, err := s.loginAttemptCache.IsLocked(ctx, user.ID, s.cfg.MaxLoginAttempts)
		if err != nil {
			s.log.Warn("检查账户锁定状态失败", slog.Any("error", err))
		} else if locked {
			s.log.Warn("账户已锁定", slog.String("user_id", user.ID))
			return nil, ErrAccountLocked
		}
	}

	// 检查是否被封禁
	banInfo, err := s.CheckBanned(ctx, user.ID)
	if err != nil {
		s.log.Error("检查封禁状态失败", slog.Any("error", err))
		return nil, fmt.Errorf("检查封禁状态失败: %w", err)
	}
	if banInfo.Banned {
		return nil, fmt.Errorf("%w: %s", ErrUserBanned, banInfo.Reason)
	}

	// 检查账户是否激活
	if !user.IsActive {
		return nil, ErrUserNotActive
	}

	// 验证密码
	match, err := s.passwordHasher.Verify(password, user.Password)
	if err != nil {
		s.log.Error("密码验证失败", slog.Any("error", err))
		return nil, fmt.Errorf("密码验证失败: %w", err)
	}
	if !match {
		// 记录失败尝试
		if s.loginAttemptCache != nil {
			count, _ := s.loginAttemptCache.IncrementFailure(ctx, user.ID)
			s.log.Warn("登录失败", slog.String("user_id", user.ID), slog.Int("attempt", count))
		}
		return nil, ErrInvalidCredentials
	}

	// 登录成功，清除失败记录
	if s.loginAttemptCache != nil {
		_ = s.loginAttemptCache.ClearFailures(ctx, user.ID)
	}

	// 检查是否需要重新哈希密码（参数升级）
	if s.passwordHasher.NeedsRehash(user.Password) {
		newHash, err := s.passwordHasher.Hash(password)
		if err == nil {
			_ = s.userRepo.UpdatePassword(ctx, user.ID, newHash)
			s.log.Info("密码哈希已升级", slog.String("user_id", user.ID))
		}
	}

	// 更新最后登录时间
	_ = s.userRepo.UpdateLastLogin(ctx, user.ID)

	s.log.Info("用户登录成功", slog.String("user_id", user.ID))

	// 生成 Token
	return s.generateTokens(user)
}

// Logout 用户登出
func (s *authServiceImpl) Logout(ctx context.Context, accessToken string) error {
	if s.tokenBlacklist == nil {
		// 没有配置黑名单，跳过
		return nil
	}

	// 获取 Token ID 和过期时间
	tokenID, err := s.jwtManager.GetTokenID(accessToken)
	if err != nil {
		s.log.Warn("解析 Token ID 失败", slog.Any("error", err))
		return nil // 不返回错误，允许登出
	}

	expiresAt, err := s.jwtManager.GetTokenExpiry(accessToken)
	if err != nil {
		s.log.Warn("解析 Token 过期时间失败", slog.Any("error", err))
		return nil
	}

	// 添加到黑名单
	if err := s.tokenBlacklist.Add(ctx, tokenID, expiresAt); err != nil {
		s.log.Error("添加 Token 到黑名单失败", slog.Any("error", err))
		return fmt.Errorf("登出失败: %w", err)
	}

	s.log.Debug("Token 已加入黑名单", slog.String("token_id", tokenID))
	return nil
}

// RefreshToken 刷新 Token
func (s *authServiceImpl) RefreshToken(ctx context.Context, refreshToken string) (*AuthResult, error) {
	// 验证 Refresh Token
	claims, err := s.jwtManager.ValidateRefreshToken(refreshToken)
	if err != nil {
		if err == crypto.ErrTokenExpired {
			return nil, ErrTokenExpired
		}
		return nil, ErrInvalidToken
	}

	// 获取用户
	user, err := s.userRepo.GetByID(ctx, claims.UserID)
	if err != nil {
		if err == repository.ErrUserNotFound {
			return nil, ErrInvalidToken
		}
		return nil, fmt.Errorf("获取用户失败: %w", err)
	}

	// 检查是否被封禁
	banInfo, err := s.CheckBanned(ctx, user.ID)
	if err != nil {
		return nil, fmt.Errorf("检查封禁状态失败: %w", err)
	}
	if banInfo.Banned {
		return nil, ErrUserBanned
	}

	// 检查账户是否激活
	if !user.IsActive {
		return nil, ErrUserNotActive
	}

	s.log.Debug("Token 刷新成功", slog.String("user_id", user.ID))

	// 生成新 Token
	return s.generateTokens(user)
}

// GetPublicKey 获取公钥信息
func (s *authServiceImpl) GetPublicKey() *PublicKeyInfo {
	info := s.jwtManager.GetPublicKeyInfo()
	if info == nil {
		return nil
	}
	return &PublicKeyInfo{
		PublicKey: info.PublicKey,
		KeyID:     info.KeyID,
		Algorithm: info.Algorithm,
		ExpiresAt: info.ExpiresAt,
	}
}

// BanUser 封禁用户
func (s *authServiceImpl) BanUser(ctx context.Context, userID, reason string, duration time.Duration, operatorID string) error {
	var expiresAt *time.Time
	if duration > 0 {
		t := time.Now().Add(duration)
		expiresAt = &t
	}

	ban := &repository.Ban{
		ID:        uuid.New().String(),
		UserID:    userID,
		Reason:    reason,
		ExpiresAt: expiresAt,
		CreatedAt: time.Now(),
		CreatedBy: operatorID,
	}

	if err := s.banRepo.Create(ctx, ban); err != nil {
		s.log.Error("创建封禁记录失败", slog.Any("error", err), slog.String("user_id", userID))
		return fmt.Errorf("封禁用户失败: %w", err)
	}

	// 清除缓存
	if s.banCache != nil {
		_ = s.banCache.Delete(ctx, userID)
	}

	s.log.Info("用户已封禁",
		slog.String("user_id", userID),
		slog.String("reason", reason),
		slog.String("operator", operatorID))

	return nil
}

// UnbanUser 解封用户
func (s *authServiceImpl) UnbanUser(ctx context.Context, userID string) error {
	if err := s.banRepo.Delete(ctx, userID); err != nil {
		s.log.Error("删除封禁记录失败", slog.Any("error", err), slog.String("user_id", userID))
		return fmt.Errorf("解封用户失败: %w", err)
	}

	// 清除缓存
	if s.banCache != nil {
		_ = s.banCache.Delete(ctx, userID)
	}

	s.log.Info("用户已解封", slog.String("user_id", userID))
	return nil
}

// CheckBanned 检查用户封禁状态
func (s *authServiceImpl) CheckBanned(ctx context.Context, userID string) (*BanInfo, error) {
	// 先查缓存
	if s.banCache != nil {
		entry, err := s.banCache.Get(ctx, userID)
		if err != nil {
			s.log.Warn("获取封禁缓存失败", slog.Any("error", err))
		} else if entry != nil {
			return &BanInfo{
				Banned:    entry.Banned,
				Reason:    entry.Reason,
				ExpiresAt: entry.ExpiresAt,
			}, nil
		}
	}

	// 查数据库
	banned, ban, err := s.banRepo.IsUserBanned(ctx, userID)
	if err != nil {
		return nil, err
	}

	info := &BanInfo{Banned: banned}
	if ban != nil {
		info.Reason = ban.Reason
		if ban.ExpiresAt != nil {
			info.ExpiresAt = ban.ExpiresAt.Unix()
		}
	}

	// 写入缓存
	if s.banCache != nil {
		_ = s.banCache.Set(ctx, userID, &redis.BanCacheEntry{
			Banned:    info.Banned,
			Reason:    info.Reason,
			ExpiresAt: info.ExpiresAt,
		})
	}

	return info, nil
}

// GetUser 获取用户信息
func (s *authServiceImpl) GetUser(ctx context.Context, userID string) (*repository.User, error) {
	return s.userRepo.GetByID(ctx, userID)
}

// generateTokens 生成 Token 对
func (s *authServiceImpl) generateTokens(user *repository.User) (*AuthResult, error) {
	accessToken, err := s.jwtManager.GenerateAccessToken(user.ID)
	if err != nil {
		return nil, fmt.Errorf("生成 Access Token 失败: %w", err)
	}

	refreshToken, err := s.jwtManager.GenerateRefreshToken(user.ID)
	if err != nil {
		return nil, fmt.Errorf("生成 Refresh Token 失败: %w", err)
	}

	return &AuthResult{
		User:         user,
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}

// 确保实现接口
var _ AuthService = (*authServiceImpl)(nil)
