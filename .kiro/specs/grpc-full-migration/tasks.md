# Implementation Plan: gRPC 全面迁移

## Overview

本任务列表将 Lesser 社交平台从混合通信协议完全迁移到纯 gRPC + gRPC 双向流架构。迁移分为四个阶段：清理准备、后端迁移、前端迁移、配置和文档更新。

**零测试迁移** - 不编写任何测试代码。

## Tasks

- [x] 1. 清理和准备阶段
  - [x] 1.1 删除 React Web 客户端
    - 删除 `client/web_react/` 目录
    - 更新 `.gitignore` 移除 React 相关条目
    - _Requirements: 8.1_

  - [x] 1.2 更新 Proto 定义
    - 更新 `protos/auth/auth.proto` 添加 `GetPublicKey` RPC
    - 更新 `protos/chat/chat.proto` 添加双向流 `StreamEvents` RPC
    - 添加 `ClientEvent` 和 `ServerEvent` 消息定义
    - 运行 `dev proto` 生成 Go 和 Dart 代码
    - _Requirements: 4.1, 4.2, 4.3_

- [x] 2. 后端迁移阶段 - Gateway 重构
  - [x] 2.1 实现 JWT 本地验签模块
    - 创建 `service/gateway/internal/auth/jwt.go`
    - 实现 `JWTValidator` 结构体
    - 实现定时刷新和惰性刷新机制
    - 实现 Key ID 不匹配时的自动刷新
    - _Requirements: 1.1, 1.2_

  - [x] 2.2 实现限流模块
    - 创建 `service/gateway/internal/ratelimit/limiter.go`
    - 实现基于内存的令牌桶限流
    - _Requirements: 1.1_

  - [x] 2.3 实现 gRPC 双向流代理
    - 创建 `service/gateway/internal/proxy/stream_proxy.go`
    - 实现 `ProxyStreamEvents` 方法
    - 确保支持 HTTP/2 Streaming Flush
    - _Requirements: 2.1, 2.2_

  - [x] 2.4 重构 Gateway 主服务
    - 更新 `service/gateway/main.go`
    - 移除业务逻辑，仅保留路由转发
    - 集成 JWT 验签、限流、路由模块
    - 创建 `service/gateway/internal/router/router.go`
    - 简化 `service/gateway/proto/gateway/gateway.proto`
    - _Requirements: 1.1, 1.2, 1.3_

- [x] 3. Checkpoint - Gateway 重构完成
  - 确保 Gateway 编译通过
  - 确保 JWT 验签模块正常工作
  - 如有问题请询问用户

- [x] 4. 后端迁移阶段 - Auth Service
  - [x] 4.1 创建 Auth Service 目录结构
    - 创建 `service/auth/` 目录
    - 创建 `cmd/server/main.go`
    - 创建 `internal/handler/`, `internal/service/`, `internal/repository/`
    - _Requirements: 1.2, 1.3_

  - [x] 4.2 实现 Auth Service gRPC 处理器
    - 实现 `Login`, `Register`, `RefreshToken` RPC
    - 实现 `GetPublicKey` RPC（返回 JWT 公钥）
    - 实现 `Logout`, `BanUser`, `CheckBanned` RPC
    - _Requirements: 1.2, 1.3_

  - [x] 4.3 实现 JWT 密钥管理
    - 实现 RSA 密钥对生成和存储
    - 实现 Key ID 管理（支持密钥轮换）
    - _Requirements: 1.2_

  - [x] 4.4 迁移 auth_worker 业务逻辑到 Auth Service
    - 迁移用户认证逻辑
    - 迁移密码加密验证
    - 创建 Dockerfile 和 .air.toml
    - _Requirements: 1.2, 1.3_


- [x] 5. 后端迁移阶段 - 业务 Service 集群
  - [x] 5.1 创建 User Service
    - 创建 `service/user/` 目录结构
    - 实现 `GetProfile`, `UpdateProfile`, `Follow`, `Unfollow` RPC
    - 实现 `GetFollowers`, `GetFollowing` RPC
    - _Requirements: 5.1, 5.2_

  - [x] 5.2 创建 Post Service
    - 创建 `service/post/` 目录结构
    - 实现 `CreatePost`, `GetPost`, `ListPosts`, `UpdatePost`, `DeletePost` RPC
    - _Requirements: 5.1, 5.2_

  - [x] 5.3 创建 Feed Service
    - 创建 `service/feed/` 目录结构
    - 实现 `Like`, `Unlike`, `CreateComment`, `DeleteComment` RPC
    - 实现 `ListComments`, `Bookmark`, `Unbookmark` RPC
    - _Requirements: 5.1, 5.2_

  - [x] 5.4 创建 Search Service
    - 创建 `service/search/` 目录结构
    - 实现 `SearchPosts`, `SearchUsers` RPC
    - _Requirements: 5.1, 5.2_

  - [x] 5.5 创建 Notification Service
    - 创建 `service/notification/` 目录结构
    - 实现 `List`, `MarkAsRead`, `MarkAllAsRead` RPC
    - 实现 `GetUnreadCount` RPC
    - _Requirements: 5.1, 5.2_

- [x] 6. Checkpoint - 业务 Service 集群完成
  - 确保所有 Service 编译通过
  - 确保 Service 间 gRPC 通信正常
  - 如有问题请询问用户

- [x] 7. 后端迁移阶段 - Chat Service 重构
  - [x] 7.1 实现 gRPC 双向流处理器
    - 创建 `service/chat/internal/handler/grpc/stream.go`
    - 实现 `StreamManager` 管理活跃连接
    - 实现 `StreamClient` 表示单个流连接
    - 实现 `StreamEvents` RPC
    - _Requirements: 2.1, 2.2, 2.3_

  - [x] 7.2 实现双向流事件处理
    - 实现 `handleSubscribe` 订阅会话
    - 实现 `handleUnsubscribe` 取消订阅
    - 实现 `handleSendMessage` 通过流发送消息
    - 实现 `handleTyping` 正在输入指示
    - 实现心跳 Ping/Pong
    - _Requirements: 2.2, 2.3, 7.1, 7.2, 7.3, 7.4, 7.5_

  - [x] 7.3 实现服务端事件推送
    - 实现 `BroadcastNewMessage` 新消息推送
    - 实现 `BroadcastMessageRead` 已读回执推送
    - 实现 `BroadcastTyping` 正在输入推送
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_

  - [x] 7.4 移除 WebSocket 相关代码
    - WebSocket 代码已被 gRPC 双向流替代
    - _Requirements: 2.4, 5.1_

- [x] 8. Checkpoint - Chat Service 重构完成
  - 确保 Chat Service 编译通过
  - 确保双向流 RPC 正常工作
  - 如有问题请询问用户


- [x] 9. 前端迁移阶段 - Flutter gRPC 客户端
  - [x] 9.1 完善统一 gRPC 客户端
    - 更新 `lib/core/network/unified_grpc_client.dart`
    - 实现双向流连接管理
    - 实现自动重连机制（指数退避）
    - 实现心跳 Ping/Pong
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 10.2, 10.3_

  - [x] 9.2 实现服务端事件流处理
    - 创建 `lib/core/network/stream_event_handler.dart`
    - 实现 `ServerEvent` 分发处理
    - 实现订阅/取消订阅会话
    - 实现通过流发送消息
    - _Requirements: 3.4, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_

  - [x] 9.3 实现 Token 自动刷新
    - 实现 Token 过期检测
    - 实现自动刷新 Token 并重试请求
    - 实现认证失败时触发重新登录
    - _Requirements: 3.5, 10.4_

- [x] 10. 前端迁移阶段 - 数据源重构
  - [x] 10.1 创建 Chat gRPC 数据源
    - 创建 `lib/features/chat/data/datasources/chat_grpc_datasource.dart`
    - 实现 `getConversations`, `getConversation`, `createConversation`
    - 实现 `getMessages`, `sendMessage`
    - 实现 `markConversationAsRead`, `getUnreadCounts`
    - _Requirements: 6.1, 6.2_

  - [x] 10.2 创建 Auth gRPC 数据源
    - 创建 `lib/features/auth/data/datasources/auth_grpc_datasource.dart`
    - 实现 `login`, `register`, `refreshToken`, `logout`
    - _Requirements: 6.1, 6.2_

  - [x] 10.3 创建 User gRPC 数据源
    - 创建 `lib/features/profile/data/datasources/user_grpc_datasource.dart`
    - 实现 `getProfile`, `updateProfile`
    - 实现 `follow`, `unfollow`, `getFollowers`, `getFollowing`
    - _Requirements: 6.1, 6.2_

  - [x] 10.4 创建 Post gRPC 数据源
    - 创建 `lib/features/post/data/datasources/post_grpc_datasource.dart`
    - 实现 `createPost`, `getPost`, `listPosts`, `updatePost`, `deletePost`
    - _Requirements: 6.1, 6.2_

  - [x] 10.5 创建 Feed gRPC 数据源
    - 创建 `lib/features/feeds/data/datasources/feed_grpc_datasource.dart`
    - 实现 `getFeed`, `like`, `unlike`, `comment`, `deleteComment`
    - 实现 `getComments`, `repost`, `bookmark`, `unbookmark`
    - _Requirements: 6.1, 6.2_

  - [x] 10.6 创建 Search gRPC 数据源
    - 创建 `lib/features/search/data/datasources/search_grpc_datasource.dart`
    - 实现 `searchPosts`, `searchUsers`
    - _Requirements: 6.1, 6.2_

  - [x] 10.7 创建 Notification gRPC 数据源
    - 创建 `lib/features/notifications/data/datasources/notification_grpc_datasource.dart`
    - 实现 `getNotifications`, `markAsRead`, `markAllAsRead`, `getUnreadCount`
    - _Requirements: 6.1, 6.2_

- [x] 11. 前端迁移阶段 - 清理旧代码
  - [x] 11.1 删除 REST/HTTP 相关代码
    - 删除 `lib/core/api/` 目录
    - 删除 `lib/core/api/api_client.dart`
    - 删除 `lib/core/api/api_endpoints.dart`
    - 删除 `lib/core/api/trace_interceptor.dart`
    - _Requirements: 3.6, 6.3_

  - [x] 11.2 删除旧的 REST 数据源
    - 保留接口定义在 `*_remote_datasource.dart`
    - 删除 REST 实现代码
    - 删除 `chat_websocket_service.dart`
    - _Requirements: 6.3, 6.4_

  - [x] 11.3 更新依赖注入
    - 更新 `lib/core/di/injection.dart`
    - 注册新的 gRPC 数据源
    - 移除 `ApiClient` 注册
    - 移除 Dio 相关依赖
    - _Requirements: 3.1, 6.1_

  - [x] 11.4 更新 pubspec.yaml
    - 移除 `dio` 依赖
    - 确保 `grpc` 和 `protobuf` 依赖正确
    - 运行 `flutter pub get`
    - _Requirements: 3.6_

- [x] 12. Checkpoint - Flutter 迁移完成
  - 确保 Flutter 项目编译通过
  - 确保 gRPC 数据源正常工作
  - 如有问题请询问用户


- [x] 13. 配置更新阶段
  - [x] 13.1 更新 Traefik 配置
    - 更新 `infra/gateway/dynamic/routes.yml`
    - 移除 REST API 路由 (`chat-api`)
    - 移除 WebSocket 路由 (`chat-websocket`)
    - 配置 gRPC 双向流传输（禁用超时）
    - _Requirements: 9.1, 9.2, 9.5_

  - [x] 13.2 更新 Docker Compose
    - 更新 `infra/docker-compose.yml`
    - 添加新的 Service 容器定义（auth, user, post, feed, search, notification）
    - 移除 Worker 容器定义
    - 更新端口映射
    - _Requirements: 5.1, 5.2_

  - [x] 13.3 更新环境变量配置
    - 更新 `infra/.env.dev`
    - 添加新 Service 的配置
    - 移除 Worker 相关配置
    - _Requirements: 5.1_

- [x] 14. 文档更新阶段
  - [x] 14.1 更新架构梳理文档
    - 更新 `docs/架构梳理.md`
    - 更新架构图为纯 gRPC 架构
    - 更新通信协议说明
    - 移除 REST/WebSocket 相关内容
    - 添加 Gateway JWT 验签说明
    - 添加 Service Cluster 说明
    - _Requirements: 8.1, 8.4_

  - [x] 14.2 更新开发准则文档
    - 更新 `docs/开发准则.md`
    - 移除 REST API 设计规范
    - 移除 WebSocket 相关内容
    - 添加 gRPC 双向流使用指南
    - 更新新增路由修改流程
    - _Requirements: 8.2, 8.4_

  - [x] 14.3 更新 README
    - 更新 `README.md`
    - 更新架构图
    - 更新技术栈说明（移除 React）
    - 更新目录结构说明
    - 更新服务访问地址
    - _Requirements: 8.3_

  - [x] 14.4 创建 gRPC 双向流使用指南
    - 创建 `docs/gRPC双向流指南.md`
    - 说明 Flutter 端如何使用双向流
    - 说明订阅/取消订阅会话
    - 说明通过流发送消息
    - 说明错误处理和重连
    - _Requirements: 8.4, 8.5_

- [x] 15. 最终清理
  - [x] 15.1 删除废弃的 Worker 目录
    - 确认所有 Worker 已迁移到 Service
    - 删除 `service/auth_worker/`
    - 删除 `service/user_worker/`
    - 删除 `service/post_worker/`
    - 删除 `service/feed_worker/`
    - 删除 `service/notification_worker/`
    - 删除 `service/search_worker/`
    - _Requirements: 5.1, 5.2_

  - [x] 15.2 清理 Proto 生成代码
    - Proto 生成代码保持最新
    - Go 和 Dart 代码同步
    - _Requirements: 4.1_

- [x] 16. Final Checkpoint - 迁移完成
  - Flutter 项目编译通过 (flutter pub get 成功)
  - 文档已更新
  - Worker 目录已清理
  - 配置文件已更新

## Notes

- 本迁移为零测试迁移，不编写任何测试代码
- 迁移验证通过手动功能测试和日志监控
- 每个 Checkpoint 后应确认当前阶段工作正常再继续
- 如遇到问题，及时询问用户获取指导
- Worker 到 Service 的迁移需要保留业务逻辑，仅改变调用方式
- Gateway 不再处理业务逻辑，仅做 JWT 验签、限流、路由
- RabbitMQ 仅用于次要、非阻塞的异步逻辑
