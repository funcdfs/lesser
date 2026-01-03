// Package ratelimit 限流器单元测试
package ratelimit

import (
	"testing"
	"time"
)

func TestLimiter_Allow_GlobalLimit(t *testing.T) {
	// 创建限流器，每秒 10 个请求，突发 20
	limiter := NewLimiter(Config{
		Rate:  10,
		Burst: 20,
	})
	defer limiter.Stop()

	// 前 20 个请求应该都通过（突发容量）
	for i := 0; i < 20; i++ {
		if !limiter.Allow() {
			t.Errorf("第 %d 个请求应该通过", i+1)
		}
	}

	// 第 21 个请求应该被限流
	if limiter.Allow() {
		t.Error("超出突发容量后应该被限流")
	}
}

func TestLimiter_AllowKey_PerKeyLimit(t *testing.T) {
	// 创建限流器
	limiter := NewLimiter(Config{
		Rate:  5,
		Burst: 10,
	})
	defer limiter.Stop()

	key1 := "user-1"
	key2 := "user-2"

	// key1 消耗所有突发容量
	for i := 0; i < 10; i++ {
		if !limiter.AllowKey(key1) {
			t.Errorf("key1 第 %d 个请求应该通过", i+1)
		}
	}

	// key1 应该被限流
	if limiter.AllowKey(key1) {
		t.Error("key1 超出突发容量后应该被限流")
	}

	// key2 应该仍然可以通过（独立限流）
	if !limiter.AllowKey(key2) {
		t.Error("key2 应该可以通过，因为它有独立的限流器")
	}
}

func TestLimiter_AllowN(t *testing.T) {
	// 创建限流器
	limiter := NewLimiter(Config{
		Rate:  10,
		Burst: 20,
	})
	defer limiter.Stop()

	key := "test-key"

	// 一次请求 15 个令牌
	if !limiter.AllowN(key, 15) {
		t.Error("请求 15 个令牌应该通过")
	}

	// 再请求 10 个令牌应该失败（只剩 5 个）
	if limiter.AllowN(key, 10) {
		t.Error("请求 10 个令牌应该失败，因为只剩 5 个")
	}

	// 请求 5 个令牌应该通过
	if !limiter.AllowN(key, 5) {
		t.Error("请求 5 个令牌应该通过")
	}
}

func TestLimiter_Stats(t *testing.T) {
	// 创建限流器
	limiter := NewLimiter(Config{
		Rate:  100,
		Burst: 200,
	})
	defer limiter.Stop()

	// 创建一些 key 的限流器
	limiter.AllowKey("key1")
	limiter.AllowKey("key2")
	limiter.AllowKey("key3")

	stats := limiter.Stats()

	if stats["rate"].(float64) != 100 {
		t.Errorf("rate 不匹配: 期望 100, 实际 %v", stats["rate"])
	}

	if stats["burst"].(int) != 200 {
		t.Errorf("burst 不匹配: 期望 200, 实际 %v", stats["burst"])
	}

	if stats["limiter_count"].(int) != 3 {
		t.Errorf("limiter_count 不匹配: 期望 3, 实际 %v", stats["limiter_count"])
	}

	if stats["stopped"].(bool) != false {
		t.Error("stopped 应该为 false")
	}
}

func TestLimiter_Stop(t *testing.T) {
	// 创建限流器
	limiter := NewLimiter(DefaultConfig())

	// 停止限流器
	limiter.Stop()

	// 停止后所有请求应该被拒绝
	if limiter.Allow() {
		t.Error("停止后全局请求应该被拒绝")
	}

	if limiter.AllowKey("any-key") {
		t.Error("停止后 key 请求应该被拒绝")
	}
}

func TestLimiter_Stop_Idempotent(t *testing.T) {
	// 创建限流器
	limiter := NewLimiter(DefaultConfig())

	// 多次调用 Stop 不应该 panic
	limiter.Stop()
	limiter.Stop()
	limiter.Stop()
}

func TestLimiter_DefaultConfig(t *testing.T) {
	cfg := DefaultConfig()

	if cfg.Rate != 100 {
		t.Errorf("默认 Rate 应该是 100, 实际 %v", cfg.Rate)
	}

	if cfg.Burst != 200 {
		t.Errorf("默认 Burst 应该是 200, 实际 %v", cfg.Burst)
	}

	if cfg.CleanupInterval != 5*time.Minute {
		t.Errorf("默认 CleanupInterval 应该是 5 分钟, 实际 %v", cfg.CleanupInterval)
	}

	if cfg.LimiterExpiry != 10*time.Minute {
		t.Errorf("默认 LimiterExpiry 应该是 10 分钟, 实际 %v", cfg.LimiterExpiry)
	}
}

func TestLimiter_InvalidConfig(t *testing.T) {
	// 使用无效配置创建限流器，应该使用默认值
	limiter := NewLimiter(Config{
		Rate:  -1,
		Burst: -1,
	})
	defer limiter.Stop()

	stats := limiter.Stats()

	// 应该使用默认值
	if stats["rate"].(float64) != DefaultConfig().Rate {
		t.Errorf("无效 Rate 应该使用默认值")
	}
}

func TestLimiter_RateRecovery(t *testing.T) {
	// 创建限流器，每秒 1000 个请求
	limiter := NewLimiter(Config{
		Rate:  1000,
		Burst: 10,
	})
	defer limiter.Stop()

	key := "test-key"

	// 消耗所有突发容量
	for i := 0; i < 10; i++ {
		limiter.AllowKey(key)
	}

	// 应该被限流
	if limiter.AllowKey(key) {
		t.Error("应该被限流")
	}

	// 等待一小段时间让令牌恢复
	time.Sleep(20 * time.Millisecond)

	// 应该可以通过了
	if !limiter.AllowKey(key) {
		t.Error("等待后应该可以通过")
	}
}
