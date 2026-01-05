// Package logic 提供内容服务的业务逻辑层
package logic

import (
	"errors"

	"github.com/funcdfs/lesser/content/internal/data_access"
	pkgerrors "github.com/funcdfs/lesser/pkg/errors"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// 业务错误定义
var (
	ErrContentNotFound  = errors.New("内容不存在")
	ErrUnauthorized     = errors.New("无权限操作")
	ErrInvalidInput     = errors.New("无效输入")
	ErrEmptyText        = errors.New("内容不能为空")
	ErrTextTooLong      = errors.New("内容超出长度限制")
	ErrInvalidStatus    = errors.New("无效的内容状态")
	ErrContentExpired   = errors.New("内容已过期")
	ErrAlreadyPublished = errors.New("内容已发布")
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
	// 内容相关
	case errors.Is(err, ErrContentNotFound):
		return status.Error(codes.NotFound, "内容不存在")
	case errors.Is(err, ErrUnauthorized):
		return status.Error(codes.PermissionDenied, "无权限操作")
	case errors.Is(err, ErrInvalidInput):
		return status.Error(codes.InvalidArgument, "无效输入")
	case errors.Is(err, ErrEmptyText):
		return status.Error(codes.InvalidArgument, "内容不能为空")
	case errors.Is(err, ErrTextTooLong):
		return status.Error(codes.InvalidArgument, "内容超出长度限制")
	case errors.Is(err, ErrInvalidStatus):
		return status.Error(codes.InvalidArgument, "无效的内容状态")
	case errors.Is(err, ErrContentExpired):
		return status.Error(codes.NotFound, "内容已过期")
	case errors.Is(err, ErrAlreadyPublished):
		return status.Error(codes.FailedPrecondition, "内容已发布")

	// 数据访问层错误转换
	case errors.Is(err, data_access.ErrContentNotFound):
		return status.Error(codes.NotFound, "内容不存在")
	case errors.Is(err, data_access.ErrUnauthorized):
		return status.Error(codes.PermissionDenied, "无权限操作")
	case errors.Is(err, data_access.ErrInvalidInput):
		return status.Error(codes.InvalidArgument, "无效输入")
	case errors.Is(err, data_access.ErrDuplicate):
		return status.Error(codes.AlreadyExists, "内容已存在")
	case errors.Is(err, data_access.ErrInvalidCounterType):
		return status.Error(codes.InvalidArgument, "无效的计数器类型")

	default:
		return status.Error(codes.Internal, "内部服务错误")
	}
}
