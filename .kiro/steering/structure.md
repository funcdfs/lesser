# 项目架构梳理

> 本文档详细描述项目的整体架构、数据流程和各端实现细节。
> 
> **架构版本**: gRPC 全面迁移后 - 纯 gRPC + gRPC 双向流架构

---

## 目录

1. [整体架构概览](#整体架构概览)
2. [前端架构 (Flutter)](#前端架构-flutter)
3. [后端架构](#后端架构)
   - [Gateway 架构](#gateway-架构)
   - [Service Cluster 架构](#service-cluster-架构)
   - [Chat 服务架构](#chat-服务架构)
4. [新增路由修改流程](#新增路由修改流程)
5. [配置参数汇总](#配置参数汇总)

---

## 整体架构概览

```mermaid
graph TB
    subgraph 客户端层["📱 客户端层"]
        Flutter["Flutter Mobile/Web"]
    end

    subgraph 网关层["🌐 网关层"]
        Traefik["Traefik Gateway<br/>统一入口 :80 / gRPC :50050"]
    end

    subgraph 服务层["⚙️ 服务层"]
        Gateway["Go Gateway<br/>gRPC :50053<br/>(JWT 验签 + 限流 + 路由)"]
        
        subgraph ServiceCluster["Service Cluster"]
            Auth["Auth Service<br/>:50054"]
            User["User Service<br/>:50055"]
            Post["Post Service<br/>:50056"]
            Feed["Feed Service<br/>:50057"]
            Search["Search Service<br/>:50058"]
            Notification["Notification Service<br/>:50059"]
        end
        
        Chat["Chat Service<br/>gRPC 双向流 :50052"]
    end

    subgraph 消息层["📨 消息层"]
        RabbitMQ["RabbitMQ<br/>(仅次要异步任务)"]
    end

    subgraph 数据层["🗄️ 数据层"]
        Postgres["PostgreSQL<br/>主数据库"]
        Redis["Redis<br/>缓存/JWT公钥"]
    end

    Flutter -->|gRPC / gRPC-Web| Traefik
    
    Traefik -->|gRPC| Gateway
    Traefik -->|gRPC 双向流| Chat
    
    Gateway -->|gRPC| Auth
    Gateway -->|gRPC| User
    Gateway -->|gRPC| Post
    Gateway -->|gRPC| Feed
    Gateway -->|gRPC| Search
    Gateway -->|gRPC| Notification
    
    Auth --> Postgres
    Auth --> Redis
    User --> Postgres
    Post --> Postgres
    Feed --> Postgres
    Search --> Postgres
    Notification --> Postgres
    
    User -.->|异步通知| RabbitMQ
    Post -.->|搜索索引| RabbitMQ
    Feed -.->|通知推送| RabbitMQ
    
    Chat --> Postgres
    Chat --> Redis
```

### 通信协议

> **重要**: 项目已完成 gRPC 全面迁移，采用纯 gRPC 架构

| 协议 | 用途 | 说明 |
|------|------|------|
| **gRPC** | 所有 API 调用 | 强类型、高性能、跨语言 |
| **gRPC 双向流** | 实时消息推送 | 替代 WebSocket，用于 Chat 服务 |
| **gRPC-Web** | Web 客户端 | 通过 Traefik 代理 |

### 技术栈说明

| 层级 | 技术 | 说明 |
|------|------|------|
| 客户端 | Flutter 3.x | 跨平台移动端 + Web |
| 网关 | Traefik 3.x | 反向代理、负载均衡、gRPC 支持 |
| API 网关 | Go + gRPC | JWT 验签、限流、路由转发 |
| 业务服务 | Go + gRPC | Auth/User/Post/Feed/Search/Notification |
| 聊天服务 | Go + gRPC 双向流 | 高性能实时聊天 |
| 消息队列 | RabbitMQ | 仅用于次要异步任务 |
| 数据库 | PostgreSQL 16 | 主数据存储 |
| 缓存 | Redis 7 | JWT 公钥缓存、会话缓存 |
| 公共库 | service/pkg | 共享基础设施代码 |

---

## 前端架构 (Flutter)

### 目录结构概览

```
lib/
├── main.dart                    # 应用入口
├── core/                        # 核心基础设施
│   ├── grpc/                    # gRPC 客户端
│   │   ├── grpc_client.dart     # gRPC 连接管理器
│   │   ├── auth_grpc_client.dart
│   │   ├── chat_grpc_client.dart
│   │   ├── feed_grpc_client.dart
│   │   ├── post_grpc_client.dart
│   │   ├── user_grpc_client.dart
│   │   ├── search_grpc_client.dart
│   │   └── notification_grpc_client.dart
│   ├── network/                 # 网络层
│   │   ├── unified_grpc_client.dart    # 统一 gRPC 客户端
│   │   ├── stream_event_handler.dart   # 双向流事件处理
│   │   └── token_manager.dart          # Token 自动刷新
│   ├── di/                      # 依赖注入 (GetIt)
│   ├── router/                  # 路由配置 (GoRouter)
│   ├── theme/                   # 主题样式
│   ├── utils/                   # 工具函数
│   ├── errors/                  # 异常处理
│   ├── storage/                 # 本地存储
│   └── constants/               # 常量定义
├── features/                    # 功能模块 (按业务划分)
│   ├── auth/                    # 认证模块
│   ├── chat/                    # 聊天模块
│   ├── feeds/                   # 动态流模块
│   ├── post/                    # 帖子模块
│   ├── profile/                 # 个人资料
│   ├── search/                  # 搜索模块
│   ├── notifications/           # 通知模块
│   └── navigation/              # 导航模块
├── shared/                      # 共享组件
└── generated/                   # 自动生成代码 (Proto)
    └── protos/
```

### gRPC 客户端架构

```
┌─────────────────────────────────────────────────────────────┐
│  UnifiedGrpcClient (unified_grpc_client.dart)               │
│  ├── 管理 gRPC Channel 连接                                  │
│  ├── 双向流连接管理 (StreamEvents)                           │
│  ├── 自动重连机制（指数退避）                                 │
│  ├── 心跳 Ping/Pong                                         │
│  └── 提供认证 CallOptions                                    │
└─────────────────────────────────────────────────────────────┘
         │
         ├── AuthGrpcClient (Gateway :50053)
         ├── ChatStreamClient (Chat :50052 双向流)
         ├── FeedGrpcClient
         ├── PostGrpcClient
         ├── UserGrpcClient
         ├── SearchGrpcClient
         └── NotificationGrpcClient
```

### Token 管理架构

```
┌─────────────────────────────────────────────────────────────┐
│  TokenManager (token_manager.dart)                          │
│  ├── JWT 过期检测                                            │
│  ├── 自动刷新 Token                                          │
│  ├── TokenRefreshInterceptor (gRPC 拦截器)                   │
│  └── TokenExpirationMonitor (后台监控)                       │
└─────────────────────────────────────────────────────────────┘
```

### 双向流事件处理

```
┌─────────────────────────────────────────────────────────────┐
│  StreamEventHandler (stream_event_handler.dart)             │
│  ├── ServerEvent 分发处理                                    │
│  │   ├── NewMessage → 新消息回调                             │
│  │   ├── MessageRead → 已读回执回调                          │
│  │   ├── Typing → 正在输入回调                               │
│  │   └── Pong → 心跳响应                                     │
│  ├── ConversationSubscriptionManager                        │
│  │   ├── subscribe(conversationId)                          │
│  │   └── unsubscribe(conversationId)                        │
│  └── MessageSendTracker                                     │
│      ├── sendMessage() → 发送消息                            │
│      └── 消息确认/重试                                       │
└─────────────────────────────────────────────────────────────┘
```

### Clean Architecture 分层详解

```
用户点击按钮
    ↓
┌─────────────────────────────────────────────────────────────┐
│  presentation/ (展示层) - 用户能看到的东西                   │
│  ├── pages/     → 页面（LoginPage、HomePage）                │
│  ├── widgets/   → UI 组件（按钮、卡片、输入框）               │
│  └── providers/ → 状态管理（loading、error、数据）            │
└─────────────────────────────────────────────────────────────┘
    ↓ 调用
┌─────────────────────────────────────────────────────────────┐
│  domain/ (领域层) - 业务规则                                 │
│  ├── entities/     → 业务对象（User、Post）                  │
│  ├── repositories/ → 仓库接口（定义"能做什么"）               │
│  └── usecases/     → 用例（登录、发帖、点赞）                 │
└─────────────────────────────────────────────────────────────┘
    ↓ 调用
┌─────────────────────────────────────────────────────────────┐
│  data/ (数据层) - 数据从哪来                                 │
│  ├── models/       → 数据模型（Proto 转对象）                │
│  ├── datasources/  → 数据源（gRPC 请求、本地存储）            │
│  └── repositories/ → 仓库实现（具体怎么拿数据）               │
└─────────────────────────────────────────────────────────────┘
    ↓
gRPC 服务 / 本地数据库
```

---

## 后端架构

### Gateway 架构

> Gateway 是统一 API 入口，只负责 JWT 验签、限流、路由转发，不处理业务逻辑

```mermaid
flowchart TB
    subgraph Client["📱 客户端"]
        Flutter["Flutter App"]
    end

    subgraph Gateway["🚪 Gateway (:50053)"]
        JWTValidator["JWT 验签模块<br/>- 定时刷新公钥<br/>- Key ID 匹配"]
        RateLimiter["限流模块<br/>- 令牌桶算法"]
        Router["路由模块<br/>- 服务发现<br/>- 负载均衡"]
    end

    subgraph Services["⚙️ Service Cluster"]
        Auth["Auth :50054"]
        User["User :50055"]
        Post["Post :50056"]
        Feed["Feed :50057"]
        Search["Search :50058"]
        Notification["Notification :50059"]
    end

    Flutter -->|gRPC| Gateway
    JWTValidator --> Router
    RateLimiter --> Router
    Router -->|gRPC| Auth
    Router -->|gRPC| User
    Router -->|gRPC| Post
    Router -->|gRPC| Feed
    Router -->|gRPC| Search
    Router -->|gRPC| Notification
```

### Gateway JWT 验签流程

```
1. 客户端请求 → Gateway
2. Gateway 从 metadata 提取 Authorization header
3. 解析 JWT header 获取 Key ID (kid)
4. 从缓存获取对应公钥（缓存未命中则从 Auth Service 获取）
5. 使用公钥验证 JWT 签名
6. 验证通过 → 转发请求到目标 Service
7. 验证失败 → 返回 UNAUTHENTICATED 错误
```

### Service Cluster 架构

> 各业务 Service 独立部署，通过 gRPC 同步调用，RabbitMQ 仅用于次要异步任务

| Service | 端口 | 职责 | 异步任务 |
|---------|------|------|----------|
| Auth | 50054 | 登录/注册/Token管理/JWT密钥 | - |
| User | 50055 | 用户资料/关注关系 | 关注通知 |
| Post | 50056 | 帖子 CRUD | 搜索索引更新 |
| Feed | 50057 | Feed 生成/点赞/评论/收藏 | 互动通知 |
| Search | 50058 | 搜索帖子/用户 | - |
| Notification | 50059 | 通知列表/已读管理 | - |

### 服务目录结构

```
service/
├── gateway/                    # API 网关服务
│   ├── cmd/server/
│   └── internal/
│       ├── auth/              # JWT 验签模块
│       ├── ratelimit/         # 限流模块
│       ├── router/            # 路由模块
│       └── proxy/             # gRPC 代理
│
├── auth/                      # 认证服务
│   ├── cmd/server/
│   └── internal/
│       ├── handler/           # gRPC 处理器
│       ├── service/           # 业务逻辑
│       └── repository/        # 数据访问
│
├── user/                      # 用户服务
├── post/                      # 帖子服务
├── feed/                      # Feed 服务
├── search/                    # 搜索服务
├── notification/              # 通知服务
│
├── chat/                      # 聊天服务 (gRPC 双向流)
│   ├── cmd/server/
│   └── internal/
│       ├── handler/grpc/      # gRPC 处理器
│       │   └── stream.go      # 双向流处理
│       ├── service/           # 业务逻辑
│       └── repository/        # 数据访问
│
└── pkg/                       # 共享公共库
    ├── app/                   # 应用生命周期管理
    ├── broker/                # RabbitMQ 客户端
    ├── cache/                 # Redis 客户端封装
    ├── config/                # 环境变量配置s
    ├── database/              # PostgreSQL 连接封装
    ├── grpcclient/            # gRPC 客户端连接池
    └── logger/                # slog 日志封装
```

### Chat 服务架构

> Chat Service 使用 gRPC 双向流替代 WebSocket，实现实时消息推送

```mermaid
flowchart TB
    subgraph Entry["🚪 入口层"]
        GRPC["gRPC Server :50052"]
        Stream["StreamEvents RPC<br/>双向流"]
    end

    subgraph Handlers["🎯 处理层"]
        StreamManager["StreamManager<br/>管理活跃连接"]
        StreamClient["StreamClient<br/>单个流连接"]
    end

    subgraph Services["⚙️ 服务层"]
        ChatService["ChatService<br/>聊天业务逻辑"]
        UnreadCache["UnreadCacheService<br/>未读消息缓存"]
    end

    subgraph Repository["🗃️ 仓库层"]
        ConvRepo["ConversationRepo"]
        MsgRepo["MessageRepo"]
    end

    subgraph External["🔗 外部依赖"]
        PG["PostgreSQL<br/>lesser_chat_db"]
        Redis["Redis"]
    end

    GRPC --> Stream
    Stream --> StreamManager
    StreamManager --> StreamClient

    StreamClient --> ChatService
    ChatService --> UnreadCache
    ChatService --> ConvRepo
    ChatService --> MsgRepo

    ConvRepo --> PG
    MsgRepo --> PG
    UnreadCache --> Redis
```

### Chat gRPC 双向流 API

```protobuf
// StreamEvents - 双向流 RPC
rpc StreamEvents(stream ClientEvent) returns (stream ServerEvent);

// 客户端事件
message ClientEvent {
  oneof event {
    SubscribeConversation subscribe = 1;
    UnsubscribeConversation unsubscribe = 2;
    SendMessage send_message = 3;
    Typing typing = 4;
    Ping ping = 5;
  }
}

// 服务端事件
message ServerEvent {
  oneof event {
    NewMessage new_message = 1;
    MessageRead message_read = 2;
    TypingIndicator typing = 3;
    Pong pong = 4;
    Error error = 5;
  }
}
```

### 双向流消息流程

```
客户端                          服务端
   │                              │
   │──── Subscribe(convId) ──────>│  订阅会话
   │<─── Subscribed ──────────────│
   │                              │
   │──── SendMessage ────────────>│  发送消息
   │<─── NewMessage ──────────────│  广播给所有订阅者
   │                              │
   │──── Typing ─────────────────>│  正在输入
   │<─── TypingIndicator ─────────│  广播给其他成员
   │                              │
   │──── Ping ───────────────────>│  心跳
   │<─── Pong ────────────────────│
   │                              │
   │──── Unsubscribe(convId) ────>│  取消订阅
   │                              │
```

---

## 新增路由修改流程

> 添加新 API 路由时，需要修改以下文件

### 新增 gRPC API (通过 Gateway)

| 步骤 | 文件/目录 | 说明 |
|------|----------|------|
| 1 | `protos/<service>/<service>.proto` | 定义 gRPC 消息和服务 |
| 2 | `service/<service>/internal/handler/` | Service gRPC 处理器 |
| 3 | `service/<service>/internal/service/` | 业务逻辑实现 |
| 4 | `service/gateway/internal/router/` | Gateway 路由配置 |
| 5 | `infra/gateway/dynamic/routes.yml` | Traefik 路由 (如需新前缀) |
| 6 | `client/mobile_flutter/lib/features/<module>/` | 客户端模块 |

### 新增 Chat gRPC API

| 步骤 | 文件/目录 | 说明 |
|------|----------|------|
| 1 | `protos/chat/chat.proto` | 定义 gRPC 消息和服务 |
| 2 | `service/chat/internal/handler/grpc/` | gRPC 处理器 |
| 3 | `service/chat/internal/service/` | 业务逻辑 |
| 4 | `client/mobile_flutter/lib/core/network/stream_event_handler.dart` | 双向流事件处理 |

---

## 配置参数汇总

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `DB_HOST` | `postgres` | PostgreSQL 主机 |
| `DB_PORT` | `5432` | PostgreSQL 端口 |
| `DB_USER` | `lesser` | 数据库用户 |
| `DB_PASSWORD` | `lesser_dev_password` | 数据库密码 |
| `DB_NAME` | `lesser_db` | 数据库名称 |
| `REDIS_URL` | `redis://redis:6379/0` | Redis 连接地址 |
| `RABBITMQ_URL` | `amqp://guest:guest@rabbitmq:5672/` | RabbitMQ 连接地址 |

### 服务端口

| 服务 | gRPC 端口 | 说明 |
|------|-----------|------|
| Traefik | 80 / 50050 | HTTP / gRPC 入口 |
| Gateway | 50053 | API 网关 |
| Auth | 50054 | 认证服务 |
| User | 50055 | 用户服务 |
| Post | 50056 | 帖子服务 |
| Feed | 50057 | Feed 服务 |
| Search | 50058 | 搜索服务 |
| Notification | 50059 | 通知服务 |
| Chat | 50052 | 聊天服务 (双向流) |

### Flutter 客户端配置

| 配置项 | 值 | 说明 |
|--------|-----|------|
| `grpcHost` | `localhost` | gRPC 服务主机 |
| `grpcPort` | `50050` | Traefik gRPC 端口 |
| `chatGrpcPort` | `50052` | Chat Service gRPC 端口 |

---

## Docker 服务列表

| 服务 | 容器名 | 说明 |
|------|--------|------|
| traefik | traefik | API 网关 |
| postgres | postgres | 数据库 |
| redis | redis | 缓存 |
| rabbitmq | rabbitmq | 消息队列 (次要异步) |
| gateway | gateway | Go Gateway |
| auth | auth | 认证服务 |
| user | user | 用户服务 |
| post | post | 帖子服务 |
| feed | feed | Feed 服务 |
| search | search | 搜索服务 |
| notification | notification | 通知服务 |
| chat | chat | 聊天服务 |
| dozzle | dozzle | 日志查看器 |
