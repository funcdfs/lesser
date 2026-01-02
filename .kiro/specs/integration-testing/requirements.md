# Requirements Document

## Introduction

本规范定义了前后端联合调试测试的需求，涵盖用户认证（注册、登录）、聊天功能（发消息、已读回执）的完整测试流程。测试分为三个阶段：后端 API 测试、前端功能测试、前后端联合测试。

## Glossary

- **Gateway**: Go API 网关服务，负责 JWT 验签、限流、路由转发，端口 50053
- **Chat_Service**: 聊天服务，支持 gRPC 双向流，端口 50052
- **Auth_Service**: 认证服务，处理登录注册，端口 50054
- **grpcurl**: gRPC 命令行测试工具
- **Conversation**: 聊天会话，可以是私聊或群聊
- **Message**: 聊天消息实体
- **Read_Receipt**: 已读回执，标记消息已被阅读
- **Flutter_Client**: Flutter 移动端/Web 客户端应用

## Requirements

### Requirement 1: 后端服务健康检查

**User Story:** As a developer, I want to verify all backend services are running correctly, so that I can proceed with functional testing.

#### Acceptance Criteria

1. WHEN the developer checks Docker container status, THE System SHALL show all services (postgres, redis, gateway, auth, chat) in running state
2. WHEN the developer sends a health check request to Gateway, THE Gateway SHALL respond with healthy status
3. WHEN the developer connects to PostgreSQL, THE Database SHALL accept connections and show initialized tables

### Requirement 2: 用户注册功能测试

**User Story:** As a developer, I want to test user registration via gRPC, so that I can verify the auth service works correctly.

#### Acceptance Criteria

1. WHEN a registration request with valid username, email, and password is sent to Gateway, THE Auth_Service SHALL create a new user and return user info with tokens
2. WHEN a registration request with duplicate username is sent, THE Auth_Service SHALL return an error indicating username already exists
3. WHEN a registration request with invalid email format is sent, THE Auth_Service SHALL return a validation error
4. THE Registration_Response SHALL contain user id, username, email, access_token, and refresh_token

### Requirement 3: 用户登录功能测试

**User Story:** As a developer, I want to test user login via gRPC, so that I can verify authentication works correctly.

#### Acceptance Criteria

1. WHEN a login request with valid email and password is sent to Gateway, THE Auth_Service SHALL return user info with valid JWT tokens
2. WHEN a login request with incorrect password is sent, THE Auth_Service SHALL return an authentication error
3. WHEN a login request with non-existent email is sent, THE Auth_Service SHALL return a user not found error
4. THE Login_Response access_token SHALL be a valid JWT that can be decoded

### Requirement 4: 聊天会话创建测试

**User Story:** As a developer, I want to test conversation creation via gRPC, so that I can verify the chat service works correctly.

#### Acceptance Criteria

1. WHEN a create conversation request with valid member_ids and creator_id is sent to Chat_Service, THE Chat_Service SHALL create a new conversation and return conversation details
2. WHEN a private conversation is created between two users, THE Conversation SHALL have type PRIVATE and contain both member_ids
3. THE Created_Conversation SHALL contain id, type, name, member_ids, creator_id, and created_at

### Requirement 5: 发送消息功能测试

**User Story:** As a developer, I want to test message sending via gRPC, so that I can verify chat messaging works correctly.

#### Acceptance Criteria

1. WHEN a send message request with valid conversation_id, sender_id, and content is sent to Chat_Service, THE Chat_Service SHALL create a new message and return message details
2. THE Sent_Message SHALL contain id, conversation_id, sender_id, content, message_type, and created_at
3. WHEN a message is sent, THE Message SHALL be persisted in the database
4. WHEN messages are retrieved for a conversation, THE Chat_Service SHALL return messages in chronological order

### Requirement 6: 已读回执功能测试

**User Story:** As a developer, I want to test read receipt functionality via gRPC, so that I can verify message read tracking works correctly.

#### Acceptance Criteria

1. WHEN a mark as read request for a single message is sent to Chat_Service, THE Chat_Service SHALL create a read receipt and return it
2. WHEN a mark conversation as read request is sent to Chat_Service, THE Chat_Service SHALL mark all unread messages in that conversation as read
3. THE Read_Receipt SHALL contain message_id, conversation_id, reader_id, and read_at timestamp
4. WHEN unread counts are requested for a conversation after marking as read, THE Chat_Service SHALL return zero unread count

### Requirement 7: 未读消息计数测试

**User Story:** As a developer, I want to test unread message counting via gRPC, so that I can verify unread tracking works correctly.

#### Acceptance Criteria

1. WHEN a new message is sent to a conversation, THE Unread_Count for other members SHALL increase by one
2. WHEN get unread counts request is sent with conversation_ids, THE Chat_Service SHALL return accurate unread counts for each conversation
3. WHEN all messages in a conversation are marked as read, THE Unread_Count SHALL become zero

### Requirement 8: Flutter 客户端登录测试

**User Story:** As a developer, I want to test Flutter client login functionality, so that I can verify frontend-backend integration for authentication.

#### Acceptance Criteria

1. WHEN a user enters valid credentials in Flutter login page and submits, THE Flutter_Client SHALL successfully authenticate and navigate to home page
2. WHEN login succeeds, THE Flutter_Client SHALL store the access_token and refresh_token securely
3. WHEN a user enters invalid credentials, THE Flutter_Client SHALL display an appropriate error message
4. THE Flutter_Client SHALL send gRPC requests to Gateway on port 50050 (via Traefik)

### Requirement 9: Flutter 客户端聊天测试

**User Story:** As a developer, I want to test Flutter client chat functionality, so that I can verify frontend-backend integration for messaging.

#### Acceptance Criteria

1. WHEN a logged-in user opens chat feature in Flutter_Client, THE Flutter_Client SHALL load and display conversation list
2. WHEN a user sends a message in Flutter_Client, THE Message SHALL be delivered to Chat_Service and appear in the conversation
3. WHEN a user views a conversation in Flutter_Client, THE Flutter_Client SHALL mark messages as read and update unread counts
4. THE Flutter_Client SHALL connect to Chat_Service on port 50052 for real-time messaging

### Requirement 10: 前后端数据一致性验证

**User Story:** As a developer, I want to verify data consistency between frontend and backend, so that I can ensure the system works correctly end-to-end.

#### Acceptance Criteria

1. WHEN a user is registered via Flutter_Client, THE User SHALL be queryable via grpcurl from Auth_Service
2. WHEN a message is sent via Flutter_Client, THE Message SHALL be retrievable via grpcurl from Chat_Service
3. WHEN a message is marked as read via Flutter_Client, THE Read_Receipt SHALL be verifiable via grpcurl from Chat_Service
4. THE Data in PostgreSQL database SHALL match the data returned by gRPC APIs
