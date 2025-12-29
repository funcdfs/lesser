package service

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/lesser/chat/pkg/cache"
)

// UserInfo represents user information from auth service
type UserInfo struct {
	ID          string  `json:"id"`
	Username    string  `json:"username"`
	Email       string  `json:"email"`
	DisplayName *string `json:"display_name"`
	AvatarURL   *string `json:"avatar_url"`
	Bio         *string `json:"bio"`
}

// 缓存配置
const (
	userCacheTTL    = 5 * time.Minute  // 用户信息缓存 5 分钟
	userCachePrefix = "user:info:"
)

// UserClient 用户信息客户端，带 Redis 缓存层
// 优先从缓存获取，缓存未命中时通过 gRPC 调用 Django AuthService
type UserClient struct {
	authClient *AuthClient
	cache      *cache.RedisClient
}

// NewUserClient 创建带缓存的用户客户端
func NewUserClient(authClient *AuthClient, redisCache *cache.RedisClient) *UserClient {
	return &UserClient{
		authClient: authClient,
		cache:      redisCache,
	}
}

// GetUser 获取单个用户信息（缓存优先）
func (c *UserClient) GetUser(ctx context.Context, userID uuid.UUID) (*UserInfo, error) {
	cacheKey := userCacheKey(userID)

	// 1. 尝试从缓存获取
	if c.cache != nil {
		var cached UserInfo
		if err := c.cache.Get(ctx, cacheKey, &cached); err == nil {
			return &cached, nil
		}
		// 缓存未命中，继续从 gRPC 获取
	}

	// 2. 从 gRPC 获取
	if c.authClient == nil {
		return nil, fmt.Errorf("auth client not configured")
	}

	user, err := c.authClient.GetUser(ctx, userID)
	if err != nil {
		return nil, err
	}

	// 3. 写入缓存
	if c.cache != nil {
		if err := c.cache.Set(ctx, cacheKey, user, userCacheTTL); err != nil {
			// 缓存写入失败不影响主流程，仅记录日志
			fmt.Printf("警告: 写入用户缓存失败: %v\n", err)
		}
	}

	return user, nil
}

// GetUsers 批量获取用户信息（缓存优先）
// 先从 Redis 批量获取，缓存未命中的再通过 gRPC 获取
func (c *UserClient) GetUsers(ctx context.Context, userIDs []uuid.UUID) (map[uuid.UUID]*UserInfo, error) {
	if len(userIDs) == 0 {
		return make(map[uuid.UUID]*UserInfo), nil
	}

	result := make(map[uuid.UUID]*UserInfo, len(userIDs))
	var missedIDs []uuid.UUID

	// 1. 批量从缓存获取
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

	// 2. 缓存全部命中，直接返回
	if len(missedIDs) == 0 {
		return result, nil
	}

	// 3. 从 gRPC 获取缓存未命中的用户
	if c.authClient == nil {
		// 没有 auth client，返回已缓存的结果
		return result, nil
	}

	for _, userID := range missedIDs {
		user, err := c.authClient.GetUser(ctx, userID)
		if err != nil {
			// 记录错误但继续 - 用户可能已被删除
			fmt.Printf("警告: 获取用户 %s 失败: %v\n", userID, err)
			continue
		}
		result[userID] = user

		// 4. 写入缓存
		if c.cache != nil {
			cacheKey := userCacheKey(userID)
			if err := c.cache.Set(ctx, cacheKey, user, userCacheTTL); err != nil {
				fmt.Printf("警告: 写入用户缓存失败: %v\n", err)
			}
		}
	}

	return result, nil
}

// InvalidateUserCache 使用户缓存失效
// 当 Django 侧用户信息更新时，可通过消息队列触发此方法
func (c *UserClient) InvalidateUserCache(ctx context.Context, userID uuid.UUID) error {
	if c.cache == nil {
		return nil
	}
	return c.cache.Delete(ctx, userCacheKey(userID))
}

// InvalidateUserCacheBatch 批量使用户缓存失效
func (c *UserClient) InvalidateUserCacheBatch(ctx context.Context, userIDs []uuid.UUID) error {
	if c.cache == nil || len(userIDs) == 0 {
		return nil
	}

	keys := make([]string, len(userIDs))
	for i, id := range userIDs {
		keys[i] = userCacheKey(id)
	}
	return c.cache.Delete(ctx, keys...)
}

// userCacheKey 生成用户缓存键
func userCacheKey(userID uuid.UUID) string {
	return userCachePrefix + userID.String()
}
