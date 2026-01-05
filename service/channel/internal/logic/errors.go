// Package logic 提供频道业务逻辑
package logic

import (
	"errors"

	"github.com/funcdfs/lesser/channel/internal/data_access"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

var (
	// ErrNotChannelOwner 不是频道所有者
	ErrNotChannelOwner = errors.New("不是频道所有者")
	// ErrNotChannelAdmin 不是频道管理员
	ErrNotChannelAdmin = errors.New("不是频道管理员")
	// ErrCannotRemoveOwner 不能移除所有者
	ErrCannotRemoveOwner = errors.New("不能移除频道所有者")
	// ErrNotSubscribed 未订阅频道
	ErrNotSubscribed = errors.New("未订阅该频道")
	// ErrChannelNotPublic 频道不公开
	ErrChannelNotPublic = errors.New("频道不公开")
	// ErrInvalidChannelName 无效的频道名称
	ErrInvalidChannelName = errors.New("频道名称不能为空")
	// ErrInvalidPostContent 无效的内容
	ErrInvalidPostContent = errors.New("内容不能为空")
)

// ToGRPCError 将业务错误转换为 gRPC 错误
func ToGRPCError(err error) error {
	switch {
	// 数据访问层错误
	case errors.Is(err, data_access.ErrNotFound):
		return status.Error(codes.NotFound, "资源不存在")
	case errors.Is(err, data_access.ErrChannelNotFound):
		return status.Error(codes.NotFound, "频道不存在")
	case errors.Is(err, data_access.ErrChannelExists):
		return status.Error(codes.AlreadyExists, "频道已存在")
	case errors.Is(err, data_access.ErrUsernameExists):
		return status.Error(codes.AlreadyExists, "频道用户名已被占用")
	case errors.Is(err, data_access.ErrPostNotFound):
		return status.Error(codes.NotFound, "内容不存在")
	case errors.Is(err, data_access.ErrSubscriptionNotFound):
		return status.Error(codes.NotFound, "订阅关系不存在")
	case errors.Is(err, data_access.ErrAlreadySubscribed):
		return status.Error(codes.AlreadyExists, "已经订阅该频道")
	case errors.Is(err, data_access.ErrAdminNotFound):
		return status.Error(codes.NotFound, "管理员不存在")
	case errors.Is(err, data_access.ErrAlreadyAdmin):
		return status.Error(codes.AlreadyExists, "该用户已经是管理员")
	case errors.Is(err, data_access.ErrInvalidInput):
		return status.Error(codes.InvalidArgument, "无效输入")

	// 业务逻辑层错误
	case errors.Is(err, ErrNotChannelOwner):
		return status.Error(codes.PermissionDenied, "不是频道所有者")
	case errors.Is(err, ErrNotChannelAdmin):
		return status.Error(codes.PermissionDenied, "不是频道管理员")
	case errors.Is(err, ErrCannotRemoveOwner):
		return status.Error(codes.InvalidArgument, "不能移除频道所有者")
	case errors.Is(err, ErrNotSubscribed):
		return status.Error(codes.FailedPrecondition, "未订阅该频道")
	case errors.Is(err, ErrChannelNotPublic):
		return status.Error(codes.PermissionDenied, "频道不公开")
	case errors.Is(err, ErrInvalidChannelName):
		return status.Error(codes.InvalidArgument, "频道名称不能为空")
	case errors.Is(err, ErrInvalidPostContent):
		return status.Error(codes.InvalidArgument, "内容不能为空")

	default:
		return status.Error(codes.Internal, "内部服务错误")
	}
}
