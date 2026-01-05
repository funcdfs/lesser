// Package broker 提供 RabbitMQ 消息队列封装
// Deprecated: 请使用 github.com/funcdfs/lesser/pkg/mq 包
package broker

import (
	"github.com/funcdfs/lesser/pkg/logger"
	"github.com/funcdfs/lesser/pkg/mq"
)

// Handler 消息处理函数类型
// Deprecated: 请使用 mq.Handler
type Handler = mq.Handler

// Config Worker 配置
// Deprecated: 请使用 mq.Config
type Config = mq.Config

// Worker RabbitMQ 消费者
// Deprecated: 请使用 mq.Worker
type Worker = mq.Worker

// NewWorker 创建新的 Worker 实例
// Deprecated: 请使用 mq.NewWorker
func NewWorker(url string, log *logger.Logger) *Worker {
	return mq.NewWorker(url, log)
}
