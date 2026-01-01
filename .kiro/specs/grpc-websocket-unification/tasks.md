# Implementation Plan: gRPC + WebSocket 统一架构

## Overview

将通信协议统一为 gRPC + WebSocket，分阶段实施：
1. Gateway Auth 同步化
2. Chat Service REST 移除
3. Flutter 网络层重构
4. Traefik 路由优化

## Tasks

- [x] 1. Gateway Auth 同步化
  - [x] 1.1 扩展 gateway.proto 添加同步 Auth 接口
    - 添加 Login, Register, RefreshToken RPC 方法
    - 定义 LoginRequest, RegisterRequest, RefreshTokenRequest, AuthResponse 消息
    - _Requirements: 3.1, 3.2_
  - [x] 1.2 实现 Gateway Auth Handler
    - 在 Gateway 中实现同步认证逻辑
    - 直接查询 PostgreSQL 验证凭证
    - 生成 JWT Token
    - _Requirements: 3.1, 3.2, 3.4_
  - [ ]* 1.3 编写 Auth 同步响应属性测试
    - **Property 2: Auth 同步响应**
    - **Validates: Requirements 3.1, 3.2, 3.4**
  - [x] 1.4 移除 Auth Worker 的 MQ 消费逻辑
    - 保留 Auth Worker 用于其他异步任务（如密码重置邮件）
    - 移除 auth.login 和 auth.register 队列消费
    - _Requirements: 3.3_

- [x] 2. Checkpoint - Auth 同步化验证
  - 使用 grpcurl 测试 Login/Register RPC
  - 确认 JWT 生成和验证正常

- [x] 3. Chat Service REST 移除
  - [x] 3.1 移除 HTTP Server 的 REST 路由
    - 保留 /health 健康检查
    - 保留 /ws/chat WebSocket 端点
    - 移除所有 /api/v1/chat/* 路由
    - _Requirements: 1.7_
  - [x] 3.2 验证 gRPC Handler 完整性
    - 确认所有 REST 功能在 gRPC 中有对应实现
    - 检查 GetConversations, GetMessages, SendMessage 等方法
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_
  - [ ]* 3.3 编写 gRPC Chat 操作一致性属性测试
    - **Property 1: gRPC Chat 操作一致性**
    - **Validates: Requirements 1.2, 1.3, 1.4, 1.5, 1.6**

- [x] 4. Checkpoint - Chat gRPC 验证
  - 使用 grpcurl 测试所有 Chat RPC 方法
  - 确认 WebSocket 实时推送正常

- [x] 5. Gateway Command/Query 分离
  - [x] 5.1 定义 Command/Query 分类规则
    - 在 gateway.proto 中标注每个 Action 的类型
    - Command: POST_CREATE, FEED_LIKE, CHAT_SEND 等
    - Query: POST_GET, USER_PROFILE_GET, FEED_LIST 等
    - _Requirements: 4.3_
  - [x] 5.2 实现 Gateway 智能路由
    - Command 请求 → 发布到 MQ，返回 request_id
    - Query 请求 → 直接查询或 RPC 调用下游服务
    - _Requirements: 4.1, 4.2, 4.4_
  - [ ]* 5.3 编写 Command/Query 分离属性测试
    - **Property 3: Command/Query 分离**
    - **Validates: Requirements 4.1, 4.2**

- [x] 6. Checkpoint - Gateway 路由验证
  - 测试 Command 请求返回 request_id
  - 测试 Query 请求直接返回数据

- [x] 7. Flutter 网络层重构
  - [x] 7.1 创建统一 gRPC 客户端
    - 创建 lib/core/network/unified_grpc_client.dart
    - 整合 Gateway 和 Chat gRPC 客户端
    - 实现统一的认证拦截器
    - _Requirements: 5.2, 5.3_
  - [ ]* 7.2 编写 gRPC 认证拦截属性测试
    - **Property 4: gRPC 认证拦截**
    - **Validates: Requirements 5.3, 8.2**
  - [x] 7.3 重构 Auth 模块使用 gRPC
    - 修改 AuthRepository 使用 Gateway gRPC 客户端
    - 移除 Dio 依赖
    - _Requirements: 5.1_
  - [x] 7.4 重构 Chat 模块使用 gRPC
    - 修改 ChatRepository 使用 Chat gRPC 客户端
    - 移除 REST API 调用
    - _Requirements: 5.1_
  - [x] 7.5 优化 WebSocket 客户端
    - 实现心跳检测
    - 实现自动重连机制
    - _Requirements: 2.4, 5.5_
  - [x] 7.6 实现 GrpcErrorConverter
    - 将 gRPC 错误码转换为用户友好提示
    - _Requirements: 8.5_
  - [ ]* 7.7 编写错误处理属性测试
    - **Property 5: 错误码一致性**
    - **Property 6: 错误消息转换**
    - **Validates: Requirements 8.2, 8.3, 8.4, 8.5**

- [x] 8. Checkpoint - Flutter 网络层验证
  - 测试登录/注册流程
  - 测试聊天功能
  - 测试 WebSocket 重连

- [x] 9. Traefik 路由配置
  - [x] 9.1 配置 HTTP/2 支持
    - 为 gRPC 服务配置 h2c 传输
    - _Requirements: 6.1_
  - [x] 9.2 配置 WebSocket 路由
    - 确保 /ws/* 路径正确路由到 Chat Service
    - _Requirements: 6.2, 6.4_
  - [x] 9.3 更新 gRPC 路由规则
    - /grpc/gateway/* → Gateway Service
    - /grpc/chat/* → Chat Service
    - _Requirements: 6.3_

- [x] 10. 清理和文档
  - [x] 10.1 移除废弃代码
    - 删除 Chat Service 中的 REST handler 代码
    - 删除 Flutter 中未使用的 Dio 相关代码
    - _Requirements: 1.7, 5.1_
  - [x] 10.2 更新架构文档
    - 更新 docs/架构梳理.md 反映新架构
    - 更新 API 路由表

- [x] 11. Final Checkpoint - 端到端验证
  - 完整测试登录 → 聊天 → 发帖流程
  - 确认所有功能正常工作
  - 确认所有测试通过

## Notes

- 任务标记 `*` 为可选测试任务，可跳过以加快 MVP 进度
- 每个 Checkpoint 确保阶段性功能完整
- 属性测试使用 Go `testing/quick` 和 Dart `glados`
- 保持向后兼容：先添加新接口，再移除旧接口
