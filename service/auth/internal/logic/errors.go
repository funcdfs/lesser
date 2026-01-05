// Package logic 提供认证服务的业务逻辑层
package logic

import (
	"errors"

	"github.com/funcdfs/lesser/auth/internal/data_access"
	pkgerrors "github.com/funcdfs/lesser/pkg/errors"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
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
	// 认证相关
	case errors.Is(err, ErrInvalidCredentials):
		return status.Error(codes.Unauthenticated, "邮箱或密码错误")
	case errors.Is(err, ErrUserBanned):
		return status.Error(codes.PermissionDenied, "用户已被封禁")
	case errors.Is(err, ErrAccountLocked):
		return status.Error(codes.ResourceExhausted, "账户已被锁定，请稍后再试")
	case errors.Is(err, ErrInvalidToken):
		return status.Error(codes.Unauthenticated, "无效的令牌")
	case errors.Is(err, ErrTokenExpired):
		return status.Error(codes.Unauthenticated, "令牌已过期")
	case errors.Is(err, ErrTokenBlacklisted):
		return status.Error(codes.Unauthenticated, "令牌已失效")
	case errors.Is(err, ErrPasswordTooWeak):
		return status.Error(codes.InvalidArgument, "密码强度不足")
	case errors.Is(err, ErrUserNotActive):
		return status.Error(codes.PermissionDenied, "用户账户未激活")

	// 数据访问层错误转换
	case errors.Is(err, data_access.ErrUserNotFound):
		return status.Error(codes.NotFound, "用户不存在")
	case errors.Is(err, data_access.ErrUserExists):
		return status.Error(codes.AlreadyExists, "用户已存在")
	case errors.Is(err, data_access.ErrBanNotFound):
		return status.Error(codes.NotFound, "封禁记录不存在")
	case errors.Is(err, data_access.ErrNotFound):
		return status.Error(codes.NotFound, "记录不存在")
	case errors.Is(err, data_access.ErrDuplicate):
		return status.Error(codes.AlreadyExists, "记录已存在")
	case errors.Is(err, data_access.ErrInvalidInput):
		return status.Error(codes.InvalidArgument, "无效输入")

	default:
		return status.Error(codes.Internal, "内部服务错误")
	}
}
