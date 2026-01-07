// Package config SuperUser 服务配置
package config

import (
	"crypto/rand"
	"encoding/base64"
	"os"
	"strconv"
	"time"
)

// Config 服务配置
type Config struct {
	// 服务配置
	ServiceName string
	GRPCPort    string

	// 数据库配置
	DBHost     string
	DBPort     string
	DBUser     string
	DBPassword string
	DBName     string
	DBSSLMode  string

	// Redis 配置
	RedisURL string

	// RabbitMQ 配置
	RabbitMQURL string

	// JWT 配置
	JWTSecret            string
	AccessTokenDuration  time.Duration
	RefreshTokenDuration time.Duration

	// 默认超级管理员配置
	DefaultUsername    string
	DefaultEmail       string
	DefaultPassword    string
	DefaultDisplayName string

	// Argon2 密码哈希参数
	Argon2Memory      uint32
	Argon2Iterations  uint32
	Argon2Parallelism uint8
	Argon2SaltLength  uint32
	Argon2KeyLength   uint32

	// 安全配置
	MaxLoginAttempts int
	LoginLockoutTime time.Duration
}

// LoadFromEnv 从环境变量加载配置
func LoadFromEnv() *Config {
	// 生成随机默认密码（仅在未设置环境变量时使用）
	defaultPassword := getEnv("SUPERUSER_PASSWORD", "")
	if defaultPassword == "" {
		// 生成随机密码，强制用户通过环境变量设置
		defaultPassword = generateRandomPassword()
	}

	// JWT 密钥必须从环境变量获取
	jwtSecret := getEnv("SUPERUSER_JWT_SECRET", "")
	if jwtSecret == "" {
		// 生成随机密钥（生产环境应该通过环境变量设置）
		jwtSecret = generateRandomPassword()
	}

	return &Config{
		// 服务配置
		ServiceName: getEnv("SERVICE_NAME", "superuser"),
		GRPCPort:    getEnv("GRPC_PORT", "50061"),

		// 数据库配置
		DBHost:     getEnv("DB_HOST", "postgres"),
		DBPort:     getEnv("DB_PORT", "5432"),
		DBUser:     getEnv("DB_USER", "lesser"),
		DBPassword: getEnv("DB_PASSWORD", "lesser_dev_password"),
		DBName:     getEnv("DB_NAME", "lesser_db"),
		DBSSLMode:  getEnv("DB_SSLMODE", "disable"),

		// Redis 配置
		RedisURL: getEnv("REDIS_URL", "redis://redis:6379/2"),

		// RabbitMQ 配置
		RabbitMQURL: getEnv("RABBITMQ_URL", "amqp://funcdfs:fw142857@rabbitmq:5672/"),

		// JWT 配置
		JWTSecret:            jwtSecret,
		AccessTokenDuration:  getDurationEnv("ACCESS_TOKEN_DURATION", 30*time.Minute),
		RefreshTokenDuration: getDurationEnv("REFRESH_TOKEN_DURATION", 24*time.Hour),

		// 默认超级管理员配置（必须通过环境变量设置）
		DefaultUsername:    getEnv("SUPERUSER_USERNAME", "admin"),
		DefaultEmail:       getEnv("SUPERUSER_EMAIL", "admin@lesser.local"),
		DefaultPassword:    defaultPassword,
		DefaultDisplayName: getEnv("SUPERUSER_DISPLAY_NAME", "Administrator"),

		// Argon2 密码哈希参数（OWASP 推荐）
		Argon2Memory:      getUint32Env("ARGON2_MEMORY", 19456), // 19 MiB
		Argon2Iterations:  getUint32Env("ARGON2_ITERATIONS", 2),
		Argon2Parallelism: uint8(getIntEnv("ARGON2_PARALLELISM", 1)),
		Argon2SaltLength:  getUint32Env("ARGON2_SALT_LENGTH", 16),
		Argon2KeyLength:   getUint32Env("ARGON2_KEY_LENGTH", 32),

		// 安全配置
		MaxLoginAttempts: getIntEnv("MAX_LOGIN_ATTEMPTS", 5),
		LoginLockoutTime: getDurationEnv("LOGIN_LOCKOUT_TIME", 15*time.Minute),
	}
}

// generateRandomPassword 生成随机密码
func generateRandomPassword() string {
	bytes := make([]byte, 32)
	if _, err := rand.Read(bytes); err != nil {
		// 回退到固定值（仅开发环境）
		return "change-me-in-production"
	}
	return base64.URLEncoding.EncodeToString(bytes)[:24]
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getIntEnv(key string, defaultValue int) int {
	if value := os.Getenv(key); value != "" {
		if intValue, err := strconv.Atoi(value); err == nil {
			return intValue
		}
	}
	return defaultValue
}

func getUint32Env(key string, defaultValue uint32) uint32 {
	if value := os.Getenv(key); value != "" {
		if intValue, err := strconv.ParseUint(value, 10, 32); err == nil {
			return uint32(intValue)
		}
	}
	return defaultValue
}

func getDurationEnv(key string, defaultValue time.Duration) time.Duration {
	if value := os.Getenv(key); value != "" {
		if duration, err := time.ParseDuration(value); err == nil {
			return duration
		}
	}
	return defaultValue
}
