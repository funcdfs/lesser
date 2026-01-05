// Package data_access 提供用户服务的数据访问层
package data_access

import (
	"github.com/funcdfs/lesser/pkg/errors"
	"google.golang.org/grpc/codes"
)

// 预定义错误
var (
	// 用户相关
	ErrUserNotFound      = errors.New(codes.NotFound, "用户不存在")
	ErrUserAlreadyExists = errors.New(codes.AlreadyExists, "用户已存在")
	ErrUsernameNotFound  = errors.New(codes.NotFound, "用户名不存在")

	// 关注相关
	ErrCannotFollowSelf    = errors.New(codes.InvalidArgument, "不能关注自己")
	ErrAlreadyFollowing    = errors.New(codes.AlreadyExists, "已经关注了该用户")
	ErrNotFollowing        = errors.New(codes.NotFound, "未关注该用户")
	ErrFollowRequestExists = errors.New(codes.AlreadyExists, "关注请求已存在")
	ErrFollowBlocked       = errors.New(codes.PermissionDenied, "无法关注该用户")

	// 屏蔽相关
	ErrCannotBlockSelf  = errors.New(codes.InvalidArgument, "不能屏蔽自己")
	ErrAlreadyBlocked   = errors.New(codes.AlreadyExists, "已经屏蔽了该用户")
	ErrNotBlocked       = errors.New(codes.NotFound, "未屏蔽该用户")
	ErrInvalidBlockType = errors.New(codes.InvalidArgument, "无效的屏蔽类型")

	// 设置相关
	ErrSettingsNotFound = errors.New(codes.NotFound, "用户设置不存在")
)
