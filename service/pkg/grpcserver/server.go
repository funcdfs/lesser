// Package grpcserver 提供 gRPC 服务器封装
// Deprecated: 请使用 github.com/funcdfs/lesser/pkg/grpc/server 包
package grpcserver

import (
	"github.com/funcdfs/lesser/pkg/grpc/server"
	"github.com/funcdfs/lesser/pkg/logger"
)

// Server gRPC 服务器
// Deprecated: 请使用 server.Server
type Server = server.Server

// Config 服务器配置
// Deprecated: 请使用 server.Config
type Config = server.Config

// Option 服务器选项
// Deprecated: 请使用 server.Option
type Option = server.Option

// DefaultConfig 默认配置
// Deprecated: 请使用 server.DefaultConfig
func DefaultConfig() Config {
	return server.DefaultConfig()
}

// WithConfig 设置配置
// Deprecated: 请使用 server.WithConfig
func WithConfig(cfg Config) Option {
	return server.WithConfig(cfg)
}

// New 创建 gRPC 服务器
// Deprecated: 请使用 server.New
func New(log *logger.Logger, opts ...Option) *Server {
	return server.New(log, opts...)
}
