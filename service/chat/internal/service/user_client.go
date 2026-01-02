package service

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/funcdfs/lesser/chat/pkg/cache"
)

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
	userCachePrefix = "user:info:"
)

type UserClient struct {
	authClient *AuthClient
	cache      *cache.RedisClient
}

func NewUserClient(authClient *AuthClient, redisCache *cache.RedisClient) *UserClient {
	return &UserClient{
		authClient: authClient,
		cache:      redisCache,
	}
}

func (c *UserClient) GetUser(ctx context.Context, userID uuid.UUID) (*UserInfo, error) {
	cacheKey := userCacheKey(userID)

	if c.cache != nil {
		var cached UserInfo
		if err := c.cache.Get(ctx, cacheKey, &cached); err == nil {
			return &cached, nil
		}
	}

	if c.authClient == nil {
		return nil, fmt.Errorf("auth client not configured")
	}

	user, err := c.authClient.GetUser(ctx, userID)
	if err != nil {
		return nil, err
	}

	if c.cache != nil {
		if err := c.cache.Set(ctx, cacheKey, user, userCacheTTL); err != nil {
			fmt.Printf("警告: 写入用户缓存失败: %v\n", err)
		}
	}

	return user, nil
}

func (c *UserClient) GetUsers(ctx context.Context, userIDs []uuid.UUID) (map[uuid.UUID]*UserInfo, error) {
	if len(userIDs) == 0 {
		return make(map[uuid.UUID]*UserInfo), nil
	}

	result := make(map[uuid.UUID]*UserInfo, len(userIDs))
	var missedIDs []uuid.UUID

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

	if len(missedIDs) == 0 {
		return result, nil
	}

	if c.authClient == nil {
		return result, nil
	}

	for _, userID := range missedIDs {
		user, err := c.authClient.GetUser(ctx, userID)
		if err != nil {
			fmt.Printf("警告: 获取用户 %s 失败: %v\n", userID, err)
			continue
		}
		result[userID] = user

		if c.cache != nil {
			cacheKey := userCacheKey(userID)
			if err := c.cache.Set(ctx, cacheKey, user, userCacheTTL); err != nil {
				fmt.Printf("警告: 写入用户缓存失败: %v\n", err)
			}
		}
	}

	return result, nil
}

func (c *UserClient) InvalidateUserCache(ctx context.Context, userID uuid.UUID) error {
	if c.cache == nil {
		return nil
	}
	return c.cache.Delete(ctx, userCacheKey(userID))
}

func userCacheKey(userID uuid.UUID) string {
	return userCachePrefix + userID.String()
}
