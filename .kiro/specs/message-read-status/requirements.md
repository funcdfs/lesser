# Requirements Document

## Introduction

本功能为聊天系统添加消息已读状态管理能力，包括：使用 `read_at` 时间戳替代简单布尔值来记录已读状态、标记已读后通知消息发送者、使用 Redis 缓存未读数以优化性能、以及同步更新 Proto 定义。

## Glossary

- **Chat_Service**: Go 语言实现的聊天微服务，负责消息的发送、接收和已读状态管理
- **Message**: 聊天消息实体，包含发送者、内容、时间戳等信息
- **Read_Receipt**: 已读回执，记录用户阅读消息的时间戳
- **WebSocket_Hub**: WebSocket 连接管理中心，负责实时消息推送
- **Redis_Cache**: Redis 缓存服务，用于缓存未读消息数量
- **Proto_Definition**: Protocol Buffers 定义文件，用于 gRPC 服务间通信

## Requirements

### Requirement 1: 已读状态数据模型优化

**User Story:** As a developer, I want to use `read_at` timestamp instead of boolean `is_read` field, so that I can track when exactly a message was read and support more advanced features like read receipts.

#### Acceptance Criteria

1. THE Message model SHALL include a nullable `read_at` timestamp field to record when the message was read
2. THE Chat_Service SHALL treat a message as read WHEN the `read_at` field is not null
3. THE Chat_Service SHALL treat a message as unread WHEN the `read_at` field is null
4. WHEN a message is marked as read, THE Chat_Service SHALL set `read_at` to the current timestamp
5. THE Message model SHALL remove the deprecated `is_read` boolean field after migration

### Requirement 2: 标记消息已读

**User Story:** As a user, I want to mark messages as read when I view them, so that the sender knows I have seen their message.

#### Acceptance Criteria

1. WHEN a user views a conversation, THE Chat_Service SHALL mark all unread messages in that conversation as read for that user
2. WHEN marking messages as read, THE Chat_Service SHALL only update messages where the user is not the sender
3. WHEN marking messages as read, THE Chat_Service SHALL set the `read_at` timestamp to the current time
4. IF no unread messages exist, THEN THE Chat_Service SHALL return success without making database changes
5. THE Chat_Service SHALL support marking a single message as read by message ID
6. THE Chat_Service SHALL support marking all messages up to a specific message as read (batch marking)

### Requirement 3: 已读通知推送

**User Story:** As a message sender, I want to be notified when my message is read, so that I know the recipient has seen my message.

#### Acceptance Criteria

1. WHEN a message is marked as read, THE Chat_Service SHALL send a read receipt notification to the message sender via WebSocket
2. THE read receipt notification SHALL include the message ID, conversation ID, reader ID, and read timestamp
3. WHEN the message sender is offline, THE Chat_Service SHALL NOT queue the read receipt for later delivery
4. THE Chat_Service SHALL batch read receipts when multiple messages are marked as read simultaneously
5. THE WebSocket_Hub SHALL only send read receipts to users who are currently connected

### Requirement 4: 未读数 Redis 缓存

**User Story:** As a developer, I want to cache unread message counts in Redis, so that the system can quickly retrieve unread counts without querying the database.

#### Acceptance Criteria

1. THE Chat_Service SHALL cache unread message count per user per conversation in Redis
2. WHEN a new message is sent, THE Chat_Service SHALL increment the unread count in Redis for all conversation members except the sender
3. WHEN messages are marked as read, THE Chat_Service SHALL decrement or reset the unread count in Redis
4. WHEN the Redis cache is empty or expired, THE Chat_Service SHALL fall back to database query and repopulate the cache
5. THE Redis cache key format SHALL be `unread:{user_id}:{conversation_id}`
6. THE Redis cache SHALL have a TTL of 24 hours to prevent stale data accumulation
7. THE Chat_Service SHALL support batch query of unread counts for multiple conversations

### Requirement 5: Proto 定义同步

**User Story:** As a developer, I want the Proto definitions to include read status fields, so that gRPC clients can access read receipt information.

#### Acceptance Criteria

1. THE Message proto definition SHALL include a `read_at` timestamp field
2. THE Proto definition SHALL include a new `ReadReceipt` message type with message_id, conversation_id, reader_id, and read_at fields
3. THE ChatService proto SHALL include a `MarkAsRead` RPC method
4. THE ChatService proto SHALL include a `GetUnreadCount` RPC method
5. THE Proto definition SHALL include a `ReadReceiptNotification` message for WebSocket push events

### Requirement 6: 批量查询优化

**User Story:** As a developer, I want to efficiently query unread counts for multiple conversations, so that the conversation list can display unread badges without N+1 queries.

#### Acceptance Criteria

1. THE Chat_Service SHALL provide a batch API to get unread counts for multiple conversations in a single request
2. WHEN fetching conversation list, THE Chat_Service SHALL include unread count for each conversation
3. THE batch query SHALL first check Redis cache, then fall back to database for cache misses
4. THE Chat_Service SHALL use a single database query to fetch unread counts for multiple conversations when cache misses occur

