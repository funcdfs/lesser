// Package logic 提供用户服务的业务逻辑层
package logic

import (
	"errors"

	pkgerrors "github.com/funcdfs/lesser/pkg/errors"
	"github.com/funcdfs/lesser/user/internal/data_access"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// 业务错误定义
var (
	ErrUserNotFound     = errors.New("用户不存在")
	ErrUnauthorized     = errors.New("无权限操作")
	ErrInvalidInput     = errors.New("无效输入")
	ErrCannotFollowSelf = errors.New("不能关注自己")
	ErrAlreadyFollowing = errors.New("已经关注了该用户")
	ErrNotFollowing     = errors.New("未关注该用户")
	ErrCannotBlockSelf  = errors.New("不能屏蔽自己")
	ErrAlreadyBlocked   = errors.New("已经屏蔽了该用户")
	ErrNotBlocked       = errors.New("未屏蔽该用户")
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
	// 用户相关
	case errors.Is(err, ErrUserNotFound):
		return status.Error(codes.NotFound, "用户不存在")
	case errors.Is(err, ErrUnauthorized):
		return status.Error(codes.PermissionDenied, "无权限操作")
	case errors.Is(err, ErrInvalidInput):
		return status.Error(codes.InvalidArgument, "无效输入")
	case errors.Is(err, ErrCannotFollowSelf):
		return status.Error(codes.InvalidArgument, "不能关注自己")
	case errors.Is(err, ErrAlreadyFollowing):
		return status.Error(codes.AlreadyExists, "已经关注了该用户")
	case errors.Is(err, ErrNotFollowing):
		return status.Error(codes.NotFound, "未关注该用户")
	case errors.Is(err, ErrCannotBlockSelf):
		return status.Error(codes.InvalidArgument, "不能屏蔽自己")
	case errors.Is(err, ErrAlreadyBlocked):
		return status.Error(codes.AlreadyExists, "已经屏蔽了该用户")
	case errors.Is(err, ErrNotBlocked):
		return status.Error(codes.NotFound, "未屏蔽该用户")

	// 数据访问层错误转换
	case errors.Is(err, data_access.ErrUserNotFound):
		return status.Error(codes.NotFound, "用户不存在")
	case errors.Is(err, data_access.ErrUserAlreadyExists):
		return status.Error(codes.AlreadyExists, "用户已存在")
	case errors.Is(err, data_access.ErrCannotFollowSelf):
		return status.Error(codes.InvalidArgument, "不能关注自己")
	case errors.Is(err, data_access.ErrAlreadyFollowing):
		return status.Error(codes.AlreadyExists, "已经关注了该用户")
	case errors.Is(err, data_access.ErrNotFollowing):
		return status.Error(codes.NotFound, "未关注该用户")
	case errors.Is(err, data_access.ErrCannotBlockSelf):
		return status.Error(codes.InvalidArgument, "不能屏蔽自己")
	case errors.Is(err, data_access.ErrAlreadyBlocked):
		return status.Error(codes.AlreadyExists, "已经屏蔽了该用户")
	case errors.Is(err, data_access.ErrNotBlocked):
		return status.Error(codes.NotFound, "未屏蔽该用户")

	default:
		return status.Error(codes.Internal, "内部服务错误")
	}
}
