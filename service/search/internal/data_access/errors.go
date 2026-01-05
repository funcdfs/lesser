// Package data_access 提供搜索服务的数据访问层
package data_access

import (
	"github.com/funcdfs/lesser/pkg/errors"
	"google.golang.org/grpc/codes"
)

// 预定义错误
var (
	// 搜索相关
	ErrNotFound     = errors.New(codes.NotFound, "记录不存在")
	ErrDuplicate    = errors.New(codes.AlreadyExists, "记录已存在")
	ErrInvalidInput = errors.New(codes.InvalidArgument, "无效输入")
	ErrInvalidQuery = errors.New(codes.InvalidArgument, "无效的搜索查询")
)
