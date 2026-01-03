// Package redis 提供 Redis 数据访问实现
package redis

import (
	"context"
	"fmt"
	"time"

	"github.com/funcdfs/lesser/auth/internal/repository"
	"github.com/funcdfs/lesser/pkg/cache"
)

const (
	// tokenBlacklistPrefix Token 黑名单键前缀
	tokenBlacklistPrefix = "auth:token:blacklist:"
)

// TokenBlacklistRepository Redis Token 黑名单实现
type TokenBlacklistRepository struct {
	cache *cache.Client
}

// NewTokenBlacklistRepository 创建 Token 黑名单仓库
func NewTokenBlacklistRepository(cache *cache.Client) *TokenBlacklistRepository {
	return &TokenBlacklistRepository{cache: cache}
}

// Add 添加 Token 到黑名单
func (r *TokenBlacklistRepository) Add(ctx context.Context, tokenID string, expiresAt time.Time) error {
	key := tokenBlacklistPrefix + tokenID
	ttl := time.Until(expiresAt)
	if ttl <= 0 {
		// Token 已过期，无需加入黑名单
		return nil
	}

	// 存储一个简单的标记值
	return r.cache.Set(ctx, key, true, ttl)
}

// IsBlacklisted 检查 Token 是否在黑名单中
func (r *TokenBlacklistRepository) IsBlacklisted(ctx context.Context, tokenID string) (bool, error) {
	key := tokenBlacklistPrefix + tokenID
	exists, err := r.cache.Exists(ctx, key)
	if err != nil {
		return false, fmt.Errorf("检查黑名单失败: %w", err)
	}
	return exists, nil
}

// 确保实现接口
var _ repository.TokenBlacklistRepository = (*TokenBlacklistRepository)(nil)
