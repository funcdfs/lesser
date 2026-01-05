// Package errors 提供统一的错误处理封装
// 支持 gRPC 状态码映射、错误包装、错误链追踪
package errors

import (
	"errors"
	"fmt"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// 预定义业务错误
var (
	// 通用错误
	ErrInternal       = New(codes.Internal, "内部服务错误")
	ErrInvalidRequest = New(codes.InvalidArgument, "请求参数无效")
	ErrUnauthorized   = New(codes.Unauthenticated, "未认证")
	ErrForbidden      = New(codes.PermissionDenied, "无权限")
	ErrNotFound       = New(codes.NotFound, "资源不存在")
	ErrAlreadyExists  = New(codes.AlreadyExists, "资源已存在")
	ErrTimeout        = New(codes.DeadlineExceeded, "请求超时")
	ErrCanceled       = New(codes.Canceled, "请求已取消")
	ErrUnavailable    = New(codes.Unavailable, "服务不可用")

	// 认证相关
	ErrInvalidCredentials  = New(codes.Unauthenticated, "用户名或密码错误")
	ErrTokenExpired        = New(codes.Unauthenticated, "Token 已过期")
	ErrTokenInvalid        = New(codes.Unauthenticated, "Token 无效")
	ErrRefreshTokenInvalid = New(codes.Unauthenticated, "Refresh Token 无效")

	// 用户相关
	ErrUserNotFound        = New(codes.NotFound, "用户不存在")
	ErrUserAlreadyExists   = New(codes.AlreadyExists, "用户已存在")
	ErrEmailAlreadyUsed    = New(codes.AlreadyExists, "邮箱已被使用")
	ErrUsernameAlreadyUsed = New(codes.AlreadyExists, "用户名已被使用")

	// 帖子相关
	ErrPostNotFound = New(codes.NotFound, "帖子不存在")
	ErrPostDeleted  = New(codes.NotFound, "帖子已删除")

	// 聊天相关
	ErrConversationNotFound  = New(codes.NotFound, "会话不存在")
	ErrNotConversationMember = New(codes.PermissionDenied, "您不是该会话的成员")
	ErrMessageNotFound       = New(codes.NotFound, "消息不存在")
)

// AppError 应用错误，包含 gRPC 状态码
type AppError struct {
	Code    codes.Code
	Message string
	Cause   error
}

// New 创建新的应用错误
func New(code codes.Code, message string) *AppError {
	return &AppError{
		Code:    code,
		Message: message,
	}
}

// Error 实现 error 接口
func (e *AppError) Error() string {
	if e.Cause != nil {
		return fmt.Sprintf("%s: %v", e.Message, e.Cause)
	}
	return e.Message
}

// Unwrap 支持 errors.Unwrap
func (e *AppError) Unwrap() error {
	return e.Cause
}

// GRPCStatus 返回 gRPC 状态
func (e *AppError) GRPCStatus() *status.Status {
	return status.New(e.Code, e.Message)
}

// ToGRPC 转换为 gRPC 错误
func (e *AppError) ToGRPC() error {
	return e.GRPCStatus().Err()
}

// WithCause 添加原因错误
func (e *AppError) WithCause(cause error) *AppError {
	return &AppError{
		Code:    e.Code,
		Message: e.Message,
		Cause:   cause,
	}
}

// WithMessage 替换错误消息
func (e *AppError) WithMessage(message string) *AppError {
	return &AppError{
		Code:    e.Code,
		Message: message,
		Cause:   e.Cause,
	}
}

// WithMessagef 格式化替换错误消息
func (e *AppError) WithMessagef(format string, args ...interface{}) *AppError {
	return &AppError{
		Code:    e.Code,
		Message: fmt.Sprintf(format, args...),
		Cause:   e.Cause,
	}
}

// Is 支持 errors.Is
func (e *AppError) Is(target error) bool {
	t, ok := target.(*AppError)
	if !ok {
		return false
	}
	return e.Code == t.Code && e.Message == t.Message
}

// Wrap 包装错误，添加上下文信息
func Wrap(err error, message string) error {
	if err == nil {
		return nil
	}
	return fmt.Errorf("%s: %w", message, err)
}

// Wrapf 格式化包装错误
func Wrapf(err error, format string, args ...interface{}) error {
	if err == nil {
		return nil
	}
	return fmt.Errorf("%s: %w", fmt.Sprintf(format, args...), err)
}

// ToGRPCError 将任意错误转换为 gRPC 错误
func ToGRPCError(err error) error {
	if err == nil {
		return nil
	}

	// 如果已经是 gRPC 错误，直接返回
	if _, ok := status.FromError(err); ok {
		return err
	}

	// 如果是 AppError，转换为 gRPC 错误
	var appErr *AppError
	if errors.As(err, &appErr) {
		return appErr.ToGRPC()
	}

	// 其他错误转换为 Internal 错误
	return status.Error(codes.Internal, err.Error())
}

// FromGRPCError 从 gRPC 错误提取信息
func FromGRPCError(err error) (codes.Code, string) {
	if err == nil {
		return codes.OK, ""
	}

	s, ok := status.FromError(err)
	if !ok {
		return codes.Unknown, err.Error()
	}

	return s.Code(), s.Message()
}

// IsNotFound 检查是否为 NotFound 错误
func IsNotFound(err error) bool {
	return IsCode(err, codes.NotFound)
}

// IsAlreadyExists 检查是否为 AlreadyExists 错误
func IsAlreadyExists(err error) bool {
	return IsCode(err, codes.AlreadyExists)
}

// IsUnauthenticated 检查是否为 Unauthenticated 错误
func IsUnauthenticated(err error) bool {
	return IsCode(err, codes.Unauthenticated)
}

// IsPermissionDenied 检查是否为 PermissionDenied 错误
func IsPermissionDenied(err error) bool {
	return IsCode(err, codes.PermissionDenied)
}

// IsInvalidArgument 检查是否为 InvalidArgument 错误
func IsInvalidArgument(err error) bool {
	return IsCode(err, codes.InvalidArgument)
}

// IsCode 检查错误是否为指定的 gRPC 状态码
func IsCode(err error, code codes.Code) bool {
	if err == nil {
		return false
	}

	// 检查 AppError
	var appErr *AppError
	if errors.As(err, &appErr) {
		return appErr.Code == code
	}

	// 检查 gRPC 状态
	s, ok := status.FromError(err)
	if ok {
		return s.Code() == code
	}

	return false
}

// InvalidArgument 创建参数错误
func InvalidArgument(field, reason string) error {
	return status.Errorf(codes.InvalidArgument, "%s: %s", field, reason)
}

// NotFoundf 创建格式化的 NotFound 错误
func NotFoundf(format string, args ...interface{}) error {
	return status.Errorf(codes.NotFound, format, args...)
}

// Internalf 创建格式化的 Internal 错误
func Internalf(format string, args ...interface{}) error {
	return status.Errorf(codes.Internal, format, args...)
}

// PermissionDeniedf 创建格式化的 PermissionDenied 错误
func PermissionDeniedf(format string, args ...interface{}) error {
	return status.Errorf(codes.PermissionDenied, format, args...)
}

// Unauthenticatedf 创建格式化的 Unauthenticated 错误
func Unauthenticatedf(format string, args ...interface{}) error {
	return status.Errorf(codes.Unauthenticated, format, args...)
}

// AlreadyExistsf 创建格式化的 AlreadyExists 错误
func AlreadyExistsf(format string, args ...interface{}) error {
	return status.Errorf(codes.AlreadyExists, format, args...)
}

// IsUnavailable 检查是否为 Unavailable 错误
func IsUnavailable(err error) bool {
	return IsCode(err, codes.Unavailable)
}

// IsDeadlineExceeded 检查是否为 DeadlineExceeded 错误
func IsDeadlineExceeded(err error) bool {
	return IsCode(err, codes.DeadlineExceeded)
}

// IsCanceled 检查是否为 Canceled 错误
func IsCanceled(err error) bool {
	return IsCode(err, codes.Canceled)
}

// IsRetryable 检查错误是否可重试
// 可重试的错误码：Unavailable, ResourceExhausted, Aborted, DeadlineExceeded
func IsRetryable(err error) bool {
	if err == nil {
		return false
	}

	code, _ := FromGRPCError(err)
	switch code {
	case codes.Unavailable, codes.ResourceExhausted, codes.Aborted, codes.DeadlineExceeded:
		return true
	default:
		return false
	}
}
