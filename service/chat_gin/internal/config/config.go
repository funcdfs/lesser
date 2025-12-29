package config

import (
	"errors"
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
}

// Load 从环境变量加载配置
func Load() (*Config, error) {
	cfg := &Config{
		HTTPPort:     getEnv("HTTP_PORT", "8080"),
		GRPCPort:     getEnv("GRPC_PORT", "50052"),
		DatabaseURL:  getEnv("DATABASE_URL", ""),
		RedisURL:     getEnv("REDIS_URL", ""),
		AuthGRPCAddr: getEnv("AUTH_GRPC_ADDR", "django:50051"),
		Environment:  getEnv("ENVIRONMENT", "development"),
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
		log.Println("missing required environment variables: " + strings.Join(missing, ", "))
		return errors.New("missing required environment variables: " + strings.Join(missing, ", "))
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

// getEnv 获取环境变量，如果不存在则报错
func getEnv(key, defaultValue string) string, error) {
	if value := os.Getenv(key); value != "" {
		return value
	}
	log.Println("missing required environment variable: " + key)
	err := errors.New("missing required environment variable: " + key)
	return defaultValue, err
}