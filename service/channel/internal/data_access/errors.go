// Package data_access 数据访问层错误定义
package data_access

import (
	"github.com/funcdfs/lesser/pkg/errors"
	"google.golang.org/grpc/codes"
)

var (
	// 通用错误
	ErrNotFound     = errors.New(codes.NotFound, "资源不存在")
	ErrDuplicate    = errors.New(codes.AlreadyExists, "资源已存在")
	ErrInvalidInput = errors.New(codes.InvalidArgument, "无效输入")

	// 频道相关
	ErrChannelNotFound = errors.New(codes.NotFound, "频道不存在")
	ErrChannelExists   = errors.New(codes.AlreadyExists, "频道已存在")

	// 订阅相关
	ErrAlreadySubscribed    = errors.New(codes.AlreadyExists, "已订阅该频道")
	ErrNotSubscribed        = errors.New(codes.NotFound, "未订阅该频道")
	ErrSubscriptionNotFound = errors.New(codes.NotFound, "订阅关系不存在")

	// 内容相关
	ErrPostNotFound = errors.New(codes.NotFound, "内容不存在")

	// 管理员相关
	ErrAdminNotFound = errors.New(codes.NotFound, "管理员不存在")
	ErrAlreadyAdmin  = errors.New(codes.AlreadyExists, "已经是管理员")

	// 用户相关（如需要）
	ErrUsernameExists = errors.New(codes.AlreadyExists, "用户名已存在")
)
