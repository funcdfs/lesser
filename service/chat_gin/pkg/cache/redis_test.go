package cache

import (
	"testing"
)

func TestErrKeyNotFound(t *testing.T) {
	if ErrKeyNotFound.Error() != "key not found" {
		t.Errorf("ErrKeyNotFound.Error() = %v, want 'key not found'", ErrKeyNotFound.Error())
	}
}

func TestNewRedis_EmptyURL(t *testing.T) {
	_, err := NewRedis("")
	if err == nil {
		t.Error("NewRedis() should return error for empty URL")
	}
}

func TestNewRedis_InvalidURL(t *testing.T) {
	_, err := NewRedis("invalid-url")
	if err == nil {
		t.Error("NewRedis() should return error for invalid URL")
	}
}

// 注意：以下测试需要真实的 Redis 连接，在 CI 环境中可能需要跳过
// 可以使用 miniredis 或 testcontainers 进行集成测试

func TestRedisClient_Methods(t *testing.T) {
	// 这是一个占位测试，验证方法签名
	// 实际测试需要 mock 或真实 Redis 连接

	t.Run("method signatures exist", func(t *testing.T) {
		// 验证 RedisClient 结构体存在
		var _ *RedisClient

		// 验证错误类型存在
		_ = ErrKeyNotFound
	})
}
