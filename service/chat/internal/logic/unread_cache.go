package logic

import (
	"context"
	"fmt"
	"log/slog"
	"time"

	"github.com/google/uuid"
	"github.com/funcdfs/lesser/chat/internal/data_access"
	"github.com/funcdfs/lesser/pkg/db"
)

const (
	// UnreadCacheTTL 未读数缓存过期时间
	UnreadCacheTTL = 24 * time.Hour
)

// UnreadCacheService 未读数缓存服务
type UnreadCacheService struct {
	cache       *db.Client
	messageRepo *data_access.MessageRepository
}

// NewUnreadCacheService 创建未读数缓存服务
func NewUnreadCacheService(cache *db.Client, messageRepo *data_access.MessageRepository) *UnreadCacheService {
	return &UnreadCacheService{
		cache:       cache,
		messageRepo: messageRepo,
	}
}

func unreadCacheKey(userID, conversationID uuid.UUID) string {
	return fmt.Sprintf("chat:unread:%s:%s", userID, conversationID)
}

// GetUnreadCount 获取单个会话的未读数
func (s *UnreadCacheService) GetUnreadCount(ctx context.Context, userID, conversationID uuid.UUID) (int64, error) {
	key := unreadCacheKey(userID, conversationID)

	// 尝试从缓存获取
	var count int64
	err := s.db.Get(ctx, key, &count)
	if err == nil {
		return count, nil
	}

	// 缓存未命中，从数据库获取
	if err == db.ErrKeyNotFound {
		count, err = s.messageRepo.GetUnreadCount(ctx, conversationID, userID)
		if err != nil {
			return 0, fmt.Errorf("从数据库获取未读数失败: %w", err)
		}

		// 写入缓存
		if cacheErr := s.db.Set(ctx, key, count, UnreadCacheTTL); cacheErr != nil {
			slog.Warn("更新未读数缓存失败", slog.Any("error", cacheErr))
		}

		return count, nil
	}

	// 缓存读取失败，降级到数据库
	slog.Warn("读取缓存失败，降级到数据库查询", slog.Any("error", err))
	return s.messageRepo.GetUnreadCount(ctx, conversationID, userID)
}

// GetUnreadCountsBatch 批量获取未读数
func (s *UnreadCacheService) GetUnreadCountsBatch(ctx context.Context, userID uuid.UUID, conversationIDs []uuid.UUID) (map[uuid.UUID]int64, error) {
	if len(conversationIDs) == 0 {
		return make(map[uuid.UUID]int64), nil
	}

	result := make(map[uuid.UUID]int64, len(conversationIDs))
	var cacheMisses []uuid.UUID

	// 尝试从缓存批量获取
	for _, convID := range conversationIDs {
		key := unreadCacheKey(userID, convID)
		var count int64
		err := s.db.Get(ctx, key, &count)
		if err == nil {
			result[convID] = count
		} else {
			cacheMisses = append(cacheMisses, convID)
		}
	}

	// 从数据库获取未命中的
	if len(cacheMisses) > 0 {
		dbCounts, err := s.messageRepo.GetUnreadCountsBatch(ctx, userID, cacheMisses)
		if err != nil {
			return nil, fmt.Errorf("从数据库批量获取未读数失败: %w", err)
		}

		for convID, count := range dbCounts {
			result[convID] = count
			// 写入缓存
			key := unreadCacheKey(userID, convID)
			if cacheErr := s.db.Set(ctx, key, count, UnreadCacheTTL); cacheErr != nil {
				slog.Warn("更新未读数缓存失败", slog.Any("error", cacheErr))
			}
		}

		// 确保所有会话都有结果
		for _, convID := range cacheMisses {
			if _, exists := result[convID]; !exists {
				result[convID] = 0
			}
		}
	}

	return result, nil
}

// IncrementUnreadCount 增加未读数
func (s *UnreadCacheService) IncrementUnreadCount(ctx context.Context, userID, conversationID uuid.UUID) error {
	key := unreadCacheKey(userID, conversationID)
	client := s.db.GetClient()

	// 检查缓存是否存在
	exists, err := s.db.Exists(ctx, key)
	if err != nil {
		return fmt.Errorf("检查缓存键是否存在失败: %w", err)
	}

	if exists {
		// 缓存存在，直接增加
		if err := client.Incr(ctx, key).Err(); err != nil {
			return fmt.Errorf("增加未读数失败: %w", err)
		}
		// 刷新 TTL
		if err := client.Expire(ctx, key, UnreadCacheTTL).Err(); err != nil {
			slog.Warn("刷新缓存 TTL 失败", slog.Any("error", err))
		}
	} else {
		// 缓存不存在，从数据库获取后设置
		count, err := s.messageRepo.GetUnreadCount(ctx, conversationID, userID)
		if err != nil {
			return fmt.Errorf("从数据库获取未读数失败: %w", err)
		}
		// 新消息已经在数据库中，所以不需要 +1
		if err := s.db.Set(ctx, key, count, UnreadCacheTTL); err != nil {
			return fmt.Errorf("设置未读数缓存失败: %w", err)
		}
	}

	return nil
}

// ResetUnreadCount 重置未读数为 0
func (s *UnreadCacheService) ResetUnreadCount(ctx context.Context, userID, conversationID uuid.UUID) error {
	key := unreadCacheKey(userID, conversationID)
	if err := s.db.Set(ctx, key, int64(0), UnreadCacheTTL); err != nil {
		return fmt.Errorf("重置未读数缓存失败: %w", err)
	}
	return nil
}

// InvalidateCache 使缓存失效
func (s *UnreadCacheService) InvalidateCache(ctx context.Context, userID, conversationID uuid.UUID) error {
	key := unreadCacheKey(userID, conversationID)
	return s.db.Delete(ctx, key)
}
