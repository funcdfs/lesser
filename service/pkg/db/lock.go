package db

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
)

// 分布式锁错误
var (
	ErrLockNotAcquired = errors.New("无法获取锁")
	ErrLockNotHeld     = errors.New("未持有锁")
)

// DistributedLock 分布式锁
type DistributedLock struct {
	client     *RedisClient
	key        string
	value      string
	expiration time.Duration
}

// NewDistributedLock 创建分布式锁
func NewDistributedLock(client *RedisClient, key string, expiration time.Duration) *DistributedLock {
	return &DistributedLock{
		client:     client,
		key:        "lock:" + key,
		value:      uuid.New().String(),
		expiration: expiration,
	}
}

// Lock 获取锁
func (l *DistributedLock) Lock(ctx context.Context) error {
	acquired, err := l.client.SetNX(ctx, l.key, l.value, l.expiration)
	if err != nil {
		return err
	}
	if !acquired {
		return ErrLockNotAcquired
	}
	return nil
}

// TryLock 尝试获取锁（带重试）
func (l *DistributedLock) TryLock(ctx context.Context, timeout time.Duration, retryInterval time.Duration) error {
	deadline := time.Now().Add(timeout)

	for time.Now().Before(deadline) {
		err := l.Lock(ctx)
		if err == nil {
			return nil
		}
		if !errors.Is(err, ErrLockNotAcquired) {
			return err
		}

		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-time.After(retryInterval):
			// 继续重试
		}
	}

	return ErrLockNotAcquired
}

// Unlock 释放锁
// 使用独立的 context 确保即使原 context 已取消也能释放锁
func (l *DistributedLock) Unlock(ctx context.Context) error {
	// 使用独立的 context，确保锁能被释放
	unlockCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// 使用 Lua 脚本确保只删除自己的锁
	script := `
		if redis.call("get", KEYS[1]) == ARGV[1] then
			return redis.call("del", KEYS[1])
		else
			return 0
		end
	`

	result, err := l.client.GetClient().Eval(unlockCtx, script, []string{l.key}, l.value).Int64()
	if err != nil {
		return err
	}
	if result == 0 {
		return ErrLockNotHeld
	}
	return nil
}

// Extend 延长锁的过期时间
func (l *DistributedLock) Extend(ctx context.Context, expiration time.Duration) error {
	// 使用 Lua 脚本确保只延长自己的锁
	script := `
		if redis.call("get", KEYS[1]) == ARGV[1] then
			return redis.call("pexpire", KEYS[1], ARGV[2])
		else
			return 0
		end
	`

	result, err := l.client.GetClient().Eval(ctx, script, []string{l.key}, l.value, expiration.Milliseconds()).Int64()
	if err != nil {
		return err
	}
	if result == 0 {
		return ErrLockNotHeld
	}
	l.expiration = expiration
	return nil
}

// WithLock 在锁保护下执行函数
func (l *DistributedLock) WithLock(ctx context.Context, fn func() error) error {
	if err := l.Lock(ctx); err != nil {
		return err
	}
	defer l.Unlock(ctx)
	return fn()
}

// WithTryLock 尝试获取锁并执行函数
func (l *DistributedLock) WithTryLock(ctx context.Context, timeout, retryInterval time.Duration, fn func() error) error {
	if err := l.TryLock(ctx, timeout, retryInterval); err != nil {
		return err
	}
	defer l.Unlock(ctx)
	return fn()
}

// ---- 便捷函数 ----

// AcquireLock 获取分布式锁的便捷函数
func (c *RedisClient) AcquireLock(ctx context.Context, key string, expiration time.Duration) (*DistributedLock, error) {
	lock := NewDistributedLock(c, key, expiration)
	if err := lock.Lock(ctx); err != nil {
		return nil, err
	}
	return lock, nil
}

// TryAcquireLock 尝试获取分布式锁的便捷函数
func (c *RedisClient) TryAcquireLock(ctx context.Context, key string, expiration, timeout, retryInterval time.Duration) (*DistributedLock, error) {
	lock := NewDistributedLock(c, key, expiration)
	if err := lock.TryLock(ctx, timeout, retryInterval); err != nil {
		return nil, err
	}
	return lock, nil
}
