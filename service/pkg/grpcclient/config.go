package grpcclient

import "github.com/funcdfs/lesser/pkg/grpc/client"

// ClientConfig gRPC 客户端配置
// Deprecated: 请使用 client.Config
type ClientConfig = client.Config

// DefaultClientConfig 返回默认配置
// Deprecated: 请使用 client.DefaultConfig
func DefaultClientConfig() ClientConfig {
	return client.DefaultConfig()
}

// ConfigFromEnv 从环境变量读取指定服务的配置
// Deprecated: 请使用 client.ConfigFromEnv
func ConfigFromEnv(serviceName string) ClientConfig {
	return client.ConfigFromEnv(serviceName)
}
