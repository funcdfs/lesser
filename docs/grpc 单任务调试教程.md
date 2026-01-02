# gRPC 单服务调试教程

本教程介绍如何单独调试 Lesser 项目中的微服务，以 Auth（登录注册）和 Chat（聊天）为例。

## 前置准备

### 安装 grpcurl

```bash
# macOS
brew install grpcurl

# 或使用 go install
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
```

### 启动基础设施

```bash
# 只启动数据库、缓存等基础设施
devlesser start infra
```

---

## 方式一：通过 Gateway 调试（推荐）

Gateway 是统一入口，会进行 JWT 验签和路由转发。

### 1. 启动服务

```bash
# 启动所有后端服务
devlesser start service
```

### 2. Auth 服务调试（登录注册）

Auth 的 `Login` 和 `Register` 是公开接口，不需要 Token。

```bash
# 注册新用户
grpcurl -plaintext \
  -d '{"username":"testuser","email":"test@example.com","password":"password123","display_name":"Test User"}' \
  localhost:50053 auth.AuthService/Register

# 登录
grpcurl -plaintext \
  -d '{"email":"test@example.com","password":"password123"}' \
  localhost:50053 auth.AuthService/Login
```

登录成功后会返回 `access_token`，后续请求需要携带此 Token。

### 3. Chat 服务调试（需要认证）

Chat 接口需要 JWT Token 认证。

```bash
# 设置 Token（从登录响应中获取）
TOKEN="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."

# 获取会话列表
grpcurl -plaintext \
  -H "authorization: Bearer $TOKEN" \
  -d '{"user_id":"用户ID","pagination":{"page":1,"page_size":20}}' \
  localhost:50053 chat.ChatService/GetConversations

# 创建私聊会话
grpcurl -plaintext \
  -H "authorization: Bearer $TOKEN" \
  -d '{"type":0,"member_ids":["用户ID1","用户ID2"],"creator_id":"用户ID1"}' \
  localhost:50053 chat.ChatService/CreateConversation

# 发送消息
grpcurl -plaintext \
  -H "authorization: Bearer $TOKEN" \
  -d '{"conversation_id":"会话ID","sender_id":"用户ID","content":"Hello!","message_type":"text"}' \
  localhost:50053 chat.ChatService/SendMessage
```

---

## 方式二：直连服务调试（绕过 Gateway）

直接连接服务端口，跳过 JWT 验签，适合开发调试。

### 服务端口

| 服务 | 端口 |
|------|------|
| Gateway | 50053 |
| Auth | 50054 |
| Chat | 50052 |

### 1. 直连 Auth 服务

```bash
# 直接连接 Auth 服务（端口 50054）
grpcurl -plaintext \
  -d '{"email":"test@example.com","password":"password123"}' \
  localhost:50054 auth.AuthService/Login

# 获取用户信息
grpcurl -plaintext \
  -d '{"user_id":"用户ID"}' \
  localhost:50054 auth.AuthService/GetUser
```

### 2. 直连 Chat 服务

Chat 服务直连时需要通过 metadata 传递用户 ID：

```bash
# 直接连接 Chat 服务（端口 50052）
# 获取会话列表
grpcurl -plaintext \
  -H "user_id: 用户ID" \
  -d '{"user_id":"用户ID","pagination":{"page":1,"page_size":20}}' \
  localhost:50052 chat.ChatService/GetConversations

# 创建会话
grpcurl -plaintext \
  -H "user_id: 用户ID" \
  -d '{"type":0,"member_ids":["用户ID1","用户ID2"],"creator_id":"用户ID1"}' \
  localhost:50052 chat.ChatService/CreateConversation

# 发送消息
grpcurl -plaintext \
  -H "user_id: 用户ID" \
  -d '{"conversation_id":"会话ID","sender_id":"用户ID","content":"Hello!","message_type":"text"}' \
  localhost:50052 chat.ChatService/SendMessage
```

---

## 方式三：只启动单个服务

适合深度调试某个服务，减少资源占用。

### 1. 启动基础设施 + 单个服务

```bash
# 启动基础设施
devlesser start infra

# 手动启动 Auth 服务
cd service/auth
go run cmd/server/main.go

# 或手动启动 Chat 服务
cd service/chat
go run cmd/server/main.go
```

### 2. 使用 Docker 启动单个服务

```bash
# 启动基础设施
devlesser start infra

# 只启动 Auth 服务
docker compose -f infra/docker-compose.yml up auth -d

# 只启动 Chat 服务
docker compose -f infra/docker-compose.yml up chat -d
```

---

## 查看服务 Proto 定义

```bash
# 列出服务的所有方法
grpcurl -plaintext localhost:50053 list
grpcurl -plaintext localhost:50054 list auth.AuthService
grpcurl -plaintext localhost:50052 list chat.ChatService

# 查看方法签名
grpcurl -plaintext localhost:50054 describe auth.AuthService.Login
grpcurl -plaintext localhost:50052 describe chat.ChatService.SendMessage
```

---

## 常用调试场景

### 场景 1：测试完整登录流程

```bash
# 1. 注册
grpcurl -plaintext \
  -d '{"username":"alice","email":"alice@test.com","password":"test123456","display_name":"Alice"}' \
  localhost:50053 auth.AuthService/Register

# 2. 登录获取 Token
RESPONSE=$(grpcurl -plaintext \
  -d '{"email":"alice@test.com","password":"test123456"}' \
  localhost:50053 auth.AuthService/Login)

echo $RESPONSE

# 3. 提取 Token（需要 jq）
TOKEN=$(echo $RESPONSE | jq -r '.accessToken')
USER_ID=$(echo $RESPONSE | jq -r '.user.id')

echo "Token: $TOKEN"
echo "User ID: $USER_ID"
```

### 场景 2：测试聊天功能

```bash
# 假设已有两个用户 ID
USER1="user-id-1"
USER2="user-id-2"
TOKEN="your-jwt-token"

# 1. 创建私聊
CONV=$(grpcurl -plaintext \
  -H "authorization: Bearer $TOKEN" \
  -d "{\"type\":0,\"member_ids\":[\"$USER1\",\"$USER2\"],\"creator_id\":\"$USER1\"}" \
  localhost:50053 chat.ChatService/CreateConversation)

CONV_ID=$(echo $CONV | jq -r '.id')
echo "Conversation ID: $CONV_ID"

# 2. 发送消息
grpcurl -plaintext \
  -H "authorization: Bearer $TOKEN" \
  -d "{\"conversation_id\":\"$CONV_ID\",\"sender_id\":\"$USER1\",\"content\":\"你好！\",\"message_type\":\"text\"}" \
  localhost:50053 chat.ChatService/SendMessage

# 3. 获取消息列表
grpcurl -plaintext \
  -H "authorization: Bearer $TOKEN" \
  -d "{\"conversation_id\":\"$CONV_ID\",\"pagination\":{\"page\":1,\"page_size\":50}}" \
  localhost:50053 chat.ChatService/GetMessages
```

---

## 调试技巧

### 查看服务日志

```bash
# 查看所有服务日志
docker compose -f infra/docker-compose.yml logs -f

# 查看单个服务日志
docker compose -f infra/docker-compose.yml logs -f auth
docker compose -f infra/docker-compose.yml logs -f chat
docker compose -f infra/docker-compose.yml logs -f gateway
```

### 进入数据库检查数据

```bash
# 进入 PostgreSQL
docker exec -it postgres psql -U lesser -d lesser_db

# 查看用户表
SELECT id, username, email FROM users;

# 查看 Chat 数据库
\c lesser_chat_db
SELECT * FROM conversations;
SELECT * FROM messages;
```

### 清理测试数据

```bash
# 清理所有数据（会删除数据库）
devlesser clean volumes

# 重新初始化
devlesser init
```
