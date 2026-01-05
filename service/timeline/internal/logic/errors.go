// Package logic 提供时间线服务的业务逻辑层
package logic

import (
	"errors"

	"github.com/funcdfs/lesser/timeline/internal/data_access"
	pkgerrors "github.com/funcdfs/lesser/pkg/errors"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// 业务错误定义
var (
	ErrContentNotFound = errors.New("内容不存在")
	ErrContentExpired  = errors.New("内容已过期")
	ErrInvalidInput    = errors.New("无效输入")
	ErrNotFound        = errors.New("记录不存在")
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
	// 时间线相关
	case errors.Is(err, ErrContentNotFound):
		return status.Error(codes.NotFound, "内容不存在")
	case errors.Is(err, ErrContentExpired):
		return status.Error(codes.NotFound, "内容已过期")
	case errors.Is(err, ErrInvalidInput):
		return status.Error(codes.InvalidArgument, "无效输入")
	case errors.Is(err, ErrNotFound):
		return status.Error(codes.NotFound, "记录不存在")

	// 数据访问层错误转换
	case errors.Is(err, data_access.ErrNotFound):
		return status.Error(codes.NotFound, "记录不存在")
	case errors.Is(err, data_access.ErrDuplicate):
		return status.Error(codes.AlreadyExists, "记录已存在")
	case errors.Is(err, data_access.ErrInvalidInput):
		return status.Error(codes.InvalidArgument, "无效输入")
	case errors.Is(err, data_access.ErrContentExpired):
		return status.Error(codes.NotFound, "内容已过期")

	default:
		return status.Error(codes.Internal, "内部服务错误")
	}
}
