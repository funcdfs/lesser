package db

import (
	"fmt"
	"os"
	"strconv"
)

// RedisConfig Redis 配置
type RedisConfig struct {
	// URL Redis 连接 URL，优先使用（格式：redis://[:password@]host:port/db）
	URL string
	// 以下字段在 URL 为空时使用
	Host     string
	Port     string
	Password string
	DB       int
	// 连接池配置
	PoolSize     int
	MinIdleConns int
}

// DefaultRedisConfig 返回默认配置
func DefaultRedisConfig() RedisConfig {
	return RedisConfig{
		Host:         "localhost",
		Port:         "6379",
		Password:     "",
		DB:           0,
		PoolSize:     10,
		MinIdleConns: 5,
	}
}

// RedisConfigFromEnv 从环境变量读取配置
// 优先使用 REDIS_URL，否则使用 REDIS_HOST/PORT/PASSWORD/DB
func RedisConfigFromEnv() RedisConfig {
	cfg := DefaultRedisConfig()

	// 优先使用 REDIS_URL
	if url := os.Getenv("REDIS_URL"); url != "" {
		cfg.URL = url
		return cfg
	}

	// 使用单独的环境变量
	if host := os.Getenv("REDIS_HOST"); host != "" {
		cfg.Host = host
	}
	if port := os.Getenv("REDIS_PORT"); port != "" {
		cfg.Port = port
	}
	if password := os.Getenv("REDIS_PASSWORD"); password != "" {
		cfg.Password = password
	}
	if dbStr := os.Getenv("REDIS_DB"); dbStr != "" {
		if db, err := strconv.Atoi(dbStr); err == nil {
			cfg.DB = db
		}
	}
	if poolSizeStr := os.Getenv("REDIS_POOL_SIZE"); poolSizeStr != "" {
		if poolSize, err := strconv.Atoi(poolSizeStr); err == nil {
			cfg.PoolSize = poolSize
		}
	}
	if minIdleStr := os.Getenv("REDIS_MIN_IDLE_CONNS"); minIdleStr != "" {
		if minIdle, err := strconv.Atoi(minIdleStr); err == nil {
			cfg.MinIdleConns = minIdle
		}
	}

	return cfg
}

// BuildURL 根据配置构建 Redis URL
func (c RedisConfig) BuildURL() string {
	if c.URL != "" {
		return c.URL
	}

	// 构建 URL: redis://[:password@]host:port/db
	if c.Password != "" {
		return fmt.Sprintf("redis://:%s@%s:%s/%d", c.Password, c.Host, c.Port, c.DB)
	}
	return fmt.Sprintf("redis://%s:%s/%d", c.Host, c.Port, c.DB)
}
