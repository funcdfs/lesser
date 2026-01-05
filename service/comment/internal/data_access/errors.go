// Package data_access 提供评论服务的数据访问层
package data_access

import (
	"github.com/funcdfs/lesser/pkg/errors"
	"google.golang.org/grpc/codes"
)

// 预定义错误
var (
	// 通用错误
	ErrNotFound = errors.New(codes.NotFound, "记录不存在")

	// 评论相关
	ErrCommentNotFound = errors.New(codes.NotFound, "评论不存在")
	ErrInvalidParent   = errors.New(codes.InvalidArgument, "父评论不存在或已删除")
	ErrInvalidInput    = errors.New(codes.InvalidArgument, "无效输入")
	ErrDuplicate       = errors.New(codes.AlreadyExists, "评论已存在")

	// 点赞相关
	ErrAlreadyLiked = errors.New(codes.AlreadyExists, "已经点赞过")
	ErrNotLiked     = errors.New(codes.NotFound, "未点赞")
)
