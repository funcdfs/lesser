// Package data_access 提供交互服务的数据访问层
package data_access

import (
	"github.com/funcdfs/lesser/pkg/errors"
	"google.golang.org/grpc/codes"
)

// 预定义错误
var (
	// 通用错误
	ErrNotFound     = errors.New(codes.NotFound, "记录不存在")
	ErrDuplicate    = errors.New(codes.AlreadyExists, "记录已存在")
	ErrInvalidInput = errors.New(codes.InvalidArgument, "无效输入")

	// 点赞相关
	ErrAlreadyLiked = errors.New(codes.AlreadyExists, "已经点赞过")
	ErrNotLiked     = errors.New(codes.NotFound, "未点赞")

	// 收藏相关
	ErrAlreadyBookmarked = errors.New(codes.AlreadyExists, "已经收藏过")
	ErrNotBookmarked     = errors.New(codes.NotFound, "未收藏")

	// 转发相关
	ErrAlreadyReposted = errors.New(codes.AlreadyExists, "已经转发过")
	ErrNotReposted     = errors.New(codes.NotFound, "未转发")
)
