package repository

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"github.com/lesser/chat/internal/model"
	"gorm.io/gorm"
)

// MessageRepository handles message data operations
type MessageRepository struct {
	db *gorm.DB
}

// NewMessageRepository creates a new MessageRepository
func NewMessageRepository(db *gorm.DB) *MessageRepository {
	return &MessageRepository{db: db}
}

// Create creates a new message
func (r *MessageRepository) Create(ctx context.Context, msg *model.Message) error {
	if err := r.db.WithContext(ctx).Create(msg).Error; err != nil {
		return fmt.Errorf("failed to create message: %w", err)
	}
	return nil
}

// GetByID retrieves a message by ID
func (r *MessageRepository) GetByID(ctx context.Context, id uuid.UUID) (*model.Message, error) {
	var msg model.Message
	err := r.db.WithContext(ctx).First(&msg, "id = ?", id).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, ErrNotFound
		}
		return nil, fmt.Errorf("failed to get message: %w", err)
	}
	return &msg, nil
}

// GetByConversationID retrieves messages for a conversation with pagination
func (r *MessageRepository) GetByConversationID(ctx context.Context, conversationID uuid.UUID, page, pageSize int) ([]model.Message, int64, error) {
	var messages []model.Message
	var total int64

	// Count total messages
	if err := r.db.WithContext(ctx).
		Model(&model.Message{}).
		Where("conversation_id = ?", conversationID).
		Count(&total).Error; err != nil {
		return nil, 0, fmt.Errorf("failed to count messages: %w", err)
	}

	// Get messages with pagination (newest first)
	offset := (page - 1) * pageSize
	err := r.db.WithContext(ctx).
		Where("conversation_id = ?", conversationID).
		Order("created_at DESC").
		Offset(offset).
		Limit(pageSize).
		Find(&messages).Error
	if err != nil {
		return nil, 0, fmt.Errorf("failed to get messages: %w", err)
	}

	return messages, total, nil
}

// GetLatestByConversationID retrieves the latest message for a conversation
func (r *MessageRepository) GetLatestByConversationID(ctx context.Context, conversationID uuid.UUID) (*model.Message, error) {
	var msg model.Message
	err := r.db.WithContext(ctx).
		Where("conversation_id = ?", conversationID).
		Order("created_at DESC").
		First(&msg).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, nil // No messages yet
		}
		return nil, fmt.Errorf("failed to get latest message: %w", err)
	}
	return &msg, nil
}

// GetByFilter retrieves messages matching the filter
func (r *MessageRepository) GetByFilter(ctx context.Context, filter model.MessageFilter, page, pageSize int) ([]model.Message, int64, error) {
	var messages []model.Message
	var total int64

	query := r.db.WithContext(ctx).Model(&model.Message{})

	// Apply filters
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

	// Count total
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, fmt.Errorf("failed to count messages: %w", err)
	}

	// Get messages with pagination
	offset := (page - 1) * pageSize
	err := query.
		Order("created_at DESC").
		Offset(offset).
		Limit(pageSize).
		Find(&messages).Error
	if err != nil {
		return nil, 0, fmt.Errorf("failed to get messages: %w", err)
	}

	return messages, total, nil
}

// Delete deletes a message
func (r *MessageRepository) Delete(ctx context.Context, id uuid.UUID) error {
	result := r.db.WithContext(ctx).Delete(&model.Message{}, "id = ?", id)
	if result.Error != nil {
		return fmt.Errorf("failed to delete message: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return ErrNotFound
	}
	return nil
}

// DeleteByConversationID deletes all messages in a conversation
func (r *MessageRepository) DeleteByConversationID(ctx context.Context, conversationID uuid.UUID) error {
	if err := r.db.WithContext(ctx).
		Where("conversation_id = ?", conversationID).
		Delete(&model.Message{}).Error; err != nil {
		return fmt.Errorf("failed to delete messages: %w", err)
	}
	return nil
}
