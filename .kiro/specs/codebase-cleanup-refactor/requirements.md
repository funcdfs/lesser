# Requirements Document

## Introduction

本规范定义了代码库清理和重构的需求，目标是：
1. 保持根目录整洁，将错误放置的文件移动到正确位置
2. 统一所有 Worker 服务使用共享的 `pkg` 库
3. 扩展 `pkg` 库功能（Redis 缓存、gRPC 客户端）
4. 验证迁移完成后安全删除 Django 服务

## Glossary

- **Worker**: 消费 RabbitMQ 消息队列的后台服务（auth_worker, chat_worker, feed_worker 等）
- **pkg**: 位于 `service/pkg/` 的共享 Go 库，提供通用功能封装
- **Gateway**: 位于根目录 `/gateway` 的 protobuf 生成文件（需移动到 `service/` 下）
- **Redis_Cache**: 需要添加到 pkg 的 Redis 缓存封装模块
- **gRPC_Client**: 需要添加到 pkg 的 gRPC 客户端封装模块
- **Django_Service**: 位于 `service/core_django/` 的遗留 Python 服务

## Requirements

### Requirement 1: 根目录清理

**User Story:** 作为开发者，我希望根目录保持整洁，只包含顶层配置文件，以便更容易理解项目结构。

#### Acceptance Criteria

1. WHEN 检查根目录时 THE File_System SHALL 不包含 `/gateway` 目录
2. WHEN 检查根目录时 THE File_System SHALL 不包含任何属于 service 的代码文件
3. WHEN `/gateway` 目录被移动后 THE Gateway_Files SHALL 位于 `service/gateway/proto/` 或合适的子目录下
4. IF 移动文件导致导入路径变化 THEN THE Build_System SHALL 更新所有相关的 import 语句

### Requirement 2: Worker 服务迁移到 pkg

**User Story:** 作为开发者，我希望所有 Worker 服务使用统一的 `pkg` 库，以减少代码重复并确保一致的行为。

#### Acceptance Criteria

1. WHEN auth_worker 启动时 THE Worker SHALL 使用 `pkg/app` 进行生命周期管理
2. WHEN auth_worker 启动时 THE Worker SHALL 使用 `pkg/broker` 进行消息消费
3. WHEN auth_worker 启动时 THE Worker SHALL 使用 `pkg/database` 进行数据库连接
4. WHEN auth_worker 启动时 THE Worker SHALL 使用 `pkg/logger` 进行日志记录
5. WHEN chat_worker 启动时 THE Worker SHALL 使用 `pkg/app` 进行生命周期管理
6. WHEN chat_worker 启动时 THE Worker SHALL 使用 `pkg/broker` 进行消息消费
7. WHEN feed_worker 启动时 THE Worker SHALL 使用 `pkg/app` 进行生命周期管理
8. WHEN feed_worker 启动时 THE Worker SHALL 使用 `pkg/broker` 进行消息消费
9. WHEN notification_worker 启动时 THE Worker SHALL 使用 `pkg/app` 进行生命周期管理
10. WHEN notification_worker 启动时 THE Worker SHALL 使用 `pkg/broker` 进行消息消费
11. WHEN post_worker 启动时 THE Worker SHALL 使用 `pkg/app` 进行生命周期管理
12. WHEN post_worker 启动时 THE Worker SHALL 使用 `pkg/broker` 进行消息消费
13. WHEN search_worker 启动时 THE Worker SHALL 使用 `pkg/app` 进行生命周期管理
14. WHEN search_worker 启动时 THE Worker SHALL 使用 `pkg/broker` 进行消息消费
15. WHEN user_worker 启动时 THE Worker SHALL 使用 `pkg/app` 进行生命周期管理
16. WHEN user_worker 启动时 THE Worker SHALL 使用 `pkg/broker` 进行消息消费

### Requirement 3: 清理冗余文件

**User Story:** 作为开发者，我希望删除不再需要的重复代码和文件，以保持代码库精简。

#### Acceptance Criteria

1. WHEN Worker 迁移完成后 THE File_System SHALL 不包含各 Worker 内部重复的 broker 实现
2. WHEN Worker 迁移完成后 THE File_System SHALL 不包含各 Worker 内部重复的 database 实现
3. WHEN 检查代码库时 THE File_System SHALL 不包含未使用的临时文件（如 `tmp/` 目录下的构建产物）
4. WHEN 检查代码库时 THE File_System SHALL 不包含重复的 proto 生成文件

### Requirement 4: 添加 Redis 缓存封装

**User Story:** 作为开发者，我希望有统一的 Redis 缓存封装，以便在各服务中一致地使用缓存功能。

#### Acceptance Criteria

1. THE Redis_Cache SHALL 提供连接池管理功能
2. THE Redis_Cache SHALL 支持自动重连机制
3. THE Redis_Cache SHALL 提供 Get、Set、Delete 基础操作
4. THE Redis_Cache SHALL 支持设置过期时间
5. THE Redis_Cache SHALL 支持 JSON 序列化和反序列化
6. THE Redis_Cache SHALL 从环境变量读取配置（REDIS_URL 或 REDIS_HOST/PORT/PASSWORD）
7. WHEN 连接失败时 THE Redis_Cache SHALL 记录错误日志并返回明确的错误信息
8. THE Redis_Cache SHALL 集成到 `pkg/app` 的生命周期管理中

### Requirement 5: 添加 gRPC 客户端封装

**User Story:** 作为开发者，我希望有统一的 gRPC 客户端封装，以便服务间通信时有一致的连接管理和错误处理。

#### Acceptance Criteria

1. THE gRPC_Client SHALL 提供连接池管理功能
2. THE gRPC_Client SHALL 支持自动重连机制
3. THE gRPC_Client SHALL 支持拦截器（用于日志、追踪、认证）
4. THE gRPC_Client SHALL 自动传递 trace_id 到下游服务
5. THE gRPC_Client SHALL 从环境变量读取服务地址配置
6. WHEN 调用失败时 THE gRPC_Client SHALL 提供统一的错误处理和重试逻辑
7. THE gRPC_Client SHALL 集成到 `pkg/app` 的生命周期管理中

### Requirement 6: Django 服务删除验证

**User Story:** 作为开发者，我希望在确认所有功能已迁移后安全删除 Django 服务，以简化技术栈。

#### Acceptance Criteria

1. WHEN 准备删除 Django 时 THE Verification_Process SHALL 确认所有 API 端点已在 Go 服务中实现
2. WHEN 准备删除 Django 时 THE Verification_Process SHALL 确认所有数据库迁移已应用
3. WHEN 准备删除 Django 时 THE Verification_Process SHALL 确认所有 Worker 功能已迁移
4. WHEN Django 被删除后 THE File_System SHALL 不包含 `service/core_django/` 目录
5. WHEN Django 被删除后 THE Docker_Compose SHALL 不包含 Django 相关服务定义
6. IF 删除 Django 后发现问题 THEN THE System SHALL 能够从版本控制恢复

### Requirement 7: 最终验证

**User Story:** 作为开发者，我希望有完整的验证流程确保重构后系统正常工作。

#### Acceptance Criteria

1. WHEN 运行验证时 THE Test_Suite SHALL 执行所有单元测试并通过
2. WHEN 运行验证时 THE Build_System SHALL 成功构建所有 Go 服务
3. WHEN 运行验证时 THE Docker_Compose SHALL 成功启动所有服务
4. WHEN 运行验证时 THE Health_Check SHALL 确认所有服务健康
5. WHEN 运行验证时 THE Integration_Test SHALL 验证服务间通信正常
