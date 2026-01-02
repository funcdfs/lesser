# Implementation Plan: Integration Testing

## Overview

本任务列表定义了前后端联合调试测试的详细步骤。测试分为三个阶段：后端 API 测试、前端功能测试、前后端联合测试。每个任务都是独立的测试步骤，按顺序执行。

**重要提示**: 每次只执行一条命令，避免终端卡顿。

## Tasks

- [x] 1. 环境准备和服务健康检查
  - [x] 1.1 检查 Docker 服务状态
    - 运行 `docker ps` 查看所有容器状态
    - 确认 postgres, redis, gateway, auth, chat 等服务都在运行
    - _Requirements: 1.1_
  - [x] 1.2 检查 grpcurl 工具是否可用
    - 运行 `which grpcurl` 或 `grpcurl --version`
    - 如未安装，提示安装方法
    - _Requirements: 1.1_
  - [x] 1.3 测试 Gateway 健康检查
    - Gateway 服务已启动并运行
    - 注意：Gateway 需要认证，直接测试 auth 服务
    - _Requirements: 1.2_
  - [x] 1.4 测试数据库连接
    - 使用 docker exec 进入 postgres 容器
    - 执行简单 SQL 查询验证连接
    - _Requirements: 1.3_

- [x] 2. 用户注册功能测试
  - [x] 2.1 注册测试用户 A
    - 使用 grpcurl 调用 Register 接口
    - user_id: 7be9d491-3f17-4b8e-954e-967984fb1f0c
    - _Requirements: 2.1, 2.4_
  - [x] 2.2 注册测试用户 B
    - 使用 grpcurl 调用 Register 接口
    - user_id: 07472e44-a3e6-4780-b56d-7562a79e6f48
    - _Requirements: 2.1, 2.4_
  - [x] 2.3 验证重复用户名注册失败
    - 使用相同用户名再次注册
    - 验证返回 ALREADY_EXISTS 错误 ✓
    - _Requirements: 2.2_
  - [x] 2.4 验证数据库中用户数据
    - 使用 SQL 查询验证用户已创建 ✓
    - _Requirements: 10.4_

- [x] 3. 用户登录功能测试
  - [x] 3.1 测试用户 A 登录
    - 使用 grpcurl 调用 Login 接口
    - 验证返回 access_token 和 refresh_token ✓
    - _Requirements: 3.1, 3.4_
  - [x] 3.2 测试错误密码登录
    - 使用错误密码调用 Login 接口
    - 验证返回 Unauthenticated 错误 ✓
    - _Requirements: 3.2_
  - [x] 3.3 测试不存在用户登录
    - 使用不存在的邮箱调用 Login 接口
    - 验证返回 Unauthenticated 错误 ✓
    - _Requirements: 3.3_

- [x] 4. 聊天会话创建测试
  - [x] 4.1 创建私聊会话
    - 使用 grpcurl 调用 CreateConversation 接口
    - 传入用户 A 和用户 B 的 ID
    - conversation_id: b3808fd9-9b8b-4f20-9c0e-52381e620e80 ✓
    - _Requirements: 4.1, 4.2, 4.3_
  - [x] 4.2 验证会话数据
    - 会话创建成功，包含两个成员 ✓
    - _Requirements: 10.4_

- [x] 5. 发送消息功能测试
  - [x] 5.1 用户 A 发送第一条消息
    - message_id: 1 ✓
    - _Requirements: 5.1, 5.2_
  - [x] 5.2 用户 B 发送回复消息
    - message_id: 2 ✓
    - _Requirements: 5.1, 5.2_
  - [x] 5.3 获取会话消息列表
    - 返回消息列表，按时间排序 ✓
    - _Requirements: 5.3, 5.4_
  - [x] 5.4 验证消息数据库持久化
    - 消息已正确存储 ✓
    - _Requirements: 5.3, 10.4_

- [x] 6. 已读回执功能测试
  - [x] 6.1 用户 B 标记单条消息已读
    - 返回 ReadReceipt 包含正确字段 ✓
    - _Requirements: 6.1, 6.3_
  - [x] 6.2 用户 A 标记会话所有消息已读
    - 返回 BatchReadReceipt，包含 message_id: 3 ✓
    - _Requirements: 6.2_
  - [x] 6.3 验证已读回执数据库记录
    - 已读回执已正确存储 ✓
    - _Requirements: 10.4_

- [x] 7. 未读消息计数测试
  - [x] 7.1 发送新消息增加未读数
    - 用户 A 发送新消息 (message_id: 3)
    - 用户 B 未读数增加到 1 ✓
    - _Requirements: 7.1_
  - [x] 7.2 获取未读消息计数
    - GetUnreadCounts 返回正确的未读数 ✓
    - _Requirements: 7.2_
  - [x] 7.3 标记已读后未读数归零
    - 用户 B 标记会话已读后，未读数为 0 ✓
    - _Requirements: 6.4, 7.3_

- [x] 8. 检查点 - 后端测试完成
  - 所有后端 API 测试通过 ✓
  - 清理了 WebSocket 相关代码，已迁移到 gRPC 双向流 ✓
  - Auth 服务：注册、登录、错误处理全部正常 ✓
  - Chat 服务：会话创建、消息发送、已读回执、未读计数全部正常 ✓

- [-] 9. Flutter 客户端测试准备
  - [x] 9.1 检查 Flutter 环境
    - 运行 `flutter doctor` 检查环境
    - 确认 Flutter SDK 可用
    - _Requirements: 8.1_
  - [-] 9.2 启动 Flutter Web 应用
    - 进入 client/mobile_flutter 目录
    - 运行 Flutter Web 应用
    - _Requirements: 8.1_

- [ ] 10. Flutter 登录功能测试
  - [ ] 10.1 测试登录页面加载
    - 访问 Flutter Web 应用
    - 验证登录页面正常显示
    - _Requirements: 8.1_
  - [ ] 10.2 测试有效凭据登录
    - 使用测试用户 A 的凭据登录
    - 验证成功跳转到主页
    - _Requirements: 8.1, 8.2_
  - [ ] 10.3 测试无效凭据登录
    - 使用错误密码尝试登录
    - 验证显示错误提示
    - _Requirements: 8.3_

- [ ] 11. Flutter 聊天功能测试
  - [ ] 11.1 测试会话列表加载
    - 登录后进入聊天页面
    - 验证会话列表正常显示
    - _Requirements: 9.1_
  - [ ] 11.2 测试发送消息
    - 在会话中发送测试消息
    - 验证消息显示在聊天界面
    - _Requirements: 9.2_
  - [ ] 11.3 后端验证消息
    - 使用 grpcurl 获取消息列表
    - 验证前端发送的消息已存储
    - _Requirements: 10.2_

- [ ] 12. 检查点 - 前端测试完成
  - 确认 Flutter 客户端功能正常
  - 记录测试结果和发现的问题
  - 如有问题，查阅 docs 文档寻找解决方案

- [ ] 13. 前后端联合测试
  - [ ] 13.1 前端注册 → 后端验证
    - 在 Flutter 中注册新用户
    - 使用 grpcurl 验证用户已创建
    - _Requirements: 10.1_
  - [ ] 13.2 前端发消息 → 后端验证
    - 在 Flutter 中发送消息
    - 使用 grpcurl 验证消息已存储
    - _Requirements: 10.2_
  - [ ] 13.3 前端标记已读 → 后端验证
    - 在 Flutter 中查看消息（触发已读）
    - 使用 grpcurl 验证已读回执
    - _Requirements: 10.3_
  - [ ] 13.4 后端发消息 → 前端验证
    - 使用 grpcurl 发送消息
    - 在 Flutter 中验证消息显示
    - _Requirements: 9.2_

- [ ] 14. 数据一致性验证
  - [ ] 14.1 验证用户数据一致性
    - 对比 gRPC API 返回和数据库记录
    - _Requirements: 10.4_
  - [ ] 14.2 验证消息数据一致性
    - 对比 gRPC API 返回和数据库记录
    - _Requirements: 10.4_
  - [ ] 14.3 验证已读回执数据一致性
    - 对比 gRPC API 返回和数据库记录
    - _Requirements: 10.4_

- [ ] 15. 最终检查点 - 测试完成
  - 汇总所有测试结果
  - 记录发现的问题和修复情况
  - 更新测试记录文档

## Notes

- 每次只执行一条命令，避免终端卡顿
- 测试过程中遇到问题，先查阅 docs/ 目录下的文档
- 记录每个测试步骤的结果，便于问题追踪
- 测试用户数据使用唯一的用户名和邮箱，避免冲突
- 保存重要的 ID（user_id, conversation_id, message_id）供后续测试使用
