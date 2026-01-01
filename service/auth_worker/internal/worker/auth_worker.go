package worker

import (
	"context"

	"github.com/lesser/auth_worker/internal/service"
	"github.com/lesser/auth_worker/proto/auth"
	"github.com/lesser/auth_worker/proto/gateway"
	"github.com/lesser/pkg/broker"
	"github.com/lesser/pkg/logger"
	"go.uber.org/zap"
	"google.golang.org/protobuf/proto"
)

// AuthWorker 认证任务处理器
type AuthWorker struct {
	authService *service.AuthService
	broker      *broker.Worker
	log         *logger.Logger
}

// NewAuthWorker 创建新的 AuthWorker
func NewAuthWorker(authService *service.AuthService, broker *broker.Worker, log *logger.Logger) *AuthWorker {
	return &AuthWorker{
		authService: authService,
		broker:      broker,
		log:         log,
	}
}

// HandleRegister 处理注册任务
// 符合 broker.Handler 签名
func (w *AuthWorker) HandleRegister(ctx context.Context, body []byte) error {
	w.log.WithContext(ctx).Info("received register task")

	// 解析 GatewayRequest
	var gatewayReq gateway.GatewayRequest
	if err := proto.Unmarshal(body, &gatewayReq); err != nil {
		w.log.WithContext(ctx).Error("failed to unmarshal gateway request", zap.Error(err))
		return err
	}

	// 解析 RegisterRequest
	var registerReq auth.RegisterRequest
	if err := proto.Unmarshal(gatewayReq.Payload, &registerReq); err != nil {
		w.log.WithContext(ctx).Error("failed to unmarshal register request", zap.Error(err))
		w.publishError(ctx, gatewayReq.RequestId, "INVALID_PAYLOAD", "Invalid register request payload")
		return nil // 返回 nil 表示消息已处理（不重试）
	}

	// 处理注册
	authResp, err := w.authService.Register(&registerReq)
	if err != nil {
		w.log.WithContext(ctx).Error("register failed", zap.Error(err))
		w.publishError(ctx, gatewayReq.RequestId, "REGISTER_FAILED", err.Error())
		return nil // 业务错误，不重试
	}

	// 发布成功结果
	w.publishSuccess(ctx, gatewayReq.RequestId, authResp)
	w.log.WithContext(ctx).Info("register task completed", zap.String("request_id", gatewayReq.RequestId))
	return nil
}

// HandleLogin 处理登录任务
// 符合 broker.Handler 签名
func (w *AuthWorker) HandleLogin(ctx context.Context, body []byte) error {
	w.log.WithContext(ctx).Info("received login task")

	// 解析 GatewayRequest
	var gatewayReq gateway.GatewayRequest
	if err := proto.Unmarshal(body, &gatewayReq); err != nil {
		w.log.WithContext(ctx).Error("failed to unmarshal gateway request", zap.Error(err))
		return err
	}

	// 解析 LoginRequest
	var loginReq auth.LoginRequest
	if err := proto.Unmarshal(gatewayReq.Payload, &loginReq); err != nil {
		w.log.WithContext(ctx).Error("failed to unmarshal login request", zap.Error(err))
		w.publishError(ctx, gatewayReq.RequestId, "INVALID_PAYLOAD", "Invalid login request payload")
		return nil
	}

	// 处理登录
	authResp, err := w.authService.Login(&loginReq)
	if err != nil {
		w.log.WithContext(ctx).Error("login failed", zap.Error(err))
		w.publishError(ctx, gatewayReq.RequestId, "LOGIN_FAILED", err.Error())
		return nil
	}

	// 发布成功结果
	w.publishSuccess(ctx, gatewayReq.RequestId, authResp)
	w.log.WithContext(ctx).Info("login task completed", zap.String("request_id", gatewayReq.RequestId))
	return nil
}

// publishSuccess 发布成功结果
func (w *AuthWorker) publishSuccess(ctx context.Context, requestId string, authResp *auth.AuthResponse) {
	payload, err := proto.Marshal(authResp)
	if err != nil {
		w.log.WithContext(ctx).Error("failed to marshal auth response", zap.Error(err))
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
		w.log.WithContext(ctx).Error("failed to marshal task result", zap.Error(err))
		return
	}

	// 发布到响应队列
	if err := w.broker.Publish(ctx, "response."+requestId, resultBytes); err != nil {
		w.log.WithContext(ctx).Error("failed to publish result", zap.Error(err))
	}
}

// publishError 发布错误结果
func (w *AuthWorker) publishError(ctx context.Context, requestId, errorCode, errorMessage string) {
	result := &gateway.TaskResult{
		RequestId:    requestId,
		Success:      false,
		ErrorCode:    errorCode,
		ErrorMessage: errorMessage,
		Status:       gateway.TaskStatus_FAILED,
	}

	resultBytes, err := proto.Marshal(result)
	if err != nil {
		w.log.WithContext(ctx).Error("failed to marshal task result", zap.Error(err))
		return
	}

	// 发布到响应队列
	if err := w.broker.Publish(ctx, "response."+requestId, resultBytes); err != nil {
		w.log.WithContext(ctx).Error("failed to publish error result", zap.Error(err))
	}
}

// HandlePasswordReset 处理密码重置任务（异步发送邮件）
func (w *AuthWorker) HandlePasswordReset(ctx context.Context, body []byte) error {
	w.log.WithContext(ctx).Info("received password reset task")

	// 解析 GatewayRequest
	var gatewayReq gateway.GatewayRequest
	if err := proto.Unmarshal(body, &gatewayReq); err != nil {
		w.log.WithContext(ctx).Error("failed to unmarshal gateway request", zap.Error(err))
		return err
	}

	// TODO: 实现密码重置邮件发送逻辑
	// 1. 解析 PasswordResetRequest
	// 2. 生成重置 token
	// 3. 发送邮件

	w.log.WithContext(ctx).Info("password reset task completed", zap.String("request_id", gatewayReq.RequestId))
	return nil
}
