// Package config 提供统一的配置管理
// 支持从环境变量读取配置
package config

import (
	"os"
	"strconv"
	"time"
)

// GetEnv 获取环境变量，如果不存在则返回默认值
func GetEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

// GetEnvInt 获取整数类型的环境变量
func GetEnvInt(key string, defaultValue int) int {
	if value := os.Getenv(key); value != "" {
		if i, err := strconv.Atoi(value); err == nil {
			return i
		}
	}
	return defaultValue
}

// GetEnvBool 获取布尔类型的环境变量
func GetEnvBool(key string, defaultValue bool) bool {
	if value := os.Getenv(key); value != "" {
		if b, err := strconv.ParseBool(value); err == nil {
			return b
		}
	}
	return defaultValue
}

// GetEnvDuration 获取时间间隔类型的环境变量
func GetEnvDuration(key string, defaultValue time.Duration) time.Duration {
	if value := os.Getenv(key); value != "" {
		if d, err := time.ParseDuration(value); err == nil {
			return d
		}
	}
	return defaultValue
}

// MustGetEnv 获取必需的环境变量，如果不存在则 panic
func MustGetEnv(key string) string {
	value := os.Getenv(key)
	if value == "" {
		panic("required environment variable not set: " + key)
	}
	return value
}

// LookupEnv 查找环境变量，返回值和是否存在
func LookupEnv(key string) (string, bool) {
	return os.LookupEnv(key)
}

// GetEnvUint32 获取 uint32 类型的环境变量
func GetEnvUint32(key string, defaultValue uint32) uint32 {
	if value := os.Getenv(key); value != "" {
		if i, err := strconv.ParseUint(value, 10, 32); err == nil {
			return uint32(i)
		}
	}
	return defaultValue
}

// GetEnvInt64 获取 int64 类型的环境变量
func GetEnvInt64(key string, defaultValue int64) int64 {
	if value := os.Getenv(key); value != "" {
		if i, err := strconv.ParseInt(value, 10, 64); err == nil {
			return i
		}
	}
	return defaultValue
}
