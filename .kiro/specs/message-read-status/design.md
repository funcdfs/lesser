# Design Document: Message Read Status

## Overview

本设计为聊天系统实现消息已读状态管理功能。核心改进包括：

1. **数据模型优化**：使用 `read_at` 时间戳替代布尔值 `is_read`，支持精确的已读时间追踪
2. **已读通知推送**：通过 WebSocket 实时通知消息发送者
3. **Redis 缓存优化**：缓存未读数以提升查询性能
4. **Proto 同步**：更新 gRPC 定义以支持已读状态相关操作

## Architecture

```mermaid
flowchart TB
    subgraph Client [Flutter 客户端]
        ChatRoom[聊天室页面]
        ConvList[会话列表]
    end

    subgraph Gateway [Traefik 网关]
        Router[路由分发]
    end

    subgraph ChatService [Go Chat Service]
        HTTP[HTTP Handler]
        WS[WebSocket Hub]
        Service[ChatService]
        Repo[MessageRepository]
    end

    subgraph Cache [Redis]
        UnreadCache[未读数缓存<br/>unread:{user}:{conv}]
        PubSub[Pub/Sub 频道]
    end

    subgraph DB [PostgreSQL]
        Messages[(chat_messages)]
    end

    ChatRoom -->|标记已读| Router
    Router -->|POST /mark-read| HTTP
    HTTP --> Service
    Service -->|更新 read_at| Repo
    Repo --> Messages
    Service -->|更新缓存| UnreadCache
    Service -->|发布已读回执| PubSub
    WS -->|订阅| PubSub
    WS -->|推送已读回执| ChatRoom
    
    ConvList -->|获取未读数| Router
    Router -->|GET /unread-counts| HTTP
    HTTP --> Service
    Service -->|查询缓存| UnreadCache
    UnreadCache -.->|缓存未命中| Repo
```

## Components and Interfaces

### 1. Message Model (更新)

```go
// service/chat_gin/internal/model/message.go

type Message struct {
    ID             uuid.UUID   `json:"id" gorm:"type:uuid;primary_key"`
    ConversationID uuid.UUID   `json:"conversation_id" gorm:"type:uuid;not null;index"`
    SenderID       uuid.UUID   `json:"sender_id" gorm:"type:uuid;not null;index"`
    Content        string      `json:"content" gorm:"type:text;not null"`
    MessageType    MessageType `json:"message_type" gorm:"type:varchar(20);not null;default:'text'"`
    CreatedAt      time.Time   `json:"created_at" gorm:"autoCreateTime;index"`
    ReadAt         *time.Time  `json:"read_at,omitempty" gorm:"index"` // 新增：已读时间戳
    Metadata       map[string]interface{} `json:"metadata,omitempty" gorm:"type:jsonb"`
}

// IsRead 判断消息是否已读
func (m *Message) IsRead() bool {
    return m.ReadAt != nil
}
```

### 2. Read Receipt Model (新增)

```go
// service/chat_gin/internal/model/read_receipt.go

// ReadReceipt 已读回执
type ReadReceipt struct {
    MessageID      uuid.UUID `json:"message_id"`
    ConversationID uuid.UUID `json:"conversation_id"`
    ReaderID       uuid.UUID `json:"reader_id"`
    ReadAt         time.Time `json:"read_at"`
}

// BatchReadReceipt 批量已读回执
type BatchReadReceipt struct {
    ConversationID uuid.UUID   `json:"conversation_id"`
    ReaderID       uuid.UUID   `json:"reader_id"`
    MessageIDs     []uuid.UUID `json:"message_ids"`
    ReadAt         time.Time   `json:"read_at"`
}
```

### 3. MessageRepository (更新)

```go
// service/chat_gin/internal/repository/message.go

// MarkAsRead 标记单条消息为已读
func (r *MessageRepository) MarkAsRead(ctx context.Context, messageID uuid.UUID, readAt time.Time) error

// MarkConversationAsRead 标记会话中用户的所有未读消息为已读
// 返回被标记的消息ID列表（用于发送已读回执）
func (r *MessageRepository) MarkConversationAsRead(ctx context.Context, conversationID, userID uuid.UUID, readAt time.Time) ([]uuid.UUID, error)

// MarkMessagesUpToAsRead 标记指定消息及之前的所有消息为已读
func (r *MessageRepository) MarkMessagesUpToAsRead(ctx context.Context, conversationID, userID, upToMessageID uuid.UUID, readAt time.Time) ([]uuid.UUID, error)

// GetUnreadCount 获取用户在会话中的未读消息数
func (r *MessageRepository) GetUnreadCount(ctx context.Context, conversationID, userID uuid.UUID) (int64, error)

// GetUnreadCountsBatch 批量获取多个会话的未读数
func (r *MessageRepository) GetUnreadCountsBatch(ctx context.Context, userID uuid.UUID, conversationIDs []uuid.UUID) (map[uuid.UUID]int64, error)
```

### 4. UnreadCacheService (新增)

```go
// service/chat_gin/internal/service/unread_cache.go

const (
    UnreadCacheTTL = 24 * time.Hour
)

type UnreadCacheService struct {
    cache       *cache.RedisClient
    messageRepo *repository.MessageRepository
}

// GetUnreadCount 获取未读数（优先从缓存）
func (s *UnreadCacheService) GetUnreadCount(ctx context.Context, userID, conversationID uuid.UUID) (int64, error)

// GetUnreadCountsBatch 批量获取未读数
func (s *UnreadCacheService) GetUnreadCountsBatch(ctx context.Context, userID uuid.UUID, conversationIDs []uuid.UUID) (map[uuid.UUID]int64, error)

// IncrementUnreadCount 增加未读数（发送新消息时调用）
func (s *UnreadCacheService) IncrementUnreadCount(ctx context.Context, userID, conversationID uuid.UUID) error

// ResetUnreadCount 重置未读数为0（标记已读时调用）
func (s *UnreadCacheService) ResetUnreadCount(ctx context.Context, userID, conversationID uuid.UUID) error

// DecrementUnreadCount 减少未读数
func (s *UnreadCacheService) DecrementUnreadCount(ctx context.Context, userID, conversationID uuid.UUID, count int64) error

// 缓存键生成
func unreadCacheKey(userID, conversationID uuid.UUID) string {
    return fmt.Sprintf("unread:%s:%s", userID, conversationID)
}
```

### 5. ChatService (更新)

```go
// service/chat_gin/internal/service/chat.go

// MarkMessageAsRead 标记单条消息为已读
func (s *ChatService) MarkMessageAsRead(ctx context.Context, messageID, userID uuid.UUID) (*model.ReadReceipt, error)

// MarkConversationAsRead 标记会话所有消息为已读
func (s *ChatService) MarkConversationAsRead(ctx context.Context, conversationID, userID uuid.UUID) (*model.BatchReadReceipt, error)

// MarkMessagesUpToAsRead 标记指定消息及之前的消息为已读
func (s *ChatService) MarkMessagesUpToAsRead(ctx context.Context, conversationID, userID, upToMessageID uuid.UUID) (*model.BatchReadReceipt, error)

// GetUnreadCounts 批量获取未读数
func (s *ChatService) GetUnreadCounts(ctx context.Context, userID uuid.UUID, conversationIDs []uuid.UUID) (map[uuid.UUID]int64, error)
```

### 6. WebSocket Hub (更新)

```go
// service/chat_gin/internal/handler/ws/hub.go

// ReadReceiptPayload 已读回执推送载荷
type ReadReceiptPayload struct {
    MessageID      string `json:"message_id,omitempty"`
    ConversationID string `json:"conversation_id"`
    ReaderID       string `json:"reader_id"`
    ReadAt         string `json:"read_at"`
    MessageIDs     []string `json:"message_ids,omitempty"` // 批量已读时使用
}

// NotifyReadReceipt 通知消息发送者已读回执
func (h *Hub) NotifyReadReceipt(senderID uuid.UUID, receipt *ReadReceiptPayload)
```

### 7. HTTP Handlers (新增)

```go
// service/chat_gin/internal/server/http.go

// POST /api/v1/chat/messages/:id/read - 标记单条消息已读
func (s *HTTPServer) markMessageAsRead(c *gin.Context)

// POST /api/v1/chat/conversations/:id/read - 标记会话所有消息已读
func (s *HTTPServer) markConversationAsRead(c *gin.Context)

// POST /api/v1/chat/conversations/:id/read-up-to - 标记到指定消息为已读
func (s *HTTPServer) markMessagesUpToAsRead(c *gin.Context)

// GET /api/v1/chat/unread-counts - 批量获取未读数
func (s *HTTPServer) getUnreadCounts(c *gin.Context)
```

## Data Models

### Database Schema Changes

```sql
-- 修改 chat_messages 表
ALTER TABLE chat_messages 
ADD COLUMN read_at TIMESTAMP WITH TIME ZONE;

-- 添加索引以优化未读消息查询
CREATE INDEX idx_messages_unread ON chat_messages (conversation_id, sender_id, read_at) 
WHERE read_at IS NULL;

-- 数据迁移：将现有 is_read=true 的记录设置 read_at
UPDATE chat_messages 
SET read_at = created_at 
WHERE is_read = true AND read_at IS NULL;

-- 迁移完成后删除旧字段
ALTER TABLE chat_messages DROP COLUMN is_read;
```

### Redis Cache Structure

```
Key: unread:{user_id}:{conversation_id}
Value: integer (未读消息数量)
TTL: 24 hours

Example:
unread:550e8400-e29b-41d4-a716-446655440000:660e8400-e29b-41d4-a716-446655440001 = 5
```

### WebSocket Message Types

```json
// 已读回执通知（单条消息）
{
  "type": "read_receipt",
  "payload": {
    "message_id": "uuid",
    "conversation_id": "uuid",
    "reader_id": "uuid",
    "read_at": "2025-12-29T10:00:00Z"
  }
}

// 批量已读回执通知
{
  "type": "read_receipt_batch",
  "payload": {
    "conversation_id": "uuid",
    "reader_id": "uuid",
    "message_ids": ["uuid1", "uuid2", "uuid3"],
    "read_at": "2025-12-29T10:00:00Z"
  }
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Read status determined by read_at nullability

*For any* Message, the `IsRead()` method SHALL return `true` if and only if `read_at` is not null, and `false` if and only if `read_at` is null.

**Validates: Requirements 1.2, 1.3**

### Property 2: Marking message sets read_at timestamp

*For any* message that is marked as read, the `read_at` field SHALL be set to a timestamp that is within 1 second of the current time.

**Validates: Requirements 1.4, 2.3**

### Property 3: Marking conversation as read updates non-sender messages only

*For any* conversation with messages from multiple senders, when a user marks the conversation as read, only messages where `sender_id != user_id` and `read_at IS NULL` SHALL have their `read_at` field updated.

**Validates: Requirements 2.1, 2.2**

### Property 4: Read receipt contains required fields

*For any* read receipt notification sent via WebSocket, it SHALL contain non-empty values for `message_id` (or `message_ids` for batch), `conversation_id`, `reader_id`, and `read_at`.

**Validates: Requirements 3.2**

### Property 5: Read receipts only sent to online users

*For any* read receipt notification, it SHALL only be delivered to users who have an active WebSocket connection at the time of notification.

**Validates: Requirements 3.3, 3.5**

### Property 6: Batch read receipts for multiple messages

*For any* operation that marks multiple messages as read simultaneously, the system SHALL send a single batched read receipt notification rather than multiple individual notifications.

**Validates: Requirements 3.4**

### Property 7: Redis cache consistency on message send

*For any* new message sent to a conversation, the Redis unread count for all conversation members (except the sender) SHALL be incremented by 1.

**Validates: Requirements 4.2**

### Property 8: Redis cache consistency on mark read

*For any* mark-as-read operation, the Redis unread count for the user in that conversation SHALL be reset to 0.

**Validates: Requirements 4.3**

### Property 9: Cache fallback to database

*For any* unread count query where the Redis cache key does not exist or has expired, the system SHALL query the database and repopulate the cache with the result.

**Validates: Requirements 4.4, 6.3**

### Property 10: Batch unread count query efficiency

*For any* batch query of unread counts for N conversations, the system SHALL make at most 1 database query (for cache misses) regardless of N.

**Validates: Requirements 4.7, 6.1, 6.4**

### Property 11: Conversation list includes unread counts

*For any* conversation list query result, each conversation object SHALL include an `unread_count` field with the correct count for the requesting user.

**Validates: Requirements 6.2**

## Error Handling

### Service Layer Errors

```go
var (
    ErrMessageNotFound     = errors.New("消息不存在")
    ErrNotMessageRecipient = errors.New("您不是该消息的接收者")
    ErrAlreadyRead         = errors.New("消息已被标记为已读")
    ErrCacheUnavailable    = errors.New("缓存服务不可用")
)
```

### Error Response Format

```json
{
  "success": false,
  "error": {
    "code": "MESSAGE_NOT_FOUND",
    "message": "消息不存在"
  }
}
```

### Graceful Degradation

1. **Redis 不可用时**：降级到直接查询数据库，不影响核心功能
2. **WebSocket 推送失败**：记录日志但不影响标记已读操作的成功
3. **批量操作部分失败**：返回成功标记的消息列表和失败原因

## Testing Strategy

### Unit Tests

- Message model `IsRead()` 方法测试
- UnreadCacheService 缓存操作测试
- MessageRepository 数据库操作测试

### Property-Based Tests

使用 Go 的 `testing/quick` 或 `gopter` 库实现属性测试：

1. **Property 1**: 生成随机 Message，验证 IsRead() 与 read_at 的一致性
2. **Property 2**: 生成随机消息并标记已读，验证时间戳设置正确
3. **Property 3**: 生成随机会话和消息，验证只有非发送者消息被标记
4. **Property 7-8**: 生成随机操作序列，验证缓存一致性
5. **Property 10**: 生成随机会话列表，验证批量查询效率

### Integration Tests

- 完整的标记已读流程测试（HTTP → Service → Repository → DB）
- WebSocket 已读回执推送测试
- Redis 缓存与数据库一致性测试

### Test Configuration

- 属性测试最少运行 100 次迭代
- 使用 `gopter` 库进行属性测试
- 测试标签格式：`**Feature: message-read-status, Property N: {property_text}**`
