// Package broker 提供 RabbitMQ 消息队列封装
package broker

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"sync"

	"github.com/funcdfs/lesser/pkg/logger"
	amqp "github.com/rabbitmq/amqp091-go"
)

// Publisher RabbitMQ 消息发布者
// 用于服务间异步事件通知（最终一致性场景）
type Publisher struct {
	url     string
	conn    *amqp.Connection
	channel *amqp.Channel
	log     *logger.Logger
	mu      sync.RWMutex
}

// NewPublisher 创建消息发布者
func NewPublisher(url string, log *logger.Logger) *Publisher {
	return &Publisher{
		url: url,
		log: log,
	}
}

// Connect 建立连接
func (p *Publisher) Connect() error {
	p.mu.Lock()
	defer p.mu.Unlock()

	conn, err := amqp.Dial(p.url)
	if err != nil {
		return fmt.Errorf("连接 RabbitMQ 失败: %w", err)
	}

	ch, err := conn.Channel()
	if err != nil {
		conn.Close()
		return fmt.Errorf("打开 channel 失败: %w", err)
	}

	// 声明默认交换机
	if err := ch.ExchangeDeclare("gateway.direct", "direct", true, false, false, false, nil); err != nil {
		ch.Close()
		conn.Close()
		return fmt.Errorf("声明交换机失败: %w", err)
	}

	p.conn = conn
	p.channel = ch

	p.log.Info("RabbitMQ Publisher 已连接")
	return nil
}

// Close 关闭连接
func (p *Publisher) Close() error {
	p.mu.Lock()
	defer p.mu.Unlock()

	if p.channel != nil {
		p.channel.Close()
	}
	if p.conn != nil {
		p.conn.Close()
	}
	return nil
}

// Publish 发布事件（JSON 序列化）
// routingKey: 路由键，如 "comment.created", "content.liked"
// event: 事件数据，会被 JSON 序列化
func (p *Publisher) Publish(ctx context.Context, routingKey string, event interface{}) error {
	body, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("序列化事件失败: %w", err)
	}

	return p.PublishRaw(ctx, routingKey, body)
}

// PublishRaw 发布原始字节数据
func (p *Publisher) PublishRaw(ctx context.Context, routingKey string, body []byte) error {
	p.mu.RLock()
	ch := p.channel
	p.mu.RUnlock()

	if ch == nil {
		return fmt.Errorf("未连接到 RabbitMQ")
	}

	headers := amqp.Table{}
	if traceID := logger.TraceIDFromContext(ctx); traceID != "" {
		headers["trace_id"] = traceID
	}

	err := ch.PublishWithContext(ctx,
		"gateway.direct",
		routingKey,
		false,
		false,
		amqp.Publishing{
			DeliveryMode: amqp.Persistent,
			ContentType:  "application/json",
			Headers:      headers,
			Body:         body,
		},
	)

	if err != nil {
		p.log.Error("发布消息失败",
			slog.String("routing_key", routingKey),
			slog.Any("error", err))
		return err
	}

	p.log.Debug("消息已发布",
		slog.String("routing_key", routingKey),
		slog.Int("body_size", len(body)))

	return nil
}

// PublishAsync 异步发布事件（不阻塞调用方）
// 适用于不需要等待发布结果的场景
func (p *Publisher) PublishAsync(ctx context.Context, routingKey string, event interface{}) {
	go func() {
		if err := p.Publish(ctx, routingKey, event); err != nil {
			p.log.Error("异步发布消息失败",
				slog.String("routing_key", routingKey),
				slog.Any("error", err))
		}
	}()
}
