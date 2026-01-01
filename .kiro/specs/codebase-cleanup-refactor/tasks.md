# Implementation Plan: Codebase Cleanup and Refactor

## Overview

本实现计划将代码库清理和重构分为 6 个主要阶段：
1. 根目录清理
2. pkg 扩展（Redis 缓存）
3. pkg 扩展（gRPC 客户端）
4. Worker 服务迁移
5. 冗余文件清理
6. 验证和 Django 删除

## Tasks

- [x] 1. 根目录清理
  - [x] 1.1 移动 gateway proto 文件到 service 目录
    - 将 `/gateway/gateway.pb.go` 和 `/gateway/gateway_grpc.pb.go` 移动到 `service/gateway/proto/gateway/`
    - 更新文件中的 package 声明（如需要）
    - _Requirements: 1.1, 1.3_
  - [x] 1.2 更新所有引用 gateway 包的 import 路径
    - 搜索所有引用 `github.com/lesser/gateway` 的文件
    - 更新为 `github.com/lesser/gateway/proto/gateway`
    - _Requirements: 1.4_
  - [x] 1.3 删除根目录下的 gateway 文件夹
    - 确认移动完成后删除 `/gateway` 目录
    - _Requirements: 1.1, 1.2_
  - [x] 1.4 验证构建成功
    - 运行 `go build ./...` 确认所有服务编译通过
    - _Requirements: 1.4_

- [x] 2. 添加 Redis 缓存封装到 pkg
  - [x] 2.1 创建 pkg/cache/config.go
    - 实现 `Config` 结构体
    - 实现 `ConfigFromEnv()` 从环境变量读取配置
    - 支持 `REDIS_URL` 或 `REDIS_HOST/PORT/PASSWORD/DB` 配置
    - _Requirements: 4.6_
  - [x] 2.2 创建 pkg/cache/redis.go
    - 实现 `Client` 结构体封装 `redis.Client`
    - 实现 `NewClient(cfg Config)` 构造函数
    - 实现 `Close()` 方法
    - 实现 `Get(ctx, key, target)` 方法（JSON 反序列化）
    - 实现 `Set(ctx, key, value, expiration)` 方法（JSON 序列化）
    - 实现 `Delete(ctx, keys...)` 方法
    - 实现 `Exists(ctx, key)` 方法
    - 实现 `SetNX(ctx, key, value, expiration)` 方法
    - 实现 `GetClient()` 返回底层客户端
    - 定义 `ErrKeyNotFound` 错误
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.7_
  - [ ]* 2.3 编写 Redis Round-Trip 属性测试
    - **Property 2: Redis 缓存 Round-Trip 一致性**
    - 使用 `rapid` 或 `gopter` 库
    - 生成随机结构体，验证 Set/Get 一致性
    - **Validates: Requirements 4.3, 4.5**
  - [x] 2.4 更新 pkg/app 集成 Redis
    - 在 `Config` 中添加 `Redis cache.Config` 和 `EnableRedis bool`
    - 在 `App` 中添加 `cache *cache.Client`
    - 在 `New()` 中初始化 Redis（如果启用）
    - 添加 `Cache()` 方法返回 Redis 客户端
    - 在 `Shutdown()` 中关闭 Redis 连接
    - _Requirements: 4.8_

- [x] 3. Checkpoint - 确保 Redis 封装测试通过
  - 运行 `go test ./pkg/cache/...`
  - 确保所有测试通过，如有问题请询问用户

- [x] 4. 添加 gRPC 客户端封装到 pkg
  - [x] 4.1 创建 pkg/grpc/config.go
    - 实现 `ClientConfig` 结构体
    - 实现 `ConfigFromEnv(serviceName)` 从环境变量读取配置
    - _Requirements: 5.5_
  - [x] 4.2 创建 pkg/grpc/interceptors.go
    - 实现 `TraceInterceptor()` 传递 trace_id
    - 实现 `LoggingInterceptor(log)` 记录调用日志
    - 实现 `RetryInterceptor(maxRetries, backoff)` 重试逻辑
    - _Requirements: 5.3, 5.4, 5.6_
  - [ ]* 4.3 编写 Trace ID 传递属性测试
    - **Property 3: gRPC Trace ID 传递**
    - 验证任意 trace_id 通过拦截器正确传递
    - **Validates: Requirements 5.4**
  - [x] 4.4 创建 pkg/grpc/pool.go
    - 实现 `ClientPool` 结构体管理多个连接
    - 实现 `NewClientPool(log)` 构造函数
    - 实现 `Register(name, cfg)` 注册服务配置
    - 实现 `GetConn(ctx, name)` 获取连接（懒加载）
    - 实现 `Close()` 关闭所有连接
    - _Requirements: 5.1, 5.2_
  - [x] 4.5 更新 pkg/app 集成 gRPC
    - 在 `Config` 中添加 `EnableGRPC bool`
    - 在 `App` 中添加 `grpcPool *grpc.ClientPool`
    - 添加 `GRPCPool()` 方法
    - 在 `Shutdown()` 中关闭 gRPC 连接
    - _Requirements: 5.7_

- [x] 5. Checkpoint - 确保 gRPC 封装测试通过
  - 运行 `go test ./pkg/grpc/...`
  - 确保所有测试通过，如有问题请询问用户

- [x] 6. 迁移 auth_worker 到 pkg
  - [x] 6.1 重构 auth_worker/cmd/worker/main.go
    - 使用 `app.ConfigFromEnv("auth-worker")` 初始化配置
    - 使用 `app.New(cfg)` 创建应用实例
    - 使用 `broker.Config` 配置队列消费
    - 使用 `application.Run(ctx, brokerConfigs...)` 启动
    - _Requirements: 2.1, 2.2, 2.3, 2.4_
  - [x] 6.2 更新 auth_worker/internal/service
    - 修改 `AuthService` 接受 `*sql.DB` 和 `*logger.Logger`
    - 更新 Handler 签名匹配 `broker.Handler` 类型
    - _Requirements: 2.1, 2.2, 2.3, 2.4_
  - [x] 6.3 删除 auth_worker 内部重复实现
    - 删除 `internal/broker/` 目录
    - 删除 `internal/database/` 目录
    - _Requirements: 3.1, 3.2_

- [x] 7. 迁移 chat_worker 到 pkg
  - [x] 7.1 重构 chat_worker/cmd/worker/main.go
    - 使用 pkg/app 和 pkg/broker
    - _Requirements: 2.5, 2.6_
  - [x] 7.2 删除 chat_worker 内部重复实现
    - 删除 `internal/broker/` 和 `internal/database/` 目录
    - _Requirements: 3.1, 3.2_

- [x] 8. 迁移 feed_worker 到 pkg
  - [x] 8.1 重构 feed_worker/cmd/worker/main.go
    - 使用 pkg/app 和 pkg/broker
    - _Requirements: 2.7, 2.8_
  - [x] 8.2 删除 feed_worker 内部重复实现
    - 删除 `internal/broker/` 和 `internal/database/` 目录
    - _Requirements: 3.1, 3.2_

- [x] 9. 迁移 notification_worker 到 pkg
  - [x] 9.1 重构 notification_worker/cmd/worker/main.go
    - 使用 pkg/app 和 pkg/broker
    - _Requirements: 2.9, 2.10_
  - [x] 9.2 删除 notification_worker 内部重复实现
    - 删除 `internal/broker/` 和 `internal/database/` 目录
    - _Requirements: 3.1, 3.2_

- [x] 10. 迁移 post_worker 到 pkg
  - [x] 10.1 重构 post_worker/cmd/worker/main.go
    - 使用 pkg/app 和 pkg/broker
    - _Requirements: 2.11, 2.12_
  - [x] 10.2 删除 post_worker 内部重复实现
    - 删除 `internal/broker/` 和 `internal/database/` 目录
    - _Requirements: 3.1, 3.2_

- [x] 11. 迁移 search_worker 到 pkg
  - [x] 11.1 重构 search_worker/cmd/worker/main.go
    - 使用 pkg/app 和 pkg/broker
    - _Requirements: 2.13, 2.14_
  - [x] 11.2 删除 search_worker 内部重复实现
    - 删除 `internal/broker/` 和 `internal/database/` 目录
    - _Requirements: 3.1, 3.2_

- [x] 12. 迁移 user_worker 到 pkg
  - [x] 12.1 重构 user_worker/cmd/worker/main.go
    - 使用 pkg/app 和 pkg/broker
    - _Requirements: 2.15, 2.16_
  - [x] 12.2 删除 user_worker 内部重复实现
    - 删除 `internal/broker/` 和 `internal/database/` 目录
    - _Requirements: 3.1, 3.2_

- [x] 13. Checkpoint - 确保所有 Worker 编译通过
  - 运行 `go build ./...` 在 service 目录
  - 确保所有 Worker 编译成功，如有问题请询问用户

- [ ]* 14. 编写 Worker 组件统一性验证测试
  - **Property 1: Worker 组件统一性**
  - 验证所有 Worker 的 main.go 导入 pkg/app 和 pkg/broker
  - 验证没有 Worker 包含 internal/broker 或 internal/database
  - **Validates: Requirements 2.1-2.16, 3.1, 3.2**

- [x] 15. 清理冗余文件
  - [x] 15.1 删除各 Worker 的 tmp 目录
    - 删除 `auth_worker/tmp/`
    - 删除 `chat_worker/tmp/`
    - 删除 `feed_worker/tmp/`
    - 删除 `notification_worker/tmp/`
    - 删除 `post_worker/tmp/`
    - 删除 `search_worker/tmp/`
    - 删除 `user_worker/tmp/`
    - 删除 `gateway/tmp/`
    - _Requirements: 3.3_
  - [ ] 15.2 检查并清理重复的 proto 生成文件
    - 比较各服务中的 proto 生成文件
    - 如有重复，统一到一个位置
    - _Requirements: 3.4_

- [x] 16. Django 删除验证
  - [x] 16.1 验证 API 端点迁移完成
    - 检查 Django 中的所有 API 端点
    - 确认每个端点在 Go 服务中有对应实现
    - _Requirements: 6.1_
  - [x] 16.2 验证数据库迁移完成
    - 确认所有数据库表结构已在 Go 服务中定义
    - _Requirements: 6.2_
  - [x] 16.3 验证 Worker 功能迁移完成
    - 确认所有 Celery 任务已迁移到 Go Worker
    - _Requirements: 6.3_
  - [x] 16.4 删除 Django 服务
    - 删除 `service/core_django/` 目录
    - 更新 `docker-compose.yml` 移除 Django 服务
    - _Requirements: 6.4, 6.5_

- [x] 17. 最终验证
  - [x] 17.1 运行所有单元测试
    - 执行 `go test ./...` 在 service 目录
    - 确保所有测试通过
    - _Requirements: 7.1_
  - [x] 17.2 验证所有服务构建成功
    - 执行 `go build ./...` 在 service 目录
    - 确保无编译错误
    - _Requirements: 7.2_
  - [x] 17.3 验证 Docker Compose 启动
    - 执行 `docker-compose up -d`
    - 确保所有服务启动成功
    - _Requirements: 7.3_
  - [ ] 17.4 验证服务健康检查
    - 检查各服务的健康检查端点
    - 确保所有服务报告健康状态
    - _Requirements: 7.4_
  - [x] 17.5 验证服务间通信
    - 测试 Gateway 到 Worker 的消息流
    - 测试 gRPC 服务间调用
    - _Requirements: 7.5_

- [x] 18. Final Checkpoint - 确保所有验证通过
  - 确认所有测试通过
  - 确认所有服务正常运行
  - 如有问题请询问用户

## Notes

- 标记 `*` 的任务为可选测试任务，可跳过以加快 MVP 进度
- 每个 Checkpoint 是验证点，确保前面的工作正确完成
- Worker 迁移可以并行进行，但建议先完成 auth_worker 作为模板
- Django 删除是不可逆操作，务必在验证完成后再执行
- 属性测试验证核心正确性属性，建议保留
