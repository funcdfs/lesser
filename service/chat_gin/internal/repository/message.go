package repository

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/lesser/chat/internal/model"
	"gorm.io/gorm"
)

// MessageRepository 消息数据仓库
type MessageRepository struct {
	db *gorm.DB
}

// NewMessageRepository 创建消息仓库实例
func NewMessageRepository(db *gorm.DB) *MessageRepository {
	return &MessageRepository{db: db}
}

// Create 创建新消息
func (r *MessageRepository) Create(ctx context.Context, msg *model.Message) error {
	if err := r.db.WithContext(ctx).Create(msg).Error; err != nil {
		return fmt.Errorf("创建消息失败: %w", err)
	}
	return nil
}

// GetByID 根据ID获取消息
func (r *MessageRepository) GetByID(ctx context.Context, id uuid.UUID) (*model.Message, error) {
	var msg model.Message
	err := r.db.WithContext(ctx).First(&msg, "id = ?", id).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, ErrNotFound
		}
		return nil, fmt.Errorf("获取消息失败: %w", err)
	}
	return &msg, nil
}

// GetByConversationID 获取会话的消息列表（分页，最新消息在前）
func (r *MessageRepository) GetByConversationID(ctx context.Context, conversationID uuid.UUID, page, pageSize int) ([]model.Message, int64, error) {
	var messages []model.Message
	var total int64

	// 统计消息总数
	if err := r.db.WithContext(ctx).
		Model(&model.Message{}).
		Where("conversation_id = ?", conversationID).
		Count(&total).Error; err != nil {
		return nil, 0, fmt.Errorf("统计消息数量失败: %w", err)
	}

	// 分页获取消息（最新消息在前）
	offset := (page - 1) * pageSize
	err := r.db.WithContext(ctx).
		Where("conversation_id = ?", conversationID).
		Order("created_at DESC").
		Offset(offset).
		Limit(pageSize).
		Find(&messages).Error
	if err != nil {
		return nil, 0, fmt.Errorf("获取消息列表失败: %w", err)
	}

	return messages, total, nil
}

// GetLatestByConversationID 获取会话的最新一条消息
func (r *MessageRepository) GetLatestByConversationID(ctx context.Context, conversationID uuid.UUID) (*model.Message, error) {
	var msg model.Message
	err := r.db.WithContext(ctx).
		Where("conversation_id = ?", conversationID).
		Order("created_at DESC").
		First(&msg).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, nil // 暂无消息
		}
		return nil, fmt.Errorf("获取最新消息失败: %w", err)
	}
	return &msg, nil
}

// GetByFilter 根据过滤条件获取消息
func (r *MessageRepository) GetByFilter(ctx context.Context, filter model.MessageFilter, page, pageSize int) ([]model.Message, int64, error) {
	var messages []model.Message
	var total int64

	query := r.db.WithContext(ctx).Model(&model.Message{})

	// 应用过滤条件
	if filter.ConversationID != uuid.Nil {
		query = query.Where("conversation_id = ?", filter.ConversationID)
	}
	if filter.SenderID != nil {
		query = query.Where("sender_id = ?", *filter.SenderID)
	}
	if filter.MessageType != nil {
		query = query.Where("message_type = ?", *filter.MessageType)
	}
	if filter.Before != nil {
		query = query.Where("created_at < ?", *filter.Before)
	}
	if filter.After != nil {
		query = query.Where("created_at > ?", *filter.After)
	}

	// 统计总数
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, fmt.Errorf("统计消息数量失败: %w", err)
	}

	// 分页获取消息
	offset := (page - 1) * pageSize
	err := query.
		Order("created_at DESC").
		Offset(offset).
		Limit(pageSize).
		Find(&messages).Error
	if err != nil {
		return nil, 0, fmt.Errorf("获取消息列表失败: %w", err)
	}

	return messages, total, nil
}

// Delete 删除消息
func (r *MessageRepository) Delete(ctx context.Context, id uuid.UUID) error {
	result := r.db.WithContext(ctx).Delete(&model.Message{}, "id = ?", id)
	if result.Error != nil {
		return fmt.Errorf("删除消息失败: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return ErrNotFound
	}
	return nil
}

// DeleteByConversationID 删除会话的所有消息
func (r *MessageRepository) DeleteByConversationID(ctx context.Context, conversationID uuid.UUID) error {
	if err := r.db.WithContext(ctx).
		Where("conversation_id = ?", conversationID).
		Delete(&model.Message{}).Error; err != nil {
		return fmt.Errorf("删除消息失败: %w", err)
	}
	return nil
}

// MarkAsRead 标记单条消息为已读
// 使用 read_at 时间戳记录已读时间
func (r *MessageRepository) MarkAsRead(ctx context.Context, messageID uuid.UUID, readAt time.Time) error {
	result := r.db.WithContext(ctx).
		Model(&model.Message{}).
		Where("id = ? AND read_at IS NULL", messageID).
		Update("read_at", readAt)
	if result.Error != nil {
		return fmt.Errorf("标记已读失败: %w", result.Error)
	}
	return nil
}

// MarkConversationAsRead 标记会话中某用户之前的所有消息为已读
// 返回被标记的消息ID列表（用于发送已读回执）
func (r *MessageRepository) MarkConversationAsRead(ctx context.Context, conversationID, userID uuid.UUID, readAt time.Time) ([]uuid.UUID, error) {
	// 先查询需要标记的消息ID
	var messageIDs []uuid.UUID
	err := r.db.WithContext(ctx).
		Model(&model.Message{}).
		Where("conversation_id = ? AND sender_id != ? AND read_at IS NULL", conversationID, userID).
		Pluck("id", &messageIDs).Error
	if err != nil {
		return nil, fmt.Errorf("查询未读消息失败: %w", err)
	}

	// 如果没有未读消息，直接返回空列表
	if len(messageIDs) == 0 {
		return []uuid.UUID{}, nil
	}

	// 标记该会话中不是自己发送的消息为已读
	result := r.db.WithContext(ctx).
		Model(&model.Message{}).
		Where("conversation_id = ? AND sender_id != ? AND read_at IS NULL", conversationID, userID).
		Update("read_at", readAt)
	if result.Error != nil {
		return nil, fmt.Errorf("标记会话已读失败: %w", result.Error)
	}
	return messageIDs, nil
}

// MarkMessagesUpToAsRead 标记指定消息及之前的所有消息为已读
// 返回被标记的消息ID列表
func (r *MessageRepository) MarkMessagesUpToAsRead(ctx context.Context, conversationID, userID, upToMessageID uuid.UUID, readAt time.Time) ([]uuid.UUID, error) {
	// 先获取目标消息的创建时间
	var targetMsg model.Message
	err := r.db.WithContext(ctx).
		Select("created_at").
		Where("id = ?", upToMessageID).
		First(&targetMsg).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, ErrNotFound
		}
		return nil, fmt.Errorf("获取目标消息失败: %w", err)
	}

	// 查询需要标记的消息ID（创建时间 <= 目标消息的创建时间）
	var messageIDs []uuid.UUID
	err = r.db.WithContext(ctx).
		Model(&model.Message{}).
		Where("conversation_id = ? AND sender_id != ? AND read_at IS NULL AND created_at <= ?",
			conversationID, userID, targetMsg.CreatedAt).
		Pluck("id", &messageIDs).Error
	if err != nil {
		return nil, fmt.Errorf("查询未读消息失败: %w", err)
	}

	// 如果没有未读消息，直接返回空列表
	if len(messageIDs) == 0 {
		return []uuid.UUID{}, nil
	}

	// 标记消息为已读
	result := r.db.WithContext(ctx).
		Model(&model.Message{}).
		Where("conversation_id = ? AND sender_id != ? AND read_at IS NULL AND created_at <= ?",
			conversationID, userID, targetMsg.CreatedAt).
		Update("read_at", readAt)
	if result.Error != nil {
		return nil, fmt.Errorf("标记消息已读失败: %w", result.Error)
	}
	return messageIDs, nil
}

// GetUnreadCount 获取用户在指定会话中的未读消息数
// 使用 read_at IS NULL 条件判断未读状态
func (r *MessageRepository) GetUnreadCount(ctx context.Context, conversationID, userID uuid.UUID) (int64, error) {
	var count int64
	err := r.db.WithContext(ctx).
		Model(&model.Message{}).
		Where("conversation_id = ? AND sender_id != ? AND read_at IS NULL", conversationID, userID).
		Count(&count).Error
	if err != nil {
		return 0, fmt.Errorf("获取未读数失败: %w", err)
	}
	return count, nil
}

// GetUnreadCountsBatch 批量获取多个会话的未读数
// 使用单条 SQL 查询多个会话的未读数，避免 N+1 查询问题
func (r *MessageRepository) GetUnreadCountsBatch(ctx context.Context, userID uuid.UUID, conversationIDs []uuid.UUID) (map[uuid.UUID]int64, error) {
	if len(conversationIDs) == 0 {
		return make(map[uuid.UUID]int64), nil
	}

	// 使用 GROUP BY 一次性查询所有会话的未读数
	type result struct {
		ConversationID uuid.UUID `gorm:"column:conversation_id"`
		Count          int64     `gorm:"column:count"`
	}
	var results []result

	err := r.db.WithContext(ctx).
		Model(&model.Message{}).
		Select("conversation_id, COUNT(*) as count").
		Where("conversation_id IN ? AND sender_id != ? AND read_at IS NULL", conversationIDs, userID).
		Group("conversation_id").
		Scan(&results).Error
	if err != nil {
		return nil, fmt.Errorf("批量获取未读数失败: %w", err)
	}

	// 构建结果 map，初始化所有会话的未读数为 0
	counts := make(map[uuid.UUID]int64, len(conversationIDs))
	for _, convID := range conversationIDs {
		counts[convID] = 0
	}
	// 填充查询结果
	for _, r := range results {
		counts[r.ConversationID] = r.Count
	}

	return counts, nil
}
