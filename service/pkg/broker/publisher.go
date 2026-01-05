// Package broker 提供 RabbitMQ 消息队列封装
// Deprecated: 请使用 github.com/funcdfs/lesser/pkg/mq 包
package broker

import (
	"github.com/funcdfs/lesser/pkg/logger"
	"github.com/funcdfs/lesser/pkg/mq"
)

// Publisher RabbitMQ 消息发布者
// Deprecated: 请使用 mq.Publisher
type Publisher = mq.Publisher

// NewPublisher 创建消息发布者
// Deprecated: 请使用 mq.NewPublisher
func NewPublisher(url string, log *logger.Logger) *Publisher {
	return mq.NewPublisher(url, log)
}
