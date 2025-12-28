package repository

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"github.com/lesser/chat/internal/model"
	"gorm.io/gorm"
)

// ConversationRepository handles conversation data operations
type ConversationRepository struct {
	db *gorm.DB
}

// NewConversationRepository creates a new ConversationRepository
func NewConversationRepository(db *gorm.DB) *ConversationRepository {
	return &ConversationRepository{db: db}
}

// Create creates a new conversation with members
func (r *ConversationRepository) Create(ctx context.Context, conv *model.Conversation, memberIDs []uuid.UUID) error {
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		// Create conversation
		if err := tx.Create(conv).Error; err != nil {
			return fmt.Errorf("failed to create conversation: %w", err)
		}

		// Add members
		members := make([]model.ConversationMember, len(memberIDs))
		for i, userID := range memberIDs {
			role := model.MemberRoleMember
			if userID == conv.CreatorID {
				role = model.MemberRoleOwner
			}
			members[i] = model.ConversationMember{
				ConversationID: conv.ID,
				UserID:         userID,
				Role:           role,
			}
		}

		if err := tx.Create(&members).Error; err != nil {
			return fmt.Errorf("failed to add members: %w", err)
		}

		return nil
	})
}

// GetByID retrieves a conversation by ID with members
func (r *ConversationRepository) GetByID(ctx context.Context, id uuid.UUID) (*model.Conversation, error) {
	var conv model.Conversation
	err := r.db.WithContext(ctx).
		Preload("Members").
		First(&conv, "id = ?", id).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, ErrNotFound
		}
		return nil, fmt.Errorf("failed to get conversation: %w", err)
	}
	return &conv, nil
}

// GetByUserID retrieves all conversations for a user
func (r *ConversationRepository) GetByUserID(ctx context.Context, userID uuid.UUID, page, pageSize int) ([]model.Conversation, int64, error) {
	var conversations []model.Conversation
	var total int64

	// Get conversation IDs for user
	subQuery := r.db.Model(&model.ConversationMember{}).
		Select("conversation_id").
		Where("user_id = ?", userID)

	// Count total
	if err := r.db.WithContext(ctx).
		Model(&model.Conversation{}).
		Where("id IN (?)", subQuery).
		Count(&total).Error; err != nil {
		return nil, 0, fmt.Errorf("failed to count conversations: %w", err)
	}

	// Get conversations with pagination
	offset := (page - 1) * pageSize
	err := r.db.WithContext(ctx).
		Preload("Members").
		Where("id IN (?)", subQuery).
		Order("updated_at DESC").
		Offset(offset).
		Limit(pageSize).
		Find(&conversations).Error
	if err != nil {
		return nil, 0, fmt.Errorf("failed to get conversations: %w", err)
	}

	return conversations, total, nil
}

// GetPrivateConversation finds an existing private conversation between two users
func (r *ConversationRepository) GetPrivateConversation(ctx context.Context, userID1, userID2 uuid.UUID) (*model.Conversation, error) {
	var conv model.Conversation

	// Find private conversation where both users are members
	subQuery1 := r.db.Model(&model.ConversationMember{}).
		Select("conversation_id").
		Where("user_id = ?", userID1)

	subQuery2 := r.db.Model(&model.ConversationMember{}).
		Select("conversation_id").
		Where("user_id = ?", userID2)

	err := r.db.WithContext(ctx).
		Preload("Members").
		Where("type = ?", model.ConversationTypePrivate).
		Where("id IN (?)", subQuery1).
		Where("id IN (?)", subQuery2).
		First(&conv).Error

	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, ErrNotFound
		}
		return nil, fmt.Errorf("failed to get private conversation: %w", err)
	}

	return &conv, nil
}

// AddMember adds a member to a conversation
func (r *ConversationRepository) AddMember(ctx context.Context, conversationID, userID uuid.UUID, role string) error {
	member := model.ConversationMember{
		ConversationID: conversationID,
		UserID:         userID,
		Role:           role,
	}
	if err := r.db.WithContext(ctx).Create(&member).Error; err != nil {
		return fmt.Errorf("failed to add member: %w", err)
	}
	return nil
}

// RemoveMember removes a member from a conversation
func (r *ConversationRepository) RemoveMember(ctx context.Context, conversationID, userID uuid.UUID) error {
	result := r.db.WithContext(ctx).
		Where("conversation_id = ? AND user_id = ?", conversationID, userID).
		Delete(&model.ConversationMember{})
	if result.Error != nil {
		return fmt.Errorf("failed to remove member: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return ErrNotFound
	}
	return nil
}

// IsMember checks if a user is a member of a conversation
func (r *ConversationRepository) IsMember(ctx context.Context, conversationID, userID uuid.UUID) (bool, error) {
	var count int64
	err := r.db.WithContext(ctx).
		Model(&model.ConversationMember{}).
		Where("conversation_id = ? AND user_id = ?", conversationID, userID).
		Count(&count).Error
	if err != nil {
		return false, fmt.Errorf("failed to check membership: %w", err)
	}
	return count > 0, nil
}

// UpdateTimestamp updates the conversation's updated_at timestamp
func (r *ConversationRepository) UpdateTimestamp(ctx context.Context, conversationID uuid.UUID) error {
	return r.db.WithContext(ctx).
		Model(&model.Conversation{}).
		Where("id = ?", conversationID).
		Update("updated_at", gorm.Expr("NOW()")).Error
}

// Delete deletes a conversation and all its members
func (r *ConversationRepository) Delete(ctx context.Context, id uuid.UUID) error {
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		// Delete members first
		if err := tx.Where("conversation_id = ?", id).Delete(&model.ConversationMember{}).Error; err != nil {
			return fmt.Errorf("failed to delete members: %w", err)
		}

		// Delete conversation
		result := tx.Delete(&model.Conversation{}, "id = ?", id)
		if result.Error != nil {
			return fmt.Errorf("failed to delete conversation: %w", result.Error)
		}
		if result.RowsAffected == 0 {
			return ErrNotFound
		}

		return nil
	})
}
