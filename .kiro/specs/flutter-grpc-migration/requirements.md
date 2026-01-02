# Requirements Document

## Introduction

本文档定义了将 Flutter 客户端从 Django RESTful API 完全迁移到 gRPC 架构的需求。基于已完成的 Auth 和 Chat 模块 gRPC 迁移，需要将 Flutter 中的 feeds、post、profile、search、notifications 等模块全部迁移到 gRPC 通信，彻底移除对 Django 和 RESTful API 的依赖。

目标：
- 移除 Flutter 中所有 RESTful API 调用（Dio HTTP 客户端）
- 为所有业务模块实现 gRPC 客户端
- 统一使用 gRPC + WebSocket 通信协议
- 保持 Clean Architecture 分层结构
- 确保与后端 Go 服务的 gRPC 接口对接

## Glossary

- **Flutter_Client**: Flutter 移动端应用
- **GrpcClientManager**: gRPC 连接管理器，负责 Channel 创建和认证
- **DataSource**: 数据源层，负责实际的网络请求
- **Repository**: 仓库层，协调数据源并转换数据模型
- **UseCase**: 用例层，封装单个业务操作
- **Provider**: 状态管理层，使用 Riverpod 管理 UI 状态
- **Gateway**: Go 网关服务，提供统一的 gRPC API 入口
- **Worker**: Go Worker 服务，处理异步业务逻辑

## Requirements

### Requirement 1: 移除 RESTful API 依赖

**User Story:** 作为开发者，我希望移除所有 RESTful API 调用，统一使用 gRPC 通信。

#### Acceptance Criteria

1. THE Flutter_Client SHALL 移除 Dio HTTP 客户端对业务接口的所有调用
2. THE Flutter_Client SHALL 移除 `core/api/api_client.dart` 中的 RESTful API 方法
3. THE Flutter_Client SHALL 移除 `core/api/api_endpoints.dart` 中的 REST 端点定义
4. THE Flutter_Client SHALL 保留 Dio 仅用于非 gRPC 场景（如文件上传、第三方 API）
5. WHEN 编译 Flutter 应用时，THE Build_System SHALL 不包含未使用的 REST API 代码

### Requirement 2: Feeds 模块 gRPC 迁移

**User Story:** 作为用户，我希望通过 gRPC 获取动态流、点赞、评论、转发、收藏等功能。

#### Acceptance Criteria

1. THE Flutter_Client SHALL 创建 FeedGrpcClient 用于 Feed 相关的 gRPC 调用
2. WHEN 用户获取动态流时，THE FeedGrpcClient SHALL 调用 Gateway 的 `GetFeed` RPC
3. WHEN 用户点赞帖子时，THE FeedGrpcClient SHALL 调用 Gateway 的 `LikePost` RPC
4. WHEN 用户评论帖子时，THE FeedGrpcClient SHALL 调用 Gateway 的 `CommentPost` RPC
5. WHEN 用户转发帖子时，THE FeedGrpcClient SHALL 调用 Gateway 的 `RepostPost` RPC
6. WHEN 用户收藏帖子时，THE FeedGrpcClient SHALL 调用 Gateway 的 `BookmarkPost` RPC
7. THE FeedGrpcClient SHALL 自动注入 JWT Token 到请求头
8. THE FeedDataSource SHALL 使用 FeedGrpcClient 替代 HTTP 请求

### Requirement 3: Post 模块 gRPC 迁移

**User Story:** 作为用户，我希望通过 gRPC 创建、获取、删除帖子。

#### Acceptance Criteria

1. THE Flutter_Client SHALL 创建 PostGrpcClient 用于 Post 相关的 gRPC 调用
2. WHEN 用户创建帖子时，THE PostGrpcClient SHALL 调用 Gateway 的 `CreatePost` RPC
3. WHEN 用户获取帖子详情时，THE PostGrpcClient SHALL 调用 Gateway 的 `GetPost` RPC
4. WHEN 用户删除帖子时，THE PostGrpcClient SHALL 调用 Gateway 的 `DeletePost` RPC
5. WHEN 用户获取帖子列表时，THE PostGrpcClient SHALL 调用 Gateway 的 `ListPosts` RPC
6. THE PostGrpcClient SHALL 自动注入 JWT Token 到请求头
7. THE PostDataSource SHALL 使用 PostGrpcClient 替代 HTTP 请求

### Requirement 4: Profile 模块 gRPC 迁移

**User Story:** 作为用户，我希望通过 gRPC 查看和编辑个人资料、管理关注关系。

#### Acceptance Criteria

1. THE Flutter_Client SHALL 创建 UserGrpcClient 用于 User 相关的 gRPC 调用
2. WHEN 用户获取个人资料时，THE UserGrpcClient SHALL 调用 Gateway 的 `GetUserProfile` RPC
3. WHEN 用户更新个人资料时，THE UserGrpcClient SHALL 调用 Gateway 的 `UpdateUserProfile` RPC
4. WHEN 用户关注他人时，THE UserGrpcClient SHALL 调用 Gateway 的 `FollowUser` RPC
5. WHEN 用户取消关注时，THE UserGrpcClient SHALL 调用 Gateway 的 `UnfollowUser` RPC
6. WHEN 用户获取关注列表时，THE UserGrpcClient SHALL 调用 Gateway 的 `GetFollowing` RPC
7. WHEN 用户获取粉丝列表时，THE UserGrpcClient SHALL 调用 Gateway 的 `GetFollowers` RPC
8. THE UserGrpcClient SHALL 自动注入 JWT Token 到请求头
9. THE ProfileDataSource SHALL 使用 UserGrpcClient 替代 HTTP 请求

### Requirement 5: Search 模块 gRPC 迁移

**User Story:** 作为用户，我希望通过 gRPC 搜索用户和帖子。

#### Acceptance Criteria

1. THE Flutter_Client SHALL 创建 SearchGrpcClient 用于 Search 相关的 gRPC 调用
2. WHEN 用户搜索帖子时，THE SearchGrpcClient SHALL 调用 Gateway 的 `SearchPosts` RPC
3. WHEN 用户搜索用户时，THE SearchGrpcClient SHALL 调用 Gateway 的 `SearchUsers` RPC
4. THE SearchGrpcClient SHALL 支持分页参数
5. THE SearchGrpcClient SHALL 自动注入 JWT Token 到请求头
6. THE SearchDataSource SHALL 使用 SearchGrpcClient 替代 HTTP 请求

### Requirement 6: Notifications 模块 gRPC 迁移

**User Story:** 作为用户，我希望通过 gRPC 获取和管理通知。

#### Acceptance Criteria

1. THE Flutter_Client SHALL 创建 NotificationGrpcClient 用于 Notification 相关的 gRPC 调用
2. WHEN 用户获取通知列表时，THE NotificationGrpcClient SHALL 调用 Gateway 的 `GetNotifications` RPC
3. WHEN 用户标记通知已读时，THE NotificationGrpcClient SHALL 调用 Gateway 的 `MarkNotificationRead` RPC
4. WHEN 用户获取未读通知数时，THE NotificationGrpcClient SHALL 调用 Gateway 的 `GetUnreadCount` RPC
5. THE NotificationGrpcClient SHALL 自动注入 JWT Token 到请求头
6. THE NotificationDataSource SHALL 使用 NotificationGrpcClient 替代 HTTP 请求

### Requirement 7: 统一 gRPC 客户端管理

**User Story:** 作为开发者，我希望有统一的 gRPC 客户端管理机制，简化配置和维护。

#### Acceptance Criteria

1. THE GrpcClientManager SHALL 管理所有 gRPC Channel 的创建和生命周期
2. THE GrpcClientManager SHALL 提供统一的认证 CallOptions
3. THE GrpcClientManager SHALL 提供统一的错误处理机制
4. THE GrpcClientManager SHALL 支持自动重连机制
5. WHEN JWT Token 过期时，THE GrpcClientManager SHALL 自动刷新 Token
6. THE GrpcClientManager SHALL 提供日志拦截器用于调试

### Requirement 8: 数据模型转换

**User Story:** 作为开发者，我希望有清晰的数据模型转换层，将 Proto 消息转换为 Domain Entity。

#### Acceptance Criteria

1. EACH Feature SHALL 在 data/models 目录下定义 Model 类
2. THE Model 类 SHALL 提供 `fromProto()` 方法将 Proto 消息转换为 Model
3. THE Model 类 SHALL 提供 `toEntity()` 方法将 Model 转换为 Domain Entity
4. THE Model 类 SHALL 提供 `toProto()` 方法将 Model 转换为 Proto 消息（用于请求）
5. THE 转换逻辑 SHALL 处理空值和默认值

### Requirement 9: 错误处理统一

**User Story:** 作为用户，我希望看到友好的错误提示，而不是技术性的错误信息。

#### Acceptance Criteria

1. THE Flutter_Client SHALL 创建 GrpcErrorHandler 统一处理 gRPC 错误
2. WHEN gRPC 返回 UNAUTHENTICATED 时，THE GrpcErrorHandler SHALL 触发重新登录流程
3. WHEN gRPC 返回 INVALID_ARGUMENT 时，THE GrpcErrorHandler SHALL 显示参数错误提示
4. WHEN gRPC 返回 NOT_FOUND 时，THE GrpcErrorHandler SHALL 显示资源不存在提示
5. WHEN gRPC 返回 INTERNAL 时，THE GrpcErrorHandler SHALL 显示服务器错误提示
6. THE GrpcErrorHandler SHALL 支持自定义错误消息映射

### Requirement 10: 依赖注入更新

**User Story:** 作为开发者，我希望通过依赖注入管理所有 gRPC 客户端实例。

#### Acceptance Criteria

1. THE Flutter_Client SHALL 在 `core/di/injection.dart` 中注册所有 gRPC 客户端
2. THE Flutter_Client SHALL 使用 GetIt 管理 gRPC 客户端的单例
3. WHEN 应用启动时，THE Injection_System SHALL 初始化所有 gRPC 客户端
4. WHEN 应用关闭时，THE Injection_System SHALL 正确释放 gRPC Channel 资源
5. THE Repository 实现 SHALL 通过依赖注入获取 gRPC 客户端

### Requirement 11: 测试覆盖

**User Story:** 作为开发者，我希望有完整的测试覆盖，确保 gRPC 迁移的正确性。

#### Acceptance Criteria

1. EACH gRPC 客户端 SHALL 有对应的单元测试
2. EACH Repository 实现 SHALL 有对应的单元测试
3. THE 测试 SHALL 使用 Mock gRPC 客户端
4. THE 测试 SHALL 覆盖成功场景和错误场景
5. THE 测试 SHALL 验证数据模型转换的正确性

### Requirement 12: 向后兼容性

**User Story:** 作为开发者，我希望在迁移过程中保持应用的可用性。

#### Acceptance Criteria

1. THE 迁移 SHALL 按模块逐步进行，每个模块独立完成
2. WHEN 某个模块迁移完成时，THE 应用 SHALL 仍然可以正常运行
3. THE 迁移 SHALL 不影响已迁移模块的功能
4. IF 后端 gRPC 接口未就绪，THEN THE 客户端 SHALL 提供降级方案或友好提示
