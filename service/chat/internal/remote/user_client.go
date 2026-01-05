// Package remote 提供外部服务客户端
package remote

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"

	"github.com/funcdfs/lesser/pkg/db"
	"github.com/funcdfs/lesser/pkg/log"
)

// UserInfo 用户信息
type UserInfo struct {
	ID          string  `json:"id"`
	Username    string  `json:"username"`
	Email       string  `json:"email"`
	DisplayName *string `json:"display_name"`
	AvatarURL   *string `json:"avatar_url"`
	Bio         *string `json:"bio"`
}

const (
	userCacheTTL    = 5 * time.Minute
	userCachePrefix = "chat:user:info:"
)

// UserClient 用户信息客户端（带缓存）
type UserClient struct {
	authClient *AuthClient
	cache      *db.Client
	log        *log.Logger
}

// NewUserClient 创建用户客户端
func NewUserClient(authClient *AuthClient, redisCache *db.Client, log *log.Logger) *UserClient {
	return &UserClient{
		authClient: authClient,
		cache:      redisCache,
		log:        log,
	}
}

// GetUser 获取单个用户信息
func (c *UserClient) GetUser(ctx context.Context, userID uuid.UUID) (*UserInfo, error) {
	cacheKey := userCacheKey(userID)

	// 尝试从缓存获取
	if c.cache != nil {
		var cached UserInfo
		if err := c.db.Get(ctx, cacheKey, &cached); err == nil {
			c.log.WithContext(ctx).Debug("用户信息缓存命中", "user_id", userID.String())
			return &cached, nil
		}
	}

	// 从 Auth 服务获取
	if c.authClient == nil {
		return nil, fmt.Errorf("Auth 客户端未配置")
	}

	user, err := c.authClient.GetUser(ctx, userID)
	if err != nil {
		return nil, err
	}

	// 写入缓存
	if c.cache != nil {
		if err := c.db.Set(ctx, cacheKey, user, userCacheTTL); err != nil {
			c.log.WithContext(ctx).Warn("写入用户缓存失败", "error", err)
		}
	}

	return user, nil
}

// GetUsers 批量获取用户信息
func (c *UserClient) GetUsers(ctx context.Context, userIDs []uuid.UUID) (map[uuid.UUID]*UserInfo, error) {
	if len(userIDs) == 0 {
		return make(map[uuid.UUID]*UserInfo), nil
	}

	result := make(map[uuid.UUID]*UserInfo, len(userIDs))
	var missedIDs []uuid.UUID

	// 尝试从缓存批量获取
	if c.cache != nil {
		for _, userID := range userIDs {
			cacheKey := userCacheKey(userID)
			var cached UserInfo
			if err := c.db.Get(ctx, cacheKey, &cached); err == nil {
				result[userID] = &cached
			} else {
				missedIDs = append(missedIDs, userID)
			}
		}
	} else {
		missedIDs = userIDs
	}

	// 所有都命中缓存
	if len(missedIDs) == 0 {
		c.log.WithContext(ctx).Debug("批量用户信息全部缓存命中", "count", len(userIDs))
		return result, nil
	}

	// 从 Auth 服务获取未命中的
	if c.authClient == nil {
		return result, nil
	}

	for _, userID := range missedIDs {
		user, err := c.authClient.GetUser(ctx, userID)
		if err != nil {
			c.log.WithContext(ctx).Warn("获取用户失败",
				"user_id", userID.String(),
				"error", err)
			continue
		}
		result[userID] = user

		// 写入缓存
		if c.cache != nil {
			cacheKey := userCacheKey(userID)
			if err := c.db.Set(ctx, cacheKey, user, userCacheTTL); err != nil {
				c.log.WithContext(ctx).Warn("写入用户缓存失败", "error", err)
			}
		}
	}

	c.log.WithContext(ctx).Debug("批量获取用户信息完成",
		"total", len(userIDs),
		"cached", len(userIDs)-len(missedIDs),
		"fetched", len(missedIDs))

	return result, nil
}

// InvalidateUserCache 使用户缓存失效
func (c *UserClient) InvalidateUserCache(ctx context.Context, userID uuid.UUID) error {
	if c.cache == nil {
		return nil
	}
	return c.db.Delete(ctx, userCacheKey(userID))
}

func userCacheKey(userID uuid.UUID) string {
	return userCachePrefix + userID.String()
}
