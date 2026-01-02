package repository

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/funcdfs/lesser/chat/internal/model"
	"gorm.io/gorm"
)

type MessageRepository struct {
	db *gorm.DB
}

func NewMessageRepository(db *gorm.DB) *MessageRepository {
	return &MessageRepository{db: db}
}

func (r *MessageRepository) Create(ctx context.Context, msg *model.Message) error {
	if err := r.db.WithContext(ctx).Create(msg).Error; err != nil {
		return fmt.Errorf("创建消息失败: %w", err)
	}
	return nil
}

func (r *MessageRepository) GetByID(ctx context.Context, id int64) (*model.Message, error) {
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

func (r *MessageRepository) GetByConversationID(ctx context.Context, conversationID uuid.UUID, page, pageSize int) ([]model.Message, int64, error) {
	var messages []model.Message
	var total int64

	if err := r.db.WithContext(ctx).
		Model(&model.Message{}).
		Where("dialog_id = ?", conversationID).
		Count(&total).Error; err != nil {
		return nil, 0, fmt.Errorf("统计消息数量失败: %w", err)
	}

	offset := (page - 1) * pageSize
	err := r.db.WithContext(ctx).
		Where("dialog_id = ?", conversationID).
		Order("date DESC").
		Offset(offset).
		Limit(pageSize).
		Find(&messages).Error
	if err != nil {
		return nil, 0, fmt.Errorf("获取消息列表失败: %w", err)
	}

	return messages, total, nil
}

func (r *MessageRepository) GetLatestByConversationID(ctx context.Context, conversationID uuid.UUID) (*model.Message, error) {
	var msg model.Message
	err := r.db.WithContext(ctx).
		Where("dialog_id = ?", conversationID).
		Order("date DESC").
		First(&msg).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, fmt.Errorf("获取最新消息失败: %w", err)
	}
	return &msg, nil
}

func (r *MessageRepository) GetByFilter(ctx context.Context, filter model.MessageFilter, page, pageSize int) ([]model.Message, int64, error) {
	var messages []model.Message
	var total int64

	query := r.db.WithContext(ctx).Model(&model.Message{})

	if filter.DialogID != nil {
		query = query.Where("dialog_id = ?", *filter.DialogID)
	}
	if filter.SenderID != nil {
		query = query.Where("sender_id = ?", *filter.SenderID)
	}
	if filter.MsgType != nil {
		query = query.Where("msg_type = ?", *filter.MsgType)
	}
	if filter.Before != nil {
		query = query.Where("date < ?", *filter.Before)
	}
	if filter.After != nil {
		query = query.Where("date > ?", *filter.After)
	}

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, fmt.Errorf("统计消息数量失败: %w", err)
	}

	offset := (page - 1) * pageSize
	err := query.
		Order("date DESC").
		Offset(offset).
		Limit(pageSize).
		Find(&messages).Error
	if err != nil {
		return nil, 0, fmt.Errorf("获取消息列表失败: %w", err)
	}

	return messages, total, nil
}

func (r *MessageRepository) Delete(ctx context.Context, id int64) error {
	result := r.db.WithContext(ctx).Delete(&model.Message{}, "id = ?", id)
	if result.Error != nil {
		return fmt.Errorf("删除消息失败: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *MessageRepository) DeleteByConversationID(ctx context.Context, conversationID uuid.UUID) error {
	if err := r.db.WithContext(ctx).
		Where("dialog_id = ?", conversationID).
		Delete(&model.Message{}).Error; err != nil {
		return fmt.Errorf("删除消息失败: %w", err)
	}
	return nil
}

func (r *MessageRepository) GetUnreadCount(ctx context.Context, conversationID, userID uuid.UUID) (int64, error) {
	var count int64
	err := r.db.WithContext(ctx).
		Table("chat_messages").
		Joins("JOIN chat_conversation_members ON chat_conversation_members.conversation_id = chat_messages.dialog_id AND chat_conversation_members.user_id = ?", userID).
		Where("chat_messages.dialog_id = ?", conversationID).
		Where("chat_messages.sender_id != ?", userID).
		Where("chat_messages.date > COALESCE(chat_conversation_members.last_read_at, chat_conversation_members.joined_at, '1970-01-01')").
		Count(&count).Error

	if err != nil {
		return 0, fmt.Errorf("获取未读数失败: %w", err)
	}
	return count, nil
}

func (r *MessageRepository) GetUnreadCountsBatch(ctx context.Context, userID uuid.UUID, conversationIDs []uuid.UUID) (map[uuid.UUID]int64, error) {
	if len(conversationIDs) == 0 {
		return make(map[uuid.UUID]int64), nil
	}

	type result struct {
		ConversationID uuid.UUID `gorm:"column:dialog_id"`
		Count          int64     `gorm:"column:count"`
	}
	var results []result

	err := r.db.WithContext(ctx).
		Table("chat_messages").
		Select("chat_messages.dialog_id, COUNT(*) as count").
		Joins("JOIN chat_conversation_members ON chat_conversation_members.conversation_id = chat_messages.dialog_id AND chat_conversation_members.user_id = ?", userID).
		Where("chat_messages.dialog_id IN ?", conversationIDs).
		Where("chat_messages.sender_id != ?", userID).
		Where("chat_messages.date > COALESCE(chat_conversation_members.last_read_at, chat_conversation_members.joined_at, '1970-01-01')").
		Group("chat_messages.dialog_id").
		Scan(&results).Error

	if err != nil {
		return nil, fmt.Errorf("批量获取未读数失败: %w", err)
	}

	counts := make(map[uuid.UUID]int64, len(conversationIDs))
	for _, convID := range conversationIDs {
		counts[convID] = 0
	}
	for _, r := range results {
		counts[r.ConversationID] = r.Count
	}

	return counts, nil
}

func (r *MessageRepository) FindUnreadMessageIDsInRange(ctx context.Context, conversationID, userID uuid.UUID, afterTime, beforeOrEqualTime time.Time) ([]int64, error) {
	var ids []int64
	err := r.db.WithContext(ctx).
		Model(&model.Message{}).
		Select("id").
		Where("dialog_id = ?", conversationID).
		Where("sender_id != ?", userID).
		Where("date > ?", afterTime).
		Where("date <= ?", beforeOrEqualTime).
		Find(&ids).Error
	if err != nil {
		return nil, fmt.Errorf("查找未读消息ID失败: %w", err)
	}
	return ids, nil
}
