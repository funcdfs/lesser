# Requirements Document

## Introduction

本文档定义了将 Django 后端服务迁移到 Go 微服务架构的需求。基于已实现的 Gateway + RabbitMQ 异步架构（注册/登录已完成），将 Django 中的 posts、feeds、notifications、users、search 模块迁移为独立的 Go Worker 服务，并整合现有 chat_gin 服务以匹配新的异步交互模式。

目标：
- 建立各服务的脚手架（不实现具体业务逻辑）
- 扩展 Gateway 支持新的 Action 类型
- 整合 chat 服务到异步架构
- 保持与 Flutter 客户端的 gRPC 通信

## Glossary

- **Gateway**: 统一网关服务，接收所有客户端请求，解析 action 并分发到消息队列
- **Worker**: 消费消息队列任务的服务，处理具体业务逻辑
- **Post_Worker**: 处理帖子相关业务的 Worker 服务
- **Feed_Worker**: 处理 Feed 交互（点赞、评论、转发、收藏）的 Worker 服务
- **Notification_Worker**: 处理通知相关业务的 Worker 服务
- **User_Worker**: 处理用户资料和关注关系的 Worker 服务
- **Search_Worker**: 处理搜索相关业务的 Worker 服务
- **Chat_Service**: 现有的聊天服务，需整合到异步架构

## Requirements

### Requirement 1: Post Worker 服务脚手架

**User Story:** 作为开发者，我希望有一个 Post Worker 服务脚手架，以便后续实现帖子相关功能。

#### Acceptance Criteria

1. THE Post_Worker SHALL 使用 Go 语言实现，遵循现有 auth_worker 的项目结构
2. THE Post_Worker SHALL 连接 RabbitMQ 并监听 post 相关队列
3. THE Post_Worker SHALL 连接 PostgreSQL 数据库
4. THE Gateway SHALL 支持 POST_CREATE、POST_GET、POST_DELETE 等 Action 类型
5. WHEN Gateway 接收到 post 相关 action 时，THE Gateway SHALL 将任务分发到 post 队列

### Requirement 2: Feed Worker 服务脚手架

**User Story:** 作为开发者，我希望有一个 Feed Worker 服务脚手架，以便后续实现点赞、评论、转发、收藏功能。

#### Acceptance Criteria

1. THE Feed_Worker SHALL 使用 Go 语言实现，遵循现有 auth_worker 的项目结构
2. THE Feed_Worker SHALL 连接 RabbitMQ 并监听 feed 相关队列
3. THE Feed_Worker SHALL 连接 PostgreSQL 数据库
4. THE Gateway SHALL 支持 FEED_LIKE、FEED_COMMENT、FEED_REPOST、FEED_BOOKMARK 等 Action 类型
5. WHEN Gateway 接收到 feed 相关 action 时，THE Gateway SHALL 将任务分发到 feed 队列

### Requirement 3: Notification Worker 服务脚手架

**User Story:** 作为开发者，我希望有一个 Notification Worker 服务脚手架，以便后续实现通知功能。

#### Acceptance Criteria

1. THE Notification_Worker SHALL 使用 Go 语言实现，遵循现有 auth_worker 的项目结构
2. THE Notification_Worker SHALL 连接 RabbitMQ 并监听 notification 相关队列
3. THE Notification_Worker SHALL 连接 PostgreSQL 数据库
4. THE Gateway SHALL 支持 NOTIFICATION_LIST、NOTIFICATION_READ 等 Action 类型
5. WHEN Gateway 接收到 notification 相关 action 时，THE Gateway SHALL 将任务分发到 notification 队列

### Requirement 4: User Worker 服务脚手架

**User Story:** 作为开发者，我希望有一个 User Worker 服务脚手架，以便后续实现用户资料和关注功能。

#### Acceptance Criteria

1. THE User_Worker SHALL 使用 Go 语言实现，遵循现有 auth_worker 的项目结构
2. THE User_Worker SHALL 连接 RabbitMQ 并监听 user 相关队列
3. THE User_Worker SHALL 连接 PostgreSQL 数据库
4. THE Gateway SHALL 支持 USER_PROFILE_GET、USER_PROFILE_UPDATE、USER_FOLLOW、USER_UNFOLLOW 等 Action 类型
5. WHEN Gateway 接收到 user 相关 action 时，THE Gateway SHALL 将任务分发到 user 队列

### Requirement 5: Search Worker 服务脚手架

**User Story:** 作为开发者，我希望有一个 Search Worker 服务脚手架，以便后续实现搜索功能。

#### Acceptance Criteria

1. THE Search_Worker SHALL 使用 Go 语言实现，遵循现有 auth_worker 的项目结构
2. THE Search_Worker SHALL 连接 RabbitMQ 并监听 search 相关队列
3. THE Search_Worker SHALL 连接 PostgreSQL 数据库
4. THE Gateway SHALL 支持 SEARCH_POSTS、SEARCH_USERS 等 Action 类型
5. WHEN Gateway 接收到 search 相关 action 时，THE Gateway SHALL 将任务分发到 search 队列

### Requirement 6: Chat 服务整合

**User Story:** 作为开发者，我希望将现有 chat_gin 服务整合到异步架构，使其与新的认证流程兼容。

#### Acceptance Criteria

1. THE Chat_Service SHALL 通过 Gateway 验证用户 token
2. THE Gateway SHALL 支持 CHAT_SEND、CHAT_GET_CONVERSATIONS、CHAT_GET_MESSAGES 等 Action 类型
3. WHEN Gateway 接收到 chat 相关 action 时，THE Gateway SHALL 将任务分发到 chat 队列
4. THE Chat_Service SHALL 消费 chat 队列处理消息相关业务
5. THE Chat_Service SHALL 保持现有的 WebSocket 实时消息功能

### Requirement 7: Proto 定义扩展

**User Story:** 作为开发者，我希望有完整的 Proto 定义，以便各服务之间通过 gRPC 通信。

#### Acceptance Criteria

1. THE Gateway proto SHALL 扩展 Action 枚举包含所有新的操作类型
2. EACH Worker SHALL 有对应的 proto 文件定义请求和响应消息
3. THE proto 定义 SHALL 与现有 Django models 的数据结构保持一致

### Requirement 8: Docker Compose 配置

**User Story:** 作为开发者，我希望所有新服务都能通过 docker-compose 启动。

#### Acceptance Criteria

1. THE docker-compose.yml SHALL 包含所有新 Worker 服务的配置
2. EACH Worker SHALL 配置正确的环境变量和网络连接
3. THE 服务启动顺序 SHALL 确保依赖服务（RabbitMQ、PostgreSQL）先启动

