package config

import (
	"errors"
	"log"
	"os"
	"strings"
)

type Config struct {
	WSPort       string // WebSocket 端口
	GRPCPort     string // gRPC 端口
	DatabaseURL  string
	RedisURL     string
	AuthGRPCAddr string
	Environment  string
	AllowedOrigins []string
}

func Load() (*Config, error) {
	cfg := &Config{
		WSPort:         getEnv("WS_PORT", "8080"),
		GRPCPort:       getEnv("GRPC_PORT", "50052"),
		DatabaseURL:    getEnv("DATABASE_URL", ""),
		RedisURL:       getEnv("REDIS_URL", ""),
		AuthGRPCAddr:   getEnv("AUTH_GRPC_ADDR", "gateway:50053"),
		Environment:    getEnv("ENVIRONMENT", "development"),
		AllowedOrigins: parseOrigins(getEnv("ALLOWED_ORIGINS", "")),
	}

	if err := cfg.validate(); err != nil {
		return nil, err
	}

	return cfg, nil
}

func (c *Config) validate() error {
	if c.DatabaseURL == "" {
		log.Println("缺少必填环境变量: DATABASE_URL")
		return errors.New("缺少必填环境变量: DATABASE_URL")
	}
	return nil
}

func (c *Config) IsDevelopment() bool {
	return c.Environment == "development"
}

func (c *Config) IsProduction() bool {
	return c.Environment == "production"
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

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

func (c *Config) IsOriginAllowed(origin string) bool {
	if c.IsDevelopment() {
		return true
	}
	if len(c.AllowedOrigins) == 0 {
		return false
	}
	for _, allowed := range c.AllowedOrigins {
		if allowed == "*" || allowed == origin {
			return true
		}
	}
	return false
}
