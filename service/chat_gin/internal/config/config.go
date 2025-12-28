package config

import (
	"errors"
	"os"
)

// Config holds all configuration for the chat service
type Config struct {
	// Server ports
	HTTPPort string
	GRPCPort string

	// Database
	DatabaseURL string

	// Redis
	RedisURL string

	// Auth service
	AuthGRPCAddr string

	// Environment
	Environment string
}

// Load loads configuration from environment variables
func Load() (*Config, error) {
	cfg := &Config{
		HTTPPort:     getEnv("HTTP_PORT", "8080"),
		GRPCPort:     getEnv("GRPC_PORT", "50052"),
		DatabaseURL:  getEnv("DATABASE_URL", ""),
		RedisURL:     getEnv("REDIS_URL", ""),
		AuthGRPCAddr: getEnv("AUTH_GRPC_ADDR", "django:50051"),
		Environment:  getEnv("ENVIRONMENT", "development"),
	}

	// Validate required configuration
	if err := cfg.validate(); err != nil {
		return nil, err
	}

	return cfg, nil
}

// validate checks that all required configuration is present
func (c *Config) validate() error {
	var missing []string

	if c.DatabaseURL == "" {
		missing = append(missing, "DATABASE_URL")
	}

	if len(missing) > 0 {
		return errors.New("missing required environment variables: " + joinStrings(missing, ", "))
	}

	return nil
}

// IsDevelopment returns true if running in development mode
func (c *Config) IsDevelopment() bool {
	return c.Environment == "development"
}

// IsProduction returns true if running in production mode
func (c *Config) IsProduction() bool {
	return c.Environment == "production"
}

// getEnv gets an environment variable with a default value
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

// joinStrings joins strings with a separator
func joinStrings(strs []string, sep string) string {
	if len(strs) == 0 {
		return ""
	}
	result := strs[0]
	for i := 1; i < len(strs); i++ {
		result += sep + strs[i]
	}
	return result
}
