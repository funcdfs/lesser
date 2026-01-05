# Requirements Document

## Introduction

本次重构旨在对 Lesser 社交平台的后端服务进行全面清理和优化，包括：
1. 服务命名和结构规范化 - 确保每个服务的函数名、文件名、目录结构符合架构规范
2. 独立 Channel 服务 - 将 Chat 服务中的 CHANNEL 类型会话拆分为独立的 Channel 服务（类似 Telegram Channel）
3. Jaeger 分布式追踪最佳实践 - 在所有服务中充分使用 OpenTelemetry/Jaeger 进行链路追踪

## Glossary

- **Service**: 后端 Go 微服务，位于 `service/<name>/` 目录
- **Handler**: gRPC 处理器层，负责协议对接和参数转换
- **Logic**: 核心业务逻辑层，负责权限判断和业务规则
- **Data_Access**: 数据访问层，负责数据库操作
- **Remote**: 远程服务调用层，负责跨服务 gRPC 调用
- **Messaging**: 消息层，负责 RabbitMQ 消息发布/订阅
- **TraceID**: 分布式追踪标识符，用于跨服务链路追踪
- **Channel**: 广播频道，类似 Telegram Channel，单向广播模式
- **Chat**: 聊天服务，支持私聊和群聊的双向通信

## Requirements

### Requirement 1: 服务目录结构规范化

**User Story:** As a developer, I want each service to follow a consistent directory structure, so that the codebase is maintainable and easy to navigate.

#### Acceptance Criteria

1. THE Service_Directory SHALL follow the standard structure: `cmd/server/main.go`, `internal/{handler,logic,data_access,remote,messaging}/`, `gen_protos/`
2. WHEN a service does not require remote calls THEN THE Service SHALL NOT contain a `remote/` directory
3. WHEN a service does not publish/consume messages THEN THE Service SHALL NOT contain a `messaging/` directory
4. THE Handler_Files SHALL be named `{service}_handler.go` (e.g., `auth_handler.go`, `chat_handler.go`)
5. THE Logic_Files SHALL be named `{service}_service.go` or `{domain}_service.go` for domain-specific logic
6. THE Data_Access_Files SHALL be named `{entity}_repository.go` (e.g., `user_repository.go`, `message_repository.go`)
7. THE Remote_Files SHALL be named `{target_service}_client.go` (e.g., `auth_client.go`, `content_client.go`)
8. THE Messaging_Files SHALL be named `publisher.go` for event publishing and `event_worker.go` for event consuming

### Requirement 2: 函数命名规范化

**User Story:** As a developer, I want consistent function naming across all services, so that the code is predictable and self-documenting.

#### Acceptance Criteria

1. THE Handler_Methods SHALL be named to match the gRPC method name (e.g., `GetUser`, `CreateContent`, `SendMessage`)
2. THE Logic_Methods SHALL use verb-noun pattern (e.g., `CreateUser`, `ValidateToken`, `GetConversationByID`)
3. THE Repository_Methods SHALL use CRUD pattern with entity name (e.g., `Create`, `GetByID`, `Update`, `Delete`, `List`, `FindBy{Field}`)
4. THE Remote_Client_Methods SHALL mirror the target service's gRPC methods
5. THE Publisher_Methods SHALL be named `Publish{EventName}` (e.g., `PublishContentLiked`, `PublishUserFollowed`)
6. WHEN a method returns multiple items THEN THE Method_Name SHALL use plural form or `List` prefix

### Requirement 3: 独立 Channel 服务

**User Story:** As a user, I want a dedicated Channel service for broadcast channels (like Telegram Channels), so that channel functionality is separate from private/group chat.

#### Acceptance Criteria

1. THE Channel_Service SHALL be created as a new service at `service/channel/` with port 50062
2. THE Channel_Service SHALL handle CHANNEL type conversations from the current Chat service
3. THE Chat_Service SHALL only handle PRIVATE and GROUP conversation types after refactoring
4. THE Channel_Proto SHALL be created at `protos/channel/channel.proto` with channel-specific messages
5. WHEN a user subscribes to a channel THEN THE Channel_Service SHALL allow read-only access for non-admin members
6. WHEN a channel admin posts content THEN THE Channel_Service SHALL broadcast to all subscribers
7. THE Channel_Service SHALL support channel metadata (name, description, avatar, subscriber count)
8. THE Channel_Service SHALL use gRPC streaming for real-time channel updates

### Requirement 4: Jaeger 分布式追踪集成

**User Story:** As a developer, I want comprehensive distributed tracing across all services, so that I can debug and monitor request flows.

#### Acceptance Criteria

1. THE TraceID SHALL be generated at the Gateway for incoming requests without existing trace_id
2. THE TraceID SHALL be propagated through gRPC metadata across all service calls
3. THE TraceID SHALL be included in RabbitMQ message headers for async operations
4. THE TraceID SHALL be logged with every log entry using the Logger.WithContext pattern
5. WHEN a service makes a remote call THEN THE TraceID SHALL be passed via gRPC metadata
6. WHEN a service publishes a message THEN THE TraceID SHALL be included in message headers
7. WHEN a service consumes a message THEN THE TraceID SHALL be extracted from message headers
8. THE OpenTelemetry_Exporter SHALL send traces to Jaeger at `jaeger:4317` (OTLP gRPC)

### Requirement 5: 服务间通信规范化

**User Story:** As a developer, I want standardized service-to-service communication patterns, so that the system is reliable and traceable.

#### Acceptance Criteria

1. THE Remote_Client SHALL use connection pooling via `grpcclient.Pool`
2. THE Remote_Client SHALL include TraceInterceptor, LoggingInterceptor, and RetryInterceptor
3. WHEN a remote call fails THEN THE Client SHALL retry with exponential backoff for retryable errors
4. THE Remote_Client SHALL log all calls with method, duration, and trace_id
5. WHEN creating a new remote client THEN THE Client SHALL be initialized in `main.go` and injected into Logic layer

### Requirement 6: 错误处理规范化

**User Story:** As a developer, I want consistent error handling across all services, so that errors are properly categorized and traceable.

#### Acceptance Criteria

1. THE Data_Access_Layer SHALL define domain-specific errors in `errors.go` file
2. THE Logic_Layer SHALL translate data access errors to appropriate gRPC status codes
3. THE Handler_Layer SHALL return gRPC status errors with descriptive messages
4. WHEN an error occurs THEN THE Error SHALL be logged with trace_id and context
5. THE Error_Messages SHALL be in Chinese for user-facing errors

### Requirement 7: 代码清理和优化

**User Story:** As a developer, I want clean and optimized code across all services, so that the codebase is maintainable and performant.

#### Acceptance Criteria

1. THE Services SHALL NOT contain unused imports, variables, or functions
2. THE Services SHALL NOT contain duplicate code that should be in `service/pkg/`
3. THE Services SHALL use consistent code formatting (gofmt)
4. THE Services SHALL have Chinese comments for all exported functions and types
5. WHEN a utility function is used by multiple services THEN THE Function SHALL be moved to `service/pkg/`

### Requirement 8: 配置和环境变量规范化

**User Story:** As a developer, I want consistent configuration patterns across all services, so that deployment and maintenance are simplified.

#### Acceptance Criteria

1. THE Services SHALL read configuration from environment variables
2. THE Services SHALL use `service/pkg/config` for common configuration patterns
3. THE Services SHALL log configuration values (excluding secrets) at startup
4. WHEN a required configuration is missing THEN THE Service SHALL fail fast with a clear error message
5. THE Jaeger_Endpoint SHALL be configurable via `OTEL_EXPORTER_OTLP_ENDPOINT` environment variable

### Requirement 9: 公共库 (pkg) 包结构规范化

**User Story:** As a developer, I want a well-organized and consistent pkg directory structure, so that shared code is easy to find, understand, and maintain.

#### Acceptance Criteria

1. THE Pkg_Directory SHALL follow domain-driven naming: `grpc/` (合并 grpcclient/grpcserver/middleware)、`db/` (合并 database/cache)、`mq/` (重命名 broker)
2. THE Pkg_Packages SHALL NOT contain test-only packages (如 structure、integration 应移至 _test 文件或独立测试目录)
3. THE Pkg_Packages SHALL have clear single responsibility (convert 包应拆分或移除冗余)
4. THE Pkg_Naming SHALL use short, action-oriented names following Go conventions
5. WHEN a package contains multiple sub-domains THEN THE Package SHALL use sub-packages (如 `grpc/client`、`grpc/server`、`grpc/interceptor`)
6. THE Pkg_Packages SHALL NOT duplicate functionality (retry 逻辑应统一在一处)
7. THE Auth_Package SHALL separate concerns: `auth/jwt.go`、`auth/password.go`、`auth/context.go` 保持独立职责
8. THE Timeutil_Package SHALL be renamed to `timex` or merged into a utility package following Go naming conventions

