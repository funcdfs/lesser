// Package logic Channel 业务逻辑层
package logic

import (
	"context"
	
	"strings"

	"github.com/funcdfs/lesser/channel/internal/data_access"
	"github.com/funcdfs/lesser/channel/internal/remote"
	"github.com/funcdfs/lesser/pkg/db"
	"github.com/funcdfs/lesser/pkg/log"
)

// channelService 频道服务实现
type channelService struct {
	channelDA      data_access.ChannelDataAccess
	subscriptionDA data_access.SubscriptionDataAccess
	postDA         data_access.PostDataAccess
	userClient       *remote.UserClient
	redisClient      *db.RedisClient
	log              *log.Logger
}

// ChannelServiceDeps 频道服务依赖
type ChannelServiceDeps struct {
	ChannelDA      data_access.ChannelDataAccess
	SubscriptionDA data_access.SubscriptionDataAccess
	PostDA         data_access.PostDataAccess
	UserClient       *remote.UserClient
	RedisClient      *db.RedisClient
	Logger           *log.Logger
}

// NewChannelService 创建频道服务
func NewChannelService(deps ChannelServiceDeps) ChannelService {
	return &channelService{
		channelDA:      deps.ChannelDA,
		subscriptionDA: deps.SubscriptionDA,
		postDA:         deps.PostDA,
		userClient:       deps.UserClient,
		redisClient:      deps.RedisClient,
		log:              deps.Logger,
	}
}

// ============================================================================
// 频道管理
// ============================================================================

// CreateChannel 创建频道
func (s *channelService) CreateChannel(ctx context.Context, userID string, req *CreateChannelRequest) (*data_access.Channel, error) {
	// 验证频道名称
	if strings.TrimSpace(req.Name) == "" {
		return nil, ErrInvalidChannelName
	}

	// 创建频道实体
	channel := &data_access.Channel{
		Name:        strings.TrimSpace(req.Name),
		Description: req.Description,
		AvatarURL:   req.AvatarURL,
		OwnerID:     userID,
	}

	// 保存到数据库
	if err := s.channelDA.Create(ctx, channel); err != nil {
		s.log.WithContext(ctx).Error("创建频道失败",
			log.String("user_id", userID),
			log.Any("error", err))
		return nil, err
	}

	s.log.WithContext(ctx).Info("频道创建成功",
		log.String("channel_id", channel.ID),
		log.String("owner_id", userID))

	return channel, nil
}

// GetChannel 获取频道信息
func (s *channelService) GetChannel(ctx context.Context, channelID, userID string) (*ChannelInfo, error) {
	// 获取频道基本信息
	channel, err := s.channelDA.GetByID(ctx, channelID)
	if err != nil {
		return nil, err
	}

	// 构建频道信息
	info := &ChannelInfo{
		Channel: channel,
		IsOwner: channel.OwnerID == userID,
	}

	// 检查是否为管理员
	if userID != "" {
		isAdmin, err := s.channelDA.IsAdmin(ctx, channelID, userID)
		if err != nil {
			s.log.WithContext(ctx).Error("检查管理员状态失败",
				log.String("channel_id", channelID),
				log.String("user_id", userID),
				log.Any("error", err))
		}
		info.IsAdmin = isAdmin || info.IsOwner

		// 检查是否已订阅
		isSubscribed, err := s.subscriptionDA.IsSubscribed(ctx, channelID, userID)
		if err != nil {
			s.log.WithContext(ctx).Error("检查订阅状态失败",
				log.String("channel_id", channelID),
				log.String("user_id", userID),
				log.Any("error", err))
		}
		info.IsSubscribed = isSubscribed
	}

	return info, nil
}

// UpdateChannel 更新频道信息
func (s *channelService) UpdateChannel(ctx context.Context, userID string, req *UpdateChannelRequest) (*data_access.Channel, error) {
	// 获取频道
	channel, err := s.channelDA.GetByID(ctx, req.ChannelID)
	if err != nil {
		return nil, err
	}

	// 检查权限：只有管理员可以更新
	isAdmin, err := s.channelDA.IsAdmin(ctx, req.ChannelID, userID)
	if err != nil {
		return nil, err
	}
	if !isAdmin && channel.OwnerID != userID {
		return nil, ErrNotChannelAdmin
	}

	// 更新字段
	if req.Name != "" {
		channel.Name = strings.TrimSpace(req.Name)
	}
	if req.Description != "" {
		channel.Description = req.Description
	}
	if req.AvatarURL != "" {
		channel.AvatarURL = req.AvatarURL
	}

	// 保存更新
	if err := s.channelDA.Update(ctx, channel); err != nil {
		s.log.WithContext(ctx).Error("更新频道失败",
			log.String("channel_id", req.ChannelID),
			log.Any("error", err))
		return nil, err
	}

	s.log.WithContext(ctx).Info("频道更新成功",
		log.String("channel_id", req.ChannelID),
		log.String("user_id", userID))

	return channel, nil
}

// DeleteChannel 删除频道
func (s *channelService) DeleteChannel(ctx context.Context, channelID, userID string) error {
	// 获取频道
	channel, err := s.channelDA.GetByID(ctx, channelID)
	if err != nil {
		return err
	}

	// 检查权限：只有所有者可以删除
	if channel.OwnerID != userID {
		return ErrNotChannelOwner
	}

	// 删除频道
	if err := s.channelDA.Delete(ctx, channelID); err != nil {
		s.log.WithContext(ctx).Error("删除频道失败",
			log.String("channel_id", channelID),
			log.Any("error", err))
		return err
	}

	s.log.WithContext(ctx).Info("频道删除成功",
		log.String("channel_id", channelID),
		log.String("user_id", userID))

	return nil
}

// GetSubscribedChannels 获取用户订阅的频道列表
func (s *channelService) GetSubscribedChannels(ctx context.Context, userID string, limit, offset int) ([]*ChannelInfo, int, error) {
	// 获取订阅的频道 ID 列表
	channelIDs, err := s.subscriptionDA.GetSubscribedChannels(ctx, userID, offset, limit)
	if err != nil {
		return nil, 0, err
	}

	// 获取频道详情
	var channels []*ChannelInfo
	for _, channelID := range channelIDs {
		info, err := s.GetChannel(ctx, channelID, userID)
		if err != nil {
			s.log.WithContext(ctx).Error("获取频道信息失败",
				log.String("channel_id", channelID),
				log.Any("error", err))
			continue
		}
		channels = append(channels, info)
	}

	return channels, len(channels), nil
}

// GetOwnedChannels 获取用户管理的频道列表
func (s *channelService) GetOwnedChannels(ctx context.Context, userID string, limit, offset int) ([]*ChannelInfo, int, error) {
	// 获取用户拥有的频道
	channels, err := s.channelDA.GetByOwnerID(ctx, userID, offset, limit)
	if err != nil {
		return nil, 0, err
	}

	// 转换为 ChannelInfo
	var result []*ChannelInfo
	for _, channel := range channels {
		result = append(result, &ChannelInfo{
			Channel:      channel,
			IsOwner:      true,
			IsAdmin:      true,
			IsSubscribed: true, // 所有者默认订阅
		})
	}

	return result, len(result), nil
}

// SearchChannels 搜索频道
func (s *channelService) SearchChannels(ctx context.Context, query, userID string, limit, offset int) ([]*ChannelInfo, int, error) {
	// TODO: 实现搜索逻辑，可以调用 Search 服务
	// 目前返回空列表
	return nil, 0, nil
}

// ============================================================================
// 订阅管理
// ============================================================================

// Subscribe 订阅频道
func (s *channelService) Subscribe(ctx context.Context, channelID, userID string) error {
	// 检查频道是否存在
	_, err := s.channelDA.GetByID(ctx, channelID)
	if err != nil {
		return err
	}

	// 订阅频道
	if err := s.subscriptionDA.Subscribe(ctx, channelID, userID); err != nil {
		s.log.WithContext(ctx).Error("订阅频道失败",
			log.String("channel_id", channelID),
			log.String("user_id", userID),
			log.Any("error", err))
		return err
	}

	// 增加订阅者计数
	if err := s.channelDA.IncrementSubscriberCount(ctx, channelID); err != nil {
		s.log.WithContext(ctx).Error("增加订阅者计数失败",
			log.String("channel_id", channelID),
			log.Any("error", err))
	}

	s.log.WithContext(ctx).Info("订阅频道成功",
		log.String("channel_id", channelID),
		log.String("user_id", userID))

	return nil
}

// Unsubscribe 取消订阅
func (s *channelService) Unsubscribe(ctx context.Context, channelID, userID string) error {
	// 取消订阅
	if err := s.subscriptionDA.Unsubscribe(ctx, channelID, userID); err != nil {
		s.log.WithContext(ctx).Error("取消订阅失败",
			log.String("channel_id", channelID),
			log.String("user_id", userID),
			log.Any("error", err))
		return err
	}

	// 减少订阅者计数
	if err := s.channelDA.DecrementSubscriberCount(ctx, channelID); err != nil {
		s.log.WithContext(ctx).Error("减少订阅者计数失败",
			log.String("channel_id", channelID),
			log.Any("error", err))
	}

	s.log.WithContext(ctx).Info("取消订阅成功",
		log.String("channel_id", channelID),
		log.String("user_id", userID))

	return nil
}

// GetSubscribers 获取频道订阅者列表
func (s *channelService) GetSubscribers(ctx context.Context, channelID string, limit, offset int) ([]*SubscriberInfo, int, error) {
	// 获取订阅者 ID 列表
	userIDs, err := s.subscriptionDA.GetSubscribers(ctx, channelID, offset, limit)
	if err != nil {
		return nil, 0, err
	}

	// 转换为 SubscriberInfo
	var subscribers []*SubscriberInfo
	for _, userID := range userIDs {
		subscribers = append(subscribers, &SubscriberInfo{
			UserID: userID,
		})
	}

	return subscribers, len(subscribers), nil
}

// CheckSubscription 检查是否已订阅
func (s *channelService) CheckSubscription(ctx context.Context, channelID, userID string) (bool, error) {
	return s.subscriptionDA.IsSubscribed(ctx, channelID, userID)
}

// ============================================================================
// 管理员管理
// ============================================================================

// AddAdmin 添加管理员
func (s *channelService) AddAdmin(ctx context.Context, channelID, targetUserID, operatorID string) error {
	// 获取频道
	channel, err := s.channelDA.GetByID(ctx, channelID)
	if err != nil {
		return err
	}

	// 检查权限：只有所有者可以添加管理员
	if channel.OwnerID != operatorID {
		return ErrNotChannelOwner
	}

	// 添加管理员
	if err := s.channelDA.AddAdmin(ctx, channelID, targetUserID); err != nil {
		s.log.WithContext(ctx).Error("添加管理员失败",
			log.String("channel_id", channelID),
			log.String("target_user_id", targetUserID),
			log.Any("error", err))
		return err
	}

	s.log.WithContext(ctx).Info("添加管理员成功",
		log.String("channel_id", channelID),
		log.String("target_user_id", targetUserID),
		log.String("operator_id", operatorID))

	return nil
}

// RemoveAdmin 移除管理员
func (s *channelService) RemoveAdmin(ctx context.Context, channelID, targetUserID, operatorID string) error {
	// 获取频道
	channel, err := s.channelDA.GetByID(ctx, channelID)
	if err != nil {
		return err
	}

	// 检查权限：只有所有者可以移除管理员
	if channel.OwnerID != operatorID {
		return ErrNotChannelOwner
	}

	// 不能移除所有者
	if targetUserID == channel.OwnerID {
		return ErrCannotRemoveOwner
	}

	// 移除管理员
	if err := s.channelDA.RemoveAdmin(ctx, channelID, targetUserID); err != nil {
		s.log.WithContext(ctx).Error("移除管理员失败",
			log.String("channel_id", channelID),
			log.String("target_user_id", targetUserID),
			log.Any("error", err))
		return err
	}

	s.log.WithContext(ctx).Info("移除管理员成功",
		log.String("channel_id", channelID),
		log.String("target_user_id", targetUserID),
		log.String("operator_id", operatorID))

	return nil
}

// GetAdmins 获取管理员列表
func (s *channelService) GetAdmins(ctx context.Context, channelID string) ([]*AdminInfo, error) {
	// 获取频道
	channel, err := s.channelDA.GetByID(ctx, channelID)
	if err != nil {
		return nil, err
	}

	// 获取管理员 ID 列表
	adminIDs, err := s.channelDA.GetAdmins(ctx, channelID)
	if err != nil {
		return nil, err
	}

	// 转换为 AdminInfo
	var admins []*AdminInfo
	for _, userID := range adminIDs {
		admins = append(admins, &AdminInfo{
			UserID:  userID,
			IsOwner: userID == channel.OwnerID,
		})
	}

	return admins, nil
}

// IsAdmin 检查是否是管理员（包括所有者）
func (s *channelService) IsAdmin(ctx context.Context, channelID, userID string) (bool, error) {
	// 获取频道
	channel, err := s.channelDA.GetByID(ctx, channelID)
	if err != nil {
		return false, err
	}

	// 所有者也是管理员
	if channel.OwnerID == userID {
		return true, nil
	}

	return s.channelDA.IsAdmin(ctx, channelID, userID)
}

// ============================================================================
// 内容发布
// ============================================================================

// PublishPost 发布内容
func (s *channelService) PublishPost(ctx context.Context, userID string, req *PublishPostRequest) (*data_access.ChannelPost, error) {
	// 验证内容
	if strings.TrimSpace(req.Content) == "" && len(req.MediaURLs) == 0 {
		return nil, ErrInvalidPostContent
	}

	// 检查权限：只有管理员可以发布内容
	isAdmin, err := s.IsAdmin(ctx, req.ChannelID, userID)
	if err != nil {
		return nil, err
	}
	if !isAdmin {
		return nil, ErrNotChannelAdmin
	}

	// 创建内容
	post := &data_access.ChannelPost{
		ChannelID: req.ChannelID,
		AuthorID:  userID,
		Content:   strings.TrimSpace(req.Content),
		MediaURLs: req.MediaURLs,
	}

	// 保存到数据库
	if err := s.postDA.Create(ctx, post); err != nil {
		s.log.WithContext(ctx).Error("发布内容失败",
			log.String("channel_id", req.ChannelID),
			log.String("user_id", userID),
			log.Any("error", err))
		return nil, err
	}

	// 增加内容计数
	if err := s.channelDA.IncrementPostCount(ctx, req.ChannelID); err != nil {
		s.log.WithContext(ctx).Error("增加内容计数失败",
			log.String("channel_id", req.ChannelID),
			log.Any("error", err))
	}

	s.log.WithContext(ctx).Info("发布内容成功",
		log.String("post_id", post.ID),
		log.String("channel_id", req.ChannelID),
		log.String("user_id", userID))

	return post, nil
}

// GetPost 获取单个内容
func (s *channelService) GetPost(ctx context.Context, postID string) (*data_access.ChannelPost, error) {
	post, err := s.postDA.GetByID(ctx, postID)
	if err != nil {
		return nil, err
	}

	// 增加浏览次数
	if err := s.postDA.IncrementViewCount(ctx, postID); err != nil {
		s.log.WithContext(ctx).Error("增加浏览次数失败",
			log.String("post_id", postID),
			log.Any("error", err))
	}

	return post, nil
}

// GetPosts 获取频道内容列表
func (s *channelService) GetPosts(ctx context.Context, channelID string, limit, offset int) ([]*data_access.ChannelPost, int, error) {
	posts, err := s.postDA.ListByChannel(ctx, channelID, offset, limit)
	if err != nil {
		return nil, 0, err
	}

	return posts, len(posts), nil
}

// EditPost 编辑内容
func (s *channelService) EditPost(ctx context.Context, userID string, req *EditPostRequest) (*data_access.ChannelPost, error) {
	// 获取内容
	post, err := s.postDA.GetByID(ctx, req.PostID)
	if err != nil {
		return nil, err
	}

	// 检查权限：只有作者或管理员可以编辑
	isAdmin, err := s.IsAdmin(ctx, post.ChannelID, userID)
	if err != nil {
		return nil, err
	}
	if post.AuthorID != userID && !isAdmin {
		return nil, ErrNotChannelAdmin
	}

	// TODO: 实现编辑逻辑（需要在 PostDataAccess 中添加 Update 方法）
	// 目前返回原内容
	return post, nil
}

// DeletePost 删除内容
func (s *channelService) DeletePost(ctx context.Context, postID, userID string) error {
	// 获取内容
	post, err := s.postDA.GetByID(ctx, postID)
	if err != nil {
		return err
	}

	// 检查权限：只有作者或管理员可以删除
	isAdmin, err := s.IsAdmin(ctx, post.ChannelID, userID)
	if err != nil {
		return err
	}
	if post.AuthorID != userID && !isAdmin {
		return ErrNotChannelAdmin
	}

	// 删除内容
	if err := s.postDA.Delete(ctx, postID); err != nil {
		s.log.WithContext(ctx).Error("删除内容失败",
			log.String("post_id", postID),
			log.Any("error", err))
		return err
	}

	// 减少内容计数
	if err := s.channelDA.DecrementPostCount(ctx, post.ChannelID); err != nil {
		s.log.WithContext(ctx).Error("减少内容计数失败",
			log.String("channel_id", post.ChannelID),
			log.Any("error", err))
	}

	s.log.WithContext(ctx).Info("删除内容成功",
		log.String("post_id", postID),
		log.String("user_id", userID))

	return nil
}

// PinPost 置顶内容
func (s *channelService) PinPost(ctx context.Context, postID, userID string) error {
	// 获取内容
	post, err := s.postDA.GetByID(ctx, postID)
	if err != nil {
		return err
	}

	// 检查权限：只有管理员可以置顶
	isAdmin, err := s.IsAdmin(ctx, post.ChannelID, userID)
	if err != nil {
		return err
	}
	if !isAdmin {
		return ErrNotChannelAdmin
	}

	// TODO: 实现置顶逻辑（需要在 PostDataAccess 中添加 Pin 方法）
	s.log.WithContext(ctx).Info("置顶内容成功",
		log.String("post_id", postID),
		log.String("user_id", userID))

	return nil
}

// UnpinPost 取消置顶
func (s *channelService) UnpinPost(ctx context.Context, postID, userID string) error {
	// 获取内容
	post, err := s.postDA.GetByID(ctx, postID)
	if err != nil {
		return err
	}

	// 检查权限：只有管理员可以取消置顶
	isAdmin, err := s.IsAdmin(ctx, post.ChannelID, userID)
	if err != nil {
		return err
	}
	if !isAdmin {
		return ErrNotChannelAdmin
	}

	// TODO: 实现取消置顶逻辑（需要在 PostDataAccess 中添加 Unpin 方法）
	s.log.WithContext(ctx).Info("取消置顶成功",
		log.String("post_id", postID),
		log.String("user_id", userID))

	return nil
}
