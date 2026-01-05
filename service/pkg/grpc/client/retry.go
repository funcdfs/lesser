package client

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

// RetryConfig 重试配置
type RetryConfig struct {
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

// DefaultRetryConfig 默认重试配置
func DefaultRetryConfig() RetryConfig {
	return RetryConfig{
		MaxRetries:   3,
		InitialDelay: 100 * time.Millisecond,
		MaxDelay:     10 * time.Second,
		Multiplier:   2.0,
		Jitter:       0.1,
		RetryIf:      func(err error) bool { return err != nil },
	}
}

// RetryOption 重试配置选项
type RetryOption func(*RetryConfig)

// WithRetryMaxRetries 设置最大重试次数
func WithRetryMaxRetries(n int) RetryOption {
	return func(c *RetryConfig) { c.MaxRetries = n }
}

// WithRetryInitialDelay 设置初始延迟
func WithRetryInitialDelay(d time.Duration) RetryOption {
	return func(c *RetryConfig) { c.InitialDelay = d }
}

// WithRetryMaxDelay 设置最大延迟
func WithRetryMaxDelay(d time.Duration) RetryOption {
	return func(c *RetryConfig) { c.MaxDelay = d }
}

// WithRetryMultiplier 设置延迟倍数
func WithRetryMultiplier(m float64) RetryOption {
	return func(c *RetryConfig) { c.Multiplier = m }
}

// WithRetryJitter 设置抖动因子
func WithRetryJitter(j float64) RetryOption {
	return func(c *RetryConfig) { c.Jitter = j }
}

// WithRetryIf 设置可重试判断函数
func WithRetryIf(f func(error) bool) RetryOption {
	return func(c *RetryConfig) { c.RetryIf = f }
}

// Retry 执行带重试的函数
func Retry(ctx context.Context, fn func() error, opts ...RetryOption) error {
	cfg := DefaultRetryConfig()
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
		delay := calculateRetryDelay(cfg, attempt)

		// 等待
		select {
		case <-ctx.Done():
			return ErrContextCanceled
		case <-time.After(delay):
		}
	}

	return lastErr
}

// RetryWithResult 执行带重试的函数（有返回值）
func RetryWithResult[T any](ctx context.Context, fn func() (T, error), opts ...RetryOption) (T, error) {
	cfg := DefaultRetryConfig()
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

		delay := calculateRetryDelay(cfg, attempt)

		select {
		case <-ctx.Done():
			return zero, ErrContextCanceled
		case <-time.After(delay):
		}
	}

	return zero, lastErr
}

// calculateRetryDelay 计算延迟时间
func calculateRetryDelay(cfg RetryConfig, attempt int) time.Duration {
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
	cfg     RetryConfig
	attempt int
}

// NewBackoff 创建退避策略
func NewBackoff(opts ...RetryOption) *Backoff {
	cfg := DefaultRetryConfig()
	for _, opt := range opts {
		opt(&cfg)
	}
	return &Backoff{cfg: cfg}
}

// Next 获取下一次延迟时间
func (b *Backoff) Next() time.Duration {
	delay := calculateRetryDelay(b.cfg, b.attempt)
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
