// Package data_access 提供时间线服务的数据访问层
package data_access

import (
	"github.com/funcdfs/lesser/pkg/errors"
	"google.golang.org/grpc/codes"
)

// 预定义错误
var (
	// 时间线相关
	ErrNotFound       = errors.New(codes.NotFound, "记录不存在")
	ErrDuplicate      = errors.New(codes.AlreadyExists, "记录已存在")
	ErrInvalidInput   = errors.New(codes.InvalidArgument, "无效输入")
	ErrContentExpired = errors.New(codes.NotFound, "内容已过期")
)
