package mq

import (
	"context"
	"fmt"
	"log/slog"
	"math"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"

	"github.com/funcdfs/lesser/pkg/logger"
	amqp "github.com/rabbitmq/amqp091-go"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/codes"
	"go.opentelemetry.io/otel/trace"
)

// Handler 消息处理函数类型
// 返回 error 时消息会被 Nack，返回 nil 时消息会被 Ack
type Handler func(ctx context.Context, body []byte) error

// Config Worker 配置
type Config struct {
	// Queue 队列名称
	Queue string
	// Handler 消息处理函数
	Handler Handler
	// Exchange 交换机名称（可选，默认使用 gateway.direct）
	Exchange string
	// RoutingKey 路由键（可选，默认使用队列名称）
	RoutingKey string
	// PrefetchCount 预取数量（可选，默认 1）
	PrefetchCount int
	// AutoAck 是否自动确认（可选，默认 false）
	AutoAck bool
}

// Worker RabbitMQ 消费者
type Worker struct {
	url        string
	conn       *amqp.Connection
	channel    *amqp.Channel
	log        *logger.Logger
	configs    []Config
	stopCh     chan struct{}
	wg         sync.WaitGroup
	mu         sync.RWMutex
	reconnectC chan struct{}
}

// NewWorker 创建新的 Worker 实例
func NewWorker(url string, log *logger.Logger) *Worker {
	return &Worker{
		url:        url,
		log:        log,
		stopCh:     make(chan struct{}),
		reconnectC: make(chan struct{}, 1),
	}
}


// Start 启动 Worker，阻塞直到收到停止信号
func (w *Worker) Start(ctx context.Context, configs ...Config) error {
	w.configs = configs

	// 初始连接
	if err := w.connect(); err != nil {
		return fmt.Errorf("initial connection failed: %w", err)
	}

	// 启动消费者
	for _, cfg := range configs {
		if err := w.startConsumer(ctx, cfg); err != nil {
			return fmt.Errorf("failed to start consumer for queue %s: %w", cfg.Queue, err)
		}
	}

	// 启动重连监控
	go w.watchConnection()

	// 监听系统信号
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)

	select {
	case <-ctx.Done():
		w.log.Info("context cancelled, shutting down")
	case sig := <-sigCh:
		w.log.Info("received signal, shutting down", slog.String("signal", sig.String()))
	}

	w.Stop()
	return nil
}

// Stop 优雅停止 Worker
func (w *Worker) Stop() {
	close(w.stopCh)
	w.wg.Wait()

	w.mu.Lock()
	defer w.mu.Unlock()

	if w.channel != nil {
		w.channel.Close()
	}
	if w.conn != nil {
		w.conn.Close()
	}

	w.log.Info("worker stopped gracefully")
}

// connect 建立 RabbitMQ 连接
func (w *Worker) connect() error {
	w.mu.Lock()
	defer w.mu.Unlock()

	conn, err := amqp.Dial(w.url)
	if err != nil {
		return fmt.Errorf("failed to connect to RabbitMQ: %w", err)
	}

	ch, err := conn.Channel()
	if err != nil {
		conn.Close()
		return fmt.Errorf("failed to open channel: %w", err)
	}

	w.conn = conn
	w.channel = ch

	w.log.Info("connected to RabbitMQ")
	return nil
}

// watchConnection 监控连接状态，断开时自动重连
func (w *Worker) watchConnection() {
	for {
		select {
		case <-w.stopCh:
			return
		case <-w.reconnectC:
			w.reconnect()
		}
	}
}

// reconnect 重连逻辑（指数退避）
func (w *Worker) reconnect() {
	maxRetries := 10
	baseDelay := time.Second

	for i := 0; i < maxRetries; i++ {
		select {
		case <-w.stopCh:
			return
		default:
		}

		delay := time.Duration(math.Pow(2, float64(i))) * baseDelay
		if delay > 30*time.Second {
			delay = 30 * time.Second
		}

		w.log.Warn("attempting to reconnect",
			slog.Int("attempt", i+1),
			slog.Duration("delay", delay))

		time.Sleep(delay)

		if err := w.connect(); err != nil {
			w.log.Error("reconnection failed", slog.Any("error", err))
			continue
		}

		// 重新启动所有消费者
		ctx := context.Background()
		for _, cfg := range w.configs {
			if err := w.startConsumer(ctx, cfg); err != nil {
				w.log.Error("failed to restart consumer",
					slog.String("queue", cfg.Queue),
					slog.Any("error", err))
			}
		}

		w.log.Info("reconnected successfully")
		return
	}

	w.log.Fatal("max reconnection attempts reached, giving up")
}


// startConsumer 启动单个队列的消费者
func (w *Worker) startConsumer(ctx context.Context, cfg Config) error {
	w.mu.RLock()
	ch := w.channel
	w.mu.RUnlock()

	// 设置预取数量
	prefetch := cfg.PrefetchCount
	if prefetch <= 0 {
		prefetch = 1
	}
	if err := ch.Qos(prefetch, 0, false); err != nil {
		return fmt.Errorf("failed to set QoS: %w", err)
	}

	// 声明交换机
	exchange := cfg.Exchange
	if exchange == "" {
		exchange = "gateway.direct"
	}
	if err := ch.ExchangeDeclare(exchange, "direct", true, false, false, false, nil); err != nil {
		return fmt.Errorf("failed to declare exchange: %w", err)
	}

	// 声明队列
	if _, err := ch.QueueDeclare(cfg.Queue, true, false, false, false, nil); err != nil {
		return fmt.Errorf("failed to declare queue: %w", err)
	}

	// 绑定队列
	routingKey := cfg.RoutingKey
	if routingKey == "" {
		routingKey = cfg.Queue
	}
	if err := ch.QueueBind(cfg.Queue, routingKey, exchange, false, nil); err != nil {
		return fmt.Errorf("failed to bind queue: %w", err)
	}

	// 开始消费
	msgs, err := ch.Consume(cfg.Queue, "", cfg.AutoAck, false, false, false, nil)
	if err != nil {
		return fmt.Errorf("failed to start consuming: %w", err)
	}

	w.wg.Add(1)
	go w.consume(ctx, cfg.Queue, msgs, cfg.Handler, cfg.AutoAck)

	w.log.Info("consumer started", slog.String("queue", cfg.Queue))
	return nil
}

// consume 消费循环
// 从消息头提取 trace_id 并注入到 handler context
// 创建 OpenTelemetry Span 用于追踪消息处理
func (w *Worker) consume(ctx context.Context, queue string, msgs <-chan amqp.Delivery, handler Handler, autoAck bool) {
	defer w.wg.Done()

	tracer := otel.Tracer("rabbitmq-consumer")

	for {
		select {
		case <-w.stopCh:
			return
		case msg, ok := <-msgs:
			if !ok {
				// 通道关闭，触发重连
				select {
				case w.reconnectC <- struct{}{}:
				default:
				}
				return
			}

			// 从消息头提取 trace_id
			var traceID string
			if tid, ok := msg.Headers["trace_id"].(string); ok && tid != "" {
				traceID = tid
			}

			// 创建消息处理 context，注入 trace_id
			msgCtx := ctx
			if traceID != "" {
				msgCtx = logger.ContextWithTraceID(ctx, traceID)
			}

			// 创建 OpenTelemetry Span
			msgCtx, span := tracer.Start(msgCtx, "consume "+queue,
				trace.WithSpanKind(trace.SpanKindConsumer),
			)

			// 设置 Span 属性
			span.SetAttributes(
				attribute.String("messaging.system", "rabbitmq"),
				attribute.String("messaging.destination", queue),
				attribute.String("messaging.operation", "receive"),
				attribute.Int("messaging.message.body.size", len(msg.Body)),
			)
			if traceID != "" {
				span.SetAttributes(attribute.String("trace_id", traceID))
			}

			// 处理消息
			if err := handler(msgCtx, msg.Body); err != nil {
				span.RecordError(err)
				span.SetStatus(codes.Error, err.Error())
				w.log.WithContext(msgCtx).Error("message handling failed",
					slog.String("queue", queue),
					slog.String("trace_id", traceID),
					slog.Any("error", err))
				if !autoAck {
					msg.Nack(false, true) // 重新入队
				}
			} else {
				span.SetStatus(codes.Ok, "")
				if !autoAck {
					msg.Ack(false)
				}
			}

			span.End()
		}
	}
}

// Publish 发布消息到指定队列
// 自动传播 trace_id 到消息头
func (w *Worker) Publish(ctx context.Context, routingKey string, body []byte) error {
	w.mu.RLock()
	ch := w.channel
	w.mu.RUnlock()

	// 从 context 中提取 trace_id
	traceID := logger.TraceIDFromContext(ctx)

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
			ContentType:  "application/protobuf",
			Headers:      headers,
			Body:         body,
		},
	)

	if err != nil {
		w.log.WithContext(ctx).Error("发布消息失败",
			slog.String("routing_key", routingKey),
			slog.String("trace_id", traceID),
			slog.Any("error", err))
	}

	return err
}
