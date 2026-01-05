// Package data_access 提供数据访问层实现
package data_access

import (
	"context"
	"fmt"
	"time"

	"github.com/funcdfs/lesser/pkg/db"
)

const (
	// tokenBlacklistPrefix Token 黑名单键前缀
	tokenBlacklistPrefix = "auth:token:blacklist:"
)

// TokenBlacklistDataAccessImpl Redis Token 黑名单实现
type TokenBlacklistDataAccessImpl struct {
	cache *db.RedisClient
}

// NewTokenBlacklistDataAccess 创建 Token 黑名单数据访问
func NewTokenBlacklistDataAccess(cache *db.RedisClient) *TokenBlacklistDataAccessImpl {
	return &TokenBlacklistDataAccessImpl{cache: cache}
}

// Add 添加 Token 到黑名单
func (r *TokenBlacklistDataAccessImpl) Add(ctx context.Context, tokenID string, expiresAt time.Time) error {
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
func (r *TokenBlacklistDataAccessImpl) IsBlacklisted(ctx context.Context, tokenID string) (bool, error) {
	key := tokenBlacklistPrefix + tokenID
	exists, err := r.cache.Exists(ctx, key)
	if err != nil {
		return false, fmt.Errorf("检查黑名单失败: %w", err)
	}
	return exists, nil
}

// 确保实现接口
var _ TokenBlacklistDataAccess = (*TokenBlacklistDataAccessImpl)(nil)
