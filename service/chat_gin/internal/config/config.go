package config

import (
	"errors"
	"log"
	"os"
	"strings"
)

// Config 服务配置
type Config struct {
	// 服务端口
	HTTPPort string
	GRPCPort string

	// 数据库
	DatabaseURL string

	// Redis
	RedisURL string

	// Auth gRPC 服务地址
	AuthGRPCAddr string

	// 环境
	Environment string

	// CORS 允许的来源列表（逗号分隔）
	// 例如: "http://localhost:3000,https://example.com"
	AllowedOrigins []string
}

// Load 从环境变量加载配置
func Load() (*Config, error) {
	cfg := &Config{
		HTTPPort:       getEnv("HTTP_PORT", "8080"),
		GRPCPort:       getEnv("GRPC_PORT", "50052"),
		DatabaseURL:    getEnv("DATABASE_URL", ""),
		RedisURL:       getEnv("REDIS_URL", ""),
		AuthGRPCAddr:   getEnv("AUTH_GRPC_ADDR", "django:50051"),
		Environment:    getEnv("ENVIRONMENT", "development"),
		AllowedOrigins: parseOrigins(getEnv("ALLOWED_ORIGINS", "")),
	}

	// 验证必填配置
	if err := cfg.validate(); err != nil {
		return nil, err
	}

	return cfg, nil
}

// validate 检查必填配置
func (c *Config) validate() error {
	var missing []string

	if c.DatabaseURL == "" {
		missing = append(missing, "DATABASE_URL")
	}

	if len(missing) > 0 {
		log.Println("缺少必填环境变量: " + strings.Join(missing, ", "))
		return errors.New("缺少必填环境变量: " + strings.Join(missing, ", "))
	}

	return nil
}

// IsDevelopment 判断是否开发环境
func (c *Config) IsDevelopment() bool {
	return c.Environment == "development"
}

// IsProduction 判断是否生产环境
func (c *Config) IsProduction() bool {
	return c.Environment == "production"
}

// getEnv 获取环境变量，不存在则返回默认值
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

// parseOrigins 解析来源列表（逗号分隔）
func parseOrigins(s string) []string {
	if s == "" {
		return nil
	}
	origins := strings.Split(s, ",")
	result := make([]string, 0, len(origins))
	for _, origin := range origins {
		origin = strings.TrimSpace(origin)
		if origin != "" {
			result = append(result, origin)
		}
	}
	return result
}

// IsOriginAllowed 检查来源是否被允许
func (c *Config) IsOriginAllowed(origin string) bool {
	// 开发环境允许所有来源
	if c.IsDevelopment() {
		return true
	}

	// 未配置允许来源时，拒绝所有
	if len(c.AllowedOrigins) == 0 {
		return false
	}

	// 检查来源是否在允许列表中
	for _, allowed := range c.AllowedOrigins {
		if allowed == "*" || allowed == origin {
			return true
		}
	}
	return false
}