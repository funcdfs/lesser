# Implementation Plan: Message Read Status

## Overview

本实现计划将消息已读状态功能分解为可执行的编码任务，按照数据模型 → 仓库层 → 服务层 → API 层 → WebSocket → Proto 的顺序实现。

## Tasks

- [x] 1. 更新数据模型
  - [x] 1.1 更新 Message 模型添加 read_at 字段
    - 修改 `service/chat_gin/internal/model/message.go`
    - 添加 `ReadAt *time.Time` 字段
    - 添加 `IsRead()` 方法
    - 移除 `IsRead bool` 字段
    - _Requirements: 1.1, 1.2, 1.3_
  - [ ]* 1.2 编写 Message.IsRead() 属性测试
    - **Property 1: Read status determined by read_at nullability**
    - **Validates: Requirements 1.2, 1.3**
  - [x] 1.3 创建 ReadReceipt 模型
    - 创建 `service/chat_gin/internal/model/read_receipt.go`
    - 定义 `ReadReceipt` 和 `BatchReadReceipt` 结构体
    - _Requirements: 3.2_

- [x] 2. 更新数据库仓库层
  - [x] 2.1 更新 MessageRepository 标记已读方法
    - 修改 `service/chat_gin/internal/repository/message.go`
    - 更新 `MarkAsRead` 使用 `read_at` 时间戳
    - 更新 `MarkConversationAsRead` 返回被标记的消息ID列表
    - 添加 `MarkMessagesUpToAsRead` 方法
    - _Requirements: 2.1, 2.2, 2.3, 2.5, 2.6_
  - [ ]* 2.2 编写标记已读属性测试
    - **Property 2: Marking message sets read_at timestamp**
    - **Property 3: Marking conversation as read updates non-sender messages only**
    - **Validates: Requirements 1.4, 2.1, 2.2, 2.3**
  - [x] 2.3 添加批量获取未读数方法
    - 添加 `GetUnreadCountsBatch` 方法
    - 使用单条 SQL 查询多个会话的未读数
    - _Requirements: 6.4_
  - [x] 2.4 更新 GetUnreadCount 使用 read_at
    - 修改查询条件从 `is_read = false` 改为 `read_at IS NULL`
    - _Requirements: 1.2, 1.3_

- [ ] 3. Checkpoint - 确保数据层测试通过
  - 运行所有测试，确保数据模型和仓库层正常工作
  - 如有问题请询问用户

- [-] 4. 实现 Redis 缓存服务
  - [x] 4.1 创建 UnreadCacheService
    - 创建 `service/chat_gin/internal/service/unread_cache.go`
    - 实现 `GetUnreadCount` 方法（缓存优先）
    - 实现 `GetUnreadCountsBatch` 方法
    - 实现 `IncrementUnreadCount` 方法
    - 实现 `ResetUnreadCount` 方法
    - 定义缓存键格式 `unread:{user_id}:{conversation_id}`
    - 设置 TTL 为 24 小时
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7_
  - [ ]* 4.2 编写缓存一致性属性测试
    - **Property 7: Redis cache consistency on message send**
    - **Property 8: Redis cache consistency on mark read**
    - **Property 9: Cache fallback to database**
    - **Validates: Requirements 4.2, 4.3, 4.4**
  - [ ]* 4.3 编写批量查询效率属性测试
    - **Property 10: Batch unread count query efficiency**
    - **Validates: Requirements 4.7, 6.1, 6.4**

- [x] 5. 更新业务服务层
  - [x] 5.1 更新 ChatService 集成缓存服务
    - 修改 `service/chat_gin/internal/service/chat.go`
    - 注入 `UnreadCacheS-ervice` 依赖
    - 更新 `SendMessage` 方法调用缓存增量
    - 更新 `MarkConversationAsRead` 方法调用缓存重置
    - _Requirements: 4.2, 4.3_
  - [x] 5.2 添加标记已读服务方法
    - 添加 `MarkMessageAsRead` 方法
    - 添加 `MarkMessagesUpToAsRead` 方法
    - 返回 `ReadReceipt` 或 `BatchReadReceipt`
    - _Requirements: 2.5, 2.6, 3.1_
  - [x] 5.3 添加批量获取未读数服务方法
    - 添加 `GetUnreadCounts` 方法
    - 集成缓存服务
    - _Requirements: 6.1_
  - [x] 5.4 更新 GetUserConversations 包含未读数
    - 使用批量查询获取未读数
    - _Requirements: 6.2_
  - [ ]* 5.5 编写会话列表未读数属性测试
    - **Property 11: Conversation list includes unread counts**
    - **Validates: Requirements 6.2**

- [ ] 6. Checkpoint - 确保服务层测试通过
  - 运行所有测试，确保服务层正常工作
  - 如有问题请询问用户

- [x] 7. 更新 WebSocket Hub 支持已读回执
  - [x] 7.1 添加已读回执推送功能
    - 修改 `service/chat_gin/internal/handler/ws/hub.go`
    - 添加 `ReadReceiptPayload` 结构体
    - 添加 `NotifyReadReceipt` 方法
    - 支持单条和批量已读回执
    - _Requirements: 3.1, 3.2, 3.4_
  - [ ]* 7.2 编写已读回执属性测试
    - **Property 4: Read receipt contains required fields**
    - **Property 5: Read receipts only sent to online users**
    - **Property 6: Batch read receipts for multiple messages**
    - **Validates: Requirements 3.2, 3.3, 3.4, 3.5**

- [x] 8. 实现 HTTP API 端点
  - [x] 8.1 添加标记消息已读端点
    - 修改 `service/chat_gin/internal/server/http.go`
    - 添加 `POST /api/v1/chat/messages/:id/read` 路由
    - 实现 `markMessageAsRead` handler
    - _Requirements: 2.5_
  - [x] 8.2 添加标记会话已读端点
    - 添加 `POST /api/v1/chat/conversations/:id/read` 路由
    - 实现 `markConversationAsRead` handler
    - 调用 WebSocket 推送已读回执
    - _Requirements: 2.1, 3.1_
  - [x] 8.3 添加标记到指定消息已读端点
    - 添加 `POST /api/v1/chat/conversations/:id/read-up-to` 路由
    - 实现 `markMessagesUpToAsRead` handler
    - _Requirements: 2.6_
  - [x] 8.4 添加批量获取未读数端点
    - 添加 `GET /api/v1/chat/unread-counts` 路由
    - 实现 `getUnreadCounts` handler
    - 支持查询参数 `conversation_ids`
    - _Requirements: 6.1_

- [x] 9. 更新 Proto 定义
  - [x] 9.1 更新 chat.proto 消息定义
    - 修改 `protos/chat/chat.proto`
    - 在 `Message` 中添加 `read_at` 字段
    - 添加 `ReadReceipt` 消息类型
    - 添加 `BatchReadReceipt` 消息类型
    - _Requirements: 5.1, 5.2_
  - [x] 9.2 添加 gRPC 服务方法
    - 添加 `MarkAsRead` RPC 方法
    - 添加 `MarkConversationAsRead` RPC 方法
    - 添加 `GetUnreadCounts` RPC 方法
    - _Requirements: 5.3, 5.4_
  - [x] 9.3 添加 WebSocket 通知消息类型
    - 添加 `ReadReceiptNotification` 消息类型
    - _Requirements: 5.5_

- [x] 10. 创建数据库迁移脚本
  - [x] 10.1 编写迁移 SQL
    - 创建 `infra/database/migrations/add_read_at_to_messages.sql`
    - 添加 `read_at` 列
    - 创建索引
    - 迁移现有数据
    - _Requirements: 1.1, 1.5_

- [x] 11. Final Checkpoint - 确保所有测试通过
  - 运行完整测试套件
  - 验证所有属性测试通过
  - 如有问题请询问用户

## Notes

- 任务标记 `*` 为可选测试任务，可跳过以加快 MVP 开发
- 每个任务引用具体需求以确保可追溯性
- Checkpoint 任务用于验证阶段性成果
- 属性测试验证正确性属性，确保系统行为符合规范
