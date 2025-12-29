package service

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/lesser/chat/internal/repository"
	"github.com/lesser/chat/pkg/cache"
)

const (
	// UnreadCacheTTL 未读数缓存过期时间
	UnreadCacheTTL = 24 * time.Hour
)

// UnreadCacheService 未读数缓存服务
type UnreadCacheService struct {
	cache       *cache.RedisClient
	messageRepo *repository.MessageRepository
}

// NewUnreadCacheService 创建未读数缓存服务实例
func NewUnreadCacheService(
	cache *cache.RedisClient,
	messageRepo *repository.MessageRepository,
) *UnreadCacheService {
	return &UnreadCacheService{
		cache:       cache,
		messageRepo: messageRepo,
	}
}

// unreadCacheKey 生成未读数缓存键
// 格式: unread:{user_id}:{conversation_id}
func unreadCacheKey(userID, conversationID uuid.UUID) string {
	return fmt.Sprintf("unread:%s:%s", userID, conversationID)
}

// GetUnreadCount 获取未读数（优先从缓存）
// 如果缓存不存在或已过期，则从数据库查询并更新缓存
func (s *UnreadCacheService) GetUnreadCount(ctx context.Context, userID, conversationID uuid.UUID) (int64, error) {
	key := unreadCacheKey(userID, conversationID)

	// 尝试从缓存获取
	var count int64
	err := s.cache.Get(ctx, key, &count)
	if err == nil {
		return count, nil
	}

	// 缓存未命中，从数据库查询
	if err == cache.ErrKeyNotFound {
		count, err = s.messageRepo.GetUnreadCount(ctx, conversationID, userID)
		if err != nil {
			return 0, fmt.Errorf("从数据库获取未读数失败: %w", err)
		}

		// 更新缓存
		if cacheErr := s.cache.Set(ctx, key, count, UnreadCacheTTL); cacheErr != nil {
			// 缓存更新失败只记录日志，不影响返回结果
			fmt.Printf("警告: 更新未读数缓存失败: %v\n", cacheErr)
		}

		return count, nil
	}

	// 其他缓存错误，降级到数据库查询
	fmt.Printf("警告: 读取缓存失败，降级到数据库查询: %v\n", err)
	return s.messageRepo.GetUnreadCount(ctx, conversationID, userID)
}

// GetUnreadCountsBatch 批量获取未读数
// 先从缓存获取，缓存未命中的从数据库查询并更新缓存
func (s *UnreadCacheService) GetUnreadCountsBatch(ctx context.Context, userID uuid.UUID, conversationIDs []uuid.UUID) (map[uuid.UUID]int64, error) {
	if len(conversationIDs) == 0 {
		return make(map[uuid.UUID]int64), nil
	}

	result := make(map[uuid.UUID]int64, len(conversationIDs))
	var cacheMisses []uuid.UUID

	// 尝试从缓存获取每个会话的未读数
	for _, convID := range conversationIDs {
		key := unreadCacheKey(userID, convID)
		var count int64
		err := s.cache.Get(ctx, key, &count)
		if err == nil {
			result[convID] = count
		} else {
			// 缓存未命中，记录下来稍后批量查询
			cacheMisses = append(cacheMisses, convID)
		}
	}

	// 如果有缓存未命中的，从数据库批量查询
	if len(cacheMisses) > 0 {
		dbCounts, err := s.messageRepo.GetUnreadCountsBatch(ctx, userID, cacheMisses)
		if err != nil {
			return nil, fmt.Errorf("从数据库批量获取未读数失败: %w", err)
		}

		// 更新结果并缓存
		for convID, count := range dbCounts {
			result[convID] = count
			// 更新缓存
			key := unreadCacheKey(userID, convID)
			if cacheErr := s.cache.Set(ctx, key, count, UnreadCacheTTL); cacheErr != nil {
				fmt.Printf("警告: 更新未读数缓存失败: %v\n", cacheErr)
			}
		}

		// 确保所有请求的会话都有结果（即使未读数为0）
		for _, convID := range cacheMisses {
			if _, exists := result[convID]; !exists {
				result[convID] = 0
			}
		}
	}

	return result, nil
}

// IncrementUnreadCount 增加未读数（发送新消息时调用）
func (s *UnreadCacheService) IncrementUnreadCount(ctx context.Context, userID, conversationID uuid.UUID) error {
	key := unreadCacheKey(userID, conversationID)

	// 获取 Redis 原生客户端进行 INCR 操作
	client := s.cache.GetClient()

	// 先检查键是否存在
	exists, err := s.cache.Exists(ctx, key)
	if err != nil {
		return fmt.Errorf("检查缓存键是否存在失败: %w", err)
	}

	if exists {
		// 键存在，直接增加
		if err := client.Incr(ctx, key).Err(); err != nil {
			return fmt.Errorf("增加未读数失败: %w", err)
		}
	} else {
		// 键不存在，从数据库获取当前值并设置
		count, err := s.messageRepo.GetUnreadCount(ctx, conversationID, userID)
		if err != nil {
			return fmt.Errorf("从数据库获取未读数失败: %w", err)
		}
		// 设置新值（当前值 + 1）
		if err := s.cache.Set(ctx, key, count+1, UnreadCacheTTL); err != nil {
			return fmt.Errorf("设置未读数缓存失败: %w", err)
		}
	}

	// 刷新 TTL
	if err := client.Expire(ctx, key, UnreadCacheTTL).Err(); err != nil {
		fmt.Printf("警告: 刷新缓存 TTL 失败: %v\n", err)
	}

	return nil
}

// ResetUnreadCount 重置未读数为0（标记已读时调用）
func (s *UnreadCacheService) ResetUnreadCount(ctx context.Context, userID, conversationID uuid.UUID) error {
	key := unreadCacheKey(userID, conversationID)

	// 设置为0并刷新TTL
	if err := s.cache.Set(ctx, key, int64(0), UnreadCacheTTL); err != nil {
		return fmt.Errorf("重置未读数缓存失败: %w", err)
	}

	return nil
}

// DecrementUnreadCount 减少未读数
func (s *UnreadCacheService) DecrementUnreadCount(ctx context.Context, userID, conversationID uuid.UUID, count int64) error {
	if count <= 0 {
		return nil
	}

	key := unreadCacheKey(userID, conversationID)
	client := s.cache.GetClient()

	// 先检查键是否存在
	exists, err := s.cache.Exists(ctx, key)
	if err != nil {
		return fmt.Errorf("检查缓存键是否存在失败: %w", err)
	}

	if exists {
		// 键存在，减少指定数量
		newVal, err := client.DecrBy(ctx, key, count).Result()
		if err != nil {
			return fmt.Errorf("减少未读数失败: %w", err)
		}
		// 确保不会变成负数
		if newVal < 0 {
			if err := s.cache.Set(ctx, key, int64(0), UnreadCacheTTL); err != nil {
				return fmt.Errorf("重置未读数缓存失败: %w", err)
			}
		}
	} else {
		// 键不存在，从数据库获取当前值并设置
		dbCount, err := s.messageRepo.GetUnreadCount(ctx, conversationID, userID)
		if err != nil {
			return fmt.Errorf("从数据库获取未读数失败: %w", err)
		}
		newCount := dbCount - count
		if newCount < 0 {
			newCount = 0
		}
		if err := s.cache.Set(ctx, key, newCount, UnreadCacheTTL); err != nil {
			return fmt.Errorf("设置未读数缓存失败: %w", err)
		}
	}

	// 刷新 TTL
	if err := client.Expire(ctx, key, UnreadCacheTTL).Err(); err != nil {
		fmt.Printf("警告: 刷新缓存 TTL 失败: %v\n", err)
	}

	return nil
}

// InvalidateCache 使缓存失效（用于数据不一致时强制刷新）
func (s *UnreadCacheService) InvalidateCache(ctx context.Context, userID, conversationID uuid.UUID) error {
	key := unreadCacheKey(userID, conversationID)
	return s.cache.Delete(ctx, key)
}

// InvalidateCacheBatch 批量使缓存失效
func (s *UnreadCacheService) InvalidateCacheBatch(ctx context.Context, userID uuid.UUID, conversationIDs []uuid.UUID) error {
	if len(conversationIDs) == 0 {
		return nil
	}

	keys := make([]string, len(conversationIDs))
	for i, convID := range conversationIDs {
		keys[i] = unreadCacheKey(userID, convID)
	}

	return s.cache.Delete(ctx, keys...)
}
