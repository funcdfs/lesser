package repository

import (
	"context"
	"database/sql"
	"database/sql/driver"
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
)

// NullableJSON 可空的 JSON 类型
type NullableJSON json.RawMessage

// Scan 实现 sql.Scanner 接口
func (n *NullableJSON) Scan(value interface{}) error {
	if value == nil {
		*n = nil
		return nil
	}
	switch v := value.(type) {
	case []byte:
		*n = NullableJSON(v)
	case string:
		*n = NullableJSON(v)
	default:
		return fmt.Errorf("无法将 %T 转换为 NullableJSON", value)
	}
	return nil
}

// Value 实现 driver.Valuer 接口
func (n NullableJSON) Value() (driver.Value, error) {
	if n == nil {
		return nil, nil
	}
	return []byte(n), nil
}

// MessageType 消息类型
type MessageType int

const (
	MessageTypeText   MessageType = 0
	MessageTypeImage  MessageType = 1
	MessageTypeVideo  MessageType = 2
	MessageTypeLink   MessageType = 3
	MessageTypeFile   MessageType = 4
	MessageTypeSystem MessageType = 9
)

// String 返回消息类型字符串
func (mt MessageType) String() string {
	switch mt {
	case MessageTypeText:
		return "text"
	case MessageTypeImage:
		return "image"
	case MessageTypeVideo:
		return "video"
	case MessageTypeLink:
		return "link"
	case MessageTypeFile:
		return "file"
	case MessageTypeSystem:
		return "system"
	default:
		return "text"
	}
}

// ParseMessageType 解析消息类型字符串
func ParseMessageType(s string) MessageType {
	switch s {
	case "text":
		return MessageTypeText
	case "image":
		return MessageTypeImage
	case "video":
		return MessageTypeVideo
	case "link":
		return MessageTypeLink
	case "file":
		return MessageTypeFile
	case "system":
		return MessageTypeSystem
	default:
		return MessageTypeText
	}
}

// Message 消息实体
type Message struct {
	ID         int64
	LocalID    int32
	DialogID   uuid.UUID
	SenderID   uuid.UUID
	Content    string
	MsgType    MessageType
	Entities   NullableJSON
	MediaInfo  NullableJSON
	ReplyToID  sql.NullInt64
	Date       time.Time
	EditDate   sql.NullTime
	IsOutgoing bool
	IsUnread   bool
	Flags      int32
}

// ReadReceipt 已读回执
type ReadReceipt struct {
	MessageID      int64
	ConversationID uuid.UUID
	ReaderID       uuid.UUID
	ReadAt         time.Time
}

// BatchReadReceipt 批量已读回执
type BatchReadReceipt struct {
	ConversationID uuid.UUID
	ReaderID       uuid.UUID
	MessageIDs     []int64
	ReadAt         time.Time
}

// MessageRepository 消息仓库
type MessageRepository struct {
	db *sql.DB
}

// NewMessageRepository 创建消息仓库
func NewMessageRepository(db *sql.DB) *MessageRepository {
	return &MessageRepository{db: db}
}

// Create 创建消息
func (r *MessageRepository) Create(ctx context.Context, msg *Message) error {
	// 使用事务确保 local_id 的原子性递增
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("开始事务失败: %w", err)
	}
	defer tx.Rollback()

	// 获取当前会话的最大 local_id
	var maxLocalID sql.NullInt32
	err = tx.QueryRowContext(ctx,
		`SELECT MAX(local_id) FROM chat_messages WHERE dialog_id = $1`,
		msg.DialogID,
	).Scan(&maxLocalID)
	if err != nil {
		return fmt.Errorf("获取最大 local_id 失败: %w", err)
	}

	nextLocalID := int32(1)
	if maxLocalID.Valid {
		nextLocalID = maxLocalID.Int32 + 1
	}

	query := `
		INSERT INTO chat_messages (
			local_id, dialog_id, sender_id, content, msg_type, entities, media_info,
			reply_to_id, date, is_outgoing, is_unread, flags
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
		RETURNING id
	`
	if msg.Date.IsZero() {
		msg.Date = time.Now().UTC()
	}

	// 处理 JSON 字段，空值转为 null
	var entities, mediaInfo interface{}
	if len(msg.Entities) > 0 {
		entities = msg.Entities
	}
	if len(msg.MediaInfo) > 0 {
		mediaInfo = msg.MediaInfo
	}

	err = tx.QueryRowContext(ctx, query,
		nextLocalID, msg.DialogID, msg.SenderID, msg.Content, msg.MsgType,
		entities, mediaInfo, msg.ReplyToID,
		msg.Date, msg.IsOutgoing, msg.IsUnread, msg.Flags,
	).Scan(&msg.ID)
	if err != nil {
		return fmt.Errorf("创建消息失败: %w", err)
	}

	msg.LocalID = nextLocalID

	if err = tx.Commit(); err != nil {
		return fmt.Errorf("提交事务失败: %w", err)
	}

	return nil
}

// GetByID 根据 ID 获取消息
func (r *MessageRepository) GetByID(ctx context.Context, id int64) (*Message, error) {
	query := `
		SELECT id, local_id, dialog_id, sender_id, content, msg_type,
			   entities, media_info, reply_to_id, date, edit_date,
			   is_outgoing, is_unread, flags
		FROM chat_messages
		WHERE id = $1 AND deleted_at IS NULL
	`
	msg := &Message{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&msg.ID, &msg.LocalID, &msg.DialogID, &msg.SenderID, &msg.Content, &msg.MsgType,
		&msg.Entities, &msg.MediaInfo, &msg.ReplyToID, &msg.Date, &msg.EditDate,
		&msg.IsOutgoing, &msg.IsUnread, &msg.Flags,
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
func (r *MessageRepository) GetByConversationID(ctx context.Context, conversationID uuid.UUID, page, pageSize int) ([]Message, int64, error) {
	// 统计总数
	countQuery := `
		SELECT COUNT(*) FROM chat_messages
		WHERE dialog_id = $1 AND deleted_at IS NULL
	`
	var total int64
	if err := r.db.QueryRowContext(ctx, countQuery, conversationID).Scan(&total); err != nil {
		return nil, 0, fmt.Errorf("统计消息数量失败: %w", err)
	}

	// 查询消息列表
	offset := (page - 1) * pageSize
	query := `
		SELECT id, local_id, dialog_id, sender_id, content, msg_type,
			   entities, media_info, reply_to_id, date, edit_date,
			   is_outgoing, is_unread, flags
		FROM chat_messages
		WHERE dialog_id = $1 AND deleted_at IS NULL
		ORDER BY date DESC
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
			&msg.ID, &msg.LocalID, &msg.DialogID, &msg.SenderID, &msg.Content, &msg.MsgType,
			&msg.Entities, &msg.MediaInfo, &msg.ReplyToID, &msg.Date, &msg.EditDate,
			&msg.IsOutgoing, &msg.IsUnread, &msg.Flags,
		); err != nil {
			return nil, 0, fmt.Errorf("扫描消息失败: %w", err)
		}
		messages = append(messages, msg)
	}

	return messages, total, nil
}

// GetLatestByConversationID 获取会话的最新消息
func (r *MessageRepository) GetLatestByConversationID(ctx context.Context, conversationID uuid.UUID) (*Message, error) {
	query := `
		SELECT id, local_id, dialog_id, sender_id, content, msg_type,
			   entities, media_info, reply_to_id, date, edit_date,
			   is_outgoing, is_unread, flags
		FROM chat_messages
		WHERE dialog_id = $1 AND deleted_at IS NULL
		ORDER BY date DESC
		LIMIT 1
	`
	msg := &Message{}
	err := r.db.QueryRowContext(ctx, query, conversationID).Scan(
		&msg.ID, &msg.LocalID, &msg.DialogID, &msg.SenderID, &msg.Content, &msg.MsgType,
		&msg.Entities, &msg.MediaInfo, &msg.ReplyToID, &msg.Date, &msg.EditDate,
		&msg.IsOutgoing, &msg.IsUnread, &msg.Flags,
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
func (r *MessageRepository) GetUnreadCount(ctx context.Context, conversationID, userID uuid.UUID) (int64, error) {
	query := `
		SELECT COUNT(*)
		FROM chat_messages m
		INNER JOIN chat_conversation_members cm
			ON cm.conversation_id = m.dialog_id AND cm.user_id = $2
		WHERE m.dialog_id = $1
			AND m.sender_id != $2
			AND m.deleted_at IS NULL
			AND m.date > COALESCE(cm.last_read_at, cm.joined_at, '1970-01-01')
	`
	var count int64
	if err := r.db.QueryRowContext(ctx, query, conversationID, userID).Scan(&count); err != nil {
		return 0, fmt.Errorf("获取未读数失败: %w", err)
	}
	return count, nil
}

// GetUnreadCountsBatch 批量获取多个会话的未读数
func (r *MessageRepository) GetUnreadCountsBatch(ctx context.Context, userID uuid.UUID, conversationIDs []uuid.UUID) (map[uuid.UUID]int64, error) {
	if len(conversationIDs) == 0 {
		return make(map[uuid.UUID]int64), nil
	}

	// 构建 IN 子句的占位符
	placeholders := "$2"
	args := []interface{}{userID, conversationIDs[0]}
	for i := 1; i < len(conversationIDs); i++ {
		placeholders += fmt.Sprintf(", $%d", i+2)
		args = append(args, conversationIDs[i])
	}

	query := fmt.Sprintf(`
		SELECT m.dialog_id, COUNT(*)
		FROM chat_messages m
		INNER JOIN chat_conversation_members cm
			ON cm.conversation_id = m.dialog_id AND cm.user_id = $1
		WHERE m.dialog_id IN (%s)
			AND m.sender_id != $1
			AND m.deleted_at IS NULL
			AND m.date > COALESCE(cm.last_read_at, cm.joined_at, '1970-01-01')
		GROUP BY m.dialog_id
	`, placeholders)

	rows, err := r.db.QueryContext(ctx, query, args...)
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

	return counts, nil
}

// FindUnreadMessageIDsInRange 查找指定时间范围内的未读消息 ID
func (r *MessageRepository) FindUnreadMessageIDsInRange(ctx context.Context, conversationID, userID uuid.UUID, afterTime, beforeOrEqualTime time.Time) ([]int64, error) {
	query := `
		SELECT id FROM chat_messages
		WHERE dialog_id = $1
			AND sender_id != $2
			AND deleted_at IS NULL
			AND date > $3
			AND date <= $4
	`
	rows, err := r.db.QueryContext(ctx, query, conversationID, userID, afterTime, beforeOrEqualTime)
	if err != nil {
		return nil, fmt.Errorf("查找未读消息 ID 失败: %w", err)
	}
	defer rows.Close()

	var ids []int64
	for rows.Next() {
		var id int64
		if err := rows.Scan(&id); err != nil {
			return nil, fmt.Errorf("扫描消息 ID 失败: %w", err)
		}
		ids = append(ids, id)
	}
	return ids, nil
}

// Delete 删除消息（软删除）
func (r *MessageRepository) Delete(ctx context.Context, id int64) error {
	query := `UPDATE chat_messages SET deleted_at = $1 WHERE id = $2 AND deleted_at IS NULL`
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
func (r *MessageRepository) DeleteByConversationID(ctx context.Context, conversationID uuid.UUID) error {
	query := `UPDATE chat_messages SET deleted_at = $1 WHERE dialog_id = $2 AND deleted_at IS NULL`
	_, err := r.db.ExecContext(ctx, query, time.Now().UTC(), conversationID)
	if err != nil {
		return fmt.Errorf("删除消息失败: %w", err)
	}
	return nil
}
