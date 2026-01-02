// Package ratelimit 提供基于令牌桶算法的限流器
//
// 使用 golang.org/x/time/rate 官方库实现
// 特性：
//   - 支持全局限流和按 Key（IP/用户ID）限流
//   - 自动清理过期的限流器
//   - 线程安全
package ratelimit

import (
	"sync"
	"sync/atomic"
	"time"

	"golang.org/x/time/rate"
)

// ============================================================================
// 配置
// ============================================================================

// Config 限流器配置
type Config struct {
	Rate            float64       // 每秒允许的请求数
	Burst           int           // 突发容量（桶大小）
	CleanupInterval time.Duration // 过期限流器清理间隔
	LimiterExpiry   time.Duration // 限流器过期时间（无请求后）
}

// DefaultConfig 返回默认配置
func DefaultConfig() Config {
	return Config{
		Rate:            100,
		Burst:           200,
		CleanupInterval: 5 * time.Minute,
		LimiterExpiry:   10 * time.Minute,
	}
}

// ============================================================================
// 限流器条目
// ============================================================================

// limiterEntry 单个限流器条目
type limiterEntry struct {
	limiter    *rate.Limiter
	lastAccess time.Time
}

// ============================================================================
// 限流器
// ============================================================================

// Limiter 多 Key 限流器
type Limiter struct {
	rate            rate.Limit
	burst           int
	cleanupInterval time.Duration
	limiterExpiry   time.Duration

	// 全局限流器
	global *rate.Limiter

	// 按 Key 限流器
	limiters map[string]*limiterEntry
	mu       sync.Mutex

	// 生命周期管理
	stopChan chan struct{}
	stopped  atomic.Bool
}

// NewLimiter 创建限流器
func NewLimiter(cfg Config) *Limiter {
	if cfg.Rate <= 0 {
		cfg.Rate = DefaultConfig().Rate
	}
	if cfg.Burst <= 0 {
		cfg.Burst = int(cfg.Rate * 2)
	}
	if cfg.CleanupInterval <= 0 {
		cfg.CleanupInterval = DefaultConfig().CleanupInterval
	}
	if cfg.LimiterExpiry <= 0 {
		cfg.LimiterExpiry = DefaultConfig().LimiterExpiry
	}

	l := &Limiter{
		rate:            rate.Limit(cfg.Rate),
		burst:           cfg.Burst,
		cleanupInterval: cfg.CleanupInterval,
		limiterExpiry:   cfg.LimiterExpiry,
		global:          rate.NewLimiter(rate.Limit(cfg.Rate), cfg.Burst),
		limiters:        make(map[string]*limiterEntry),
		stopChan:        make(chan struct{}),
	}

	go l.cleanupLoop()
	return l
}

// Allow 检查全局是否允许请求
func (l *Limiter) Allow() bool {
	if l.stopped.Load() {
		return false
	}
	return l.global.Allow()
}

// AllowKey 检查指定 Key 是否允许请求
func (l *Limiter) AllowKey(key string) bool {
	if l.stopped.Load() {
		return false
	}
	return l.getLimiter(key).Allow()
}

// AllowN 检查指定 Key 是否允许 n 个请求
func (l *Limiter) AllowN(key string, n int) bool {
	if l.stopped.Load() {
		return false
	}
	return l.getLimiter(key).AllowN(time.Now(), n)
}

// getLimiter 获取或创建指定 Key 的限流器
func (l *Limiter) getLimiter(key string) *rate.Limiter {
	l.mu.Lock()
	defer l.mu.Unlock()

	now := time.Now()
	entry, exists := l.limiters[key]

	if exists {
		entry.lastAccess = now
		return entry.limiter
	}

	// 创建新的限流器
	limiter := rate.NewLimiter(l.rate, l.burst)
	l.limiters[key] = &limiterEntry{
		limiter:    limiter,
		lastAccess: now,
	}
	return limiter
}

// Stats 返回限流器统计信息
func (l *Limiter) Stats() map[string]interface{} {
	l.mu.Lock()
	defer l.mu.Unlock()

	return map[string]interface{}{
		"rate":          float64(l.rate),
		"burst":         l.burst,
		"limiter_count": len(l.limiters),
		"stopped":       l.stopped.Load(),
	}
}

// Stop 停止限流器（幂等操作）
func (l *Limiter) Stop() {
	if l.stopped.Swap(true) {
		return
	}
	close(l.stopChan)
}

// cleanupLoop 定期清理过期的限流器
func (l *Limiter) cleanupLoop() {
	ticker := time.NewTicker(l.cleanupInterval)
	defer ticker.Stop()

	for {
		select {
		case <-l.stopChan:
			return
		case <-ticker.C:
			l.cleanup()
		}
	}
}

// cleanup 清理过期的限流器
func (l *Limiter) cleanup() {
	l.mu.Lock()
	defer l.mu.Unlock()

	threshold := time.Now().Add(-l.limiterExpiry)
	for key, entry := range l.limiters {
		if entry.lastAccess.Before(threshold) {
			delete(l.limiters, key)
		}
	}
}
