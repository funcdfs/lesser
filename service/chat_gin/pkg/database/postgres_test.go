package database

import (
	"testing"
)

func TestNewPostgres_EmptyURL(t *testing.T) {
	_, err := NewPostgres("")
	if err == nil {
		t.Error("NewPostgres() should return error for empty URL")
	}
}

func TestNewPostgres_InvalidURL(t *testing.T) {
	// 使用无效的连接字符串
	_, err := NewPostgres("invalid-connection-string")
	if err == nil {
		t.Error("NewPostgres() should return error for invalid URL")
	}
}

// 注意：以下测试需要真实的 PostgreSQL 连接，在 CI 环境中可能需要跳过
// 可以使用 testcontainers 或 dockertest 进行集成测试

func TestDatabaseFunctions(t *testing.T) {
	t.Run("function signatures exist", func(t *testing.T) {
		// 验证函数存在
		_ = NewPostgres
		_ = AutoMigrate
	})
}
