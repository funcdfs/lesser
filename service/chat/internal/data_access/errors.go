// Package data_access 提供聊天服务的数据访问层
package data_access

import (
	"github.com/funcdfs/lesser/pkg/errors"
	"google.golang.org/grpc/codes"
)

// 预定义错误
var (
	// 通用错误
	ErrNotFound     = errors.New(codes.NotFound, "记录不存在")
	ErrDuplicate    = errors.New(codes.AlreadyExists, "记录重复")
	ErrInvalidInput = errors.New(codes.InvalidArgument, "输入参数无效")

	// 会话相关
	ErrConversationNotFound  = errors.New(codes.NotFound, "会话不存在")
	ErrNotConversationMember = errors.New(codes.PermissionDenied, "您不是该会话的成员")

	// 消息相关
	ErrMessageNotFound = errors.New(codes.NotFound, "消息不存在")
)
