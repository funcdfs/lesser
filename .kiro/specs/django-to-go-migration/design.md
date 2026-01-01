# Design Document: Django to Go Migration

## Overview

本设计将 Django 后端服务迁移为多个 Go 微服务，复用已实现的 Gateway + RabbitMQ 异步架构。

核心目标：
- 建立 5 个新 Worker 服务的脚手架（post、feed、notification、user、search）
- 整合现有 chat 服务到异步架构
- 扩展 Gateway 支持新的 Action 类型
- 不实现具体业务逻辑，仅搭建框架

```
┌─────────────┐     gRPC/Protobuf     ┌─────────────┐     AMQP      ┌─────────────┐
│   Flutter   │ ──────────────────▶   │   Gateway   │ ──────────▶   │  RabbitMQ   │
│   Client    │                       │   Service   │               │   Broker    │
└─────────────┘                       └─────────────┘               └──────┬──────┘
                                                                          │
                    ┌─────────────────────────────────────────────────────┤
                    │           │           │           │           │     │
                    ▼           ▼           ▼           ▼           ▼     ▼
             ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
             │   Auth   │ │   Post   │ │   Feed   │ │  Notif   │ │   User   │
             │  Worker  │ │  Worker  │ │  Worker  │ │  Worker  │ │  Worker  │
             └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘
                  │            │            │            │            │
                  └────────────┴────────────┴────────────┴────────────┘
                                            │
                                            ▼
                                     ┌─────────────┐
                                     │  PostgreSQL │
                                     └─────────────┘
```

## Architecture

### 服务划分

| 服务 | 职责 | 队列前缀 |
|------|------|----------|
| auth_worker | 认证（已实现） | auth.* |
| post_worker | 帖子 CRUD | post.* |
| feed_worker | 点赞/评论/转发/收藏 | feed.* |
| notification_worker | 通知管理 | notification.* |
| user_worker | 用户资料/关注 | user.* |
| search_worker | 搜索 | search.* |
| chat_worker | 聊天（整合现有） | chat.* |

### 目录结构（每个 Worker 统一）

```
service/{worker_name}/
├── cmd/worker/
│   └── main.go              # 入口
├── internal/
│   ├── broker/
│   │   └── rabbitmq.go      # RabbitMQ 连接和队列定义
│   ├── database/
│   │   └── postgres.go      # PostgreSQL 连接
│   ├── service/
│   │   └── {name}_service.go # 业务逻辑（脚手架）
│   └── worker/
│       └── {name}_worker.go  # 消息消费者
├── proto/                    # 生成的 protobuf 代码
├── Dockerfile
├── Dockerfile.dev
├── go.mod
└── go.sum
```

## Components and Interfaces

### 1. Gateway 扩展

扩展 Action 枚举支持所有新操作：

```go
// 新增 Action 类型
const (
    // Post
    POST_CREATE, POST_GET, POST_LIST, POST_DELETE
    // Feed
    FEED_LIKE, FEED_UNLIKE, FEED_COMMENT, FEED_REPOST, FEED_BOOKMARK
    // Notification
    NOTIFICATION_LIST, NOTIFICATION_READ, NOTIFICATION_READ_ALL
    // User
    USER_PROFILE_GET, USER_PROFILE_UPDATE, USER_FOLLOW, USER_UNFOLLOW, USER_FOLLOWERS, USER_FOLLOWING
    // Search
    SEARCH_POSTS, SEARCH_USERS
    // Chat
    CHAT_SEND, CHAT_GET_CONVERSATIONS, CHAT_GET_MESSAGES, CHAT_CREATE_CONVERSATION
)
```

### 2. Post Worker

```go
type PostWorker struct {
    db     *sql.DB
    broker *broker.Connection
}

// 队列
const (
    QueuePostCreate = "post.create"
    QueuePostGet    = "post.get"
    QueuePostList   = "post.list"
    QueuePostDelete = "post.delete"
)

// 处理方法（脚手架，返回 TODO）
func (w *PostWorker) HandleCreate(req *post.CreatePostRequest) (*post.Post, error)
func (w *PostWorker) HandleGet(req *post.GetPostRequest) (*post.Post, error)
func (w *PostWorker) HandleList(req *post.ListPostsRequest) (*post.ListPostsResponse, error)
func (w *PostWorker) HandleDelete(req *post.DeletePostRequest) error
```

### 3. Feed Worker

```go
type FeedWorker struct {
    db     *sql.DB
    broker *broker.Connection
}

// 队列
const (
    QueueFeedLike     = "feed.like"
    QueueFeedUnlike   = "feed.unlike"
    QueueFeedComment  = "feed.comment"
    QueueFeedRepost   = "feed.repost"
    QueueFeedBookmark = "feed.bookmark"
)

// 处理方法（脚手架）
func (w *FeedWorker) HandleLike(req *feed.LikeRequest) error
func (w *FeedWorker) HandleComment(req *feed.CommentRequest) (*feed.Comment, error)
func (w *FeedWorker) HandleRepost(req *feed.RepostRequest) (*feed.Repost, error)
func (w *FeedWorker) HandleBookmark(req *feed.BookmarkRequest) error
```

### 4. Notification Worker

```go
type NotificationWorker struct {
    db     *sql.DB
    broker *broker.Connection
}

// 队列
const (
    QueueNotificationList    = "notification.list"
    QueueNotificationRead    = "notification.read"
    QueueNotificationReadAll = "notification.read_all"
)

// 处理方法（脚手架）
func (w *NotificationWorker) HandleList(req *notification.ListRequest) (*notification.ListResponse, error)
func (w *NotificationWorker) HandleRead(req *notification.ReadRequest) error
func (w *NotificationWorker) HandleReadAll(req *notification.ReadAllRequest) error
```

### 5. User Worker

```go
type UserWorker struct {
    db     *sql.DB
    broker *broker.Connection
}

// 队列
const (
    QueueUserProfileGet    = "user.profile.get"
    QueueUserProfileUpdate = "user.profile.update"
    QueueUserFollow        = "user.follow"
    QueueUserUnfollow      = "user.unfollow"
    QueueUserFollowers     = "user.followers"
    QueueUserFollowing     = "user.following"
)

// 处理方法（脚手架）
func (w *UserWorker) HandleProfileGet(req *user.GetProfileRequest) (*user.Profile, error)
func (w *UserWorker) HandleFollow(req *user.FollowRequest) error
func (w *UserWorker) HandleUnfollow(req *user.UnfollowRequest) error
```

### 6. Search Worker

```go
type SearchWorker struct {
    db     *sql.DB
    broker *broker.Connection
}

// 队列
const (
    QueueSearchPosts = "search.posts"
    QueueSearchUsers = "search.users"
)

// 处理方法（脚手架）
func (w *SearchWorker) HandleSearchPosts(req *search.SearchPostsRequest) (*search.SearchPostsResponse, error)
func (w *SearchWorker) HandleSearchUsers(req *search.SearchUsersRequest) (*search.SearchUsersResponse, error)
```

### 7. Chat Worker（整合现有服务）

将现有 chat_gin 服务改造为 Worker 模式：

```go
type ChatWorker struct {
    db     *sql.DB
    broker *broker.Connection
}

// 队列
const (
    QueueChatSend               = "chat.send"
    QueueChatGetConversations   = "chat.conversations.get"
    QueueChatGetMessages        = "chat.messages.get"
    QueueChatCreateConversation = "chat.conversation.create"
)

// 处理方法（复用现有逻辑）
func (w *ChatWorker) HandleSend(req *chat.SendMessageRequest) (*chat.Message, error)
func (w *ChatWorker) HandleGetConversations(req *chat.GetConversationsRequest) (*chat.ConversationsResponse, error)
```

## Data Models

### Proto 定义扩展

#### gateway.proto 扩展

```protobuf
enum Action {
  ACTION_UNSPECIFIED = 0;
  // Auth (已有)
  USER_REGISTER = 1;
  USER_LOGIN = 2;
  USER_LOGOUT = 3;
  
  // Post (新增)
  POST_CREATE = 10;
  POST_GET = 11;
  POST_LIST = 12;
  POST_DELETE = 13;
  
  // Feed (新增)
  FEED_LIKE = 20;
  FEED_UNLIKE = 21;
  FEED_COMMENT = 22;
  FEED_REPOST = 23;
  FEED_BOOKMARK = 24;
  FEED_UNBOOKMARK = 25;
  
  // Notification (新增)
  NOTIFICATION_LIST = 30;
  NOTIFICATION_READ = 31;
  NOTIFICATION_READ_ALL = 32;
  
  // User (新增)
  USER_PROFILE_GET = 40;
  USER_PROFILE_UPDATE = 41;
  USER_FOLLOW = 42;
  USER_UNFOLLOW = 43;
  USER_FOLLOWERS = 44;
  USER_FOLLOWING = 45;
  
  // Search (新增)
  SEARCH_POSTS = 50;
  SEARCH_USERS = 51;
  
  // Chat (新增)
  CHAT_SEND = 60;
  CHAT_GET_CONVERSATIONS = 61;
  CHAT_GET_MESSAGES = 62;
  CHAT_CREATE_CONVERSATION = 63;
}
```

#### post.proto（新建）

```protobuf
message Post {
  string id = 1;
  string author_id = 2;
  PostType post_type = 3;
  string title = 4;
  string content = 5;
  repeated string media_urls = 6;
  common.Timestamp expires_at = 7;
  common.Timestamp created_at = 8;
  int32 like_count = 9;
  int32 comment_count = 10;
}

enum PostType {
  POST_TYPE_UNSPECIFIED = 0;
  STORY = 1;
  SHORT = 2;
  COLUMN = 3;
}

message CreatePostRequest {
  PostType post_type = 1;
  string title = 2;
  string content = 3;
  repeated string media_urls = 4;
  string author_id = 5;
}
```

#### feed.proto（新建）

```protobuf
message LikeRequest {
  string user_id = 1;
  string post_id = 2;
}

message CommentRequest {
  string author_id = 1;
  string post_id = 2;
  string content = 3;
  string parent_id = 4;  // 可选，回复评论
}

message Comment {
  string id = 1;
  string author_id = 2;
  string post_id = 3;
  string content = 4;
  string parent_id = 5;
  common.Timestamp created_at = 6;
}
```

#### notification.proto（新建）

```protobuf
message Notification {
  string id = 1;
  string user_id = 2;
  NotificationType type = 3;
  string actor_id = 4;
  string target_type = 5;
  string target_id = 6;
  string message = 7;
  bool is_read = 8;
  common.Timestamp created_at = 9;
}

enum NotificationType {
  NOTIFICATION_TYPE_UNSPECIFIED = 0;
  LIKE = 1;
  COMMENT = 2;
  REPLY = 3;
  FOLLOW = 4;
  REPOST = 5;
  MENTION = 6;
}
```

#### user.proto（新建）

```protobuf
message Profile {
  string id = 1;
  string username = 2;
  string email = 3;
  string display_name = 4;
  string avatar_url = 5;
  string bio = 6;
  int32 followers_count = 7;
  int32 following_count = 8;
  common.Timestamp created_at = 9;
}

message FollowRequest {
  string follower_id = 1;
  string following_id = 2;
}
```

#### search.proto（新建）

```protobuf
message SearchPostsRequest {
  string query = 1;
  common.Pagination pagination = 2;
}

message SearchPostsResponse {
  repeated post.Post posts = 1;
  common.Pagination pagination = 2;
}

message SearchUsersRequest {
  string query = 1;
  common.Pagination pagination = 2;
}

message SearchUsersResponse {
  repeated user.Profile users = 1;
  common.Pagination pagination = 2;
}
```

## RabbitMQ 队列设计

```
Exchange: gateway.direct (direct exchange)

Queues:
  # Auth (已有)
  - auth.register
  - auth.login
  
  # Post (新增)
  - post.create
  - post.get
  - post.list
  - post.delete
  
  # Feed (新增)
  - feed.like
  - feed.unlike
  - feed.comment
  - feed.repost
  - feed.bookmark
  - feed.unbookmark
  
  # Notification (新增)
  - notification.list
  - notification.read
  - notification.read_all
  
  # User (新增)
  - user.profile.get
  - user.profile.update
  - user.follow
  - user.unfollow
  - user.followers
  - user.following
  
  # Search (新增)
  - search.posts
  - search.users
  
  # Chat (新增)
  - chat.send
  - chat.conversations.get
  - chat.messages.get
  - chat.conversation.create
  
  # Response (动态)
  - response.{request_id}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system.*

由于本次迁移主要是建立脚手架，不实现具体业务逻辑，可测试属性有限：

**Property 1: 服务启动连接性**
*For any* Worker 服务，启动时必须成功连接 RabbitMQ 和 PostgreSQL，否则应退出并报错
**Validates: Requirements 1.2, 1.3, 2.2, 2.3, 3.2, 3.3, 4.2, 4.3, 5.2, 5.3**

**Property 2: Gateway Action 路由正确性**
*For any* 有效的 Action，Gateway 必须将其路由到正确的队列
**Validates: Requirements 1.4, 1.5, 2.4, 2.5, 3.4, 3.5, 4.4, 4.5, 5.4, 5.5, 6.2, 6.3**

## Error Handling

| 场景 | 错误码 | 处理方式 |
|------|--------|----------|
| 无效 action | INVALID_ACTION | Gateway 直接返回错误 |
| Worker 未实现 | NOT_IMPLEMENTED | Worker 返回 TODO 状态 |
| 数据库连接失败 | DB_UNAVAILABLE | Worker 启动失败 |
| RabbitMQ 连接失败 | BROKER_UNAVAILABLE | 服务启动失败 |

## Testing Strategy

由于明确要求「拒绝测试」，本设计不包含详细测试计划。

验证方式：
1. 启动所有服务，确认无报错
2. 通过 Gateway 发送各类 Action，确认路由正确
3. 检查 Worker 日志，确认收到消息

