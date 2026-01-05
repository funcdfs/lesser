// Package mq 提供 RabbitMQ 消息队列封装
// 支持 TraceID 传播和 OpenTelemetry 追踪
package mq

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"sync"

	"github.com/funcdfs/lesser/pkg/log"
	amqp "github.com/rabbitmq/amqp091-go"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/codes"
	"go.opentelemetry.io/otel/trace"
)

// Publisher RabbitMQ 消息发布者
// 用于服务间异步事件通知（最终一致性场景）
type Publisher struct {
	url     string
	conn    *amqp.Connection
	channel *amqp.Channel
	log     *log.Logger
	mu      sync.RWMutex
}

// NewPublisher 创建消息发布者
func NewPublisher(url string, logger *log.Logger) *Publisher {
	return &Publisher{
		url: url,
		log: logger,
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
// 自动传播 trace_id 到消息头，并创建 OpenTelemetry Span
func (p *Publisher) PublishRaw(ctx context.Context, routingKey string, body []byte) error {
	p.mu.RLock()
	ch := p.channel
	conn := p.conn
	p.mu.RUnlock()

	if ch == nil || conn == nil {
		return fmt.Errorf("未连接到 RabbitMQ")
	}

	// 检查连接是否已关闭
	if conn.IsClosed() {
		return fmt.Errorf("RabbitMQ 连接已关闭")
	}

	// 从 context 中提取 trace_id
	traceID := log.TraceIDFromContext(ctx)

	// 创建 OpenTelemetry Span
	tracer := otel.Tracer("rabbitmq-publisher")
	ctx, span := tracer.Start(ctx, "publish "+routingKey,
		trace.WithSpanKind(trace.SpanKindProducer),
	)
	defer span.End()

	// 设置 Span 属性
	span.SetAttributes(
		attribute.String("messaging.system", "rabbitmq"),
		attribute.String("messaging.destination", routingKey),
		attribute.String("messaging.operation", "publish"),
		attribute.Int("messaging.message.body.size", len(body)),
	)
	if traceID != "" {
		span.SetAttributes(attribute.String("trace_id", traceID))
	}

	// 构建消息头，包含 trace_id
	headers := amqp.Table{}
	if traceID != "" {
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
		span.RecordError(err)
		span.SetStatus(codes.Error, err.Error())
		p.log.WithContext(ctx).Error("发布消息失败",
			slog.String("routing_key", routingKey),
			slog.String("trace_id", traceID),
			slog.Any("error", err))
		return err
	}

	span.SetStatus(codes.Ok, "")
	p.log.WithContext(ctx).Debug("消息已发布",
		slog.String("routing_key", routingKey),
		slog.String("trace_id", traceID),
		slog.Int("body_size", len(body)))

	return nil
}

// PublishAsync 异步发布事件（不阻塞调用方）
// 适用于不需要等待发布结果的场景
// 自动传播 trace_id 到消息头
func (p *Publisher) PublishAsync(ctx context.Context, routingKey string, event interface{}) {
	// 提取 trace_id 以便在 goroutine 中使用
	traceID := log.TraceIDFromContext(ctx)

	go func() {
		// 在新的 goroutine 中重新注入 trace_id
		asyncCtx := context.Background()
		if traceID != "" {
			asyncCtx = log.ContextWithTraceID(asyncCtx, traceID)
		}

		if err := p.Publish(asyncCtx, routingKey, event); err != nil {
			p.log.Error("异步发布消息失败",
				slog.String("routing_key", routingKey),
				slog.String("trace_id", traceID),
				slog.Any("error", err))
		}
	}()
}
