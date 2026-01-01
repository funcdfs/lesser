# Requirements Document

## Introduction

本文档定义了将通信协议统一为 **gRPC (用于指令与查询)** + **WebSocket (仅用于实时双向消息)** 的架构重构需求。核心目标是：
- 移除 Chat Service 的 REST API，全部改为 gRPC
- 统一前后端通信协议，消除 JSON 序列化/反序列化的样板代码
- 保留 WebSocket 仅用于实时消息推送
- 将 Auth 流程从异步 MQ 改为同步 gRPC 调用
- 提升类型安全性，降低前后端联调成本

## Glossary

- **Gateway**: 统一网关服务，接收所有 gRPC 请求，处理 Command/Query 分发
- **Chat_Service**: 聊天服务，提供 gRPC 接口和 WebSocket 实时连接
- **Command**: 写操作请求（如发帖、创建会话），通过 Gateway 发布到 MQ 异步处理
- **Query**: 读操作请求（如获取会话列表、消息历史），Gateway 直接查询返回
- **gRPC_Web**: 浏览器兼容的 gRPC 协议，通过 Traefik 代理
- **WebSocket_Hub**: WebSocket 连接管理器，负责实时消息分发

## Requirements

### Requirement 1: Chat Service gRPC 化

**User Story:** 作为前端开发者，我希望通过 gRPC 调用 Chat 服务的所有接口，以获得强类型和更好的开发体验。

#### Acceptance Criteria

1. THE Chat_Service SHALL 提供 gRPC 接口替代现有 REST API
2. WHEN 客户端请求会话列表时，THE Chat_Service SHALL 通过 `GetConversations` RPC 返回会话数据
3. WHEN 客户端请求消息历史时，THE Chat_Service SHALL 通过 `GetMessageHistory` RPC 返回消息列表
4. WHEN 客户端标记会话已读时，THE Chat_Service SHALL 通过 `MarkAsRead` RPC 处理请求
5. WHEN 客户端创建会话时，THE Chat_Service SHALL 通过 `CreateConversation` RPC 处理请求
6. WHEN 客户端发送消息时，THE Chat_Service SHALL 通过 `SendMessage` RPC 处理请求
7. THE Chat_Service SHALL 移除所有 REST API 端点（保留健康检查除外）

### Requirement 2: WebSocket 保留与优化

**User Story:** 作为用户，我希望实时收到新消息通知，无需手动刷新。

#### Acceptance Criteria

1. THE Chat_Service SHALL 保留 WebSocket 端点 `/ws/chat` 用于实时消息推送
2. WHEN 新消息到达时，THE WebSocket_Hub SHALL 向订阅该会话的客户端推送消息
3. WHEN 会话状态变更时，THE WebSocket_Hub SHALL 向相关客户端推送更新
4. THE WebSocket_Hub SHALL 支持心跳检测和自动重连机制
5. WHILE WebSocket 连接断开时，THE Chat_Service SHALL 通过 gRPC 轮询作为降级方案

### Requirement 3: Auth 流程同步化

**User Story:** 作为用户，我希望登录时能立即获得响应，而不是等待异步处理。

#### Acceptance Criteria

1. WHEN 客户端发送登录请求时，THE Gateway SHALL 同步处理认证并返回 JWT
2. WHEN 客户端发送注册请求时，THE Gateway SHALL 同步处理注册并返回结果
3. THE Gateway SHALL 移除 Auth 相关的 MQ 异步流程
4. IF 认证失败，THEN THE Gateway SHALL 立即返回错误信息

### Requirement 4: Gateway Command/Query 分离

**User Story:** 作为系统架构师，我希望 Gateway 能智能区分读写操作，优化请求处理路径。

#### Acceptance Criteria

1. WHEN Gateway 接收到 Command 类型请求时，THE Gateway SHALL 发布到 MQ 并返回处理中状态
2. WHEN Gateway 接收到 Query 类型请求时，THE Gateway SHALL 直接查询数据源并返回结果
3. THE Gateway SHALL 通过 RPC 方法名或元数据区分 Command 和 Query
4. WHEN Query 请求需要调用下游服务时，THE Gateway SHALL 通过 gRPC 同步调用

### Requirement 5: Flutter 客户端统一网络层

**User Story:** 作为 Flutter 开发者，我希望只使用 gRPC 和 WebSocket 两种协议，简化网络层代码。

#### Acceptance Criteria

1. THE Flutter_Client SHALL 移除 Dio HTTP 客户端对业务接口的依赖
2. THE Flutter_Client SHALL 使用统一的 gRPC Channel 配置和拦截器
3. WHEN 发送 gRPC 请求时，THE Flutter_Client SHALL 自动注入 JWT Token
4. THE Flutter_Client SHALL 使用 WebSocket 客户端处理实时消息
5. WHEN WebSocket 断开时，THE Flutter_Client SHALL 自动尝试重连

### Requirement 6: Traefik 路由配置

**User Story:** 作为运维人员，我希望 Traefik 能正确路由 gRPC 和 WebSocket 请求。

#### Acceptance Criteria

1. THE Traefik SHALL 配置 HTTP/2 (h2c) 支持 gRPC 请求
2. THE Traefik SHALL 配置 HTTP/1.1 Upgrade 支持 WebSocket 请求
3. WHEN 请求路径为 `/grpc/*` 时，THE Traefik SHALL 路由到 Gateway 或 Chat_Service
4. WHEN 请求路径为 `/ws/*` 时，THE Traefik SHALL 路由到 Chat_Service WebSocket 端点

### Requirement 7: Proto 定义与代码生成

**User Story:** 作为开发团队，我们希望通过 Proto 文件自动生成前后端代码，减少手写样板代码。

#### Acceptance Criteria

1. THE Proto_Files SHALL 定义 ChatService 的所有 RPC 方法
2. THE Proto_Files SHALL 定义完整的请求/响应消息类型
3. WHEN Proto 文件更新时，THE Build_System SHALL 自动生成 Go 和 Dart 代码
4. THE Generated_Code SHALL 包含强类型的 Request/Response 类

### Requirement 8: 错误处理统一

**User Story:** 作为前端开发者，我希望有统一的错误处理机制，便于向用户展示友好的错误信息。

#### Acceptance Criteria

1. THE gRPC_Services SHALL 使用标准 gRPC Status Code 返回错误
2. WHEN 认证失败时，THE Service SHALL 返回 `UNAUTHENTICATED` 状态码
3. WHEN 参数无效时，THE Service SHALL 返回 `INVALID_ARGUMENT` 状态码
4. WHEN 资源不存在时，THE Service SHALL 返回 `NOT_FOUND` 状态码
5. THE Flutter_Client SHALL 提供 GrpcErrorConverter 将错误码转换为用户友好提示
