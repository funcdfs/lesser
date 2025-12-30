# Chat Service 测试文档

此文档描述了 `chat_gin` 服务的测试方法，包括单元测试、集成测试和 API 测试。

## 目录

- [前置条件](#前置条件)
- [单元测试](#单元测试)
- [集成测试](#集成测试)
- [HTTP API 测试](#http-api-测试)
- [测试覆盖范围](#测试覆盖范围)
- [常用命令](#常用命令)
- [测试结果](#测试结果)

---

## 前置条件

运行测试需要以下基础设施：
1. **PostgreSQL**: 用于存储会话和消息数据
2. **Redis**: (可选但推荐) 用于消息发布/订阅和未读数缓存

数据库架构（一个 PostgreSQL 容器，两个独立数据库）：
- `lesser_db`: Django 核心服务 (用户、帖子、Feed 等)
- `lesser_chat_db`: Go Chat 服务 (会话、消息)

默认连接配置：
- Chat DB: `postgres://lesser:lesser_dev_password@localhost:5432/lesser_chat_db?sslmode=disable`
- Redis: `redis://localhost:6379/1`

启动基础设施：
```bash
# 从项目根目录
docker-compose -f infra/docker-compose.yml up -d postgres redis
```

---

## 单元测试

单元测试不需要外部依赖，可以直接运行：

```bash
cd service/chat_gin
go test ./... -v -count=1
```

---

## 集成测试

集成测试需要数据库和 Redis 运行。必须设置环境变量 `INTEGRATION_TEST=true`。

```bash
cd service/chat_gin

# 清理测试数据（可选）
docker exec postgres psql -U lesser -d lesser_chat_db -c "TRUNCATE chat_messages, chat_conversation_members, chat_conversations CASCADE;"
docker exec redis redis-cli -n 1 FLUSHDB

# 运行所有集成测试
INTEGRATION_TEST=true DATABASE_URL="postgres://lesser:lesser_dev_password@localhost:5432/lesser_chat_db?sslmode=disable" REDIS_URL="redis://localhost:6379/1" go test -tags=integration ./internal/service/... -v -count=1

# 运行特定测试
INTEGRATION_TEST=true DATABASE_URL="postgres://lesser:lesser_dev_password@localhost:5432/lesser_chat_db?sslmode=disable" go test -tags=integration ./internal/service/... -run TestGroupChatCursorReadStatus -v -count=1
```

---

## HTTP API 测试

Chat 服务通过 HTTP REST API 和 gRPC 提供服务。以下是使用 curl 进行 HTTP API 测试的示例。

### 测试用户

使用以下固定的测试用户 UUID：
- **testuser1**: `11111111-1111-1111-1111-111111111111`
- **testuser2**: `22222222-2222-2222-2222-222222222222`

### 服务端口

- Docker 容器内: gRPC `:50052`, HTTP `:8081`
- 本地开发: gRPC `:50051`, HTTP `:8080`

### 私聊测试

#### 1. 创建私聊会话
```bash
curl -X POST http://localhost:8081/api/v1/chat/conversations \
  -H "Content-Type: application/json" \
  -H "X-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{
    "type": "private",
    "member_ids": [
      "11111111-1111-1111-1111-111111111111",
      "22222222-2222-2222-2222-222222222222"
    ]
  }'
```

#### 2. testuser1 发送消息
```bash
curl -X POST http://localhost:8081/api/v1/chat/conversations/<conversation_id>/messages \
  -H "Content-Type: application/json" \
  -H "X-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{
    "content": "你好，testuser2！",
    "message_type": "text"
  }'
```

#### 3. testuser2 发送消息
```bash
curl -X POST http://localhost:8081/api/v1/chat/conversations/<conversation_id>/messages \
  -H "Content-Type: application/json" \
  -H "X-User-ID: 22222222-2222-2222-2222-222222222222" \
  -d '{
    "content": "你好，testuser1！",
    "message_type": "text"
  }'
```

#### 4. 获取消息列表
```bash
curl -X GET "http://localhost:8081/api/v1/chat/conversations/<conversation_id>/messages?page=1&page_size=20" \
  -H "X-User-ID: 11111111-1111-1111-1111-111111111111"
```

#### 5. 获取未读数
```bash
curl -X GET "http://localhost:8081/api/v1/chat/unread-counts?conversation_ids=<conversation_id>" \
  -H "X-User-ID: 22222222-2222-2222-2222-222222222222"
```

#### 6. 标记会话已读
```bash
curl -X POST http://localhost:8081/api/v1/chat/conversations/<conversation_id>/read \
  -H "X-User-ID: 22222222-2222-2222-2222-222222222222"
```

### 群聊测试

#### 1. 创建群聊会话
```bash
curl -X POST http://localhost:8081/api/v1/chat/conversations \
  -H "Content-Type: application/json" \
  -H "X-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{
    "type": "group",
    "name": "测试群聊",
    "member_ids": [
      "11111111-1111-1111-1111-111111111111",
      "22222222-2222-2222-2222-222222222222"
    ]
  }'
```

#### 2. 群聊发送消息
```bash
curl -X POST http://localhost:8081/api/v1/chat/conversations/<conversation_id>/messages \
  -H "Content-Type: application/json" \
  -H "X-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{
    "content": "大家好！",
    "message_type": "text"
  }'
```

#### 3. 添加成员到群聊
```bash
curl -X POST http://localhost:8081/api/v1/chat/conversations/<conversation_id>/members \
  -H "Content-Type: application/json" \
  -H "X-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{
    "user_id": "33333333-3333-3333-3333-333333333333"
  }'
```

#### 4. 移除成员
```bash
curl -X DELETE http://localhost:8081/api/v1/chat/conversations/<conversation_id>/members/33333333-3333-3333-3333-333333333333 \
  -H "X-User-ID: 11111111-1111-1111-1111-111111111111"
```

### 已读未读测试

#### 1. 检查初始未读数
```bash
curl -X GET "http://localhost:8081/api/v1/chat/unread-counts?conversation_ids=<conversation_id>" \
  -H "X-User-ID: 22222222-2222-2222-2222-222222222222"
```

#### 2. testuser1 发送多条消息
```bash
for i in 1 2 3; do
  curl -X POST http://localhost:8081/api/v1/chat/conversations/<conversation_id>/messages \
    -H "Content-Type: application/json" \
    -H "X-User-ID: 11111111-1111-1111-1111-111111111111" \
    -d "{\"content\": \"消息 $i\", \"message_type\": \"text\"}"
done
```

#### 3. 检查 testuser2 的未读数（应为 3）
```bash
curl -X GET "http://localhost:8081/api/v1/chat/unread-counts?conversation_ids=<conversation_id>" \
  -H "X-User-ID: 22222222-2222-2222-2222-222222222222"
```

#### 4. testuser2 标记会话已读
```bash
curl -X POST http://localhost:8081/api/v1/chat/conversations/<conversation_id>/read \
  -H "X-User-ID: 22222222-2222-2222-2222-222222222222"
```

#### 5. 再次检查未读数（应为 0）
```bash
curl -X GET "http://localhost:8081/api/v1/chat/unread-counts?conversation_ids=<conversation_id>" \
  -H "X-User-ID: 22222222-2222-2222-2222-222222222222"
```

### WebSocket 测试

Chat 服务支持 WebSocket 连接用于实时消息推送。

使用 `websocat` 测试：
```bash
brew install websocat  # macOS
websocat "ws://localhost:8081/ws?user_id=11111111-1111-1111-1111-111111111111"
```

---

## 测试覆盖范围

测试文件 `internal/service/chat_integration_test.go` 覆盖了以下核心功能：

### 1. 会话管理 (Conversation Management)
- **创建会话** (`CreateConversation`):
  - 私聊 (Private): 验证成员检查，唯一性
  - 群聊 (Group): 验证群名，成员列表
- **获取会话** (`GetConversation`): 验证 ID, 类型, 成员信息填充
- **用户会话列表** (`GetUserConversations`): 分页获取，包含最后一条消息和未读数

### 2. 成员管理 (Member Management)
- **添加成员** (`AddMember`): 验证权限（仅成员/管理员可拉人），私聊限制
- **移除成员** (`RemoveMember`): 验证权限（仅管理员或自己可操作）
- **获取成员列表** (`GetConversationMemberIDs`)

### 3. 消息管理 (Message Management)
- **发送消息** (`SendMessage`): 验证非成员不能发送，消息内容持久化
- **获取消息** (`GetMessages`): 分页获取历史消息，内容完整性
- **单条消息获取** (`GetMessageByID`)

### 4. 已读回执 (Read Receipts) - Cursor 模式
- **更新 LastReadAt**:
  - `MarkMessageAsRead`: 标记单条已读
  - `MarkConversationAsRead`: 标记整个会话已读
  - `MarkMessagesUpToAsRead`: 标记特定消息之前的所有消息为已读
- **未读数计算** (`GetUnreadCount`):
  - 验证发送消息后未读数增加
  - 验证标记已读后未读数减少
  - 群聊中每个用户独立的未读状态

### 5. 实时推送 (Real-time features)
- **订阅会话** (`SubscribeToConversation`): 使用 Redis Pub/Sub 验证消息实时推送

---

## 常用命令

```bash
# 启动基础设施
docker-compose -f infra/docker-compose.yml up -d postgres redis

# 清理测试数据
docker exec postgres psql -U lesser -d lesser_chat_db -c "TRUNCATE chat_messages, chat_conversation_members, chat_conversations CASCADE;"
docker exec redis redis-cli -n 1 FLUSHDB

# 运行单元测试
cd service/chat_gin && go test ./... -v -count=1

# 运行集成测试
cd service/chat_gin && INTEGRATION_TEST=true DATABASE_URL="postgres://lesser:lesser_dev_password@localhost:5432/lesser_chat_db?sslmode=disable" REDIS_URL="redis://localhost:6379/1" go test -tags=integration ./internal/service/... -v -count=1

# 启动服务（本地开发）
cd service/chat_gin && DATABASE_URL="postgres://lesser:lesser_dev_password@localhost:5432/lesser_chat_db?sslmode=disable" go run cmd/server/main.go
```

---

## 手动测试流程

以下是完整的手动测试流程，使用 testuser1 和 testuser2 测试私聊和群聊功能。

### 测试用户

- **testuser1**: `11111111-1111-1111-1111-111111111111`
- **testuser2**: `22222222-2222-2222-2222-222222222222`

### 清理测试数据

```bash
docker exec postgres psql -U lesser -d lesser_chat_db -c "TRUNCATE chat_messages, chat_conversation_members, chat_conversations CASCADE;"
docker exec redis redis-cli -n 1 FLUSHDB
```

### 私聊测试

#### 1. 创建私聊
```bash
curl -s -X POST http://localhost:8081/api/v1/chat/conversations \
  -H "Content-Type: application/json" \
  -H "X-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{
    "type": "private",
    "member_ids": [
      "11111111-1111-1111-1111-111111111111",
      "22222222-2222-2222-2222-222222222222"
    ]
  }' | jq .
# 记录返回的 conversation id
```

#### 2. testuser1 发送消息
```bash
curl -s -X POST "http://localhost:8081/api/v1/chat/conversations/<CONV_ID>/messages" \
  -H "Content-Type: application/json" \
  -H "X-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{"content": "你好，testuser2！", "message_type": "text"}' | jq .
```

#### 3. testuser2 发送消息
```bash
curl -s -X POST "http://localhost:8081/api/v1/chat/conversations/<CONV_ID>/messages" \
  -H "Content-Type: application/json" \
  -H "X-User-ID: 22222222-2222-2222-2222-222222222222" \
  -d '{"content": "你好，testuser1！", "message_type": "text"}' | jq .
```

#### 4. 检查 testuser1 未读数
```bash
curl -s -X GET "http://localhost:8081/api/v1/chat/unread-counts?conversation_ids=<CONV_ID>" \
  -H "X-User-ID: 11111111-1111-1111-1111-111111111111" | jq .
# 预期: 1 (testuser2 发的消息)
```

#### 5. testuser1 标记已读
```bash
curl -s -X POST "http://localhost:8081/api/v1/chat/conversations/<CONV_ID>/read" \
  -H "X-User-ID: 11111111-1111-1111-1111-111111111111" | jq .
```

#### 6. 再次检查未读数
```bash
curl -s -X GET "http://localhost:8081/api/v1/chat/unread-counts?conversation_ids=<CONV_ID>" \
  -H "X-User-ID: 11111111-1111-1111-1111-111111111111" | jq .
# 预期: 0
```

### 群聊测试

#### 1. 创建群聊
```bash
curl -s -X POST http://localhost:8081/api/v1/chat/conversations \
  -H "Content-Type: application/json" \
  -H "X-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{
    "type": "group",
    "name": "测试群聊",
    "member_ids": [
      "11111111-1111-1111-1111-111111111111",
      "22222222-2222-2222-2222-222222222222"
    ]
  }' | jq .
# 记录返回的 conversation id
```

#### 2. testuser1 发送 3 条消息
```bash
curl -s -X POST "http://localhost:8081/api/v1/chat/conversations/<CONV_ID>/messages" \
  -H "Content-Type: application/json" \
  -H "X-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{"content": "群聊消息1", "message_type": "text"}' | jq .

curl -s -X POST "http://localhost:8081/api/v1/chat/conversations/<CONV_ID>/messages" \
  -H "Content-Type: application/json" \
  -H "X-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{"content": "群聊消息2", "message_type": "text"}' | jq .

curl -s -X POST "http://localhost:8081/api/v1/chat/conversations/<CONV_ID>/messages" \
  -H "Content-Type: application/json" \
  -H "X-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{"content": "群聊消息3", "message_type": "text"}' | jq .
```

#### 3. 检查 testuser2 未读数
```bash
curl -s -X GET "http://localhost:8081/api/v1/chat/unread-counts?conversation_ids=<CONV_ID>" \
  -H "X-User-ID: 22222222-2222-2222-2222-222222222222" | jq .
# 预期: 3
```

#### 4. testuser2 发送消息
```bash
curl -s -X POST "http://localhost:8081/api/v1/chat/conversations/<CONV_ID>/messages" \
  -H "Content-Type: application/json" \
  -H "X-User-ID: 22222222-2222-2222-2222-222222222222" \
  -d '{"content": "收到！我是testuser2", "message_type": "text"}' | jq .
```

#### 5. testuser2 标记已读
```bash
curl -s -X POST "http://localhost:8081/api/v1/chat/conversations/<CONV_ID>/read" \
  -H "X-User-ID: 22222222-2222-2222-2222-222222222222" | jq .
# 预期: marked_count: 3
```

#### 6. 检查两个用户的未读数
```bash
# testuser2 未读数 (预期: 0)
curl -s -X GET "http://localhost:8081/api/v1/chat/unread-counts?conversation_ids=<CONV_ID>" \
  -H "X-User-ID: 22222222-2222-2222-2222-222222222222" | jq .

# testuser1 未读数 (预期: 1，testuser2 发的消息)
curl -s -X GET "http://localhost:8081/api/v1/chat/unread-counts?conversation_ids=<CONV_ID>" \
  -H "X-User-ID: 11111111-1111-1111-1111-111111111111" | jq .
```

#### 7. 获取消息列表
```bash
curl -s -X GET "http://localhost:8081/api/v1/chat/conversations/<CONV_ID>/messages?page=1&page_size=20" \
  -H "X-User-ID: 11111111-1111-1111-1111-111111111111" | jq .
# 预期: 4 条消息
```

---

## 测试结果

### 最近测试运行 (2025-12-30)

#### 集成测试

```
=== RUN   TestGroupChatCursorReadStatus
--- PASS: TestGroupChatCursorReadStatus (0.20s)

=== RUN   TestChatIntegration
=== RUN   TestChatIntegration/创建私聊会话
=== RUN   TestChatIntegration/消息往返测试
=== RUN   TestChatIntegration/获取会话
=== RUN   TestChatIntegration/获取用户会话列表
=== RUN   TestChatIntegration/非成员不能发送消息
=== RUN   TestChatIntegration/LastReadAt和未读数
--- PASS: TestChatIntegration (0.23s)

=== RUN   TestMessageContentIntegrity
--- PASS: TestMessageContentIntegrity (0.19s)

=== RUN   TestChatMemberManagement
=== RUN   TestChatMemberManagement/创建群聊
=== RUN   TestChatMemberManagement/创建群聊/添加成员
=== RUN   TestChatMemberManagement/创建群聊/移除成员
=== RUN   TestChatMemberManagement/私聊不能加人
--- PASS: TestChatMemberManagement (0.07s)

=== RUN   TestChatMessageRetrievalAndReadRange
=== RUN   TestChatMessageRetrievalAndReadRange/GetMessageByID
=== RUN   TestChatMessageRetrievalAndReadRange/MarkMessagesUpToAsRead
--- PASS: TestChatMessageRetrievalAndReadRange (0.15s)

=== RUN   TestChatSubscription
--- PASS: TestChatSubscription (1.06s)

PASS
ok      github.com/lesser/chat/internal/service 2.704s
```

#### 手动 HTTP API 测试

| 测试项 | 结果 | 说明 |
|--------|------|------|
| 私聊创建 | ✅ | 两用户私聊，自动去重 |
| 私聊发送消息 | ✅ | 双向消息发送正常 |
| 私聊未读数 | ✅ | 正确计算对方发送的消息 |
| 私聊标记已读 | ✅ | 未读数归零 |
| 群聊创建 | ✅ | 支持群名和多成员 |
| 群聊发送消息 | ✅ | 多条消息发送正常 |
| 群聊未读数 | ✅ | 每个用户独立计数 |
| 群聊标记已读 | ✅ | 正确标记消息数量 |
| 消息列表获取 | ✅ | 分页正常，内容完整 |

---

## 注意事项

- 测试会在数据库中产生测试数据。建议使用专门的测试数据库或在测试后清理数据
- 部分测试依赖 Redis。如果 Redis 不可用，部分功能测试（如订阅）会被跳过
- 集成测试使用 UUID 避免数据冲突，但建议在测试前清理数据以确保一致性
- Docker 容器内服务端口与本地开发端口不同，注意区分
