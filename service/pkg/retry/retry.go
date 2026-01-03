// Package retry 提供重试机制
// 支持指数退避、最大重试次数、可重试错误判断
package retry

import (
	"context"
	"errors"
	"math"
	"math/rand"
	"time"
)

// 预定义错误
var (
	ErrMaxRetriesExceeded = errors.New("超过最大重试次数")
	ErrContextCanceled    = errors.New("context 已取消")
)

// Config 重试配置
type Config struct {
	// MaxRetries 最大重试次数（0 表示不重试）
	MaxRetries int
	// InitialDelay 初始延迟
	InitialDelay time.Duration
	// MaxDelay 最大延迟
	MaxDelay time.Duration
	// Multiplier 延迟倍数
	Multiplier float64
	// Jitter 抖动因子（0-1）
	Jitter float64
	// RetryIf 判断是否可重试的函数
	RetryIf func(error) bool
}

// DefaultConfig 默认配置
func DefaultConfig() Config {
	return Config{
		MaxRetries:   3,
		InitialDelay: 100 * time.Millisecond,
		MaxDelay:     10 * time.Second,
		Multiplier:   2.0,
		Jitter:       0.1,
		RetryIf:      func(err error) bool { return err != nil },
	}
}

// Option 配置选项
type Option func(*Config)

// WithMaxRetries 设置最大重试次数
func WithMaxRetries(n int) Option {
	return func(c *Config) { c.MaxRetries = n }
}

// WithInitialDelay 设置初始延迟
func WithInitialDelay(d time.Duration) Option {
	return func(c *Config) { c.InitialDelay = d }
}

// WithMaxDelay 设置最大延迟
func WithMaxDelay(d time.Duration) Option {
	return func(c *Config) { c.MaxDelay = d }
}

// WithMultiplier 设置延迟倍数
func WithMultiplier(m float64) Option {
	return func(c *Config) { c.Multiplier = m }
}

// WithJitter 设置抖动因子
func WithJitter(j float64) Option {
	return func(c *Config) { c.Jitter = j }
}

// WithRetryIf 设置可重试判断函数
func WithRetryIf(f func(error) bool) Option {
	return func(c *Config) { c.RetryIf = f }
}


// Do 执行带重试的函数
func Do(ctx context.Context, fn func() error, opts ...Option) error {
	cfg := DefaultConfig()
	for _, opt := range opts {
		opt(&cfg)
	}

	var lastErr error
	for attempt := 0; attempt <= cfg.MaxRetries; attempt++ {
		// 检查 context
		select {
		case <-ctx.Done():
			return ErrContextCanceled
		default:
		}

		// 执行函数
		err := fn()
		if err == nil {
			return nil
		}

		lastErr = err

		// 检查是否可重试
		if !cfg.RetryIf(err) {
			return err
		}

		// 最后一次尝试不需要等待
		if attempt == cfg.MaxRetries {
			break
		}

		// 计算延迟
		delay := calculateDelay(cfg, attempt)

		// 等待
		select {
		case <-ctx.Done():
			return ErrContextCanceled
		case <-time.After(delay):
		}
	}

	return lastErr
}

// DoWithResult 执行带重试的函数（有返回值）
func DoWithResult[T any](ctx context.Context, fn func() (T, error), opts ...Option) (T, error) {
	cfg := DefaultConfig()
	for _, opt := range opts {
		opt(&cfg)
	}

	var zero T
	var lastErr error
	var result T

	for attempt := 0; attempt <= cfg.MaxRetries; attempt++ {
		select {
		case <-ctx.Done():
			return zero, ErrContextCanceled
		default:
		}

		result, lastErr = fn()
		if lastErr == nil {
			return result, nil
		}

		if !cfg.RetryIf(lastErr) {
			return zero, lastErr
		}

		if attempt == cfg.MaxRetries {
			break
		}

		delay := calculateDelay(cfg, attempt)

		select {
		case <-ctx.Done():
			return zero, ErrContextCanceled
		case <-time.After(delay):
		}
	}

	return zero, lastErr
}

// calculateDelay 计算延迟时间
func calculateDelay(cfg Config, attempt int) time.Duration {
	delay := float64(cfg.InitialDelay) * math.Pow(cfg.Multiplier, float64(attempt))

	// 添加抖动
	if cfg.Jitter > 0 {
		jitter := delay * cfg.Jitter * (rand.Float64()*2 - 1)
		delay += jitter
	}

	// 限制最大延迟
	if delay > float64(cfg.MaxDelay) {
		delay = float64(cfg.MaxDelay)
	}

	return time.Duration(delay)
}

// Backoff 创建退避策略
type Backoff struct {
	cfg     Config
	attempt int
}

// NewBackoff 创建退避策略
func NewBackoff(opts ...Option) *Backoff {
	cfg := DefaultConfig()
	for _, opt := range opts {
		opt(&cfg)
	}
	return &Backoff{cfg: cfg}
}

// Next 获取下一次延迟时间
func (b *Backoff) Next() time.Duration {
	delay := calculateDelay(b.cfg, b.attempt)
	b.attempt++
	return delay
}

// Reset 重置退避策略
func (b *Backoff) Reset() {
	b.attempt = 0
}

// Attempt 获取当前尝试次数
func (b *Backoff) Attempt() int {
	return b.attempt
}
