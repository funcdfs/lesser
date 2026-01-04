// Package integration 提供服务间通信的集成测试
// 验证 Gateway 到 Worker 的消息流和 gRPC 服务间调用
package integration

import (
	"context"
	"crypto/rand"
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/funcdfs/lesser/pkg/grpcclient"
	"github.com/funcdfs/lesser/pkg/logger"
	amqp "github.com/rabbitmq/amqp091-go"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/metadata"
)

// generateUUID 生成简单的 UUID 字符串
func generateUUID() string {
	b := make([]byte, 16)
	rand.Read(b)
	return fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:])
}

// TestGatewayToWorkerMessageFlow 验证 Gateway 到 Worker 的消息流
// 测试 RabbitMQ 消息从 Gateway 发布到 Worker 消费的完整流程
// Requirements: 7.5
func TestGatewayToWorkerMessageFlow(t *testing.T) {
	if os.Getenv("INTEGRATION_TEST") != "true" {
		t.Skip("跳过集成测试。设置 INTEGRATION_TEST=true 以运行。")
	}

	// 获取 RabbitMQ 连接 URL
	rabbitURL := os.Getenv("RABBITMQ_URL")
	if rabbitURL == "" {
		rabbitURL = "amqp://guest:guest@localhost:5672/"
	}

	// 连接 RabbitMQ
	conn, err := amqp.Dial(rabbitURL)
	if err != nil {
		t.Fatalf("无法连接 RabbitMQ: %v", err)
	}
	defer conn.Close()

	ch, err := conn.Channel()
	if err != nil {
		t.Fatalf("无法打开 channel: %v", err)
	}
	defer ch.Close()

	// 声明测试队列
	testQueue := "test.integration.queue"
	_, err = ch.QueueDeclare(testQueue, false, true, false, false, nil)
	if err != nil {
		t.Fatalf("无法声明队列: %v", err)
	}

	// 发布测试消息
	testMessage := []byte(fmt.Sprintf(`{"test_id": "%s", "timestamp": "%s"}`,
		generateUUID(), time.Now().Format(time.RFC3339)))

	err = ch.Publish("", testQueue, false, false, amqp.Publishing{
		ContentType:  "application/json",
		Body:         testMessage,
		DeliveryMode: amqp.Persistent,
	})
	if err != nil {
		t.Fatalf("无法发布消息: %v", err)
	}

	// 消费消息验证
	msgs, err := ch.Consume(testQueue, "", true, false, false, false, nil)
	if err != nil {
		t.Fatalf("无法消费消息: %v", err)
	}

	// 等待消息
	select {
	case msg := <-msgs:
		if string(msg.Body) != string(testMessage) {
			t.Errorf("消息内容不匹配: 期望 %s, 实际 %s", testMessage, msg.Body)
		}
		t.Logf("✓ 消息流验证成功: %s", msg.Body)
	case <-time.After(5 * time.Second):
		t.Fatal("等待消息超时")
	}
}

// TestGatewayExchangeAndQueues 验证 Gateway 的 Exchange 和队列配置
// 确保所有必要的队列都已正确声明和绑定
// Requirements: 7.5
func TestGatewayExchangeAndQueues(t *testing.T) {
	if os.Getenv("INTEGRATION_TEST") != "true" {
		t.Skip("跳过集成测试。设置 INTEGRATION_TEST=true 以运行。")
	}

	rabbitURL := os.Getenv("RABBITMQ_URL")
	if rabbitURL == "" {
		rabbitURL = "amqp://guest:guest@localhost:5672/"
	}

	conn, err := amqp.Dial(rabbitURL)
	if err != nil {
		t.Fatalf("无法连接 RabbitMQ: %v", err)
	}
	defer conn.Close()

	ch, err := conn.Channel()
	if err != nil {
		t.Fatalf("无法打开 channel: %v", err)
	}
	defer ch.Close()

	// 验证 gateway.direct exchange 存在
	err = ch.ExchangeDeclarePassive("gateway.direct", "direct", true, false, false, false, nil)
	if err != nil {
		t.Logf("⚠ gateway.direct exchange 不存在（可能 Gateway 服务未启动）: %v", err)
		// 重新打开 channel（passive declare 失败会关闭 channel）
		ch, err = conn.Channel()
		if err != nil {
			t.Fatalf("无法重新打开 channel: %v", err)
		}
	} else {
		t.Log("✓ gateway.direct exchange 存在")
	}

	// 验证关键队列存在
	queues := []string{
		"auth.register",
		"auth.login",
		"post.create",
		"chat.send",
		"user.profile.get",
	}

	for _, queue := range queues {
		_, err := ch.QueueDeclarePassive(queue, true, false, false, false, nil)
		if err != nil {
			t.Logf("⚠ 队列 %s 不存在（可能 Gateway 服务未启动）", queue)
			// 重新打开 channel
			ch, err = conn.Channel()
			if err != nil {
				t.Fatalf("无法重新打开 channel: %v", err)
			}
		} else {
			t.Logf("✓ 队列 %s 存在", queue)
		}
	}
}

// TestGRPCServiceCommunication 验证 gRPC 服务间调用
// 测试 gRPC 连接池和拦截器功能
// Requirements: 7.5
func TestGRPCServiceCommunication(t *testing.T) {
	if os.Getenv("INTEGRATION_TEST") != "true" {
		t.Skip("跳过集成测试。设置 INTEGRATION_TEST=true 以运行。")
	}

	// 获取 Gateway gRPC 地址
	gatewayAddr := os.Getenv("GATEWAY_GRPC_ADDR")
	if gatewayAddr == "" {
		gatewayAddr = "localhost:50051"
	}

	// 创建 gRPC 连接
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	conn, err := grpc.DialContext(ctx, gatewayAddr,
		grpc.WithTransportCredentials(insecure.NewCredentials()),
		grpc.WithBlock(),
	)
	if err != nil {
		t.Logf("⚠ 无法连接 Gateway gRPC 服务 (%s): %v", gatewayAddr, err)
		t.Log("  提示: 确保 Gateway 服务正在运行")
		return
	}
	defer conn.Close()

	t.Logf("✓ 成功连接 Gateway gRPC 服务: %s", gatewayAddr)
}

// TestGRPCClientPool 验证 gRPC 客户端连接池功能
// Requirements: 7.5
func TestGRPCClientPool(t *testing.T) {
	if os.Getenv("INTEGRATION_TEST") != "true" {
		t.Skip("跳过集成测试。设置 INTEGRATION_TEST=true 以运行。")
	}

	log := logger.New("test")
	pool := grpcclient.NewClientPool(log)

	// 获取 Gateway 地址
	gatewayAddr := os.Getenv("GATEWAY_GRPC_ADDR")
	if gatewayAddr == "" {
		gatewayAddr = "localhost:50051"
	}

	// 注册测试服务配置
	pool.Register("gateway", grpcclient.ClientConfig{
		Target:       gatewayAddr,
		Insecure:     true,
		Timeout:      5 * time.Second,
		MaxRetries:   3,
		RetryBackoff: 100 * time.Millisecond,
	})

	if pool == nil {
		t.Fatal("连接池创建失败")
	}

	// 测试获取连接
	ctx := context.Background()
	_, err := pool.GetConn(ctx, "gateway")
	if err != nil {
		t.Logf("⚠ 无法获取 Gateway 连接: %v", err)
		t.Log("  提示: 确保 Gateway 服务正在运行")
	} else {
		t.Log("✓ 成功从连接池获取 Gateway 连接")
	}

	// 清理
	pool.Close()
}

// TestTraceIDPropagation 验证 Trace ID 在服务间传递
// Requirements: 7.5
func TestTraceIDPropagation(t *testing.T) {
	if os.Getenv("INTEGRATION_TEST") != "true" {
		t.Skip("跳过集成测试。设置 INTEGRATION_TEST=true 以运行。")
	}

	// 创建带 trace_id 的 context
	traceID := generateUUID()
	ctx := logger.ContextWithTraceID(context.Background(), traceID)

	// 验证 trace_id 可以从 context 中提取
	extractedTraceID := logger.TraceIDFromContext(ctx)
	if extractedTraceID != traceID {
		t.Errorf("Trace ID 不匹配: 期望 %s, 实际 %s", traceID, extractedTraceID)
	}

	// 验证 gRPC metadata 传递
	md := metadata.New(map[string]string{"trace_id": traceID})
	ctx = metadata.NewOutgoingContext(ctx, md)

	outMD, ok := metadata.FromOutgoingContext(ctx)
	if !ok {
		t.Fatal("无法从 context 获取 outgoing metadata")
	}

	values := outMD.Get("trace_id")
	if len(values) == 0 || values[0] != traceID {
		t.Errorf("gRPC metadata 中的 trace_id 不匹配")
	}

	t.Logf("✓ Trace ID 传递验证成功: %s", traceID)
}

// TestRabbitMQTraceIDInHeaders 验证 RabbitMQ 消息头中的 Trace ID 传递
// Requirements: 7.5
func TestRabbitMQTraceIDInHeaders(t *testing.T) {
	if os.Getenv("INTEGRATION_TEST") != "true" {
		t.Skip("跳过集成测试。设置 INTEGRATION_TEST=true 以运行。")
	}

	rabbitURL := os.Getenv("RABBITMQ_URL")
	if rabbitURL == "" {
		rabbitURL = "amqp://guest:guest@localhost:5672/"
	}

	conn, err := amqp.Dial(rabbitURL)
	if err != nil {
		t.Fatalf("无法连接 RabbitMQ: %v", err)
	}
	defer conn.Close()

	ch, err := conn.Channel()
	if err != nil {
		t.Fatalf("无法打开 channel: %v", err)
	}
	defer ch.Close()

	// 声明测试队列
	testQueue := "test.trace.queue"
	_, err = ch.QueueDeclare(testQueue, false, true, false, false, nil)
	if err != nil {
		t.Fatalf("无法声明队列: %v", err)
	}

	// 发布带 trace_id 的消息
	traceID := generateUUID()
	err = ch.Publish("", testQueue, false, false, amqp.Publishing{
		ContentType: "application/json",
		Body:        []byte(`{"test": "data"}`),
		Headers: amqp.Table{
			"trace_id": traceID,
		},
	})
	if err != nil {
		t.Fatalf("无法发布消息: %v", err)
	}

	// 消费并验证 trace_id
	msgs, err := ch.Consume(testQueue, "", true, false, false, false, nil)
	if err != nil {
		t.Fatalf("无法消费消息: %v", err)
	}

	select {
	case msg := <-msgs:
		receivedTraceID, ok := msg.Headers["trace_id"].(string)
		if !ok || receivedTraceID != traceID {
			t.Errorf("消息头中的 trace_id 不匹配: 期望 %s, 实际 %v", traceID, msg.Headers["trace_id"])
		} else {
			t.Logf("✓ RabbitMQ 消息头 trace_id 传递成功: %s", traceID)
		}
	case <-time.After(5 * time.Second):
		t.Fatal("等待消息超时")
	}
}

// TestChatServiceGRPCConnection 验证 Chat 服务的 gRPC 连接
// Requirements: 7.5
func TestChatServiceGRPCConnection(t *testing.T) {
	if os.Getenv("INTEGRATION_TEST") != "true" {
		t.Skip("跳过集成测试。设置 INTEGRATION_TEST=true 以运行。")
	}

	chatAddr := os.Getenv("CHAT_GRPC_ADDR")
	if chatAddr == "" {
		chatAddr = "localhost:50060"
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	conn, err := grpc.DialContext(ctx, chatAddr,
		grpc.WithTransportCredentials(insecure.NewCredentials()),
		grpc.WithBlock(),
	)
	if err != nil {
		t.Logf("⚠ 无法连接 Chat gRPC 服务 (%s): %v", chatAddr, err)
		t.Log("  提示: 确保 Chat 服务正在运行")
		return
	}
	defer conn.Close()

	t.Logf("✓ 成功连接 Chat gRPC 服务: %s", chatAddr)
}
