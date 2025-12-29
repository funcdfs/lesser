package config

import (
	"os"
	"testing"
)

func TestLoad(t *testing.T) {
	// 保存原始环境变量
	origDBURL := os.Getenv("DATABASE_URL")
	origHTTPPort := os.Getenv("HTTP_PORT")
	origGRPCPort := os.Getenv("GRPC_PORT")
	origEnv := os.Getenv("ENVIRONMENT")
	origOrigins := os.Getenv("ALLOWED_ORIGINS")

	defer func() {
		os.Setenv("DATABASE_URL", origDBURL)
		os.Setenv("HTTP_PORT", origHTTPPort)
		os.Setenv("GRPC_PORT", origGRPCPort)
		os.Setenv("ENVIRONMENT", origEnv)
		os.Setenv("ALLOWED_ORIGINS", origOrigins)
	}()

	tests := []struct {
		name        string
		envVars     map[string]string
		wantErr     bool
		checkConfig func(*Config) bool
	}{
		{
			name: "valid config",
			envVars: map[string]string{
				"DATABASE_URL": "postgres://localhost/test",
				"HTTP_PORT":    "9090",
				"GRPC_PORT":    "50053",
				"ENVIRONMENT":  "production",
			},
			wantErr: false,
			checkConfig: func(c *Config) bool {
				return c.DatabaseURL == "postgres://localhost/test" &&
					c.HTTPPort == "9090" &&
					c.GRPCPort == "50053" &&
					c.Environment == "production"
			},
		},
		{
			name: "missing DATABASE_URL",
			envVars: map[string]string{
				"DATABASE_URL": "",
			},
			wantErr: true,
		},
		{
			name: "default values",
			envVars: map[string]string{
				"DATABASE_URL": "postgres://localhost/test",
			},
			wantErr: false,
			checkConfig: func(c *Config) bool {
				return c.HTTPPort == "8080" &&
					c.GRPCPort == "50052" &&
					c.Environment == "development"
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// 清除环境变量
			os.Unsetenv("DATABASE_URL")
			os.Unsetenv("HTTP_PORT")
			os.Unsetenv("GRPC_PORT")
			os.Unsetenv("ENVIRONMENT")
			os.Unsetenv("ALLOWED_ORIGINS")

			// 设置测试环境变量
			for k, v := range tt.envVars {
				if v != "" {
					os.Setenv(k, v)
				}
			}

			cfg, err := Load()
			if (err != nil) != tt.wantErr {
				t.Errorf("Load() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			if !tt.wantErr && tt.checkConfig != nil && !tt.checkConfig(cfg) {
				t.Errorf("Load() config check failed")
			}
		})
	}
}

func TestConfig_IsDevelopment(t *testing.T) {
	tests := []struct {
		name        string
		environment string
		want        bool
	}{
		{"development", "development", true},
		{"production", "production", false},
		{"staging", "staging", false},
		{"empty", "", false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			c := &Config{Environment: tt.environment}
			if got := c.IsDevelopment(); got != tt.want {
				t.Errorf("IsDevelopment() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestConfig_IsProduction(t *testing.T) {
	tests := []struct {
		name        string
		environment string
		want        bool
	}{
		{"production", "production", true},
		{"development", "development", false},
		{"staging", "staging", false},
		{"empty", "", false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			c := &Config{Environment: tt.environment}
			if got := c.IsProduction(); got != tt.want {
				t.Errorf("IsProduction() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestParseOrigins(t *testing.T) {
	tests := []struct {
		name  string
		input string
		want  []string
	}{
		{"empty", "", nil},
		{"single", "http://localhost:3000", []string{"http://localhost:3000"}},
		{"multiple", "http://localhost:3000,https://example.com", []string{"http://localhost:3000", "https://example.com"}},
		{"with spaces", " http://localhost:3000 , https://example.com ", []string{"http://localhost:3000", "https://example.com"}},
		{"empty entries", "http://localhost:3000,,https://example.com", []string{"http://localhost:3000", "https://example.com"}},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := parseOrigins(tt.input)
			if len(got) != len(tt.want) {
				t.Errorf("parseOrigins() = %v, want %v", got, tt.want)
				return
			}
			for i := range got {
				if got[i] != tt.want[i] {
					t.Errorf("parseOrigins()[%d] = %v, want %v", i, got[i], tt.want[i])
				}
			}
		})
	}
}

func TestConfig_IsOriginAllowed(t *testing.T) {
	tests := []struct {
		name           string
		environment    string
		allowedOrigins []string
		origin         string
		want           bool
	}{
		{"development allows all", "development", nil, "http://any.com", true},
		{"production no config", "production", nil, "http://any.com", false},
		{"production with wildcard", "production", []string{"*"}, "http://any.com", true},
		{"production exact match", "production", []string{"http://example.com"}, "http://example.com", true},
		{"production no match", "production", []string{"http://example.com"}, "http://other.com", false},
		{"production multiple origins", "production", []string{"http://a.com", "http://b.com"}, "http://b.com", true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			c := &Config{
				Environment:    tt.environment,
				AllowedOrigins: tt.allowedOrigins,
			}
			if got := c.IsOriginAllowed(tt.origin); got != tt.want {
				t.Errorf("IsOriginAllowed() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestGetEnv(t *testing.T) {
	key := "TEST_GET_ENV_KEY"
	defer os.Unsetenv(key)

	// 测试默认值
	if got := getEnv(key, "default"); got != "default" {
		t.Errorf("getEnv() = %v, want default", got)
	}

	// 测试设置值
	os.Setenv(key, "custom")
	if got := getEnv(key, "default"); got != "custom" {
		t.Errorf("getEnv() = %v, want custom", got)
	}
}
