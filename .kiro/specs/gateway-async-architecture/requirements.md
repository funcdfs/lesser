# Requirements Document

## Introduction

本文档定义了一个新的前后端交互架构，采用统一网关入口 + 异步消息队列的模式，替代传统的 RESTful API 同步调用方式。核心目标是：
- 统一的请求入口（单一 POST 端点）
- gRPC 消息格式（强类型、高性能）
- RabbitMQ 异步任务分发
- 纯 Go 实现（抛弃 Django）

首先通过注册和登录流程验证整体架构可行性。

## Glossary

- **Gateway**: 统一网关服务，接收所有客户端请求，解析 action 并分发到消息队列
- **Action**: 客户端请求的操作类型，如 `USER_REGISTER`、`USER_LOGIN`
- **Message_Broker**: RabbitMQ 消息队列，负责任务的异步分发和管理
- **Worker**: 消费消息队列任务的服务，处理具体业务逻辑
- **Request_Envelope**: 统一的请求包装格式，包含 action、version、params 等字段

## Requirements

### Requirement 1: 统一网关入口

**User Story:** 作为前端开发者，我希望只需要向单一端点发送请求，无需关心后端路由细节，从而简化客户端实现。

#### Acceptance Criteria

1. THE Gateway SHALL 提供单一 POST 端点 `/api/gateway/` 接收所有客户端请求
2. WHEN 客户端发送请求时，THE Gateway SHALL 解析 Request_Envelope 中的 action 字段确定操作类型
3. THE Gateway SHALL 使用 gRPC 格式（Protocol Buffers）作为消息序列化格式
4. WHEN 请求格式无效时，THE Gateway SHALL 返回明确的错误响应

### Requirement 2: 异步任务分发

**User Story:** 作为系统架构师，我希望请求处理采用异步模式，使各服务解耦，提高系统容错性。

#### Acceptance Criteria

1. WHEN Gateway 接收到有效请求后，THE Gateway SHALL 将任务发布到 Message_Broker
2. THE Message_Broker SHALL 使用 RabbitMQ 实现消息队列管理
3. WHEN 任务发布成功后，THE Gateway SHALL 立即返回任务接收确认给客户端
4. THE Worker SHALL 从 Message_Broker 消费任务并处理具体业务逻辑
5. WHEN Worker 处理完成后，THE Worker SHALL 通过 Message_Broker 发送处理结果

### Requirement 3: 用户注册流程

**User Story:** 作为新用户，我希望能够注册账号，以便使用系统功能。

#### Acceptance Criteria

1. WHEN 客户端发送 action 为 `USER_REGISTER` 的请求时，THE Gateway SHALL 将注册任务分发到 Message_Broker
2. THE Worker SHALL 验证注册信息并创建用户记录
3. WHEN 注册成功时，THE Worker SHALL 返回用户信息和认证令牌
4. IF 用户名或邮箱已存在，THEN THE Worker SHALL 返回相应错误信息

### Requirement 4: 用户登录流程

**User Story:** 作为已注册用户，我希望能够登录系统，以便访问我的账户。

#### Acceptance Criteria

1. WHEN 客户端发送 action 为 `USER_LOGIN` 的请求时，THE Gateway SHALL 将登录任务分发到 Message_Broker
2. THE Worker SHALL 验证用户凭证
3. WHEN 登录成功时，THE Worker SHALL 返回认证令牌
4. IF 凭证无效，THEN THE Worker SHALL 返回认证失败错误

### Requirement 5: 纯 Go 实现

**User Story:** 作为开发团队，我们希望使用 Go 语言实现整个后端，以获得更好的性能和类型安全。

#### Acceptance Criteria

1. THE Gateway SHALL 使用 Go 语言实现
2. THE Worker SHALL 使用 Go 语言实现
3. THE Gateway SHALL 与 Flutter 客户端通过 gRPC/Protobuf 通信
4. THE Worker SHALL 与 PostgreSQL 数据库交互存储用户数据
