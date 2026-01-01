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
	UnreadCacheTTL = 24 * time.Hour
)

type UnreadCacheService struct {
	cache       *cache.RedisClient
	messageRepo *repository.MessageRepository
}

func NewUnreadCacheService(cache *cache.RedisClient, messageRepo *repository.MessageRepository) *UnreadCacheService {
	return &UnreadCacheService{
		cache:       cache,
		messageRepo: messageRepo,
	}
}

func unreadCacheKey(userID, conversationID uuid.UUID) string {
	return fmt.Sprintf("unread:%s:%s", userID, conversationID)
}

func (s *UnreadCacheService) GetUnreadCount(ctx context.Context, userID, conversationID uuid.UUID) (int64, error) {
	key := unreadCacheKey(userID, conversationID)

	var count int64
	err := s.cache.Get(ctx, key, &count)
	if err == nil {
		return count, nil
	}

	if err == cache.ErrKeyNotFound {
		count, err = s.messageRepo.GetUnreadCount(ctx, conversationID, userID)
		if err != nil {
			return 0, fmt.Errorf("从数据库获取未读数失败: %w", err)
		}

		if cacheErr := s.cache.Set(ctx, key, count, UnreadCacheTTL); cacheErr != nil {
			fmt.Printf("警告: 更新未读数缓存失败: %v\n", cacheErr)
		}

		return count, nil
	}

	fmt.Printf("警告: 读取缓存失败，降级到数据库查询: %v\n", err)
	return s.messageRepo.GetUnreadCount(ctx, conversationID, userID)
}

func (s *UnreadCacheService) GetUnreadCountsBatch(ctx context.Context, userID uuid.UUID, conversationIDs []uuid.UUID) (map[uuid.UUID]int64, error) {
	if len(conversationIDs) == 0 {
		return make(map[uuid.UUID]int64), nil
	}

	result := make(map[uuid.UUID]int64, len(conversationIDs))
	var cacheMisses []uuid.UUID

	for _, convID := range conversationIDs {
		key := unreadCacheKey(userID, convID)
		var count int64
		err := s.cache.Get(ctx, key, &count)
		if err == nil {
			result[convID] = count
		} else {
			cacheMisses = append(cacheMisses, convID)
		}
	}

	if len(cacheMisses) > 0 {
		dbCounts, err := s.messageRepo.GetUnreadCountsBatch(ctx, userID, cacheMisses)
		if err != nil {
			return nil, fmt.Errorf("从数据库批量获取未读数失败: %w", err)
		}

		for convID, count := range dbCounts {
			result[convID] = count
			key := unreadCacheKey(userID, convID)
			if cacheErr := s.cache.Set(ctx, key, count, UnreadCacheTTL); cacheErr != nil {
				fmt.Printf("警告: 更新未读数缓存失败: %v\n", cacheErr)
			}
		}

		for _, convID := range cacheMisses {
			if _, exists := result[convID]; !exists {
				result[convID] = 0
			}
		}
	}

	return result, nil
}

func (s *UnreadCacheService) IncrementUnreadCount(ctx context.Context, userID, conversationID uuid.UUID) error {
	key := unreadCacheKey(userID, conversationID)
	client := s.cache.GetClient()

	exists, err := s.cache.Exists(ctx, key)
	if err != nil {
		return fmt.Errorf("检查缓存键是否存在失败: %w", err)
	}

	if exists {
		if err := client.Incr(ctx, key).Err(); err != nil {
			return fmt.Errorf("增加未读数失败: %w", err)
		}
		if err := client.Expire(ctx, key, UnreadCacheTTL).Err(); err != nil {
			fmt.Printf("警告: 刷新缓存 TTL 失败: %v\n", err)
		}
	} else {
		count, err := s.messageRepo.GetUnreadCount(ctx, conversationID, userID)
		if err != nil {
			return fmt.Errorf("从数据库获取未读数失败: %w", err)
		}
		if err := s.cache.Set(ctx, key, count, UnreadCacheTTL); err != nil {
			return fmt.Errorf("设置未读数缓存失败: %w", err)
		}
	}

	return nil
}

func (s *UnreadCacheService) ResetUnreadCount(ctx context.Context, userID, conversationID uuid.UUID) error {
	key := unreadCacheKey(userID, conversationID)
	if err := s.cache.Set(ctx, key, int64(0), UnreadCacheTTL); err != nil {
		return fmt.Errorf("重置未读数缓存失败: %w", err)
	}
	return nil
}

func (s *UnreadCacheService) InvalidateCache(ctx context.Context, userID, conversationID uuid.UUID) error {
	key := unreadCacheKey(userID, conversationID)
	return s.cache.Delete(ctx, key)
}
