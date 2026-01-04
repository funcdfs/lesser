package remote

import (
	"context"
	"fmt"
	"log/slog"
	"time"

	"github.com/google/uuid"
	"github.com/funcdfs/lesser/pkg/cache"
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
	cache      *cache.Client
}

// NewUserClient 创建用户客户端
func NewUserClient(authClient *AuthClient, redisCache *cache.Client) *UserClient {
	return &UserClient{
		authClient: authClient,
		cache:      redisCache,
	}
}

// GetUser 获取单个用户信息
func (c *UserClient) GetUser(ctx context.Context, userID uuid.UUID) (*UserInfo, error) {
	cacheKey := userCacheKey(userID)

	// 尝试从缓存获取
	if c.cache != nil {
		var cached UserInfo
		if err := c.cache.Get(ctx, cacheKey, &cached); err == nil {
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
		if err := c.cache.Set(ctx, cacheKey, user, userCacheTTL); err != nil {
			slog.Warn("写入用户缓存失败", slog.Any("error", err))
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
			if err := c.cache.Get(ctx, cacheKey, &cached); err == nil {
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
		return result, nil
	}

	// 从 Auth 服务获取未命中的
	if c.authClient == nil {
		return result, nil
	}

	for _, userID := range missedIDs {
		user, err := c.authClient.GetUser(ctx, userID)
		if err != nil {
			slog.Warn("获取用户失败", slog.String("user_id", userID.String()), slog.Any("error", err))
			continue
		}
		result[userID] = user

		// 写入缓存
		if c.cache != nil {
			cacheKey := userCacheKey(userID)
			if err := c.cache.Set(ctx, cacheKey, user, userCacheTTL); err != nil {
				slog.Warn("写入用户缓存失败", slog.Any("error", err))
			}
		}
	}

	return result, nil
}

// InvalidateUserCache 使用户缓存失效
func (c *UserClient) InvalidateUserCache(ctx context.Context, userID uuid.UUID) error {
	if c.cache == nil {
		return nil
	}
	return c.cache.Delete(ctx, userCacheKey(userID))
}

func userCacheKey(userID uuid.UUID) string {
	return userCachePrefix + userID.String()
}
