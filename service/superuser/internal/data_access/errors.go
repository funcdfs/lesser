// Package data_access 提供超级用户服务的数据访问层
package data_access

import (
	"github.com/funcdfs/lesser/pkg/errors"
	"google.golang.org/grpc/codes"
)

// 预定义错误
var (
	// 超级用户相关
	ErrSuperUserNotFound = errors.New(codes.NotFound, "超级管理员不存在")
	ErrNotFound          = errors.New(codes.NotFound, "记录不存在")
	ErrDuplicate         = errors.New(codes.AlreadyExists, "记录已存在")
	ErrInvalidInput      = errors.New(codes.InvalidArgument, "无效输入")

	// 认证相关
	ErrInvalidCredentials = errors.New(codes.Unauthenticated, "用户名或密码错误")
	ErrAccountDisabled    = errors.New(codes.PermissionDenied, "账户已禁用")

	// 会话相关
	ErrSessionNotFound = errors.New(codes.NotFound, "会话不存在")
	ErrSessionExpired  = errors.New(codes.Unauthenticated, "会话已过期")
)
