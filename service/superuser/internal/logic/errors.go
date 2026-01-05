// Package logic 提供超级用户服务的业务逻辑层
package logic

import (
	"errors"

	pkgerrors "github.com/funcdfs/lesser/pkg/errors"
	"github.com/funcdfs/lesser/superuser/internal/data_access"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// 业务错误定义
var (
	ErrSuperUserNotFound  = errors.New("超级管理员不存在")
	ErrInvalidCredentials = errors.New("用户名或密码错误")
	ErrAccountDisabled    = errors.New("账户已禁用")
	ErrSessionNotFound    = errors.New("会话不存在")
	ErrSessionExpired     = errors.New("会话已过期")
	ErrUnauthorized       = errors.New("无权限操作")
	ErrInvalidInput       = errors.New("无效输入")
)

// ToGRPCError 将业务错误转换为 gRPC 错误
// 确保所有错误消息为中文
func ToGRPCError(err error) error {
	if err == nil {
		return nil
	}

	// 如果已经是 gRPC 错误，直接返回
	if _, ok := status.FromError(err); ok {
		return err
	}

	// 如果是 pkg/errors.AppError，使用其内置转换
	var appErr *pkgerrors.AppError
	if errors.As(err, &appErr) {
		return appErr.ToGRPC()
	}

	// 业务逻辑层错误转换
	switch {
	// 超级用户相关
	case errors.Is(err, ErrSuperUserNotFound):
		return status.Error(codes.NotFound, "超级管理员不存在")
	case errors.Is(err, ErrInvalidCredentials):
		return status.Error(codes.Unauthenticated, "用户名或密码错误")
	case errors.Is(err, ErrAccountDisabled):
		return status.Error(codes.PermissionDenied, "账户已禁用")
	case errors.Is(err, ErrSessionNotFound):
		return status.Error(codes.NotFound, "会话不存在")
	case errors.Is(err, ErrSessionExpired):
		return status.Error(codes.Unauthenticated, "会话已过期")
	case errors.Is(err, ErrUnauthorized):
		return status.Error(codes.PermissionDenied, "无权限操作")
	case errors.Is(err, ErrInvalidInput):
		return status.Error(codes.InvalidArgument, "无效输入")

	// 数据访问层错误转换
	case errors.Is(err, data_access.ErrSuperUserNotFound):
		return status.Error(codes.NotFound, "超级管理员不存在")
	case errors.Is(err, data_access.ErrNotFound):
		return status.Error(codes.NotFound, "记录不存在")
	case errors.Is(err, data_access.ErrDuplicate):
		return status.Error(codes.AlreadyExists, "记录已存在")
	case errors.Is(err, data_access.ErrInvalidInput):
		return status.Error(codes.InvalidArgument, "无效输入")
	case errors.Is(err, data_access.ErrInvalidCredentials):
		return status.Error(codes.Unauthenticated, "用户名或密码错误")
	case errors.Is(err, data_access.ErrAccountDisabled):
		return status.Error(codes.PermissionDenied, "账户已禁用")
	case errors.Is(err, data_access.ErrSessionNotFound):
		return status.Error(codes.NotFound, "会话不存在")
	case errors.Is(err, data_access.ErrSessionExpired):
		return status.Error(codes.Unauthenticated, "会话已过期")

	default:
		return status.Error(codes.Internal, "内部服务错误")
	}
}
