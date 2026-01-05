package cache

import (
	"context"
	"time"

	"github.com/funcdfs/lesser/pkg/db"
	"github.com/redis/go-redis/v9"
)

// ErrKeyNotFound 键不存在错误
// Deprecated: 请使用 db.ErrKeyNotFound
var ErrKeyNotFound = db.ErrKeyNotFound

// Client Redis 客户端封装
// Deprecated: 请使用 db.RedisClient
type Client = db.RedisClient

// NewClient 创建新的 Redis 客户端
// Deprecated: 请使用 db.NewRedisClient
func NewClient(cfg Config) (*Client, error) {
	return db.NewRedisClient(cfg)
}

// Z 有序集合成员
type Z = redis.Z

// ZRangeBy 有序集合范围查询选项
type ZRangeBy = redis.ZRangeBy

// PubSub 发布订阅
type PubSub = redis.PubSub

// Pipeliner 管道
type Pipeliner = redis.Pipeliner

// DistributedLock 分布式锁
// Deprecated: 请使用 db.DistributedLock
type DistributedLock = db.DistributedLock

// NewDistributedLock 创建分布式锁
// Deprecated: 请使用 db.NewDistributedLock
func NewDistributedLock(client *Client, key string, expiration time.Duration) *DistributedLock {
	return db.NewDistributedLock(client, key, expiration)
}

// ErrLockNotAcquired 无法获取锁
// Deprecated: 请使用 db.ErrLockNotAcquired
var ErrLockNotAcquired = db.ErrLockNotAcquired

// ErrLockNotHeld 未持有锁
// Deprecated: 请使用 db.ErrLockNotHeld
var ErrLockNotHeld = db.ErrLockNotHeld

// AcquireLock 获取分布式锁的便捷函数
// Deprecated: 请使用 client.AcquireLock
func AcquireLock(ctx context.Context, client *Client, key string, expiration time.Duration) (*DistributedLock, error) {
	return client.AcquireLock(ctx, key, expiration)
}
