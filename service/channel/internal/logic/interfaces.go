package logic

import (
	"context"

	"github.com/funcdfs/lesser/channel/internal/data_access"
)

// ChannelService 频道服务接口
type ChannelService interface {
	// ============================================================================
	// 频道管理
	// ============================================================================

	// CreateChannel 创建频道
	CreateChannel(ctx context.Context, userID string, req *CreateChannelRequest) (*data_access.Channel, error)
	// GetChannel 获取频道信息
	GetChannel(ctx context.Context, channelID, userID string) (*ChannelInfo, error)
	// UpdateChannel 更新频道信息
	UpdateChannel(ctx context.Context, userID string, req *UpdateChannelRequest) (*data_access.Channel, error)
	// DeleteChannel 删除频道
	DeleteChannel(ctx context.Context, channelID, userID string) error
	// GetSubscribedChannels 获取用户订阅的频道列表
	GetSubscribedChannels(ctx context.Context, userID string, limit, offset int) ([]*ChannelInfo, int, error)
	// GetOwnedChannels 获取用户管理的频道列表
	GetOwnedChannels(ctx context.Context, userID string, limit, offset int) ([]*ChannelInfo, int, error)
	// SearchChannels 搜索频道
	SearchChannels(ctx context.Context, query, userID string, limit, offset int) ([]*ChannelInfo, int, error)

	// ============================================================================
	// 订阅管理
	// ============================================================================

	// Subscribe 订阅频道
	Subscribe(ctx context.Context, channelID, userID string) error
	// Unsubscribe 取消订阅
	Unsubscribe(ctx context.Context, channelID, userID string) error
	// GetSubscribers 获取频道订阅者列表
	GetSubscribers(ctx context.Context, channelID string, limit, offset int) ([]*SubscriberInfo, int, error)
	// CheckSubscription 检查是否已订阅
	CheckSubscription(ctx context.Context, channelID, userID string) (bool, error)

	// ============================================================================
	// 管理员管理
	// ============================================================================

	// AddAdmin 添加管理员
	AddAdmin(ctx context.Context, channelID, targetUserID, operatorID string) error
	// RemoveAdmin 移除管理员
	RemoveAdmin(ctx context.Context, channelID, targetUserID, operatorID string) error
	// GetAdmins 获取管理员列表
	GetAdmins(ctx context.Context, channelID string) ([]*AdminInfo, error)
	// IsAdmin 检查是否是管理员（包括所有者）
	IsAdmin(ctx context.Context, channelID, userID string) (bool, error)

	// ============================================================================
	// 内容发布
	// ============================================================================

	// PublishPost 发布内容
	PublishPost(ctx context.Context, userID string, req *PublishPostRequest) (*data_access.ChannelPost, error)
	// GetPost 获取单个内容
	GetPost(ctx context.Context, postID string) (*data_access.ChannelPost, error)
	// GetPosts 获取频道内容列表
	GetPosts(ctx context.Context, channelID string, limit, offset int) ([]*data_access.ChannelPost, int, error)
	// EditPost 编辑内容
	EditPost(ctx context.Context, userID string, req *EditPostRequest) (*data_access.ChannelPost, error)
	// DeletePost 删除内容
	DeletePost(ctx context.Context, postID, userID string) error
	// PinPost 置顶内容
	PinPost(ctx context.Context, postID, userID string) error
	// UnpinPost 取消置顶
	UnpinPost(ctx context.Context, postID, userID string) error
}

// CreateChannelRequest 创建频道请求
type CreateChannelRequest struct {
	Name        string
	Description string
	AvatarURL   string
	Username    string
	IsPublic    bool
}

// UpdateChannelRequest 更新频道请求
type UpdateChannelRequest struct {
	ChannelID   string
	Name        string
	Description string
	AvatarURL   string
	Username    string
	IsPublic    bool
}

// PublishPostRequest 发布内容请求
type PublishPostRequest struct {
	ChannelID string
	Content   string
	MediaURLs []string
}

// EditPostRequest 编辑内容请求
type EditPostRequest struct {
	PostID    string
	Content   string
	MediaURLs []string
}

// ChannelInfo 频道信息（包含用户相关状态）
type ChannelInfo struct {
	Channel      *data_access.Channel
	IsSubscribed bool
	IsAdmin      bool
	IsOwner      bool
	PinnedPost   *data_access.ChannelPost
}

// SubscriberInfo 订阅者信息
type SubscriberInfo struct {
	UserID       string
	SubscribedAt int64
}

// AdminInfo 管理员信息
type AdminInfo struct {
	UserID  string
	IsOwner bool
	AddedAt int64
}
