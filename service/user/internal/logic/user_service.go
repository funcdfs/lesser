// Package logic 提供用户服务的业务逻辑层
package logic

import (
	"context"
	"database/sql"
	"log/slog"

	"github.com/funcdfs/lesser/pkg/db"
	"github.com/funcdfs/lesser/pkg/log"
	"github.com/funcdfs/lesser/user/internal/data_access"
)

// EventPublisher 事件发布接口
// 由 messaging 层实现
type EventPublisher interface {
	PublishUserFollowed(ctx context.Context, followerID, followingID string)
}

// UserService 用户服务
type UserService struct {
	db           *sql.DB
	log          *log.Logger
	userRepo     *data_access.UserRepository
	followRepo   *data_access.FollowRepository
	blockRepo    *data_access.BlockRepository
	settingsRepo *data_access.SettingsRepository
	publisher    EventPublisher // 事件发布者（可选）
}

// NewUserService 创建用户服务实例
func NewUserService(
	db *sql.DB,
	log *log.Logger,
	userRepo *data_access.UserRepository,
	followRepo *data_access.FollowRepository,
	blockRepo *data_access.BlockRepository,
	settingsRepo *data_access.SettingsRepository,
) *UserService {
	return &UserService{
		db:           db,
		log:          log,
		userRepo:     userRepo,
		followRepo:   followRepo,
		blockRepo:    blockRepo,
		settingsRepo: settingsRepo,
	}
}

// SetPublisher 设置事件发布者
func (s *UserService) SetPublisher(publisher EventPublisher) {
	s.publisher = publisher
}

// ============================================================================
// 用户资料
// ============================================================================

// GetProfile 获取用户资料
func (s *UserService) GetProfile(ctx context.Context, userID string) (*data_access.User, error) {
	return s.userRepo.GetByID(ctx, userID)
}

// GetProfileByUsername 通过用户名获取资料
func (s *UserService) GetProfileByUsername(ctx context.Context, username string) (*data_access.User, error) {
	return s.userRepo.GetByUsername(ctx, username)
}

// GetProfileWithRelationship 获取用户资料（带关系状态）
func (s *UserService) GetProfileWithRelationship(ctx context.Context, userID, viewerID string) (*data_access.User, *data_access.RelationshipStatus, error) {
	user, err := s.userRepo.GetByID(ctx, userID)
	if err != nil {
		return nil, nil, err
	}

	// 如果没有查看者，不计算关系
	if viewerID == "" || viewerID == userID {
		return user, nil, nil
	}

	relationship, err := s.GetRelationship(ctx, viewerID, userID)
	if err != nil {
		return user, nil, err
	}

	return user, relationship, nil
}

// UpdateProfile 更新用户资料
func (s *UserService) UpdateProfile(ctx context.Context, userID string, updates map[string]interface{}) (*data_access.User, error) {
	// 检查用户是否存在
	user, err := s.userRepo.GetByID(ctx, userID)
	if err != nil {
		return nil, err
	}

	// 应用更新
	if v, ok := updates["display_name"]; ok && v.(string) != "" {
		user.DisplayName = v.(string)
	}
	if v, ok := updates["avatar_url"]; ok && v.(string) != "" {
		user.AvatarURL = v.(string)
	}
	if v, ok := updates["bio"]; ok {
		user.Bio = v.(string)
	}
	if v, ok := updates["location"]; ok {
		user.Location = v.(string)
	}
	if v, ok := updates["website"]; ok {
		user.Website = v.(string)
	}
	if v, ok := updates["is_private"]; ok {
		user.IsPrivate = v.(bool)
	}

	if err := s.userRepo.Update(ctx, user); err != nil {
		return nil, err
	}

	return s.userRepo.GetByID(ctx, userID)
}

// BatchGetProfiles 批量获取用户资料
func (s *UserService) BatchGetProfiles(ctx context.Context, userIDs []string) (map[string]*data_access.User, error) {
	if len(userIDs) > 100 {
		userIDs = userIDs[:100]
	}
	return s.userRepo.BatchGetByIDs(ctx, userIDs)
}

// SearchUsers 搜索用户
func (s *UserService) SearchUsers(ctx context.Context, query string, limit, offset int) ([]*data_access.User, int, error) {
	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}
	return s.userRepo.Search(ctx, query, limit, offset)
}

// ============================================================================
// 关注系统
// ============================================================================

// Follow 关注用户
func (s *UserService) Follow(ctx context.Context, followerID, followingID string) error {
	// 不能关注自己
	if followerID == followingID {
		return data_access.ErrCannotFollowSelf
	}

	// 检查目标用户是否存在
	targetUser, err := s.userRepo.GetByID(ctx, followingID)
	if err != nil {
		return err
	}

	// 检查是否被对方屏蔽
	isBlocked, blockType, err := s.blockRepo.IsBlockedBy(ctx, followerID, followingID)
	if err != nil {
		return err
	}
	if isBlocked && (blockType == data_access.BlockTypeBlock || blockType == data_access.BlockTypeHideMe) {
		return data_access.ErrFollowBlocked
	}

	// 检查是否已关注
	exists, err := s.followRepo.Exists(ctx, followerID, followingID)
	if err != nil {
		return err
	}
	if exists {
		return nil // 幂等操作
	}

	// 如果是私密账户，创建关注请求
	if targetUser.IsPrivate {
		return s.followRepo.CreateFollowRequest(ctx, followerID, followingID)
	}

	// 使用事务创建关注关系
	err = db.WithTransaction(ctx, s.db, func(tx *sql.Tx) error {
		if err := s.followRepo.Create(ctx, followerID, followingID); err != nil {
			return err
		}
		if err := s.userRepo.IncrementFollowingCount(ctx, followerID); err != nil {
			return err
		}
		return s.userRepo.IncrementFollowersCount(ctx, followingID)
	})

	if err != nil {
		return err
	}

	// 发布关注事件（异步，不阻塞主流程）
	if s.publisher != nil {
		s.publisher.PublishUserFollowed(ctx, followerID, followingID)
		s.log.Debug("已发布用户关注事件",
			slog.String("follower_id", followerID),
			slog.String("following_id", followingID))
	}

	return nil
}

// Unfollow 取消关注
func (s *UserService) Unfollow(ctx context.Context, followerID, followingID string) error {
	// 检查是否已关注
	exists, err := s.followRepo.Exists(ctx, followerID, followingID)
	if err != nil {
		return err
	}
	if !exists {
		// 可能有待处理的关注请求，删除它
		_ = s.followRepo.DeleteFollowRequest(ctx, followerID, followingID)
		return nil // 幂等操作
	}

	// 使用事务删除关注关系
	return db.WithTransaction(ctx, s.db, func(tx *sql.Tx) error {
		if err := s.followRepo.Delete(ctx, followerID, followingID); err != nil {
			return err
		}
		if err := s.userRepo.DecrementFollowingCount(ctx, followerID); err != nil {
			return err
		}
		return s.userRepo.DecrementFollowersCount(ctx, followingID)
	})
}

// GetFollowers 获取粉丝列表
func (s *UserService) GetFollowers(ctx context.Context, userID string, limit, offset int) ([]*data_access.User, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.followRepo.GetFollowers(ctx, userID, limit, offset)
}

// GetFollowing 获取关注列表
func (s *UserService) GetFollowing(ctx context.Context, userID string, limit, offset int) ([]*data_access.User, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.followRepo.GetFollowing(ctx, userID, limit, offset)
}

// CheckFollowing 检查是否关注
func (s *UserService) CheckFollowing(ctx context.Context, followerID, followingID string) (bool, error) {
	return s.followRepo.Exists(ctx, followerID, followingID)
}

// GetMutualFollowers 获取共同关注
func (s *UserService) GetMutualFollowers(ctx context.Context, userID, targetID string, limit, offset int) ([]*data_access.User, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.followRepo.GetMutualFollowers(ctx, userID, targetID, limit, offset)
}

// ============================================================================
// 关系状态
// ============================================================================

// GetRelationship 获取两用户间的关系状态
func (s *UserService) GetRelationship(ctx context.Context, userID, targetID string) (*data_access.RelationshipStatus, error) {
	status := &data_access.RelationshipStatus{}

	// 关注状态
	isFollowing, err := s.followRepo.Exists(ctx, userID, targetID)
	if err != nil {
		return nil, err
	}
	status.IsFollowing = isFollowing

	isFollowedBy, err := s.followRepo.Exists(ctx, targetID, userID)
	if err != nil {
		return nil, err
	}
	status.IsFollowedBy = isFollowedBy
	status.IsMutual = isFollowing && isFollowedBy

	// 屏蔽状态
	myBlockType, theirBlockType, err := s.blockRepo.GetBidirectionalBlockStatus(ctx, userID, targetID)
	if err != nil {
		return nil, err
	}

	status.MyBlockType = myBlockType
	status.TheirBlockType = theirBlockType
	status.IsBlocking = myBlockType != data_access.BlockTypeUnspecified
	status.IsBlockedBy = theirBlockType != data_access.BlockTypeUnspecified

	// 细分屏蔽类型
	status.IsMuting = myBlockType == data_access.BlockTypeHidePosts || myBlockType == data_access.BlockTypeBlock
	status.IsHidingFrom = myBlockType == data_access.BlockTypeHideMe || myBlockType == data_access.BlockTypeBlock

	return status, nil
}

// ============================================================================
// 屏蔽系统
// ============================================================================

// Block 屏蔽用户
func (s *UserService) Block(ctx context.Context, blockerID, blockedID string, blockType data_access.BlockType) error {
	// 不能屏蔽自己
	if blockerID == blockedID {
		return data_access.ErrCannotBlockSelf
	}

	// 验证屏蔽类型
	if blockType < data_access.BlockTypeHidePosts || blockType > data_access.BlockTypeBlock {
		return data_access.ErrInvalidBlockType
	}

	// 检查目标用户是否存在
	if _, err := s.userRepo.GetByID(ctx, blockedID); err != nil {
		return err
	}

	// 使用事务
	return db.WithTransaction(ctx, s.db, func(tx *sql.Tx) error {
		// 创建屏蔽关系
		if err := s.blockRepo.Create(ctx, blockerID, blockedID, blockType); err != nil {
			return err
		}

		// 如果是拉黑，同时取消双方的关注关系
		if blockType == data_access.BlockTypeBlock {
			// 取消我对他的关注
			if exists, _ := s.followRepo.Exists(ctx, blockerID, blockedID); exists {
				if err := s.followRepo.Delete(ctx, blockerID, blockedID); err != nil {
					return err
				}
				_ = s.userRepo.DecrementFollowingCount(ctx, blockerID)
				_ = s.userRepo.DecrementFollowersCount(ctx, blockedID)
			}

			// 取消他对我的关注
			if exists, _ := s.followRepo.Exists(ctx, blockedID, blockerID); exists {
				if err := s.followRepo.Delete(ctx, blockedID, blockerID); err != nil {
					return err
				}
				_ = s.userRepo.DecrementFollowingCount(ctx, blockedID)
				_ = s.userRepo.DecrementFollowersCount(ctx, blockerID)
			}
		}

		return nil
	})
}

// Unblock 取消屏蔽
func (s *UserService) Unblock(ctx context.Context, blockerID, blockedID string, blockType data_access.BlockType) error {
	// 获取当前屏蔽状态
	currentBlock, err := s.blockRepo.Get(ctx, blockerID, blockedID)
	if err != nil {
		return err
	}
	if currentBlock == nil {
		return nil // 幂等操作
	}

	// 如果要取消的类型是 BLOCK，直接删除
	if blockType == data_access.BlockTypeBlock {
		return s.blockRepo.Delete(ctx, blockerID, blockedID)
	}

	// 如果当前是 BLOCK，取消其中一种
	if currentBlock.BlockType == data_access.BlockTypeBlock {
		// BLOCK = HIDE_POSTS + HIDE_ME
		// 取消 HIDE_POSTS 后变成 HIDE_ME
		// 取消 HIDE_ME 后变成 HIDE_POSTS
		var newType data_access.BlockType
		if blockType == data_access.BlockTypeHidePosts {
			newType = data_access.BlockTypeHideMe
		} else {
			newType = data_access.BlockTypeHidePosts
		}
		return s.blockRepo.UpdateType(ctx, blockerID, blockedID, newType)
	}

	// 如果当前类型和要取消的类型一致，删除
	if currentBlock.BlockType == blockType {
		return s.blockRepo.Delete(ctx, blockerID, blockedID)
	}

	return nil // 类型不匹配，不做操作
}

// GetBlockList 获取屏蔽列表
func (s *UserService) GetBlockList(ctx context.Context, userID string, blockType data_access.BlockType, limit, offset int) ([]*data_access.BlockedUser, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.blockRepo.GetBlockList(ctx, userID, blockType, limit, offset)
}

// CheckBlocked 检查屏蔽状态
func (s *UserService) CheckBlocked(ctx context.Context, userID, targetID string) (*data_access.RelationshipStatus, error) {
	return s.GetRelationship(ctx, userID, targetID)
}

// ============================================================================
// 用户设置
// ============================================================================

// GetUserSettings 获取用户设置
func (s *UserService) GetUserSettings(ctx context.Context, userID string) (*data_access.UserSettings, error) {
	return s.settingsRepo.GetUserSettings(ctx, userID)
}

// UpdatePrivacySettings 更新隐私设置
func (s *UserService) UpdatePrivacySettings(ctx context.Context, userID string, settings *data_access.PrivacySettings) error {
	settings.UserID = userID
	return s.settingsRepo.UpsertPrivacySettings(ctx, settings)
}

// UpdateNotificationSettings 更新通知设置
func (s *UserService) UpdateNotificationSettings(ctx context.Context, userID string, settings *data_access.NotificationSettings) error {
	settings.UserID = userID
	return s.settingsRepo.UpsertNotificationSettings(ctx, settings)
}
