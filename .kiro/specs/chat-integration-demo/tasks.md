# Implementation Plan: Chat Integration Demo

## Overview

本任务列表实现 Django 与 Go 聊天服务的 gRPC 通信演示模板，包括测试用户创建、好友关系、聊天测试和前端页面。

## Tasks

- [x] 1. Django 后端扩展
  - [x] 1.1 创建测试用户管理命令
    - 创建 `apps/users/management/commands/setup_test_users.py`
    - 实现创建 test1、test2 用户
    - 实现建立互相关注关系
    - _Requirements: 2.1, 2.2, 2.3, 3.1, 3.2_
  - [x] 1.2 添加好友列表 API
    - 在 `apps/users/views.py` 添加 `FriendsListView`
    - 在 `apps/users/urls.py` 添加路由 `/friends/`
    - _Requirements: 3.3_

- [x] 2. Go Chat 服务扩展
  - [x] 2.1 添加 HTTP API handlers
    - 创建 `internal/handler/http/chat.go`
    - 实现 CreateConversation、SendMessage、GetMessages
    - _Requirements: 4.1, 4.2, 4.3_
  - [x] 2.2 注册 HTTP 路由
    - 修改 `internal/server/http.go` 添加聊天路由
    - _Requirements: 4.1_
  - [x] 2.3 编写集成测试
    - 创建 `internal/service/chat_integration_test.go`
    - 测试会话创建、消息发送、消息获取
    - **Property 1: Message Round-Trip Integrity**
    - **Property 2: Conversation Membership Consistency**
    - **Validates: Requirements 4.1, 4.2, 4.3, 4.4**

- [x] 3. Checkpoint - 后端验证
  - 启动服务验证 Django 和 Go Chat 正常运行
  - 运行测试用户创建命令
  - 如有问题请询问用户

- [x] 4. Flutter 前端页面
  - [x] 4.1 创建聊天演示页面
    - 创建 `lib/features/chat/presentation/pages/chat_demo_page.dart`
    - 实现好友列表显示
    - 实现聊天界面
    - _Requirements: 6.1, 6.2, 6.3, 6.4_
  - [x] 4.2 添加 API 调用
    - 实现获取好友列表 API 调用
    - 实现创建会话 API 调用
    - 实现发送/获取消息 API 调用
    - _Requirements: 6.5_
  - [x] 4.3 添加路由配置
    - 在路由中添加聊天演示页面入口
    - _Requirements: 6.1_

- [x] 5. 集成测试脚本
  - [x] 5.1 创建演示环境设置脚本
    - 创建 `scripts/dev/setup_chat_demo.sh`
    - 实现启动服务、创建用户、运行测试
    - _Requirements: 7.1, 7.2, 7.3, 7.4_

- [x] 6. Final Checkpoint - 完整验证
  - 运行 `./scripts/dev/setup_chat_demo.sh` 验证完整流程
  - 验证前端页面可以正常显示和发送消息
  - 如有问题请询问用户

## Notes

- 任务按依赖顺序排列，请按顺序执行
- 所有任务均为必需
- 所有代码应遵循项目现有的代码风格
- 测试用户密码统一为 `testtesttest`
