package service

import "errors"

// 服务层错误定义
var (
	// 权限相关
	ErrNotMember            = errors.New("用户不是该会话的成员")
	ErrNotAuthorized        = errors.New("用户无权执行此操作")
	ErrCannotAddToPrivate   = errors.New("无法向私聊会话添加成员")
	ErrCannotMarkOwnMessage = errors.New("不能标记自己发送的消息为已读")

	// 资源相关
	ErrMessageNotFound      = errors.New("消息不存在")
	ErrConversationNotFound = errors.New("会话不存在")

	// 状态相关
	ErrAlreadyRead       = errors.New("消息已被标记为已读")
	ErrCacheNotAvailable = errors.New("缓存服务不可用")

	// 输入相关
	ErrInvalidInput          = errors.New("输入参数无效")
	ErrInvalidConversationID = errors.New("会话ID不能为空")
	ErrInvalidSenderID       = errors.New("发送者ID不能为空")
	ErrInvalidCreatorID      = errors.New("创建者ID不能为空")
	ErrEmptyContent          = errors.New("消息内容不能为空")
	ErrNoMembers             = errors.New("至少需要一个成员")
	ErrPrivateMemberCount    = errors.New("私聊会话必须有且仅有2个成员")
	ErrGroupNameRequired     = errors.New("群聊会话必须有名称")

	// 操作相关
	ErrCreateConversationFailed = errors.New("创建会话失败")
	ErrCreateMessageFailed      = errors.New("创建消息失败")
	ErrCheckMemberFailed        = errors.New("检查成员身份失败")
	ErrGetConversationFailed    = errors.New("获取会话信息失败")
	ErrGetMessagesFailed        = errors.New("获取消息列表失败")
	ErrGetConversationsFailed   = errors.New("获取会话列表失败")
	ErrAddMemberFailed          = errors.New("添加成员失败")
	ErrRemoveMemberFailed       = errors.New("移除成员失败")
	ErrMarkReadFailed           = errors.New("标记消息已读失败")
	ErrGetMessageFailed         = errors.New("获取消息失败")
)
