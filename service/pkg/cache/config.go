// Package cache 提供统一的 Redis 缓存封装
// Deprecated: 请使用 github.com/funcdfs/lesser/pkg/db 包
package cache

import "github.com/funcdfs/lesser/pkg/db"

// Config Redis 配置
// Deprecated: 请使用 db.RedisConfig
type Config = db.RedisConfig

// DefaultConfig 返回默认配置
// Deprecated: 请使用 db.DefaultRedisConfig
func DefaultConfig() Config {
	return db.DefaultRedisConfig()
}

// ConfigFromEnv 从环境变量读取配置
// Deprecated: 请使用 db.RedisConfigFromEnv
func ConfigFromEnv() Config {
	return db.RedisConfigFromEnv()
}
