package ratelimit

import (
	"sync"
	"time"
)

// Limiter 基于令牌桶的限流器
// 设计要点：
// 1. 基于内存的令牌桶算法
// 2. 支持按 IP 或用户 ID 限流
// 3. 自动清理过期的限流记录
type Limiter struct {
	rate       float64       // 每秒生成的令牌数
	burst      int           // 桶容量（最大令牌数）
	buckets    map[string]*bucket
	mu         sync.RWMutex
	cleanupInterval time.Duration
	stopChan   chan struct{}
}

// bucket 单个令牌桶
type bucket struct {
	tokens     float64
	lastUpdate time.Time
}

// Config 限流器配置
type Config struct {
	Rate            float64       // 每秒请求数限制
	Burst           int           // 突发请求数限制
	CleanupInterval time.Duration // 清理间隔
}

// DefaultConfig 默认配置
func DefaultConfig() Config {
	return Config{
		Rate:            100,           // 每秒 100 个请求
		Burst:           200,           // 最多突发 200 个请求
		CleanupInterval: 5 * time.Minute,
	}
}

// NewLimiter 创建限流器
func NewLimiter(config Config) *Limiter {
	if config.Rate <= 0 {
		config.Rate = 100
	}
	if config.Burst <= 0 {
		config.Burst = int(config.Rate * 2)
	}
	if config.CleanupInterval <= 0 {
		config.CleanupInterval = 5 * time.Minute
	}

	l := &Limiter{
		rate:            config.Rate,
		burst:           config.Burst,
		buckets:         make(map[string]*bucket),
		cleanupInterval: config.CleanupInterval,
		stopChan:        make(chan struct{}),
	}

	// 启动清理协程
	go l.cleanup()

	return l
}

// Allow 检查是否允许请求（全局限流）
func (l *Limiter) Allow() bool {
	return l.AllowKey("global")
}

// AllowKey 检查指定 key 是否允许请求
func (l *Limiter) AllowKey(key string) bool {
	l.mu.Lock()
	defer l.mu.Unlock()

	now := time.Now()
	b, exists := l.buckets[key]
	
	if !exists {
		// 创建新桶，初始满令牌
		l.buckets[key] = &bucket{
			tokens:     float64(l.burst) - 1, // 消耗一个令牌
			lastUpdate: now,
		}
		return true
	}

	// 计算自上次更新以来生成的令牌数
	elapsed := now.Sub(b.lastUpdate).Seconds()
	b.tokens += elapsed * l.rate
	
	// 令牌数不能超过桶容量
	if b.tokens > float64(l.burst) {
		b.tokens = float64(l.burst)
	}
	
	b.lastUpdate = now

	// 检查是否有可用令牌
	if b.tokens >= 1 {
		b.tokens--
		return true
	}

	return false
}

// AllowN 检查是否允许 n 个请求
func (l *Limiter) AllowN(key string, n int) bool {
	l.mu.Lock()
	defer l.mu.Unlock()

	now := time.Now()
	b, exists := l.buckets[key]
	
	if !exists {
		if n > l.burst {
			return false
		}
		l.buckets[key] = &bucket{
			tokens:     float64(l.burst - n),
			lastUpdate: now,
		}
		return true
	}

	// 计算自上次更新以来生成的令牌数
	elapsed := now.Sub(b.lastUpdate).Seconds()
	b.tokens += elapsed * l.rate
	
	if b.tokens > float64(l.burst) {
		b.tokens = float64(l.burst)
	}
	
	b.lastUpdate = now

	if b.tokens >= float64(n) {
		b.tokens -= float64(n)
		return true
	}

	return false
}

// cleanup 定期清理过期的桶
func (l *Limiter) cleanup() {
	ticker := time.NewTicker(l.cleanupInterval)
	defer ticker.Stop()

	for {
		select {
		case <-l.stopChan:
			return
		case <-ticker.C:
			l.doCleanup()
		}
	}
}

// doCleanup 执行清理
func (l *Limiter) doCleanup() {
	l.mu.Lock()
	defer l.mu.Unlock()

	now := time.Now()
	expireThreshold := 10 * time.Minute // 10 分钟未使用的桶将被清理

	for key, b := range l.buckets {
		if now.Sub(b.lastUpdate) > expireThreshold {
			delete(l.buckets, key)
		}
	}
}

// Stats 获取限流器统计信息
func (l *Limiter) Stats() map[string]interface{} {
	l.mu.RLock()
	defer l.mu.RUnlock()

	return map[string]interface{}{
		"rate":         l.rate,
		"burst":        l.burst,
		"bucket_count": len(l.buckets),
	}
}

// Stop 停止限流器
func (l *Limiter) Stop() {
	close(l.stopChan)
}
