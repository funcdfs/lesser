// Package grpcclient 提供统一的 gRPC 客户端封装
// 支持连接池管理、自动重连、拦截器（日志、追踪、重试）
package grpcclient

import (
	"os"
	"strconv"
	"strings"
	"time"
)

// ClientConfig gRPC 客户端配置
type ClientConfig struct {
	// Target 服务地址（host:port）
	Target string
	// Insecure 是否使用不安全连接（无 TLS）
	Insecure bool
	// Timeout 连接超时
	Timeout time.Duration
	// MaxRetries 最大重试次数
	MaxRetries int
	// RetryBackoff 重试退避时间
	RetryBackoff time.Duration
}

// DefaultClientConfig 返回默认配置
func DefaultClientConfig() ClientConfig {
	return ClientConfig{
		Insecure:     true,
		Timeout:      5 * time.Second,
		MaxRetries:   3,
		RetryBackoff: 100 * time.Millisecond,
	}
}

// ConfigFromEnv 从环境变量读取指定服务的配置
// 环境变量格式：GRPC_{SERVICE_NAME}_ADDR, GRPC_{SERVICE_NAME}_INSECURE 等
// 例如：GRPC_AUTH_ADDR=auth:50051
func ConfigFromEnv(serviceName string) ClientConfig {
	cfg := DefaultClientConfig()
	prefix := "GRPC_" + strings.ToUpper(serviceName) + "_"

	if addr := os.Getenv(prefix + "ADDR"); addr != "" {
		cfg.Target = addr
	}

	if insecure := os.Getenv(prefix + "INSECURE"); insecure != "" {
		if b, err := strconv.ParseBool(insecure); err == nil {
			cfg.Insecure = b
		}
	}

	if timeout := os.Getenv(prefix + "TIMEOUT"); timeout != "" {
		if d, err := time.ParseDuration(timeout); err == nil {
			cfg.Timeout = d
		}
	}

	if maxRetries := os.Getenv(prefix + "MAX_RETRIES"); maxRetries != "" {
		if n, err := strconv.Atoi(maxRetries); err == nil {
			cfg.MaxRetries = n
		}
	}

	if backoff := os.Getenv(prefix + "RETRY_BACKOFF"); backoff != "" {
		if d, err := time.ParseDuration(backoff); err == nil {
			cfg.RetryBackoff = d
		}
	}

	return cfg
}
