# Implementation Plan: Flutter Chat Sync

## Overview

本任务列表修复 Flutter 与 Go Chat 服务之间的不一致问题，确保两端功能对齐。优先修复 Go 端以匹配 Flutter 期望的格式，减少客户端改动。

## Tasks

- [x] 1. 修复 Go Message JSON 序列化
  - [x] 1.1 统一 Message JSON 字段名
    - 修改 `service/chat_gin/internal/model/message.go`
    - 将 `dialog_id` 改为 `conversation_id` (JSON tag)
    - 将 `date` 改为 `created_at` (JSON tag)
    - 将 `msg_type` 改为 `message_type` (JSON tag)
    - 添加 `id` 字段的 String 序列化
    - _Requirements: 2.3_
  - [x] 1.2 添加消息类型 String 序列化
    - 实现 `MarshalJSON` 方法将 int 类型转为 string
    - 支持 text/image/video/link/file/system
    - _Requirements: 3.3, 3.4_
  - [x] 1.3 编写 Message JSON 序列化属性测试
    - **Property 2: Message Parsing Round-Trip**
    - **Validates: Requirements 2.5, 3.3, 3.4**

- [x] 2. 更新 Flutter Message 模型解析
  - [x] 2.1 支持 int64 ID 解析
    - 修改 `client/mobile_flutter/lib/features/chat/data/models/message_model.dart`
    - 在 `fromJson` 中处理 `id` 为 int 或 String 的情况
    - _Requirements: 2.1, 2.5_
  - [x] 2.2 支持 int 消息类型解析
    - 添加 `_parseMessageTypeFromInt` 方法
    - 在 `fromJson` 中同时支持 String 和 int 类型
    - _Requirements: 3.4_

- [ ] 3. Checkpoint - 验证 Message 模型对齐
  - 运行 Go 单元测试验证 JSON 序列化
  - 如有问题请询问用户

- [x] 4. 统一 WebSocket 事件类型
  - [x] 4.1 更新 Go WebSocket 已读事件类型
    - 修改 `service/chat_gin/internal/handler/ws/hub.go`
    - 将 `read_receipt_batch` 改为 `messages_read`
    - 将 `read_receipt` 改为 `message_read`
    - _Requirements: 6.3_
  - [x] 4.2 验证 Flutter WebSocket 事件处理
    - 确认 `chat_websocket_service.dart` 中的事件类型常量
    - 确保 `WSMessageType.messagesRead` 与 Go 端一致
    - _Requirements: 6.4_
  - [x] 4.3 编写 WebSocket 事件格式属性测试
    - **Property 5: WebSocket Event Format Consistency**
    - **Validates: Requirements 6.1, 6.2, 6.3, 6.4**

- [x] 5. 添加缺失的消息类型支持
  - [x] 5.1 Flutter 添加 video 和 link 类型
    - 修改 `client/mobile_flutter/lib/features/chat/domain/entities/message.dart`
    - 在 `MessageType` 枚举中添加 `video` 和 `link`
    - _Requirements: 3.1_
  - [x] 5.2 更新 Flutter 类型解析
    - 修改 `message_model.dart` 中的 `_parseMessageType`
    - 添加 video 和 link 的解析支持
    - _Requirements: 3.4_

- [x] 6. Checkpoint - 验证类型对齐
  - 运行 Flutter 单元测试验证类型解析
  - 如有问题请询问用户

- [x] 7. 创建联合调试测试
  - [x] 7.1 创建 Go 端 Flutter 兼容性测试
    - 创建 `service/chat_gin/internal/service/flutter_sync_test.go`
    - 测试 Message JSON 序列化格式
    - 测试 Conversation JSON 序列化格式
    - 测试 WebSocket 事件格式
    - _Requirements: 7.3_
  - [x] 7.2 编写 API 响应结构属性测试
    - **Property 1: API Response Structure Consistency**
    - **Validates: Requirements 1.1-1.6, 2.3, 2.4**
  - [x] 7.3 编写会话验证属性测试
    - **Property 3: Conversation Type Validation**
    - **Validates: Requirements 4.3, 4.4**
  - [x] 7.4 编写未读数一致性属性测试
    - **Property 4: Unread Count Consistency**
    - **Validates: Requirements 5.1, 5.2, 5.3**

- [x] 8. 创建联合调试脚本
  - [x] 8.1 创建测试脚本
    - 创建 `scripts/dev/flutter_chat_sync_test.sh`
    - 启动服务、创建测试用户、运行测试
    - _Requirements: 7.1, 7.2, 7.4, 7.5_

- [x] 9. Final Checkpoint - 完整验证
  - 运行联合调试脚本验证所有修复
  - 如有问题请询问用户

## Notes

- 所有任务均为必需，包括属性测试
- 优先修复 Go 端以减少 Flutter 改动量
- 保持向后兼容，避免破坏现有功能
- 每个任务引用具体需求以确保可追溯性

