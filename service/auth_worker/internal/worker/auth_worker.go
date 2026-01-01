package worker

import (
	"database/sql"
	"log"
	"sync"

	"github.com/lesser/auth_worker/internal/broker"
	"github.com/lesser/auth_worker/internal/service"
	"github.com/lesser/auth_worker/proto/auth"
	"github.com/lesser/auth_worker/proto/gateway"
	amqp "github.com/rabbitmq/amqp091-go"
	"google.golang.org/protobuf/proto"
)

// AuthWorker 认证任务消费者
type AuthWorker struct {
	db          *sql.DB
	broker      *broker.Connection
	authService *service.AuthService
	stopCh      chan struct{}
	wg          sync.WaitGroup
}

// NewAuthWorker 创建新的 AuthWorker
func NewAuthWorker(db *sql.DB, broker *broker.Connection, jwtSecret string) *AuthWorker {
	return &AuthWorker{
		db:          db,
		broker:      broker,
		authService: service.NewAuthService(db, jwtSecret),
		stopCh:      make(chan struct{}),
	}
}

// Start 启动消费者
func (w *AuthWorker) Start() error {
	// 启动注册队列消费者
	registerMsgs, err := w.broker.Consume(broker.QueueAuthRegister)
	if err != nil {
		return err
	}

	// 启动登录队列消费者
	loginMsgs, err := w.broker.Consume(broker.QueueAuthLogin)
	if err != nil {
		return err
	}

	// 处理注册消息
	w.wg.Add(1)
	go w.consumeRegister(registerMsgs)

	// 处理登录消息
	w.wg.Add(1)
	go w.consumeLogin(loginMsgs)

	return nil
}

// Stop 停止消费者
func (w *AuthWorker) Stop() {
	close(w.stopCh)
	w.wg.Wait()
}

// consumeRegister 消费注册队列
func (w *AuthWorker) consumeRegister(msgs <-chan amqp.Delivery) {
	defer w.wg.Done()

	for {
		select {
		case <-w.stopCh:
			return
		case msg, ok := <-msgs:
			if !ok {
				return
			}
			w.handleRegister(msg)
		}
	}
}

// consumeLogin 消费登录队列
func (w *AuthWorker) consumeLogin(msgs <-chan amqp.Delivery) {
	defer w.wg.Done()

	for {
		select {
		case <-w.stopCh:
			return
		case msg, ok := <-msgs:
			if !ok {
				return
			}
			w.handleLogin(msg)
		}
	}
}

// handleRegister 处理注册任务
func (w *AuthWorker) handleRegister(msg amqp.Delivery) {
	log.Printf("Received register task")

	// 解析 GatewayRequest
	var gatewayReq gateway.GatewayRequest
	if err := proto.Unmarshal(msg.Body, &gatewayReq); err != nil {
		log.Printf("Failed to unmarshal gateway request: %v", err)
		msg.Nack(false, false)
		return
	}

	// 解析 RegisterRequest
	var registerReq auth.RegisterRequest
	if err := proto.Unmarshal(gatewayReq.Payload, &registerReq); err != nil {
		log.Printf("Failed to unmarshal register request: %v", err)
		w.publishError(gatewayReq.RequestId, "INVALID_PAYLOAD", "Invalid register request payload")
		msg.Ack(false)
		return
	}

	// 处理注册
	authResp, err := w.authService.Register(&registerReq)
	if err != nil {
		log.Printf("Register failed: %v", err)
		w.publishError(gatewayReq.RequestId, "REGISTER_FAILED", err.Error())
		msg.Ack(false)
		return
	}

	// 发布成功结果
	w.publishSuccess(gatewayReq.RequestId, authResp)
	msg.Ack(false)
	log.Printf("Register task completed for request: %s", gatewayReq.RequestId)
}

// handleLogin 处理登录任务
func (w *AuthWorker) handleLogin(msg amqp.Delivery) {
	log.Printf("Received login task")

	// 解析 GatewayRequest
	var gatewayReq gateway.GatewayRequest
	if err := proto.Unmarshal(msg.Body, &gatewayReq); err != nil {
		log.Printf("Failed to unmarshal gateway request: %v", err)
		msg.Nack(false, false)
		return
	}

	// 解析 LoginRequest
	var loginReq auth.LoginRequest
	if err := proto.Unmarshal(gatewayReq.Payload, &loginReq); err != nil {
		log.Printf("Failed to unmarshal login request: %v", err)
		w.publishError(gatewayReq.RequestId, "INVALID_PAYLOAD", "Invalid login request payload")
		msg.Ack(false)
		return
	}

	// 处理登录
	authResp, err := w.authService.Login(&loginReq)
	if err != nil {
		log.Printf("Login failed: %v", err)
		w.publishError(gatewayReq.RequestId, "LOGIN_FAILED", err.Error())
		msg.Ack(false)
		return
	}

	// 发布成功结果
	w.publishSuccess(gatewayReq.RequestId, authResp)
	msg.Ack(false)
	log.Printf("Login task completed for request: %s", gatewayReq.RequestId)
}

// publishSuccess 发布成功结果
func (w *AuthWorker) publishSuccess(requestId string, authResp *auth.AuthResponse) {
	payload, err := proto.Marshal(authResp)
	if err != nil {
		log.Printf("Failed to marshal auth response: %v", err)
		return
	}

	result := &gateway.TaskResult{
		RequestId: requestId,
		Success:   true,
		Payload:   payload,
		Status:    gateway.TaskStatus_COMPLETED,
	}

	resultBytes, err := proto.Marshal(result)
	if err != nil {
		log.Printf("Failed to marshal task result: %v", err)
		return
	}

	// 发布到响应队列（使用 request_id 作为 routing key）
	if err := w.broker.Publish("response."+requestId, resultBytes); err != nil {
		log.Printf("Failed to publish result: %v", err)
	}
}

// publishError 发布错误结果
func (w *AuthWorker) publishError(requestId, errorCode, errorMessage string) {
	result := &gateway.TaskResult{
		RequestId:    requestId,
		Success:      false,
		ErrorCode:    errorCode,
		ErrorMessage: errorMessage,
		Status:       gateway.TaskStatus_FAILED,
	}

	resultBytes, err := proto.Marshal(result)
	if err != nil {
		log.Printf("Failed to marshal task result: %v", err)
		return
	}

	// 发布到响应队列
	if err := w.broker.Publish("response."+requestId, resultBytes); err != nil {
		log.Printf("Failed to publish error result: %v", err)
	}
}
