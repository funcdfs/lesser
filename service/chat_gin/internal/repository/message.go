package repository

import (
	"context"
	"fmt"

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

// MarkAsRead 标记消息为已读
func (r *MessageRepository) MarkAsRead(ctx context.Context, messageID uuid.UUID) error {
	result := r.db.WithContext(ctx).
		Model(&model.Message{}).
		Where("id = ?", messageID).
		Update("is_read", true)
	if result.Error != nil {
		return fmt.Errorf("标记已读失败: %w", result.Error)
	}
	return nil
}

// MarkConversationAsRead 标记会话中某用户之前的所有消息为已读
func (r *MessageRepository) MarkConversationAsRead(ctx context.Context, conversationID, userID uuid.UUID) error {
	// 标记该会话中不是自己发送的消息为已读
	result := r.db.WithContext(ctx).
		Model(&model.Message{}).
		Where("conversation_id = ? AND sender_id != ? AND is_read = ?", conversationID, userID, false).
		Update("is_read", true)
	if result.Error != nil {
		return fmt.Errorf("标记会话已读失败: %w", result.Error)
	}
	return nil
}
