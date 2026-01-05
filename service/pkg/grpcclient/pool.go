// Package grpcclient 提供统一的 gRPC 客户端封装
// Deprecated: 请使用 github.com/funcdfs/lesser/pkg/grpc/client 包
package grpcclient

import (
	"github.com/funcdfs/lesser/pkg/grpc/client"
	"github.com/funcdfs/lesser/pkg/logger"
)

// ClientPool gRPC 客户端连接池
// Deprecated: 请使用 client.Pool
type ClientPool = client.Pool

// NewClientPool 创建客户端连接池
// Deprecated: 请使用 client.NewPool
func NewClientPool(log *logger.Logger) *ClientPool {
	return client.NewPool(log)
}
