package repository

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"github.com/lesser/chat/internal/model"
	"gorm.io/gorm"
)

// ConversationRepository 会话数据仓库
type ConversationRepository struct {
	db *gorm.DB
}

// NewConversationRepository 创建会话仓库实例
func NewConversationRepository(db *gorm.DB) *ConversationRepository {
	return &ConversationRepository{db: db}
}

// Create 创建新会话及其成员
func (r *ConversationRepository) Create(ctx context.Context, conv *model.Conversation, memberIDs []uuid.UUID) error {
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		// 创建会话
		if err := tx.Create(conv).Error; err != nil {
			return fmt.Errorf("创建会话失败: %w", err)
		}

		// 添加成员
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
			return fmt.Errorf("添加成员失败: %w", err)
		}

		return nil
	})
}

// GetByID 根据ID获取会话（包含成员信息）
func (r *ConversationRepository) GetByID(ctx context.Context, id uuid.UUID) (*model.Conversation, error) {
	var conv model.Conversation
	err := r.db.WithContext(ctx).
		Preload("Members").
		First(&conv, "id = ?", id).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, ErrNotFound
		}
		return nil, fmt.Errorf("获取会话失败: %w", err)
	}
	return &conv, nil
}

// GetByUserID 获取用户的所有会话（分页）
func (r *ConversationRepository) GetByUserID(ctx context.Context, userID uuid.UUID, page, pageSize int) ([]model.Conversation, int64, error) {
	var conversations []model.Conversation
	var total int64

	// 获取用户参与的会话ID
	subQuery := r.db.Model(&model.ConversationMember{}).
		Select("conversation_id").
		Where("user_id = ?", userID)

	// 统计总数
	if err := r.db.WithContext(ctx).
		Model(&model.Conversation{}).
		Where("id IN (?)", subQuery).
		Count(&total).Error; err != nil {
		return nil, 0, fmt.Errorf("统计会话数量失败: %w", err)
	}

	// 分页获取会话
	offset := (page - 1) * pageSize
	err := r.db.WithContext(ctx).
		Preload("Members").
		Where("id IN (?)", subQuery).
		Order("updated_at DESC").
		Offset(offset).
		Limit(pageSize).
		Find(&conversations).Error
	if err != nil {
		return nil, 0, fmt.Errorf("获取会话列表失败: %w", err)
	}

	return conversations, total, nil
}

// GetPrivateConversation 查找两个用户之间的私聊会话
func (r *ConversationRepository) GetPrivateConversation(ctx context.Context, userID1, userID2 uuid.UUID) (*model.Conversation, error) {
	var conv model.Conversation

	// 查找两个用户都是成员的私聊会话
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
		return nil, fmt.Errorf("获取私聊会话失败: %w", err)
	}

	return &conv, nil
}

// AddMember 向会话添加成员
func (r *ConversationRepository) AddMember(ctx context.Context, conversationID, userID uuid.UUID, role string) error {
	member := model.ConversationMember{
		ConversationID: conversationID,
		UserID:         userID,
		Role:           role,
	}
	if err := r.db.WithContext(ctx).Create(&member).Error; err != nil {
		return fmt.Errorf("添加成员失败: %w", err)
	}
	return nil
}

// RemoveMember 从会话移除成员
func (r *ConversationRepository) RemoveMember(ctx context.Context, conversationID, userID uuid.UUID) error {
	result := r.db.WithContext(ctx).
		Where("conversation_id = ? AND user_id = ?", conversationID, userID).
		Delete(&model.ConversationMember{})
	if result.Error != nil {
		return fmt.Errorf("移除成员失败: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return ErrNotFound
	}
	return nil
}

// IsMember 检查用户是否是会话成员
func (r *ConversationRepository) IsMember(ctx context.Context, conversationID, userID uuid.UUID) (bool, error) {
	var count int64
	err := r.db.WithContext(ctx).
		Model(&model.ConversationMember{}).
		Where("conversation_id = ? AND user_id = ?", conversationID, userID).
		Count(&count).Error
	if err != nil {
		return false, fmt.Errorf("检查成员身份失败: %w", err)
	}
	return count > 0, nil
}

// UpdateTimestamp 更新会话的最后活动时间
func (r *ConversationRepository) UpdateTimestamp(ctx context.Context, conversationID uuid.UUID) error {
	return r.db.WithContext(ctx).
		Model(&model.Conversation{}).
		Where("id = ?", conversationID).
		Update("updated_at", gorm.Expr("NOW()")).Error
}

// Delete 删除会话及其所有成员
func (r *ConversationRepository) Delete(ctx context.Context, id uuid.UUID) error {
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		// 先删除成员
		if err := tx.Where("conversation_id = ?", id).Delete(&model.ConversationMember{}).Error; err != nil {
			return fmt.Errorf("删除成员失败: %w", err)
		}

		// 删除会话
		result := tx.Delete(&model.Conversation{}, "id = ?", id)
		if result.Error != nil {
			return fmt.Errorf("删除会话失败: %w", result.Error)
		}
		if result.RowsAffected == 0 {
			return ErrNotFound
		}

		return nil
	})
}
