package data_access

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
)

// MessageType 消息类型 (数据库中为 INTEGER)
type MessageType int

const (
	MessageTypeText   MessageType = 1 // 文本消息
	MessageTypeImage  MessageType = 2 // 图片消息
	MessageTypeVideo  MessageType = 3 // 视频消息
	MessageTypeFile   MessageType = 4 // 文件消息
	MessageTypeSystem MessageType = 5 // 系统消息
)

// Message 消息实体 (匹配数据库 messages 表结构)
type Message struct {
	ID             uuid.UUID
	ConversationID uuid.UUID
	SenderID       uuid.UUID
	Type           MessageType
	Content        sql.NullString
	MediaURL       sql.NullString
	MediaType      sql.NullString
	ReplyToID      uuid.NullUUID
	IsEdited       bool
	IsDeleted      bool
	CreatedAt      time.Time
	UpdatedAt      time.Time
}

// MessageDataAccess 消息数据访问
type MessageDataAccess struct {
	db *sql.DB
}

// NewMessageDataAccess 创建消息数据访问
func NewMessageDataAccess(db *sql.DB) *MessageDataAccess {
	return &MessageDataAccess{db: db}
}

// Create 创建消息
func (r *MessageDataAccess) Create(ctx context.Context, msg *Message) error {
	query := `
		INSERT INTO messages (id, conversation_id, sender_id, type, content, media_url, media_type, reply_to_id, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
	`
	now := time.Now().UTC()
	if msg.ID == uuid.Nil {
		msg.ID = uuid.New()
	}
	msg.CreatedAt = now
	msg.UpdatedAt = now

	_, err := r.db.ExecContext(ctx, query,
		msg.ID, msg.ConversationID, msg.SenderID, int(msg.Type),
		msg.Content, msg.MediaURL, msg.MediaType, msg.ReplyToID,
		msg.CreatedAt, msg.UpdatedAt,
	)
	if err != nil {
		return fmt.Errorf("创建消息失败: %w", err)
	}
	return nil
}

// GetByID 根据 ID 获取消息
func (r *MessageDataAccess) GetByID(ctx context.Context, id uuid.UUID) (*Message, error) {
	query := `
		SELECT id, conversation_id, sender_id, type, content, media_url, media_type,
			   reply_to_id, is_edited, is_deleted, created_at, updated_at
		FROM messages
		WHERE id = $1 AND is_deleted = false
	`
	msg := &Message{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&msg.ID, &msg.ConversationID, &msg.SenderID, &msg.Type,
		&msg.Content, &msg.MediaURL, &msg.MediaType, &msg.ReplyToID,
		&msg.IsEdited, &msg.IsDeleted, &msg.CreatedAt, &msg.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, ErrNotFound
		}
		return nil, fmt.Errorf("获取消息失败: %w", err)
	}
	return msg, nil
}

// GetByConversationID 获取会话的消息列表
func (r *MessageDataAccess) GetByConversationID(ctx context.Context, conversationID uuid.UUID, page, pageSize int) ([]Message, int64, error) {
	// 统计总数
	countQuery := `
		SELECT COUNT(*) FROM messages
		WHERE conversation_id = $1 AND is_deleted = false
	`
	var total int64
	if err := r.db.QueryRowContext(ctx, countQuery, conversationID).Scan(&total); err != nil {
		return nil, 0, fmt.Errorf("统计消息数量失败: %w", err)
	}

	// 查询消息列表
	offset := (page - 1) * pageSize
	query := `
		SELECT id, conversation_id, sender_id, type, content, media_url, media_type,
			   reply_to_id, is_edited, is_deleted, created_at, updated_at
		FROM messages
		WHERE conversation_id = $1 AND is_deleted = false
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`
	rows, err := r.db.QueryContext(ctx, query, conversationID, pageSize, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("获取消息列表失败: %w", err)
	}
	defer rows.Close()

	var messages []Message
	for rows.Next() {
		var msg Message
		if err := rows.Scan(
			&msg.ID, &msg.ConversationID, &msg.SenderID, &msg.Type,
			&msg.Content, &msg.MediaURL, &msg.MediaType, &msg.ReplyToID,
			&msg.IsEdited, &msg.IsDeleted, &msg.CreatedAt, &msg.UpdatedAt,
		); err != nil {
			return nil, 0, fmt.Errorf("扫描消息失败: %w", err)
		}
		messages = append(messages, msg)
	}

	if err := rows.Err(); err != nil {
		return nil, 0, fmt.Errorf("遍历消息列表失败: %w", err)
	}

	return messages, total, nil
}

// GetLatestByConversationID 获取会话的最新消息
func (r *MessageDataAccess) GetLatestByConversationID(ctx context.Context, conversationID uuid.UUID) (*Message, error) {
	query := `
		SELECT id, conversation_id, sender_id, type, content, media_url, media_type,
			   reply_to_id, is_edited, is_deleted, created_at, updated_at
		FROM messages
		WHERE conversation_id = $1 AND is_deleted = false
		ORDER BY created_at DESC
		LIMIT 1
	`
	msg := &Message{}
	err := r.db.QueryRowContext(ctx, query, conversationID).Scan(
		&msg.ID, &msg.ConversationID, &msg.SenderID, &msg.Type,
		&msg.Content, &msg.MediaURL, &msg.MediaType, &msg.ReplyToID,
		&msg.IsEdited, &msg.IsDeleted, &msg.CreatedAt, &msg.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("获取最新消息失败: %w", err)
	}
	return msg, nil
}

// GetUnreadCount 获取会话的未读消息数
func (r *MessageDataAccess) GetUnreadCount(ctx context.Context, conversationID, userID uuid.UUID) (int64, error) {
	query := `
		SELECT COUNT(*)
		FROM messages m
		INNER JOIN conversation_members cm
			ON cm.conversation_id = m.conversation_id AND cm.user_id = $2
		WHERE m.conversation_id = $1
			AND m.sender_id != $2
			AND m.is_deleted = false
			AND m.created_at > COALESCE(cm.last_read_at, cm.joined_at, '1970-01-01')
	`
	var count int64
	if err := r.db.QueryRowContext(ctx, query, conversationID, userID).Scan(&count); err != nil {
		return 0, fmt.Errorf("获取未读数失败: %w", err)
	}
	return count, nil
}

// GetUnreadCountsBatch 批量获取多个会话的未读数
// 使用 pq.Array 安全处理 UUID 数组，避免 SQL 注入
func (r *MessageDataAccess) GetUnreadCountsBatch(ctx context.Context, userID uuid.UUID, conversationIDs []uuid.UUID) (map[uuid.UUID]int64, error) {
	if len(conversationIDs) == 0 {
		return make(map[uuid.UUID]int64), nil
	}

	// 将 UUID 转换为字符串数组
	convIDStrings := make([]string, len(conversationIDs))
	for i, id := range conversationIDs {
		convIDStrings[i] = id.String()
	}

	query := `
		SELECT m.conversation_id, COUNT(*)
		FROM messages m
		INNER JOIN conversation_members cm
			ON cm.conversation_id = m.conversation_id AND cm.user_id = $1
		WHERE m.conversation_id = ANY($2::uuid[])
			AND m.sender_id != $1
			AND m.is_deleted = false
			AND m.created_at > COALESCE(cm.last_read_at, cm.joined_at, '1970-01-01')
		GROUP BY m.conversation_id
	`

	rows, err := r.db.QueryContext(ctx, query, userID, pq.Array(convIDStrings))
	if err != nil {
		return nil, fmt.Errorf("批量获取未读数失败: %w", err)
	}
	defer rows.Close()

	// 初始化结果，所有会话默认为 0
	counts := make(map[uuid.UUID]int64, len(conversationIDs))
	for _, convID := range conversationIDs {
		counts[convID] = 0
	}

	for rows.Next() {
		var convID uuid.UUID
		var count int64
		if err := rows.Scan(&convID, &count); err != nil {
			return nil, fmt.Errorf("扫描未读数失败: %w", err)
		}
		counts[convID] = count
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("遍历结果失败: %w", err)
	}

	return counts, nil
}

// Delete 删除消息（软删除）
func (r *MessageDataAccess) Delete(ctx context.Context, id uuid.UUID) error {
	query := `UPDATE messages SET is_deleted = true, updated_at = $1 WHERE id = $2 AND is_deleted = false`
	result, err := r.db.ExecContext(ctx, query, time.Now().UTC(), id)
	if err != nil {
		return fmt.Errorf("删除消息失败: %w", err)
	}
	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		return ErrNotFound
	}
	return nil
}

// DeleteByConversationID 删除会话的所有消息（软删除）
func (r *MessageDataAccess) DeleteByConversationID(ctx context.Context, conversationID uuid.UUID) error {
	query := `UPDATE messages SET is_deleted = true, updated_at = $1 WHERE conversation_id = $2 AND is_deleted = false`
	_, err := r.db.ExecContext(ctx, query, time.Now().UTC(), conversationID)
	if err != nil {
		return fmt.Errorf("删除消息失败: %w", err)
	}
	return nil
}

// ReadReceipt 已读回执
type ReadReceipt struct {
	MessageID      uuid.UUID
	ConversationID uuid.UUID
	ReaderID       uuid.UUID
	ReadAt         time.Time
}

// BatchReadReceipt 批量已读回执
type BatchReadReceipt struct {
	ConversationID uuid.UUID
	ReaderID       uuid.UUID
	MessageIDs     []uuid.UUID
	ReadAt         time.Time
}

// FindUnreadMessageIDsInRange 查找指定时间范围内的未读消息 ID
func (r *MessageDataAccess) FindUnreadMessageIDsInRange(ctx context.Context, conversationID, userID uuid.UUID, afterTime, beforeOrEqualTime time.Time) ([]uuid.UUID, error) {
	query := `
		SELECT id FROM messages
		WHERE conversation_id = $1
			AND sender_id != $2
			AND is_deleted = false
			AND created_at > $3
			AND created_at <= $4
	`
	rows, err := r.db.QueryContext(ctx, query, conversationID, userID, afterTime, beforeOrEqualTime)
	if err != nil {
		return nil, fmt.Errorf("查找未读消息 ID 失败: %w", err)
	}
	defer rows.Close()

	var ids []uuid.UUID
	for rows.Next() {
		var id uuid.UUID
		if err := rows.Scan(&id); err != nil {
			return nil, fmt.Errorf("扫描消息 ID 失败: %w", err)
		}
		ids = append(ids, id)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("遍历消息 ID 列表失败: %w", err)
	}

	return ids, nil
}
