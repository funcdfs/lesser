package service

import (
	"errors"
	"testing"
)

func TestServiceErrors(t *testing.T) {
	tests := []struct {
		name string
		err  error
		want string
	}{
		// 权限相关
		{"ErrNotMember", ErrNotMember, "用户不是该会话的成员"},
		{"ErrNotAuthorized", ErrNotAuthorized, "用户无权执行此操作"},
		{"ErrCannotAddToPrivate", ErrCannotAddToPrivate, "无法向私聊会话添加成员"},
		{"ErrCannotMarkOwnMessage", ErrCannotMarkOwnMessage, "不能标记自己发送的消息为已读"},

		// 资源相关
		{"ErrMessageNotFound", ErrMessageNotFound, "消息不存在"},
		{"ErrConversationNotFound", ErrConversationNotFound, "会话不存在"},

		// 状态相关
		{"ErrAlreadyRead", ErrAlreadyRead, "消息已被标记为已读"},
		{"ErrCacheNotAvailable", ErrCacheNotAvailable, "缓存服务不可用"},

		// 输入相关
		{"ErrInvalidInput", ErrInvalidInput, "输入参数无效"},
		{"ErrInvalidConversationID", ErrInvalidConversationID, "会话ID不能为空"},
		{"ErrInvalidSenderID", ErrInvalidSenderID, "发送者ID不能为空"},
		{"ErrInvalidCreatorID", ErrInvalidCreatorID, "创建者ID不能为空"},
		{"ErrEmptyContent", ErrEmptyContent, "消息内容不能为空"},
		{"ErrNoMembers", ErrNoMembers, "至少需要一个成员"},
		{"ErrPrivateMemberCount", ErrPrivateMemberCount, "私聊会话必须有且仅有2个成员"},
		{"ErrGroupNameRequired", ErrGroupNameRequired, "群聊会话必须有名称"},

		// 操作相关
		{"ErrCreateConversationFailed", ErrCreateConversationFailed, "创建会话失败"},
		{"ErrCreateMessageFailed", ErrCreateMessageFailed, "创建消息失败"},
		{"ErrCheckMemberFailed", ErrCheckMemberFailed, "检查成员身份失败"},
		{"ErrGetConversationFailed", ErrGetConversationFailed, "获取会话信息失败"},
		{"ErrGetMessagesFailed", ErrGetMessagesFailed, "获取消息列表失败"},
		{"ErrGetConversationsFailed", ErrGetConversationsFailed, "获取会话列表失败"},
		{"ErrAddMemberFailed", ErrAddMemberFailed, "添加成员失败"},
		{"ErrRemoveMemberFailed", ErrRemoveMemberFailed, "移除成员失败"},
		{"ErrMarkReadFailed", ErrMarkReadFailed, "标记消息已读失败"},
		{"ErrGetMessageFailed", ErrGetMessageFailed, "获取消息失败"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if tt.err.Error() != tt.want {
				t.Errorf("%s.Error() = %v, want %v", tt.name, tt.err.Error(), tt.want)
			}
		})
	}
}

func TestErrorsAreDistinct(t *testing.T) {
	allErrors := []error{
		ErrNotMember,
		ErrNotAuthorized,
		ErrCannotAddToPrivate,
		ErrCannotMarkOwnMessage,
		ErrMessageNotFound,
		ErrConversationNotFound,
		ErrAlreadyRead,
		ErrCacheNotAvailable,
		ErrInvalidInput,
		ErrInvalidConversationID,
		ErrInvalidSenderID,
		ErrInvalidCreatorID,
		ErrEmptyContent,
		ErrNoMembers,
		ErrPrivateMemberCount,
		ErrGroupNameRequired,
	}

	for i, err1 := range allErrors {
		for j, err2 := range allErrors {
			if i != j && errors.Is(err1, err2) {
				t.Errorf("Error %v should not be equal to %v", err1, err2)
			}
		}
	}
}
