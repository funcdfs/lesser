// Package retry 提供重试机制
// Deprecated: 请使用 github.com/funcdfs/lesser/pkg/grpc/client 包中的重试功能
package retry

import (
	"context"

	"github.com/funcdfs/lesser/pkg/grpc/client"
)

// 预定义错误
var (
	// ErrMaxRetriesExceeded 超过最大重试次数
	// Deprecated: 请使用 client.ErrMaxRetriesExceeded
	ErrMaxRetriesExceeded = client.ErrMaxRetriesExceeded
	// ErrContextCanceled context 已取消
	// Deprecated: 请使用 client.ErrContextCanceled
	ErrContextCanceled = client.ErrContextCanceled
)

// Config 重试配置
// Deprecated: 请使用 client.RetryConfig
type Config = client.RetryConfig

// DefaultConfig 默认配置
// Deprecated: 请使用 client.DefaultRetryConfig
var DefaultConfig = client.DefaultRetryConfig

// Option 配置选项
// Deprecated: 请使用 client.RetryOption
type Option = client.RetryOption

// WithMaxRetries 设置最大重试次数
// Deprecated: 请使用 client.WithRetryMaxRetries
var WithMaxRetries = client.WithRetryMaxRetries

// WithInitialDelay 设置初始延迟
// Deprecated: 请使用 client.WithRetryInitialDelay
var WithInitialDelay = client.WithRetryInitialDelay

// WithMaxDelay 设置最大延迟
// Deprecated: 请使用 client.WithRetryMaxDelay
var WithMaxDelay = client.WithRetryMaxDelay

// WithMultiplier 设置延迟倍数
// Deprecated: 请使用 client.WithRetryMultiplier
var WithMultiplier = client.WithRetryMultiplier

// WithJitter 设置抖动因子
// Deprecated: 请使用 client.WithRetryJitter
var WithJitter = client.WithRetryJitter

// WithRetryIf 设置可重试判断函数
// Deprecated: 请使用 client.WithRetryIf
var WithRetryIf = client.WithRetryIf

// Do 执行带重试的函数
// Deprecated: 请使用 client.Retry
func Do(ctx context.Context, fn func() error, opts ...Option) error {
	return client.Retry(ctx, fn, opts...)
}

// DoWithResult 执行带重试的函数（有返回值）
// Deprecated: 请使用 client.RetryWithResult
func DoWithResult[T any](ctx context.Context, fn func() (T, error), opts ...Option) (T, error) {
	return client.RetryWithResult(ctx, fn, opts...)
}

// Backoff 创建退避策略
// Deprecated: 请使用 client.Backoff
type Backoff = client.Backoff

// NewBackoff 创建退避策略
// Deprecated: 请使用 client.NewBackoff
var NewBackoff = client.NewBackoff
