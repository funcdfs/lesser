// Package config 提供 Auth 服务的配置管理
// 支持从环境变量读取配置，包含安全相关的默认值
package config

import (
	"time"

	pkgConfig "github.com/funcdfs/lesser/pkg/config"
)

// Config Auth 服务配置
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

	// JWT 配置
	JWTSecret            string        // HMAC 密钥（用于 Refresh Token）
	AccessTokenDuration  time.Duration // Access Token 有效期
	RefreshTokenDuration time.Duration // Refresh Token 有效期
	RSAKeySize           int           // RSA 密钥长度
	KeyRotationInterval  time.Duration // 密钥轮换间隔

	// 安全配置
	MaxLoginAttempts    int           // 最大登录失败次数
	LoginLockoutTime    time.Duration // 登录锁定时间
	PasswordMinLength   int           // 密码最小长度
	PasswordRequireNum  bool          // 密码是否需要数字
	PasswordRequireMix  bool          // 密码是否需要大小写混合
	TokenBlacklistTTL   time.Duration // Token 黑名单 TTL
	BanCacheTTL         time.Duration // 封禁状态缓存 TTL
	UserCacheTTL        time.Duration // 用户信息缓存 TTL

	// Argon2id 配置（密码哈希）
	Argon2Memory      uint32 // 内存使用量（KB）
	Argon2Iterations  uint32 // 迭代次数
	Argon2Parallelism uint8  // 并行度
	Argon2SaltLength  uint32 // 盐长度
	Argon2KeyLength   uint32 // 密钥长度
}

// LoadFromEnv 从环境变量加载配置
func LoadFromEnv() *Config {
	env := pkgConfig.GetEnv("ENV", "development")
	isProd := env == "production"

	// 根据环境设置 Token 有效期
	accessDuration := time.Hour // 开发环境 1 小时
	refreshDuration := 7 * 24 * time.Hour // 开发环境 7 天
	if isProd {
		accessDuration = 30 * time.Minute // 生产环境 30 分钟
		refreshDuration = 24 * time.Hour  // 生产环境 1 天
	}

	return &Config{
		// 服务配置
		ServiceName: "auth",
		GRPCPort:    pkgConfig.GetEnv("GRPC_PORT", "50052"),

		// 数据库配置
		DBHost:     pkgConfig.GetEnv("DB_HOST", "localhost"),
		DBPort:     pkgConfig.GetEnv("DB_PORT", "5432"),
		DBUser:     pkgConfig.GetEnv("DB_USER", "postgres"),
		DBPassword: pkgConfig.GetEnv("DB_PASSWORD", "postgres"),
		DBName:     pkgConfig.GetEnv("DB_NAME", "lesser"),
		DBSSLMode:  pkgConfig.GetEnv("DB_SSLMODE", "disable"),

		// Redis 配置
		RedisURL: pkgConfig.GetEnv("REDIS_URL", "redis://localhost:6379/0"),

		// JWT 配置
		JWTSecret:            pkgConfig.GetEnv("JWT_SECRET", "your-secret-key-change-in-production"),
		AccessTokenDuration:  pkgConfig.GetEnvDuration("ACCESS_TOKEN_DURATION", accessDuration),
		RefreshTokenDuration: pkgConfig.GetEnvDuration("REFRESH_TOKEN_DURATION", refreshDuration),
		RSAKeySize:           pkgConfig.GetEnvInt("RSA_KEY_SIZE", 2048),
		KeyRotationInterval:  pkgConfig.GetEnvDuration("KEY_ROTATION_INTERVAL", 30*24*time.Hour),

		// 安全配置
		MaxLoginAttempts:    pkgConfig.GetEnvInt("MAX_LOGIN_ATTEMPTS", 5),
		LoginLockoutTime:    pkgConfig.GetEnvDuration("LOGIN_LOCKOUT_TIME", 15*time.Minute),
		PasswordMinLength:   pkgConfig.GetEnvInt("PASSWORD_MIN_LENGTH", 8),
		PasswordRequireNum:  pkgConfig.GetEnvBool("PASSWORD_REQUIRE_NUM", true),
		PasswordRequireMix:  pkgConfig.GetEnvBool("PASSWORD_REQUIRE_MIX", false),
		TokenBlacklistTTL:   pkgConfig.GetEnvDuration("TOKEN_BLACKLIST_TTL", 24*time.Hour),
		BanCacheTTL:         pkgConfig.GetEnvDuration("BAN_CACHE_TTL", 5*time.Minute),
		UserCacheTTL:        pkgConfig.GetEnvDuration("USER_CACHE_TTL", 10*time.Minute),

		// Argon2id 配置（OWASP 推荐参数）
		Argon2Memory:      pkgConfig.GetEnvUint32("ARGON2_MEMORY", 19456),    // 19 MiB
		Argon2Iterations:  pkgConfig.GetEnvUint32("ARGON2_ITERATIONS", 2),    // 2 次迭代
		Argon2Parallelism: uint8(pkgConfig.GetEnvInt("ARGON2_PARALLELISM", 1)), // 1 线程
		Argon2SaltLength:  pkgConfig.GetEnvUint32("ARGON2_SALT_LENGTH", 16),  // 16 字节
		Argon2KeyLength:   pkgConfig.GetEnvUint32("ARGON2_KEY_LENGTH", 32),   // 32 字节
	}
}
