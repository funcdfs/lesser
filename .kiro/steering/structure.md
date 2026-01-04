# 项目架构

## 后端服务架构

```mermaid
graph TB
    subgraph Client["客户端"]
        Flutter["Flutter Mobile/Web"]
    end

    subgraph Gateway["网关层"]
        Traefik["Traefik :80/:50050"]
        GW["Gateway :50053<br/>JWT/限流/路由"]
    end

    subgraph Services["业务服务"]
        Auth["Auth :50054"]
        User["User :50055"]
        Content["Content :50056"]
        Interaction["Interaction :50060"]
        Comment["Comment :50061"]
        Timeline["Timeline :50062"]
        Search["Search :50058"]
        Notification["Notification :50059"]
        SuperUser["SuperUser :50063"]
    end

    subgraph Realtime["实时服务"]
        Chat["Chat :50052<br/>gRPC 双向流"]
    end

    subgraph Data["数据层"]
        PG["PostgreSQL<br/>lesser_db / lesser_chat_db"]
        Redis["Redis<br/>缓存/Pub-Sub"]
        MQ["RabbitMQ<br/>异步事件"]
    end

    Flutter -->|gRPC-Web| Traefik
    Traefik --> GW
    Traefik --> Chat
    GW --> Auth
    GW --> User
    GW --> Content
    GW --> Interaction
    GW --> Comment
    GW --> Timeline
    GW --> Search
    GW --> Notification
    GW --> SuperUser

    Comment -->|gRPC| Content
    Interaction -->|gRPC| Content
    Timeline -->|gRPC| Interaction
    Chat -->|gRPC| Auth

    Comment -.->|MQ| Notification
    Interaction -.->|MQ| Notification
    User -.->|MQ| Notification
    Content -.->|MQ| Search

    Auth --> PG
    Auth --> Redis
    User --> PG
    Content --> PG
    Interaction --> PG
    Comment --> PG
    Timeline --> PG
    Search --> PG
    Notification --> PG
    Notification --> MQ
    Chat --> PG
    Chat --> Redis
    SuperUser --> PG
```

## Flutter 客户端架构

```mermaid
graph TB
    subgraph UI["页面层"]
        AuthPage["auth/pages<br/>登录页"]
        HomePage["home/pages<br/>Tab1: 首页"]
        ChannelPage["channel/pages<br/>Tab2: 频道"]
        ChatPage["chat/pages<br/>Tab3: 聊天"]
        ProfilePage["profile/pages<br/>Tab4: 我的"]
    end

    subgraph Handler["业务逻辑层"]
        AuthHandler["auth/handler"]
        HomeHandler["home/handler"]
        ChannelHandler["channel/handler"]
        ChatHandler["chat/handler<br/>+ stream_handler"]
        ProfileHandler["profile/handler"]
    end

    subgraph DataAccess["数据访问层"]
        AuthDA["auth/data_access"]
        HomeDA["home/data_access"]
        ChannelDA["channel/data_access"]
        ChatDA["chat/data_access"]
        ProfileDA["profile/data_access"]
    end

    subgraph Models["模型层"]
        AuthModel["auth/models"]
        HomeModel["home/models"]
        ChannelModel["channel/models"]
        ChatModel["chat/models"]
        ProfileModel["profile/models"]
    end

    subgraph Pkg["公共库 pkg/"]
        Network["network/<br/>gRPC Channel"]
        Errors["errors/<br/>异常处理"]
        UI_Pkg["ui/<br/>主题/组件"]
        Constants["constants/<br/>端点/颜色"]
    end

    subgraph Proto["gen_protos/"]
        ProtoFiles["protoc 生成代码<br/>【禁止手动修改】"]
    end

    subgraph Backend["后端"]
        GW["Gateway :50053"]
        ChatSvc["Chat :50052"]
    end

    AuthPage --> AuthHandler
    HomePage --> HomeHandler
    ChannelPage --> ChannelHandler
    ChatPage --> ChatHandler
    ProfilePage --> ProfileHandler

    AuthHandler --> AuthDA
    HomeHandler --> HomeDA
    ChannelHandler --> ChannelDA
    ChatHandler --> ChatDA
    ProfileHandler --> ProfileDA

    AuthDA --> AuthModel
    HomeDA --> HomeModel
    ChannelDA --> ChannelModel
    ChatDA --> ChatModel
    ProfileDA --> ProfileModel

    AuthModel --> ProtoFiles
    HomeModel --> ProtoFiles
    ChannelModel --> ProtoFiles
    ChatModel --> ProtoFiles
    ProfileModel --> ProtoFiles

    AuthDA --> Network
    HomeDA --> Network
    ChannelDA --> Network
    ChatDA --> Network
    ProfileDA --> Network

    Network --> GW
    Network --> ChatSvc
```

## 服务端口

| 服务 | 端口 |
|------|------|
| Traefik HTTP | 80 |
| Traefik gRPC | 50050 |
| Gateway | 50053 |
| Chat | 50052 |
| Auth | 50054 |
| User | 50055 |
| Content | 50056 |
| Search | 50058 |
| Notification | 50059 |
| Interaction | 50060 |
| Comment | 50061 |
| Timeline | 50062 |
| SuperUser | 50063 |

## 目录结构

### Go 后端

```
service/<name>/
├── internal/
│   ├── handler/        # gRPC 处理器（协议对接、参数转换）
│   ├── logic/          # 核心业务规则（权限判断、缓存策略）
│   ├── remote/         # 外部服务调用（跨服务 gRPC 调用）
│   ├── data_access/    # 数据库存取（SQL/NoSQL 操作）
│   └── messaging/      # 异步消息发布/订阅（RabbitMQ）
├── gen_protos/         # 生成的 proto 代码
└── main.go

service/pkg/            # 共享公共库
```

### Flutter 客户端

```
lib/
├── gen_protos/         # protoc 生成代码
├── pkg/
│   ├── constants/
│   ├── network/
│   ├── errors/
│   ├── logs/
│   ├── ui/
│   └── utils/
├── features/
│   ├── auth/           # 登录页
│   ├── home/           # Tab 1
│   ├── channel/        # Tab 2
│   ├── chat/           # Tab 3
│   └── profile/        # Tab 4
├── app.dart
└── main.dart

features/<name>/
├── handler/
├── data_access/
├── models/
├── pages/
└── widgets/
```

## 底部导航栏

| Tab | 名称 | 后端服务 |
|-----|------|---------|
| 1 | 首页 | Timeline + Content + Comment + Interaction + Search |
| 2 | 频道 | Chat (CHANNEL 类型) |
| 3 | 聊天 | Chat + Notification |
| 4 | 我的 | User |

登录页独立，不在底部导航栏。

## 调用链路

```
Flutter:  pages → handler → data_access → gRPC → Gateway → Service
Go:       handler → logic → data_access → PostgreSQL/Redis
          handler → logic → remote → 其他服务
          handler → logic → messaging → RabbitMQ (异步事件)
```

## Messaging 层详解

### 设计原则

- `logic/` 层定义 `EventPublisher` 接口
- `messaging/` 层实现该接口
- 调用流：`logic` → `messaging.Publish(...)`

### 目录结构

```
service/<name>/internal/messaging/
├── publisher.go   # 实现 logic 层的发布接口（发送消息）
├── consumer.go    # 启动监听，管理 RabbitMQ 连接（可选）
└── handler.go     # 收到消息后的处理逻辑（可选）
```

### 消息发布者（Publisher）

以下服务包含 `messaging/publisher.go`：

| 服务 | 发布事件 |
|------|---------|
| user | UserFollowed（关注） |
| interaction | ContentLiked, ContentBookmarked, ContentReposted（点赞/收藏/转发） |
| comment | CommentCreated, CommentLiked（评论/评论点赞） |

### 消息消费者（Consumer）

`notification` 服务包含 `messaging/event_worker.go`，订阅以下事件：

- `content.liked` - 内容点赞通知
- `content.bookmarked` - 内容收藏通知
- `content.reposted` - 内容转发通知
- `comment.created` - 评论/回复通知
- `comment.liked` - 评论点赞通知
- `user.followed` - 关注通知
- `user.mentioned` - @ 提及通知

### 接口定义示例

```go
// logic/xxx_service.go
type EventPublisher interface {
    PublishContentLiked(ctx context.Context, contentID, contentAuthorID, likerID string)
    // ...
}

// messaging/publisher.go
type EventPublisher struct {
    publisher *broker.Publisher
}

func (p *EventPublisher) PublishContentLiked(ctx context.Context, contentID, contentAuthorID, likerID string) {
    event := broker.ContentLikedEvent{...}
    p.publisher.PublishAsync(ctx, broker.EventContentLiked, event)
}
```

### 注入方式

```go
// main.go
publisher := broker.NewPublisher(rabbitURL, log)
if err := publisher.Connect(); err == nil {
    eventPublisher := messaging.NewEventPublisher(publisher)
    svc.SetPublisher(eventPublisher)
}
```
