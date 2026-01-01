package broker

import (
	"fmt"
	"log"

	amqp "github.com/rabbitmq/amqp091-go"
)

// 队列名称常量
const (
	QueueAuthRegister = "auth.register"
	QueueAuthLogin    = "auth.login"
	ExchangeGateway   = "gateway.direct"
)

// Connection 封装 RabbitMQ 连接
type Connection struct {
	conn    *amqp.Connection
	channel *amqp.Channel
}

// NewConnection 创建新的 RabbitMQ 连接
func NewConnection(url string) (*Connection, error) {
	conn, err := amqp.Dial(url)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to RabbitMQ: %w", err)
	}

	ch, err := conn.Channel()
	if err != nil {
		conn.Close()
		return nil, fmt.Errorf("failed to open channel: %w", err)
	}

	c := &Connection{
		conn:    conn,
		channel: ch,
	}

	// 初始化 exchange 和队列
	if err := c.setupExchangeAndQueues(); err != nil {
		c.Close()
		return nil, err
	}

	return c, nil
}

// setupExchangeAndQueues 初始化 exchange 和队列
func (c *Connection) setupExchangeAndQueues() error {
	// 声明 direct exchange
	err := c.channel.ExchangeDeclare(
		ExchangeGateway, // name
		"direct",        // type
		true,            // durable
		false,           // auto-deleted
		false,           // internal
		false,           // no-wait
		nil,             // arguments
	)
	if err != nil {
		return fmt.Errorf("failed to declare exchange: %w", err)
	}

	// 声明队列
	queues := []string{QueueAuthRegister, QueueAuthLogin}
	for _, queueName := range queues {
		_, err := c.channel.QueueDeclare(
			queueName, // name
			true,      // durable
			false,     // delete when unused
			false,     // exclusive
			false,     // no-wait
			nil,       // arguments
		)
		if err != nil {
			return fmt.Errorf("failed to declare queue %s: %w", queueName, err)
		}

		// 绑定队列到 exchange
		err = c.channel.QueueBind(
			queueName,       // queue name
			queueName,       // routing key
			ExchangeGateway, // exchange
			false,
			nil,
		)
		if err != nil {
			return fmt.Errorf("failed to bind queue %s: %w", queueName, err)
		}

		log.Printf("Queue %s declared and bound", queueName)
	}

	return nil
}

// Publish 发布消息到指定队列
func (c *Connection) Publish(routingKey string, body []byte) error {
	return c.channel.Publish(
		ExchangeGateway, // exchange
		routingKey,      // routing key
		false,           // mandatory
		false,           // immediate
		amqp.Publishing{
			DeliveryMode: amqp.Persistent,
			ContentType:  "application/protobuf",
			Body:         body,
		},
	)
}

// Close 关闭连接
func (c *Connection) Close() {
	if c.channel != nil {
		c.channel.Close()
	}
	if c.conn != nil {
		c.conn.Close()
	}
}
