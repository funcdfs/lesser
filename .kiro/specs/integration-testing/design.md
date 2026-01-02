# Design Document: Integration Testing

## Overview

本设计文档描述前后端联合调试测试的详细方案。测试采用分阶段、逐步验证的方式，确保每个功能点都能独立验证后再进行集成测试。

测试工具：
- **grpcurl**: 命令行 gRPC 测试工具，用于后端 API 测试
- **Flutter**: 前端客户端测试
- **psql**: PostgreSQL 命令行工具，用于数据验证

测试环境：
- Gateway: localhost:50053 (直连) / localhost:50050 (via Traefik)
- Chat Service: localhost:50052
- PostgreSQL: localhost:5432
- Redis: localhost:6379

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    测试架构                                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐   │
│  │   grpcurl   │     │   Flutter   │     │    psql     │   │
│  │  (后端测试)  │     │  (前端测试)  │     │  (数据验证)  │   │
│  └──────┬──────┘     └──────┬──────┘     └──────┬──────┘   │
│         │                   │                   │           │
│         ▼                   ▼                   ▼           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Traefik Gateway (:50050)               │   │
│  └─────────────────────────┬───────────────────────────┘   │
│                            │                               │
│         ┌──────────────────┼──────────────────┐           │
│         ▼                  ▼                  ▼           │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐   │
│  │   Gateway   │    │    Chat     │    │    Auth     │   │
│  │   :50053    │    │   :50052    │    │   :50054    │   │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘   │
│         │                  │                  │           │
│         └──────────────────┼──────────────────┘           │
│                            ▼                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              PostgreSQL + Redis                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### 1. 后端服务组件

| 组件 | 端口 | 职责 | 测试接口 |
|------|------|------|----------|
| Gateway | 50053 | JWT 验签、路由转发 | Health, Register, Login |
| Auth | 50054 | 用户认证 | Register, Login, GetUser |
| Chat | 50052 | 聊天消息 | CreateConversation, SendMessage, MarkAsRead |
| PostgreSQL | 5432 | 数据存储 | SQL 查询 |
| Redis | 6379 | 缓存 | CLI 命令 |

### 2. gRPC 接口定义

#### Auth Service (via Gateway)
```protobuf
service AuthService {
  rpc Register(RegisterRequest) returns (AuthResponse);
  rpc Login(LoginRequest) returns (AuthResponse);
  rpc GetUser(GetUserRequest) returns (User);
}
```

#### Chat Service
```protobuf
service ChatService {
  rpc CreateConversation(CreateConversationRequest) returns (Conversation);
  rpc SendMessage(SendMessageRequest) returns (Message);
  rpc GetMessages(GetMessagesRequest) returns (MessagesResponse);
  rpc MarkAsRead(MarkAsReadRequest) returns (ReadReceipt);
  rpc MarkConversationAsRead(MarkConversationAsReadRequest) returns (BatchReadReceipt);
  rpc GetUnreadCounts(GetUnreadCountsRequest) returns (GetUnreadCountsResponse);
}
```

### 3. 测试数据模型

```
TestUser {
  username: string (unique)
  email: string (unique)
  password: string
  user_id: string (generated)
  access_token: string (generated)
}

TestConversation {
  conversation_id: string (generated)
  type: PRIVATE | GROUP
  member_ids: string[]
  creator_id: string
}

TestMessage {
  message_id: string (generated)
  conversation_id: string
  sender_id: string
  content: string
  message_type: "text"
}
```

## Data Models

### 测试用户数据

```json
{
  "test_user_1": {
    "username": "testuser_a",
    "email": "testuser_a@test.com",
    "password": "Test123456"
  },
  "test_user_2": {
    "username": "testuser_b",
    "email": "testuser_b@test.com",
    "password": "Test123456"
  }
}
```

### 测试会话数据

```json
{
  "test_conversation": {
    "type": 0,
    "name": "Test Chat",
    "member_ids": ["<user_a_id>", "<user_b_id>"],
    "creator_id": "<user_a_id>"
  }
}
```

### 测试消息数据

```json
{
  "test_message": {
    "conversation_id": "<conv_id>",
    "sender_id": "<user_a_id>",
    "content": "Hello from test!",
    "message_type": "text"
  }
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Registration Response Completeness
*For any* valid registration request with unique username and email, the response SHALL contain non-empty user_id, username, email, access_token, and refresh_token fields.
**Validates: Requirements 2.1, 2.4**

### Property 2: Login Token Validity
*For any* successful login with valid credentials, the returned access_token SHALL be a valid JWT that can be decoded and contains user_id claim.
**Validates: Requirements 3.1, 3.4**

### Property 3: Conversation Creation Completeness
*For any* valid conversation creation request, the response SHALL contain non-empty id, correct type, all member_ids, creator_id, and created_at timestamp.
**Validates: Requirements 4.1, 4.2, 4.3**

### Property 4: Message Sending and Persistence
*For any* valid message sent to a conversation, the message SHALL be retrievable via GetMessages API with matching content, sender_id, and conversation_id.
**Validates: Requirements 5.1, 5.2, 5.3**

### Property 5: Message Chronological Order
*For any* conversation with multiple messages, GetMessages SHALL return messages ordered by created_at timestamp in ascending order.
**Validates: Requirements 5.4**

### Property 6: Read Receipt Completeness
*For any* mark as read request, the returned read receipt SHALL contain message_id, conversation_id, reader_id, and non-null read_at timestamp.
**Validates: Requirements 6.1, 6.3**

### Property 7: Unread Count Accuracy
*For any* conversation, after marking all messages as read, GetUnreadCounts SHALL return zero for that conversation.
**Validates: Requirements 6.4, 7.3**

### Property 8: Unread Count Increment
*For any* new message sent to a conversation, the unread count for non-sender members SHALL increase by exactly one.
**Validates: Requirements 7.1, 7.2**

### Property 9: Data Consistency
*For any* data created via gRPC API, the same data SHALL be queryable from PostgreSQL database with matching field values.
**Validates: Requirements 10.4**

## Error Handling

### 后端错误处理

| 错误场景 | gRPC 状态码 | 处理方式 |
|----------|-------------|----------|
| 用户名已存在 | ALREADY_EXISTS | 返回错误信息，提示用户更换用户名 |
| 邮箱格式无效 | INVALID_ARGUMENT | 返回验证错误详情 |
| 密码错误 | UNAUTHENTICATED | 返回认证失败错误 |
| 用户不存在 | NOT_FOUND | 返回用户未找到错误 |
| 会话不存在 | NOT_FOUND | 返回会话未找到错误 |
| 服务不可用 | UNAVAILABLE | 重试或返回服务不可用错误 |

### 测试错误处理

| 错误场景 | 处理方式 |
|----------|----------|
| Docker 服务未启动 | 提示启动 Docker 服务 |
| 端口被占用 | 提示检查端口占用情况 |
| grpcurl 未安装 | 提示安装 grpcurl |
| 数据库连接失败 | 检查 PostgreSQL 服务状态 |

## Testing Strategy

### 测试框架

- **后端 API 测试**: grpcurl 命令行工具
- **数据验证**: psql + SQL 查询
- **前端测试**: Flutter 应用手动测试
- **集成测试**: 前后端联合验证

### 测试阶段

#### 阶段一：后端服务测试
1. 服务健康检查
2. 用户注册测试
3. 用户登录测试
4. 会话创建测试
5. 消息发送测试
6. 已读回执测试
7. 未读计数测试

#### 阶段二：前端功能测试
1. Flutter 客户端启动
2. 登录功能测试
3. 聊天功能测试

#### 阶段三：前后端联合测试
1. 前端操作 → 后端验证
2. 后端操作 → 前端验证
3. 数据一致性验证

### 测试命令模板

#### 用户注册
```bash
grpcurl -plaintext \
  -d '{"username": "<username>", "email": "<email>", "password": "<password>"}' \
  localhost:50053 auth.AuthService/Register
```

#### 用户登录
```bash
grpcurl -plaintext \
  -d '{"email": "<email>", "password": "<password>"}' \
  localhost:50053 auth.AuthService/Login
```

#### 创建会话
```bash
grpcurl -plaintext \
  -d '{"type": 0, "name": "<name>", "member_ids": ["<id1>", "<id2>"], "creator_id": "<id1>"}' \
  localhost:50052 chat.ChatService/CreateConversation
```

#### 发送消息
```bash
grpcurl -plaintext \
  -d '{"conversation_id": "<conv_id>", "sender_id": "<user_id>", "content": "<content>", "message_type": "text"}' \
  localhost:50052 chat.ChatService/SendMessage
```

#### 标记已读
```bash
grpcurl -plaintext \
  -d '{"message_id": "<msg_id>", "user_id": "<user_id>"}' \
  localhost:50052 chat.ChatService/MarkAsRead
```

#### 获取未读数
```bash
grpcurl -plaintext \
  -d '{"user_id": "<user_id>", "conversation_ids": ["<conv_id>"]}' \
  localhost:50052 chat.ChatService/GetUnreadCounts
```

### 数据验证 SQL

```sql
-- 验证用户
SELECT id, username, email FROM users WHERE username = '<username>';

-- 验证会话
SELECT id, type, name, member_ids FROM conversations WHERE id = '<conv_id>';

-- 验证消息
SELECT id, conversation_id, sender_id, content FROM messages WHERE conversation_id = '<conv_id>';

-- 验证已读回执
SELECT message_id, reader_id, read_at FROM read_receipts WHERE message_id = '<msg_id>';
```
