// Package data_access 提供内容服务的数据访问层
package data_access

import (
	"github.com/funcdfs/lesser/pkg/errors"
	"google.golang.org/grpc/codes"
)

// 预定义错误
var (
	// 内容相关
	ErrContentNotFound = errors.New(codes.NotFound, "内容不存在")
	ErrUnauthorized    = errors.New(codes.PermissionDenied, "无权限操作")
	ErrInvalidInput    = errors.New(codes.InvalidArgument, "无效输入")
	ErrDuplicate       = errors.New(codes.AlreadyExists, "内容已存在")

	// 计数器相关
	ErrInvalidCounterType = errors.New(codes.InvalidArgument, "无效的计数器类型")
)
