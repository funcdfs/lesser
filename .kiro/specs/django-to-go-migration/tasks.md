# Implementation Plan: Django to Go Migration

## Overview

将 Django 后端迁移为多个 Go Worker 服务，建立脚手架（不实现具体业务逻辑）。

## Tasks

- [x] 1. 扩展 Proto 定义
  - [x] 1.1 扩展 gateway.proto Action 枚举
    - 添加 POST_*, FEED_*, NOTIFICATION_*, USER_*, SEARCH_*, CHAT_* 等 Action
    - _Requirements: 7.1_
  - [x] 1.2 创建 post.proto
    - 定义 Post、CreatePostRequest、GetPostRequest 等消息
    - _Requirements: 7.2, 7.3_
  - [x] 1.3 创建 feed.proto
    - 定义 LikeRequest、CommentRequest、Comment、Repost 等消息
    - _Requirements: 7.2, 7.3_
  - [x] 1.4 创建 notification.proto
    - 定义 Notification、ListRequest、ReadRequest 等消息
    - _Requirements: 7.2, 7.3_
  - [x] 1.5 创建 user.proto（扩展现有 auth.proto）
    - 定义 Profile、FollowRequest、GetProfileRequest 等消息
    - _Requirements: 7.2, 7.3_
  - [x] 1.6 创建 search.proto
    - 定义 SearchPostsRequest、SearchUsersRequest 等消息
    - _Requirements: 7.2, 7.3_

- [x] 2. 扩展 Gateway 服务
  - [x] 2.1 更新 Gateway broker 队列定义
    - 添加所有新队列常量
    - _Requirements: 1.5, 2.5, 3.5, 4.5, 5.5, 6.3_
  - [x] 2.2 更新 Gateway server 路由逻辑
    - 在 Process 方法中添加新 Action 的路由
    - _Requirements: 1.4, 2.4, 3.4, 4.4, 5.4, 6.2_

- [x] 3. 创建 Post Worker 脚手架
  - [x] 3.1 初始化 service/post_worker 目录结构
    - 创建 cmd/worker/main.go、go.mod
    - _Requirements: 1.1_
  - [x] 3.2 实现 RabbitMQ 连接和队列定义
    - 创建 internal/broker/rabbitmq.go
    - _Requirements: 1.2_
  - [x] 3.3 实现 PostgreSQL 连接
    - 创建 internal/database/postgres.go
    - _Requirements: 1.3_
  - [x] 3.4 实现 Worker 消费者框架
    - 创建 internal/worker/post_worker.go（返回 NOT_IMPLEMENTED）
    - _Requirements: 1.4_
  - [x] 3.5 创建 Dockerfile
    - _Requirements: 8.1_

- [x] 4. 创建 Feed Worker 脚手架
  - [x] 4.1 初始化 service/feed_worker 目录结构
    - 创建 cmd/worker/main.go、go.mod
    - _Requirements: 2.1_
  - [x] 4.2 实现 RabbitMQ 连接和队列定义
    - 创建 internal/broker/rabbitmq.go
    - _Requirements: 2.2_
  - [x] 4.3 实现 PostgreSQL 连接
    - 创建 internal/database/postgres.go
    - _Requirements: 2.3_
  - [x] 4.4 实现 Worker 消费者框架
    - 创建 internal/worker/feed_worker.go（返回 NOT_IMPLEMENTED）
    - _Requirements: 2.4_
  - [x] 4.5 创建 Dockerfile
    - _Requirements: 8.1_

- [x] 5. 创建 Notification Worker 脚手架
  - [x] 5.1 初始化 service/notification_worker 目录结构
    - 创建 cmd/worker/main.go、go.mod
    - _Requirements: 3.1_
  - [x] 5.2 实现 RabbitMQ 连接和队列定义
    - 创建 internal/broker/rabbitmq.go
    - _Requirements: 3.2_
  - [x] 5.3 实现 PostgreSQL 连接
    - 创建 internal/database/postgres.go
    - _Requirements: 3.3_
  - [x] 5.4 实现 Worker 消费者框架
    - 创建 internal/worker/notification_worker.go（返回 NOT_IMPLEMENTED）
    - _Requirements: 3.4_
  - [x] 5.5 创建 Dockerfile
    - _Requirements: 8.1_

- [x] 6. 创建 User Worker 脚手架
  - [x] 6.1 初始化 service/user_worker 目录结构
    - 创建 cmd/worker/main.go、go.mod
    - _Requirements: 4.1_
  - [x] 6.2 实现 RabbitMQ 连接和队列定义
    - 创建 internal/broker/rabbitmq.go
    - _Requirements: 4.2_
  - [x] 6.3 实现 PostgreSQL 连接
    - 创建 internal/database/postgres.go
    - _Requirements: 4.3_
  - [x] 6.4 实现 Worker 消费者框架
    - 创建 internal/worker/user_worker.go（返回 NOT_IMPLEMENTED）
    - _Requirements: 4.4_
  - [x] 6.5 创建 Dockerfile
    - _Requirements: 8.1_

- [x] 7. 创建 Search Worker 脚手架
  - [x] 7.1 初始化 service/search_worker 目录结构
    - 创建 cmd/worker/main.go、go.mod
    - _Requirements: 5.1_
  - [x] 7.2 实现 RabbitMQ 连接和队列定义
    - 创建 internal/broker/rabbitmq.go
    - _Requirements: 5.2_
  - [x] 7.3 实现 PostgreSQL 连接
    - 创建 internal/database/postgres.go
    - _Requirements: 5.3_
  - [x] 7.4 实现 Worker 消费者框架
    - 创建 internal/worker/search_worker.go（返回 NOT_IMPLEMENTED）
    - _Requirements: 5.4_
  - [x] 7.5 创建 Dockerfile
    - _Requirements: 8.1_

- [x] 8. 整合 Chat Worker
  - [x] 8.1 创建 service/chat_worker 目录结构
    - 基于现有 chat_gin 创建新的 Worker 结构
    - _Requirements: 6.1_
  - [x] 8.2 实现 RabbitMQ 连接和队列定义
    - 创建 internal/broker/rabbitmq.go
    - _Requirements: 6.4_
  - [x] 8.3 实现 Worker 消费者框架
    - 创建 internal/worker/chat_worker.go
    - _Requirements: 6.4_
  - [x] 8.4 创建 Dockerfile
    - _Requirements: 8.1_

- [x] 9. 更新 Docker Compose 配置
  - [x] 9.1 添加所有新 Worker 服务到 docker-compose.yml
    - 配置环境变量、网络、依赖
    - 这是一个非常典型的微服务开发痛点。如果你为 5 个 Worker 各自维护一套 RabbitMQ 连接、Postgres 初始化和日志逻辑，代码重复率会高达 **60%-70%**。更可怕的是，如果你未来想修改 MQ 的重试策略，你得改 5 个地方。
】最优雅的解法是引入一个 **`pkg` (Internal Library)** 模式，将公共逻辑“组件化”，而 Worker 只负责“装配”。

---

### 1. 结构优化：引入 `pkg` 层

将重复的“基础设施”逻辑抽离到项目根目录的 `pkg` 下。

```
.
├── pkg/                  # 所有服务共用的“硬核”底层逻辑
│   ├── broker/           # RabbitMQ 封装 (连接池、断线重连、消费框架)
│   ├── database/         # Postgres/Ent 初始化、连接池管理
│   ├── logger/           # Zap 结构化日志封装
│   └── transport/        # gRPC/Proto 通用工具类
├── service/
│   ├── auth_worker/      # 业务代码：只关心 Auth 逻辑
│   ├── post_worker/      # 业务代码：只关心 Post 逻辑
│   └── ...
└── api/                  # 存放所有 .proto 文件和生成的代码

```

---

### 2. 核心：封装一个“万能”的 `BaseWorker`

在 `pkg/broker/rabbitmq.go` 中，你可以编写一个通用的启动器。每一个 Worker 只需要传入自己的 `handler` 函数即可。

**`pkg` 里的通用逻辑示例：**

```go
// pkg/broker/worker_engine.go
type Handler func(ctx context.Context, payload []byte) error

type WorkerConfig struct {
    QueueName  string
    Exchange   string
    RoutingKey string
}

// StartWorker 封装了所有重复的连接、声明、重连逻辑
func StartWorker(connStr string, cfg WorkerConfig, h Handler) {
    // 1. 这里处理所有复杂的 Dial, Channel, QueueDeclare 逻辑 (只写一次)
    // 2. 启动无限循环监听消息
    // 3. 收到消息后，调用传入的 h(ctx, body)
}

```

---

### 3. Worker 侧：代码会变得多么精简？

有了 `pkg` 之后，你的 `service/post_worker/main.go` 只需要关注它自己：

```go
func main() {
    // 1. 初始化公共组件 (只需一行)
    db := database.MustInitPostgres(os.Getenv("DB_URL"))
    
    // 2. 定义具体的业务逻辑
    handler := func(ctx context.Context, payload []byte) error {
        var req post.CreateRequest
        proto.Unmarshal(payload, &req) // 解析自己的业务包
        return service.NewPostService(db).Create(req)
    }

    // 3. 启动 (使用 pkg 提供的引擎)
    broker.StartWorker(os.Getenv("MQ_URL"), broker.WorkerConfig{
        QueueName: "post.create",
    }, handler)
}

```

---

### 4. 这种方式的 3 个好处

1. **心跳与重连一致性**：RabbitMQ 的连接很脆弱。你在 `pkg` 里写好一次“指数退避重连”逻辑，所有的 Worker 都瞬间具备了高可用性。
2. **脚手架极其轻量**：当你想要新增一个 `search_worker` 时，你只需要复制几行代码，重点全在 `proto` 和业务逻辑上。
3. **统一监控**：你可以在 `pkg` 的通用逻辑里埋入 Prometheus 指标（如 `messages_processed_total`），这样 5 个 Worker 的监控数据格式完全统一。

---

### 5. 关于“注册/登录”流程的最后检查

在你的异步注册流程中，**Auth Worker** 实际上需要两份代码：

* **注册 (完全异步)**：消费 `auth.register` 队列 -> 写入 DB。
* **登录 (同步响应)**：虽然你想要异步架构，但登录必须给前端回结果。
* **建议**：登录不走 MQ，直接由 Gateway 通过 gRPC 调用 Auth Worker 的 Service 方法（同步模式），或者在网关层直接处理。只有“注册成功后的副作用”（如发邮件、初始化头像）才扔进 MQ 异步执行。


    - _Requirements: 8.1, 8.2, 8.3_

- [ ] 10. Checkpoint - 验证服务启动
  - 启动所有服务，确认无报错
  - 检查 RabbitMQ 队列是否正确创建
  - 通过 Gateway 发送测试请求，确认路由正确

## Notes

- 所有 Worker 遵循 auth_worker 的项目结构
- 脚手架阶段业务方法返回 NOT_IMPLEMENTED 错误
- 不包含单元测试和属性测试（按要求跳过）
- Chat Worker 保留 WebSocket 实时功能，异步部分通过队列处理

