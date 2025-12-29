package service

import "errors"

// 服务层错误定义
var (
	ErrNotMember            = errors.New("用户不是该会话的成员")
	ErrNotAuthorized        = errors.New("用户无权执行此操作")
	ErrCannotAddToPrivate   = errors.New("无法向私聊会话添加成员")
	ErrCacheNotAvailable    = errors.New("缓存服务不可用")
	ErrInvalidInput         = errors.New("输入参数无效")
	ErrCannotMarkOwnMessage = errors.New("不能标记自己发送的消息为已读")
	ErrAlreadyRead          = errors.New("消息已被标记为已读")
	ErrMessageNotFound      = errors.New("消息不存在")
)
