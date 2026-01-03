// Package repository 提供 Chat 服务的数据访问层
package repository

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
)

// ConversationType 会话类型
type ConversationType string

const (
	ConversationTypePrivate ConversationType = "private"
	ConversationTypeGroup   ConversationType = "group"
	ConversationTypeChannel ConversationType = "channel"
)

// MemberRole 成员角色
const (
	MemberRoleOwner  = "owner"
	MemberRoleAdmin  = "admin"
	MemberRoleMember = "member"
)

// Conversation 会话实体
type Conversation struct {
	ID          uuid.UUID
	Type        ConversationType
	Name        string
	CreatorID   uuid.UUID
	CreatedAt   time.Time
	UpdatedAt   time.Time
	Members     []ConversationMember
	LastMessage *Message
	UnreadCount int
}

// ConversationMember 会话成员
type ConversationMember struct {
	ConversationID uuid.UUID
	UserID         uuid.UUID
	Role           string
	JoinedAt       time.Time
	LastReadAt     sql.NullTime
	// 以下字段从 User 服务获取，不存储在数据库
	Username    string
	Email       string
	DisplayName *string
	AvatarURL   *string
}

// ConversationRepository 会话仓库
type ConversationRepository struct {
	db *sql.DB
}

// NewConversationRepository 创建会话仓库
func NewConversationRepository(db *sql.DB) *ConversationRepository {
	return &ConversationRepository{db: db}
}

// Create 创建会话
func (r *ConversationRepository) Create(ctx context.Context, conv *Conversation, memberIDs []uuid.UUID) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("开始事务失败: %w", err)
	}
	defer tx.Rollback()

	// 插入会话
	query := `
		INSERT INTO chat_conversations (id, type, name, creator_id, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6)
	`
	now := time.Now().UTC()
	conv.ID = uuid.New()
	conv.CreatedAt = now
	conv.UpdatedAt = now

	_, err = tx.ExecContext(ctx, query,
		conv.ID, conv.Type, conv.Name, conv.CreatorID, conv.CreatedAt, conv.UpdatedAt,
	)
	if err != nil {
		return fmt.Errorf("创建会话失败: %w", err)
	}

	// 插入成员
	memberQuery := `
		INSERT INTO chat_conversation_members (conversation_id, user_id, role, joined_at)
		VALUES ($1, $2, $3, $4)
	`
	for _, userID := range memberIDs {
		role := MemberRoleMember
		if userID == conv.CreatorID {
			role = MemberRoleOwner
		}
		_, err = tx.ExecContext(ctx, memberQuery, conv.ID, userID, role, now)
		if err != nil {
			return fmt.Errorf("添加成员失败: %w", err)
		}
	}

	return tx.Commit()
}

// GetByID 根据 ID 获取会话
func (r *ConversationRepository) GetByID(ctx context.Context, id uuid.UUID) (*Conversation, error) {
	query := `
		SELECT id, type, name, creator_id, created_at, updated_at
		FROM chat_conversations
		WHERE id = $1
	`
	conv := &Conversation{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&conv.ID, &conv.Type, &conv.Name, &conv.CreatorID, &conv.CreatedAt, &conv.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, ErrNotFound
		}
		return nil, fmt.Errorf("获取会话失败: %w", err)
	}

	// 获取成员
	members, err := r.getMembers(ctx, id)
	if err != nil {
		return nil, err
	}
	conv.Members = members

	return conv, nil
}

// GetByUserID 获取用户的会话列表
func (r *ConversationRepository) GetByUserID(ctx context.Context, userID uuid.UUID, page, pageSize int) ([]Conversation, int64, error) {
	// 统计总数
	countQuery := `
		SELECT COUNT(*)
		FROM chat_conversations c
		INNER JOIN chat_conversation_members m ON c.id = m.conversation_id
		WHERE m.user_id = $1
	`
	var total int64
	if err := r.db.QueryRowContext(ctx, countQuery, userID).Scan(&total); err != nil {
		return nil, 0, fmt.Errorf("统计会话数量失败: %w", err)
	}

	// 查询会话列表
	offset := (page - 1) * pageSize
	query := `
		SELECT c.id, c.type, c.name, c.creator_id, c.created_at, c.updated_at
		FROM chat_conversations c
		INNER JOIN chat_conversation_members m ON c.id = m.conversation_id
		WHERE m.user_id = $1
		ORDER BY c.updated_at DESC
		LIMIT $2 OFFSET $3
	`
	rows, err := r.db.QueryContext(ctx, query, userID, pageSize, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("获取会话列表失败: %w", err)
	}
	defer rows.Close()

	var conversations []Conversation
	for rows.Next() {
		var conv Conversation
		if err := rows.Scan(&conv.ID, &conv.Type, &conv.Name, &conv.CreatorID, &conv.CreatedAt, &conv.UpdatedAt); err != nil {
			return nil, 0, fmt.Errorf("扫描会话失败: %w", err)
		}

		// 获取成员
		members, err := r.getMembers(ctx, conv.ID)
		if err != nil {
			return nil, 0, err
		}
		conv.Members = members

		conversations = append(conversations, conv)
	}

	return conversations, total, nil
}

// GetPrivateConversation 获取两个用户之间的私聊会话
func (r *ConversationRepository) GetPrivateConversation(ctx context.Context, userID1, userID2 uuid.UUID) (*Conversation, error) {
	query := `
		SELECT c.id, c.type, c.name, c.creator_id, c.created_at, c.updated_at
		FROM chat_conversations c
		WHERE c.type = 'private'
		AND c.id IN (
			SELECT conversation_id FROM chat_conversation_members WHERE user_id = $1
		)
		AND c.id IN (
			SELECT conversation_id FROM chat_conversation_members WHERE user_id = $2
		)
		LIMIT 1
	`
	conv := &Conversation{}
	err := r.db.QueryRowContext(ctx, query, userID1, userID2).Scan(
		&conv.ID, &conv.Type, &conv.Name, &conv.CreatorID, &conv.CreatedAt, &conv.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, ErrNotFound
		}
		return nil, fmt.Errorf("获取私聊会话失败: %w", err)
	}

	members, err := r.getMembers(ctx, conv.ID)
	if err != nil {
		return nil, err
	}
	conv.Members = members

	return conv, nil
}

// IsMember 检查用户是否为会话成员
func (r *ConversationRepository) IsMember(ctx context.Context, conversationID, userID uuid.UUID) (bool, error) {
	query := `
		SELECT COUNT(*) FROM chat_conversation_members
		WHERE conversation_id = $1 AND user_id = $2
	`
	var count int64
	if err := r.db.QueryRowContext(ctx, query, conversationID, userID).Scan(&count); err != nil {
		return false, fmt.Errorf("检查成员身份失败: %w", err)
	}
	return count > 0, nil
}

// GetMember 获取成员信息
func (r *ConversationRepository) GetMember(ctx context.Context, conversationID, userID uuid.UUID) (*ConversationMember, error) {
	query := `
		SELECT conversation_id, user_id, role, joined_at, last_read_at
		FROM chat_conversation_members
		WHERE conversation_id = $1 AND user_id = $2
	`
	member := &ConversationMember{}
	err := r.db.QueryRowContext(ctx, query, conversationID, userID).Scan(
		&member.ConversationID, &member.UserID, &member.Role, &member.JoinedAt, &member.LastReadAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, ErrNotFound
		}
		return nil, fmt.Errorf("获取成员信息失败: %w", err)
	}
	return member, nil
}

// GetMemberIDs 获取会话的所有成员 ID
func (r *ConversationRepository) GetMemberIDs(ctx context.Context, conversationID uuid.UUID) ([]uuid.UUID, error) {
	query := `SELECT user_id FROM chat_conversation_members WHERE conversation_id = $1`
	rows, err := r.db.QueryContext(ctx, query, conversationID)
	if err != nil {
		return nil, fmt.Errorf("获取成员列表失败: %w", err)
	}
	defer rows.Close()

	var ids []uuid.UUID
	for rows.Next() {
		var id uuid.UUID
		if err := rows.Scan(&id); err != nil {
			return nil, fmt.Errorf("扫描成员 ID 失败: %w", err)
		}
		ids = append(ids, id)
	}
	return ids, nil
}

// AddMember 添加成员
func (r *ConversationRepository) AddMember(ctx context.Context, conversationID, userID uuid.UUID, role string) error {
	query := `
		INSERT INTO chat_conversation_members (conversation_id, user_id, role, joined_at)
		VALUES ($1, $2, $3, $4)
	`
	_, err := r.db.ExecContext(ctx, query, conversationID, userID, role, time.Now().UTC())
	if err != nil {
		if pqErr, ok := err.(*pq.Error); ok && pqErr.Code == "23505" {
			return ErrDuplicate
		}
		return fmt.Errorf("添加成员失败: %w", err)
	}
	return nil
}

// RemoveMember 移除成员
func (r *ConversationRepository) RemoveMember(ctx context.Context, conversationID, userID uuid.UUID) error {
	query := `DELETE FROM chat_conversation_members WHERE conversation_id = $1 AND user_id = $2`
	result, err := r.db.ExecContext(ctx, query, conversationID, userID)
	if err != nil {
		return fmt.Errorf("移除成员失败: %w", err)
	}
	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		return ErrNotFound
	}
	return nil
}

// UpdateTimestamp 更新会话时间戳
func (r *ConversationRepository) UpdateTimestamp(ctx context.Context, conversationID uuid.UUID) error {
	query := `UPDATE chat_conversations SET updated_at = $1 WHERE id = $2`
	_, err := r.db.ExecContext(ctx, query, time.Now().UTC(), conversationID)
	if err != nil {
		return fmt.Errorf("更新会话时间戳失败: %w", err)
	}
	return nil
}

// UpdateLastReadAt 更新成员的最后已读时间
func (r *ConversationRepository) UpdateLastReadAt(ctx context.Context, conversationID, userID uuid.UUID, readAt time.Time) error {
	query := `
		UPDATE chat_conversation_members
		SET last_read_at = $1
		WHERE conversation_id = $2 AND user_id = $3
	`
	result, err := r.db.ExecContext(ctx, query, readAt, conversationID, userID)
	if err != nil {
		return fmt.Errorf("更新最后已读时间失败: %w", err)
	}
	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		return ErrNotFound
	}
	return nil
}

// Delete 删除会话
func (r *ConversationRepository) Delete(ctx context.Context, id uuid.UUID) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("开始事务失败: %w", err)
	}
	defer tx.Rollback()

	// 删除成员
	_, err = tx.ExecContext(ctx, `DELETE FROM chat_conversation_members WHERE conversation_id = $1`, id)
	if err != nil {
		return fmt.Errorf("删除成员失败: %w", err)
	}

	// 删除会话
	result, err := tx.ExecContext(ctx, `DELETE FROM chat_conversations WHERE id = $1`, id)
	if err != nil {
		return fmt.Errorf("删除会话失败: %w", err)
	}
	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		return ErrNotFound
	}

	return tx.Commit()
}

// getMembers 获取会话的所有成员
func (r *ConversationRepository) getMembers(ctx context.Context, conversationID uuid.UUID) ([]ConversationMember, error) {
	query := `
		SELECT conversation_id, user_id, role, joined_at, last_read_at
		FROM chat_conversation_members
		WHERE conversation_id = $1
	`
	rows, err := r.db.QueryContext(ctx, query, conversationID)
	if err != nil {
		return nil, fmt.Errorf("获取成员列表失败: %w", err)
	}
	defer rows.Close()

	var members []ConversationMember
	for rows.Next() {
		var m ConversationMember
		if err := rows.Scan(&m.ConversationID, &m.UserID, &m.Role, &m.JoinedAt, &m.LastReadAt); err != nil {
			return nil, fmt.Errorf("扫描成员失败: %w", err)
		}
		members = append(members, m)
	}
	return members, nil
}
