// Package data_access 提供认证服务的数据访问层
package data_access

import (
	"github.com/funcdfs/lesser/pkg/errors"
	"google.golang.org/grpc/codes"
)

// 预定义错误
var (
	// 用户相关
	ErrUserNotFound = errors.New(codes.NotFound, "用户不存在")
	ErrUserExists   = errors.New(codes.AlreadyExists, "用户已存在")
	ErrNotFound     = errors.New(codes.NotFound, "记录不存在")
	ErrDuplicate    = errors.New(codes.AlreadyExists, "记录已存在")
	ErrInvalidInput = errors.New(codes.InvalidArgument, "无效输入")

	// 封禁相关
	ErrBanNotFound = errors.New(codes.NotFound, "封禁记录不存在")
	ErrUserBanned  = errors.New(codes.PermissionDenied, "用户已被封禁")

	// 认证相关
	ErrInvalidCredentials = errors.New(codes.Unauthenticated, "用户名或密码错误")
	ErrTokenExpired       = errors.New(codes.Unauthenticated, "Token 已过期")
	ErrTokenInvalid       = errors.New(codes.Unauthenticated, "Token 无效")
)
