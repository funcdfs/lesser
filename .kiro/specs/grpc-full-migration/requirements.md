# Requirements Document

## Introduction

本规范定义了将 Lesser 社交平台从混合通信协议（REST API + WebSocket + gRPC）完全迁移到纯 gRPC + gRPC 双向流架构的需求。迁移后，所有客户端（Flutter/React）将统一使用 gRPC 进行数据获取和实时通信，彻底抛弃 RESTful API 和 WebSocket。

迁移目标：
- 统一通信协议为 gRPC
- 使用 gRPC 双向流替代 WebSocket 实现实时通信
- Flutter 客户端采用统一的 gRPC 数据获取模式
- 零测试迁移（不编写测试代码）
- 迁移完成后更新所有文档

## Glossary

- **Gateway_Service**: Go 语言实现的 gRPC 网关服务，统一处理所有客户端请求
- **Chat_Service**: Go 语言实现的聊天 gRPC 服务，处理实时消息
- **Bidirectional_Stream**: gRPC 双向流，用于替代 WebSocket 实现实时通信
- **Unified_gRPC_Client**: Flutter 端统一的 gRPC 客户端，管理所有 gRPC 连接
- **Proto_Definition**: Protocol Buffers 定义文件，描述 gRPC 服务和消息格式
- **Worker_Service**: 后端异步任务处理服务，通过 RabbitMQ 消费消息

## Requirements

### Requirement 1: 统一 gRPC 网关服务

**User Story:** As a 开发者, I want 所有 API 请求通过统一的 gRPC 网关处理, so that 通信协议一致且易于维护。

#### Acceptance Criteria

1. THE Gateway_Service SHALL 提供统一的 gRPC 入口处理所有业务请求
2. WHEN 客户端发送认证请求 THEN THE Gateway_Service SHALL 同步返回认证结果（Login/Register/RefreshToken）
3. WHEN 客户端发送业务请求（Post/Feed/User/Search/Notification）THEN THE Gateway_Service SHALL 将请求发布到 RabbitMQ 并返回请求 ID
4. THE Gateway_Service SHALL 移除所有 REST API 端点
5. THE Gateway_Service SHALL 提供 GetResult RPC 用于查询异步任务结果

### Requirement 2: gRPC 双向流替代 WebSocket

**User Story:** As a 用户, I want 实时消息通过 gRPC 双向流传输, so that 无需维护额外的 WebSocket 连接。

#### Acceptance Criteria

1. THE Chat_Service SHALL 提供 StreamMessages 双向流 RPC 用于实时消息推送
2. WHEN 用户订阅会话 THEN THE Chat_Service SHALL 通过双向流推送该会话的新消息
3. WHEN 用户发送消息 THEN THE Chat_Service SHALL 通过双向流广播给会话成员
4. THE Chat_Service SHALL 移除所有 WebSocket 端点和 Hub 实现
5. WHEN 连接断开 THEN THE Chat_Service SHALL 支持客户端自动重连和状态恢复
6. THE Chat_Service SHALL 通过双向流推送已读回执、会话更新等实时事件

### Requirement 3: Flutter 统一 gRPC 客户端

**User Story:** As a Flutter 开发者, I want 使用统一的 gRPC 客户端获取数据, so that 代码结构清晰且易于维护。

#### Acceptance Criteria

1. THE Unified_gRPC_Client SHALL 管理所有 gRPC Channel 连接（Gateway + Chat）
2. THE Unified_gRPC_Client SHALL 提供统一的认证拦截器自动附加 JWT Token
3. WHEN 调用任何 gRPC 方法 THEN THE Unified_gRPC_Client SHALL 自动处理错误和重试
4. THE Unified_gRPC_Client SHALL 提供双向流管理，支持订阅/取消订阅会话
5. WHEN Token 过期 THEN THE Unified_gRPC_Client SHALL 自动刷新 Token 并重试请求
6. THE Unified_gRPC_Client SHALL 移除所有 HTTP/REST 相关代码（Dio、ApiClient 等）

### Requirement 4: Proto 定义更新

**User Story:** As a 开发者, I want Proto 定义完整覆盖所有业务功能, so that gRPC 服务能处理所有请求类型。

#### Acceptance Criteria

1. THE Proto_Definition SHALL 定义所有业务实体（User/Post/Feed/Notification/Search）
2. THE Proto_Definition SHALL 定义双向流消息类型用于实时通信
3. WHEN 定义流消息 THEN THE Proto_Definition SHALL 包含消息类型字段区分不同事件
4. THE Proto_Definition SHALL 定义统一的错误响应格式
5. THE Proto_Definition SHALL 定义分页请求和响应格式

### Requirement 5: 后端服务迁移

**User Story:** As a 后端开发者, I want 所有服务统一使用 gRPC 通信, so that 服务间通信协议一致。

#### Acceptance Criteria

1. THE Chat_Service SHALL 移除 HTTP Server 和 WebSocket Hub
2. THE Chat_Service SHALL 仅保留 gRPC Server 和双向流实现
3. THE Gateway_Service SHALL 移除所有 REST 路由处理
4. WHEN Worker 处理完成 THEN THE Worker_Service SHALL 通过 Redis Pub/Sub 通知结果
5. THE Traefik 配置 SHALL 移除 HTTP 路由，仅保留 gRPC 路由

### Requirement 6: Flutter 数据层重构

**User Story:** As a Flutter 开发者, I want 数据层完全基于 gRPC, so that 无需维护多种数据源实现。

#### Acceptance Criteria

1. THE Flutter 数据源 SHALL 全部使用 gRPC 客户端实现
2. WHEN 获取数据 THEN THE Flutter 数据源 SHALL 调用对应的 gRPC RPC 方法
3. THE Flutter 数据源 SHALL 移除所有 HTTP/REST 数据源实现
4. THE Flutter 数据源 SHALL 移除 WebSocket 服务实现
5. WHEN 需要实时数据 THEN THE Flutter 数据源 SHALL 使用 gRPC 双向流

### Requirement 7: 实时事件流设计

**User Story:** As a 用户, I want 接收所有类型的实时事件, so that 应用状态始终保持最新。

#### Acceptance Criteria

1. THE Chat_Service 双向流 SHALL 支持推送新消息事件
2. THE Chat_Service 双向流 SHALL 支持推送已读回执事件
3. THE Chat_Service 双向流 SHALL 支持推送会话更新事件
4. THE Chat_Service 双向流 SHALL 支持推送未读数更新事件
5. THE Chat_Service 双向流 SHALL 支持推送用户在线状态事件
6. WHEN 客户端发送订阅请求 THEN THE Chat_Service SHALL 开始推送对应会话的事件

### Requirement 8: 文档更新

**User Story:** As a 开发者, I want 文档反映最新的架构, so that 新成员能快速理解系统。

#### Acceptance Criteria

1. WHEN 迁移完成 THEN THE 架构梳理文档 SHALL 更新为纯 gRPC 架构
2. WHEN 迁移完成 THEN THE 开发准则文档 SHALL 移除 REST/WebSocket 相关内容
3. WHEN 迁移完成 THEN THE README 文档 SHALL 更新架构图和技术栈说明
4. THE 文档 SHALL 包含新的 gRPC 双向流使用指南
5. THE 文档 SHALL 包含 Flutter gRPC 客户端使用示例

### Requirement 9: Traefik 网关配置

**User Story:** As a 运维人员, I want Traefik 仅处理 gRPC 流量, so that 配置简洁且性能最优。

#### Acceptance Criteria

1. THE Traefik 配置 SHALL 移除所有 HTTP 路由规则
2. THE Traefik 配置 SHALL 仅保留 gRPC 路由到 Gateway 和 Chat 服务
3. THE Traefik 配置 SHALL 支持 gRPC-Web 用于浏览器客户端
4. THE Traefik 配置 SHALL 配置 gRPC 健康检查
5. WHEN 配置 gRPC 路由 THEN THE Traefik 配置 SHALL 启用 HTTP/2

### Requirement 10: 错误处理和重试机制

**User Story:** As a 用户, I want 应用能优雅处理网络错误, so that 使用体验流畅。

#### Acceptance Criteria

1. WHEN gRPC 调用失败 THEN THE Unified_gRPC_Client SHALL 根据错误类型决定是否重试
2. WHEN 双向流断开 THEN THE Unified_gRPC_Client SHALL 自动重连并恢复订阅状态
3. THE Unified_gRPC_Client SHALL 实现指数退避重试策略
4. WHEN 认证失败 THEN THE Unified_gRPC_Client SHALL 触发重新登录流程
5. THE Unified_gRPC_Client SHALL 提供统一的错误消息转换为用户友好提示
