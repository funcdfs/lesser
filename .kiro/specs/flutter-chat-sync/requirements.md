# Requirements Document

## Introduction

本功能旨在确保 Flutter 客户端与 Go Chat 服务之间的功能一致性，进行联合调试验证。目标是防止过度设计，确保当前阶段两端实现的功能完全对齐，并建立可重复的联合测试流程。

## Glossary

- **Flutter_Client**: Flutter 移动端应用，负责聊天 UI 和用户交互
- **Chat_Service**: Go 语言实现的聊天微服务，提供 HTTP API 和 WebSocket 实时通信
- **API_Contract**: Flutter 与 Chat_Service 之间的 HTTP API 接口约定
- **WebSocket_Protocol**: 实时消息推送的 WebSocket 消息格式约定
- **Feature_Parity**: 功能对等性，指两端实现的功能完全一致

## Requirements

### Requirement 1: API 接口对齐验证

**User Story:** As a developer, I want to verify that Flutter client API calls match Chat Service endpoints, so that I can ensure seamless communication between frontend and backend.

#### Acceptance Criteria

1. WHEN Flutter calls GET /api/v1/chat/conversations, THE Chat_Service SHALL return a list of conversations with pagination
2. WHEN Flutter calls POST /api/v1/chat/conversations, THE Chat_Service SHALL create a new conversation and return it
3. WHEN Flutter calls GET /api/v1/chat/conversations/:id/messages, THE Chat_Service SHALL return messages with pagination
4. WHEN Flutter calls POST /api/v1/chat/conversations/:id/messages, THE Chat_Service SHALL create and return the new message
5. WHEN Flutter calls POST /api/v1/chat/conversations/:id/read, THE Chat_Service SHALL mark messages as read and return marked count
6. WHEN Flutter calls GET /api/v1/chat/unread-counts, THE Chat_Service SHALL return unread counts for specified conversations

### Requirement 2: 数据模型一致性

**User Story:** As a developer, I want Flutter and Chat Service data models to be consistent, so that data can be correctly serialized and deserialized.

#### Acceptance Criteria

1. THE Message model in Flutter SHALL include fields: id, conversationId, senderId, content, messageType, createdAt, readAt
2. THE Conversation model in Flutter SHALL include fields: id, type, members, createdAt, name, creatorId, lastMessage, unreadCount
3. THE Chat_Service Message response SHALL include fields matching Flutter's expected format
4. THE Chat_Service Conversation response SHALL include fields matching Flutter's expected format
5. WHEN Chat_Service returns a message, THE Flutter_Client SHALL correctly parse all fields including nullable readAt

### Requirement 3: 消息类型对齐

**User Story:** As a developer, I want message types to be consistent between Flutter and Chat Service, so that all message types are correctly handled.

#### Acceptance Criteria

1. THE Flutter_Client SHALL support message types: text, image, file, system
2. THE Chat_Service SHALL support message types: text (0), image (1), video (2), link (3), file (4), system (9)
3. WHEN Flutter sends a message with type "text", THE Chat_Service SHALL store it with msg_type=0
4. WHEN Chat_Service returns a message with msg_type=0, THE Flutter_Client SHALL interpret it as MessageType.text

### Requirement 4: 会话类型对齐

**User Story:** As a developer, I want conversation types to be consistent between Flutter and Chat Service, so that all conversation types work correctly.

#### Acceptance Criteria

1. THE Flutter_Client SHALL support conversation types: private, group, channel
2. THE Chat_Service SHALL support conversation types: private, group, channel
3. WHEN Flutter creates a private conversation, THE Chat_Service SHALL enforce exactly 2 members
4. WHEN Flutter creates a group conversation, THE Chat_Service SHALL require a name

### Requirement 5: 已读状态同步

**User Story:** As a developer, I want read status to be correctly synchronized between Flutter and Chat Service, so that users see accurate read indicators.

#### Acceptance Criteria

1. WHEN Flutter marks a conversation as read, THE Chat_Service SHALL update LastReadAt for the user
2. WHEN Flutter fetches conversations, THE Chat_Service SHALL return correct unread_count for each conversation
3. WHEN a new message arrives, THE Chat_Service SHALL increment unread count for all members except sender
4. THE Flutter_Client SHALL display unread count badge based on unread_count field

### Requirement 6: WebSocket 实时消息

**User Story:** As a developer, I want WebSocket messages to be correctly handled by Flutter, so that users receive real-time updates.

#### Acceptance Criteria

1. WHEN Chat_Service sends a new_message event, THE Flutter_Client SHALL add the message to the conversation
2. WHEN Chat_Service sends a conversation_update event, THE Flutter_Client SHALL update the conversation list
3. WHEN Chat_Service sends a read_receipt event, THE Flutter_Client SHALL update message read status
4. THE WebSocket message format SHALL be consistent between Chat_Service and Flutter_Client

### Requirement 7: 联合调试测试脚本

**User Story:** As a developer, I want an automated test script to verify Flutter-Chat integration, so that I can quickly validate changes.

#### Acceptance Criteria

1. THE test script SHALL start all required services (PostgreSQL, Redis, Django, Chat)
2. THE test script SHALL create test users with known credentials
3. THE test script SHALL verify API endpoint responses match expected format
4. THE test script SHALL report success or failure with detailed logs
5. THE test script SHALL be runnable with a single command

