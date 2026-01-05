package interceptor

import (
	"context"
	"sync"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

// RateLimiter 限流器接口
type RateLimiter interface {
	Allow(key string) bool
}

// TokenBucket 令牌桶限流器
type TokenBucket struct {
	rate       float64   // 每秒生成的令牌数
	capacity   float64   // 桶容量
	tokens     float64   // 当前令牌数
	lastUpdate time.Time // 上次更新时间
	mu         sync.Mutex
}

// NewTokenBucket 创建令牌桶
func NewTokenBucket(rate, capacity float64) *TokenBucket {
	return &TokenBucket{
		rate:       rate,
		capacity:   capacity,
		tokens:     capacity,
		lastUpdate: time.Now(),
	}
}

// Allow 检查是否允许请求
func (tb *TokenBucket) Allow() bool {
	tb.mu.Lock()
	defer tb.mu.Unlock()

	now := time.Now()
	elapsed := now.Sub(tb.lastUpdate).Seconds()
	tb.lastUpdate = now

	// 添加新令牌
	tb.tokens += elapsed * tb.rate
	if tb.tokens > tb.capacity {
		tb.tokens = tb.capacity
	}

	// 检查是否有可用令牌
	if tb.tokens >= 1 {
		tb.tokens--
		return true
	}

	return false
}

// PerKeyRateLimiter 按 key 限流器
type PerKeyRateLimiter struct {
	rate     float64
	capacity float64
	buckets  map[string]*TokenBucket
	mu       sync.RWMutex
}

// NewPerKeyRateLimiter 创建按 key 限流器
func NewPerKeyRateLimiter(rate, capacity float64) *PerKeyRateLimiter {
	limiter := &PerKeyRateLimiter{
		rate:     rate,
		capacity: capacity,
		buckets:  make(map[string]*TokenBucket),
	}

	// 启动清理协程
	go limiter.cleanup()

	return limiter
}

// Allow 检查指定 key 是否允许请求
func (l *PerKeyRateLimiter) Allow(key string) bool {
	l.mu.RLock()
	bucket, exists := l.buckets[key]
	l.mu.RUnlock()

	if !exists {
		l.mu.Lock()
		// 双重检查
		if bucket, exists = l.buckets[key]; !exists {
			bucket = NewTokenBucket(l.rate, l.capacity)
			l.buckets[key] = bucket
		}
		l.mu.Unlock()
	}

	return bucket.Allow()
}

// cleanup 定期清理过期的桶
func (l *PerKeyRateLimiter) cleanup() {
	ticker := time.NewTicker(5 * time.Minute)
	defer ticker.Stop()

	for range ticker.C {
		l.mu.Lock()
		now := time.Now()
		for key, bucket := range l.buckets {
			bucket.mu.Lock()
			// 如果超过 10 分钟没有请求，删除桶
			if now.Sub(bucket.lastUpdate) > 10*time.Minute {
				delete(l.buckets, key)
			}
			bucket.mu.Unlock()
		}
		l.mu.Unlock()
	}
}

// RateLimitInterceptor 创建限流拦截器
func RateLimitInterceptor(limiter *PerKeyRateLimiter, keyExtractor func(ctx context.Context) string) grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		key := keyExtractor(ctx)
		if key == "" {
			key = "anonymous"
		}

		if !limiter.Allow(key) {
			return nil, status.Error(codes.ResourceExhausted, "请求过于频繁，请稍后再试")
		}

		return handler(ctx, req)
	}
}

// IPKeyExtractor 从 metadata 中提取 IP 作为限流 key
func IPKeyExtractor(ctx context.Context) string {
	if md, ok := metadata.FromIncomingContext(ctx); ok {
		// 尝试从 x-forwarded-for 获取
		if values := md.Get("x-forwarded-for"); len(values) > 0 {
			return values[0]
		}
		// 尝试从 x-real-ip 获取
		if values := md.Get("x-real-ip"); len(values) > 0 {
			return values[0]
		}
	}
	return ""
}

// UserIDKeyExtractor 从 metadata 中提取用户 ID 作为限流 key
func UserIDKeyExtractor(ctx context.Context) string {
	if md, ok := metadata.FromIncomingContext(ctx); ok {
		if values := md.Get("x-user-id"); len(values) > 0 {
			return values[0]
		}
	}
	return ""
}

// MethodKeyExtractor 使用方法名作为限流 key
func MethodKeyExtractor(method string) func(ctx context.Context) string {
	return func(ctx context.Context) string {
		return method
	}
}

// CompositeKeyExtractor 组合多个 key 提取器
func CompositeKeyExtractor(extractors ...func(ctx context.Context) string) func(ctx context.Context) string {
	return func(ctx context.Context) string {
		var key string
		for _, extractor := range extractors {
			if k := extractor(ctx); k != "" {
				if key != "" {
					key += ":"
				}
				key += k
			}
		}
		return key
	}
}
