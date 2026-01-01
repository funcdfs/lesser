# Implementation Plan: Gateway Async Architecture

## Overview

实现统一网关 + RabbitMQ 异步架构，纯 Go 实现，跑通注册和登录流程。

## Tasks

- [x] 1. 创建 Proto 定义
  - 创建 `protos/gateway/gateway.proto` 定义统一请求/响应格式
  - 定义 GatewayRequest、GatewayResponse、TaskResult 消息
  - _Requirements: 1.1, 1.3_

- [x] 2. 搭建 Gateway Service 基础结构
  - [x] 2.1 创建 `service/gateway` 目录和 Go module
    - 初始化 go.mod，添加依赖（grpc, amqp）
    - _Requirements: 5.1_
  - [x] 2.2 实现 RabbitMQ 连接管理
    - 创建连接池和 channel 管理
    - _Requirements: 2.2_
  - [x] 2.3 实现 gRPC Gateway Server
    - 实现 Process 方法，解析 action 并分发到队列
    - _Requirements: 1.1, 1.2, 2.1_

- [x] 3. 搭建 Auth Worker 基础结构
  - [x] 3.1 创建 `service/auth_worker` 目录和 Go module
    - 初始化 go.mod，添加依赖
    - _Requirements: 5.2_
  - [x] 3.2 实现 RabbitMQ 消费者
    - 监听 auth.register 和 auth.login 队列
    - _Requirements: 2.4_
  - [x] 3.3 实现 PostgreSQL 连接
    - 连接用户数据库
    - _Requirements: 5.4_

- [x] 4. 实现注册流程
  - [x] 4.1 Gateway 处理 USER_REGISTER action
    - 解析 payload 为 RegisterRequest，发布到 auth.register 队列
    - _Requirements: 3.1_
  - [x] 4.2 Auth Worker 处理注册任务
    - 验证信息，创建用户，生成 token
    - _Requirements: 3.2, 3.3, 3.4_

- [x] 5. 实现登录流程
  - [x] 5.1 Gateway 处理 USER_LOGIN action
    - 解析 payload 为 LoginRequest，发布到 auth.login 队列
    - _Requirements: 4.1_
  - [x] 5.2 Auth Worker 处理登录任务
    - 验证凭证，生成 token
    - _Requirements: 4.2, 4.3, 4.4_

- [x] 6. 配置基础设施
  - [x] 6.1 添加 RabbitMQ 到 docker-compose
    - 配置 RabbitMQ 服务
    - _Requirements: 2.2_
  - [x] 6.2 添加 Gateway 和 Auth Worker 到 docker-compose
    - 配置服务启动和网络
    - _Requirements: 5.1, 5.2_

- [ ] 7. Checkpoint - 手动验证
  - 启动服务，使用 grpcurl 测试注册和登录
  - 确认整体流程跑通

## Notes

- 纯 Go 实现，不依赖 Django
- 不包含单元测试和属性测试（按要求跳过）
- 先跑通核心流程，后续再完善细节
