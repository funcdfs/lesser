// Package logic 提供评论服务的业务逻辑层
package logic

import (
	"errors"

	"github.com/funcdfs/lesser/comment/internal/data_access"
	pkgerrors "github.com/funcdfs/lesser/pkg/errors"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// ToGRPCError 将业务错误转换为 gRPC 错误
// 确保所有错误消息为中文
func ToGRPCError(err error) error {
	if err == nil {
		return nil
	}

	// 如果已经是 gRPC 错误，直接返回
	if _, ok := status.FromError(err); ok {
		return err
	}

	// 如果是 pkg/errors.AppError，使用其内置转换
	var appErr *pkgerrors.AppError
	if errors.As(err, &appErr) {
		return appErr.ToGRPC()
	}

	// 业务逻辑层错误转换
	switch {
	// 评论相关
	case errors.Is(err, ErrContentNotFound):
		return status.Error(codes.NotFound, "内容不存在")
	case errors.Is(err, ErrCommentsDisabled):
		return status.Error(codes.PermissionDenied, "该内容已禁止评论")
	case errors.Is(err, ErrUnauthorized):
		return status.Error(codes.PermissionDenied, "无权限操作")
	case errors.Is(err, ErrCommentNotFound):
		return status.Error(codes.NotFound, "评论不存在")
	case errors.Is(err, ErrInvalidParent):
		return status.Error(codes.InvalidArgument, "父评论不存在或已删除")
	case errors.Is(err, ErrEmptyText):
		return status.Error(codes.InvalidArgument, "评论内容不能为空")
	case errors.Is(err, ErrTextTooLong):
		return status.Error(codes.InvalidArgument, "评论内容超出长度限制")
	case errors.Is(err, ErrAlreadyLiked):
		return status.Error(codes.AlreadyExists, "已经点赞过")
	case errors.Is(err, ErrNotLiked):
		return status.Error(codes.NotFound, "未点赞")

	// 数据访问层错误转换
	case errors.Is(err, data_access.ErrCommentNotFound):
		return status.Error(codes.NotFound, "评论不存在")
	case errors.Is(err, data_access.ErrInvalidParent):
		return status.Error(codes.InvalidArgument, "父评论不存在或已删除")
	case errors.Is(err, data_access.ErrAlreadyLiked):
		return status.Error(codes.AlreadyExists, "已经点赞过")
	case errors.Is(err, data_access.ErrNotLiked):
		return status.Error(codes.NotFound, "未点赞")
	case errors.Is(err, data_access.ErrNotFound):
		return status.Error(codes.NotFound, "记录不存在")
	case errors.Is(err, data_access.ErrDuplicate):
		return status.Error(codes.AlreadyExists, "记录已存在")
	case errors.Is(err, data_access.ErrInvalidInput):
		return status.Error(codes.InvalidArgument, "无效输入")

	default:
		return status.Error(codes.Internal, "内部服务错误")
	}
}
