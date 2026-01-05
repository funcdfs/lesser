// Package data_access 提供数据访问层实现
package data_access

import (
	"context"
	"fmt"
	"time"

	"github.com/funcdfs/lesser/pkg/db"
)

const (
	// banCachePrefix 封禁状态缓存键前缀
	banCachePrefix = "auth:ban:"
	// loginAttemptPrefix 登录尝试缓存键前缀
	loginAttemptPrefix = "auth:login:attempt:"
)

// BanCacheEntry 封禁缓存条目
type BanCacheEntry struct {
	Banned    bool   `json:"banned"`
	Reason    string `json:"reason,omitempty"`
	ExpiresAt int64  `json:"expires_at,omitempty"` // Unix 时间戳，0 表示永久
}

// BanCache 封禁状态缓存
type BanCache struct {
	cache *db.RedisClient
	ttl   time.Duration
}

// NewBanCache 创建封禁缓存
func NewBanCache(cache *db.RedisClient, ttl time.Duration) *BanCache {
	if ttl == 0 {
		ttl = 5 * time.Minute
	}
	return &BanCache{cache: cache, ttl: ttl}
}

// Get 获取封禁状态缓存
func (c *BanCache) Get(ctx context.Context, userID string) (*BanCacheEntry, error) {
	key := banCachePrefix + userID
	var entry BanCacheEntry
	err := c.db.Get(ctx, key, &entry)
	if err == db.ErrKeyNotFound {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("获取封禁缓存失败: %w", err)
	}
	return &entry, nil
}

// Set 设置封禁状态缓存
func (c *BanCache) Set(ctx context.Context, userID string, entry *BanCacheEntry) error {
	key := banCachePrefix + userID
	return c.db.Set(ctx, key, entry, c.ttl)
}

// Delete 删除封禁状态缓存
func (c *BanCache) Delete(ctx context.Context, userID string) error {
	key := banCachePrefix + userID
	return c.db.Delete(ctx, key)
}

// LoginAttemptCache 登录尝试缓存
type LoginAttemptCache struct {
	cache  *db.RedisClient
	window time.Duration // 统计窗口
}

// NewLoginAttemptCache 创建登录尝试缓存
func NewLoginAttemptCache(cache *db.RedisClient, window time.Duration) *LoginAttemptCache {
	if window == 0 {
		window = 15 * time.Minute
	}
	return &LoginAttemptCache{cache: cache, window: window}
}

// IncrementFailure 增加失败次数（使用原子操作）
func (c *LoginAttemptCache) IncrementFailure(ctx context.Context, userID string) (int, error) {
	key := loginAttemptPrefix + userID

	// 使用 Redis INCR 原子操作
	count, err := c.db.Incr(ctx, key)
	if err != nil {
		return 0, fmt.Errorf("增加登录尝试次数失败: %w", err)
	}

	// 首次设置时添加过期时间
	if count == 1 {
		if _, err := c.db.Expire(ctx, key, c.window); err != nil {
			// 过期时间设置失败不影响主流程，仅记录
			return int(count), nil
		}
	}

	return int(count), nil
}

// GetFailureCount 获取失败次数
func (c *LoginAttemptCache) GetFailureCount(ctx context.Context, userID string) (int, error) {
	key := loginAttemptPrefix + userID
	// 使用 GetString 获取原始值，因为 Incr 存储的是纯数字
	result, err := c.db.GetString(ctx, key)
	if err == db.ErrKeyNotFound {
		return 0, nil
	}
	if err != nil {
		return 0, fmt.Errorf("获取登录尝试次数失败: %w", err)
	}

	var count int
	if _, err := fmt.Sscanf(result, "%d", &count); err != nil {
		return 0, fmt.Errorf("解析登录尝试次数失败: %w", err)
	}
	return count, nil
}

// ClearFailures 清除失败记录
func (c *LoginAttemptCache) ClearFailures(ctx context.Context, userID string) error {
	key := loginAttemptPrefix + userID
	return c.db.Delete(ctx, key)
}

// IsLocked 检查是否被锁定
func (c *LoginAttemptCache) IsLocked(ctx context.Context, userID string, maxAttempts int) (bool, error) {
	count, err := c.GetFailureCount(ctx, userID)
	if err != nil {
		return false, err
	}
	return count >= maxAttempts, nil
}
