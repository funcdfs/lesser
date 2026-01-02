// Package errors 定义 Gateway 服务的错误类型
// 所有错误消息使用中文，便于调试和用户反馈
package errors

import (
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// 预定义错误（中文消息）
var (
	// 认证相关错误
	ErrMissingMetadata    = status.Error(codes.Unauthenticated, "缺少请求元数据")
	ErrMissingToken       = status.Error(codes.Unauthenticated, "缺少认证令牌")
	ErrInvalidToken       = status.Error(codes.Unauthenticated, "无效的认证令牌")
	ErrTokenExpired       = status.Error(codes.Unauthenticated, "认证令牌已过期")
	ErrPublicKeyNotLoaded = status.Error(codes.Internal, "公钥未加载")
	ErrKeyIDMismatch      = status.Error(codes.Unauthenticated, "密钥 ID 不匹配")

	// 限流相关错误
	ErrRateLimitExceeded = status.Error(codes.ResourceExhausted, "请求频率超限")

	// 服务相关错误
	ErrServiceUnavailable = status.Error(codes.Unavailable, "服务暂不可用")
	ErrServiceNotFound    = status.Error(codes.NotFound, "服务不存在")

	// 用户相关错误
	ErrUserNotFound       = status.Error(codes.NotFound, "用户不存在")
	ErrUserAlreadyExists  = status.Error(codes.AlreadyExists, "用户已存在")
	ErrInvalidCredentials = status.Error(codes.Unauthenticated, "用户名或密码错误")

	// 通用错误
	ErrInternal       = status.Error(codes.Internal, "内部服务错误")
	ErrInvalidRequest = status.Error(codes.InvalidArgument, "无效的请求参数")
)

// ServiceUnavailableError 返回指定服务不可用的错误
func ServiceUnavailableError(serviceName string) error {
	return status.Errorf(codes.Unavailable, "服务 %s 暂不可用", serviceName)
}

// ServiceNotFoundError 返回指定服务不存在的错误
func ServiceNotFoundError(serviceName string) error {
	return status.Errorf(codes.NotFound, "未知服务: %s", serviceName)
}

// InvalidTokenError 返回带详细信息的令牌错误
func InvalidTokenError(detail string) error {
	return status.Errorf(codes.Unauthenticated, "无效的认证令牌: %s", detail)
}

// InternalError 返回带详细信息的内部错误
func InternalError(detail string) error {
	return status.Errorf(codes.Internal, "内部错误: %s", detail)
}
