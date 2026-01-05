# service/pkg - 共享公共库

为 Lesser 项目所有 Go 微服务提供统一的基础设施代码。

## 📦 包列表

| 包名 | 说明 | 使用场景 |
|------|------|----------|
| `app` | 应用生命周期管理 | 服务启动、优雅关闭、组件注册 |
| `auth` | JWT 认证、密码哈希 | 用户认证、Token 管理 |
| `config` | 环境变量配置 | 配置读取 |
| `db` | 数据存储封装 | PostgreSQL、Redis、分布式锁 |
| `errors` | 统一错误处理 | gRPC 错误、业务错误 |
| `grpc/client` | gRPC 客户端连接池 | 服务间调用、自动重连 |
| `grpc/server` | gRPC 服务器封装 | 服务启动、健康检查 |
| `grpc/interceptor` | gRPC 拦截器 | 日志、追踪、恢复、限流 |
| `health` | 健康检查 | 服务健康状态 |
| `id` | ID 生成 | UUID、雪花 ID |
| `log` | 日志封装 | 结构化日志、链路追踪 |
| `mq` | 消息队列 | RabbitMQ 发布/订阅 |
| `page` | 分页处理 | 偏移分页、游标分页 |
| `trace` | 分布式追踪 | OpenTelemetry/Jaeger |
| `validate` | 参数验证 | 字段验证、gRPC 错误 |

## 🔄 迁移说明

本次重构对 pkg 包结构进行了优化，以下是主要变更：

| 旧包名 | 新包名 | 说明 |
|--------|--------|------|
| `grpcclient` | `grpc/client` | 统一 gRPC 相关代码 |
| `grpcserver` | `grpc/server` | 统一 gRPC 相关代码 |
| `middleware` | `grpc/interceptor` | 更清晰的命名 |
| `database` | `db` | 简化命名 |
| `cache` | `db` | 合并到数据存储包 |
| `broker` | `mq` | 更清晰的命名 |
| `tracing` | `trace` | 更简洁 |
| `logger` | `log` | 更简洁 |
| `validator` | `validate` | 动词形式更符合 Go 惯例 |
| `pagination` | `page` | 更简洁 |
| `convert` | 已删除 | 使用标准库或泛型替代 |
| `timeutil` | 已删除 | 使用标准库 time 替代 |
| `retry` | `grpc/client` | 合并到客户端包 |

## 🚀 快速开始

### 安装

```go
import "github.com/funcdfs/lesser/pkg"
```

### 基础用法

```go
package main

import (
    "context"
    "github.com/funcdfs/lesser/pkg/app"
    "github.com/funcdfs/lesser/pkg/log"
)

func main() {
    // 创建应用
    cfg := app.ConfigFromEnv("my-service")
    application, err := app.New(cfg)
    if err != nil {
        panic(err)
    }

    // 获取组件
    logger := application.Logger()
    db := application.DB()
    cache := application.Cache()

    logger.Info("服务启动中...")

    // 运行应用
    application.Run(context.Background())
}
```

## 📚 详细文档

### auth - 认证模块

```go
import "github.com/funcdfs/lesser/pkg/auth"

// 密码哈希
hasher := auth.DefaultPasswordHasher()
hash, _ := hasher.Hash("password123")
match, _ := hasher.Verify("password123", hash)

// JWT 管理
manager := auth.NewJWTManager(privateKey, publicKey, "key-id", auth.DefaultTokenConfig())
pair, _ := manager.GenerateTokenPair(ctx, userID, username, email, role)
claims, _ := manager.ValidateToken(pair.AccessToken)

// 上下文操作
ctx = auth.ContextWithUserID(ctx, "user-123")
userID := auth.UserIDFromContext(ctx)
```

### db - 数据存储

```go
import "github.com/funcdfs/lesser/pkg/db"

// PostgreSQL 连接
cfg := db.PostgresConfigFromEnv()
conn, err := db.NewPostgresConnection(cfg)

// 事务管理
db.WithTransaction(ctx, conn, func(tx *sql.Tx) error {
    // 在事务中执行操作
    return nil
})

// Redis 连接
redisCfg := db.RedisConfigFromEnv()
client, err := db.NewRedisClient(redisCfg)

// 基础操作
client.Set(ctx, "key", value, time.Hour)
client.Get(ctx, "key", &target)
client.Delete(ctx, "key")

// 分布式锁
lock := db.NewDistributedLock(client, "resource", 30*time.Second)
lock.Lock(ctx)
defer lock.Unlock(ctx)

// 带重试的锁获取
lock.TryLock(ctx, 5*time.Second, 100*time.Millisecond)

// 在锁保护下执行
lock.WithLock(ctx, func() error {
    // 临界区代码
    return nil
})

// Hash 操作
client.HSet(ctx, "user:123", "name", "张三", "age", 25)
client.HGet(ctx, "user:123", "name")

// 有序集合
client.ZAdd(ctx, "leaderboard", redis.Z{Score: 100, Member: "user1"})
```

### grpc/client - gRPC 客户端

```go
import "github.com/funcdfs/lesser/pkg/grpc/client"

// 创建连接池
pool := client.NewPool(logger)

// 注册服务
pool.Register("auth", client.Config{
    Target:       "auth:50052",
    Insecure:     true,
    MaxRetries:   3,
    RetryBackoff: 100 * time.Millisecond,
})

// 或从环境变量注册
pool.RegisterFromEnv("auth")

// 获取连接
conn, err := pool.GetConn(ctx, "auth")
authClient := pb.NewAuthServiceClient(conn)

// 关闭连接池
defer pool.Close()
```

### grpc/server - gRPC 服务器

```go
import (
    "github.com/funcdfs/lesser/pkg/grpc/server"
    "github.com/funcdfs/lesser/pkg/grpc/interceptor"
)

// 创建服务器
srv := server.New(logger, server.WithConfig(server.Config{
    Port:              50052,
    EnableReflection:  true,
    EnableHealthCheck: true,
}))

// 构建 gRPC 服务器（自动添加默认拦截器）
grpcServer := srv.Build(nil, nil)

// 注册服务
pb.RegisterAuthServiceServer(grpcServer, handler)

// 启动服务器
go srv.Start()

// 优雅停止
srv.StopWithTimeout(10 * time.Second)
```

### grpc/interceptor - gRPC 拦截器

```go
import "github.com/funcdfs/lesser/pkg/grpc/interceptor"

// 创建服务器（手动配置拦截器）
server := grpc.NewServer(
    grpc.ChainUnaryInterceptor(
        interceptor.RecoveryInterceptor(logger),
        interceptor.TraceInterceptor(),
        interceptor.LoggingInterceptor(logger),
        interceptor.RateLimitInterceptor(limiter, interceptor.UserIDKeyExtractor),
    ),
    grpc.ChainStreamInterceptor(
        interceptor.StreamRecoveryInterceptor(logger),
        interceptor.StreamTraceInterceptor(),
        interceptor.StreamLoggingInterceptor(logger),
    ),
)

// 限流器
limiter := interceptor.NewPerKeyRateLimiter(100, 200)
```

### log - 日志

```go
import "github.com/funcdfs/lesser/pkg/log"

// 创建 Logger
logger := log.New("my-service")

// 基础日志
logger.Info("操作完成", slog.String("user_id", userID))
logger.Error("操作失败", slog.Any("error", err))

// 带上下文的日志（自动注入 trace_id）
logger.WithContext(ctx).Info("处理请求")

// 上下文操作
ctx = log.ContextWithTraceID(ctx, "trace-123")
ctx = log.ContextWithUserID(ctx, "user-456")
traceID := log.TraceIDFromContext(ctx)

// 结构化日志辅助
logger.LogOperation(ctx, "create_user", log.Fields{
    "username": "test",
    "email":    "test@example.com",
})

logger.LogDuration(ctx, "query_users", startTime, log.Fields{
    "count": 100,
})

// 全局 Logger
log.SetGlobal(logger)
log.Info("全局日志")
```

### mq - 消息队列

```go
import "github.com/funcdfs/lesser/pkg/mq"

// 创建发布者
publisher := mq.NewPublisher(rabbitURL, logger)
if err := publisher.Connect(); err != nil {
    panic(err)
}
defer publisher.Close()

// 同步发布（带 TraceID 传播）
err := publisher.Publish(ctx, "content.liked", mq.ContentLikedEvent{
    ContentID: "123",
    UserID:    "456",
})

// 异步发布
publisher.PublishAsync(ctx, "user.followed", event)

// 创建消费者
worker := mq.NewWorker(rabbitURL, logger)
if err := worker.Connect(); err != nil {
    panic(err)
}

// 注册处理器
worker.RegisterHandler("content.liked", func(ctx context.Context, body []byte) error {
    // 处理消息（ctx 中包含 trace_id）
    return nil
})

// 启动消费
worker.Start(ctx)
```

### trace - 分布式追踪

```go
import "github.com/funcdfs/lesser/pkg/trace"

// 初始化追踪
cfg := trace.DefaultConfig("my-service")
shutdown, err := trace.Init(ctx, cfg)
if err != nil {
    panic(err)
}
defer shutdown(ctx)

// 创建 Span
ctx, span := trace.StartSpan(ctx, "process_request")
defer span.End()

// 设置属性
trace.SetSpanAttributes(span,
    attribute.String("user_id", userID),
    attribute.Int("item_count", count),
)

// 记录错误
trace.RecordError(span, err)

// 从 context 获取 TraceID
traceID := trace.TraceIDFromContext(ctx)
```

### page - 分页

```go
import "github.com/funcdfs/lesser/pkg/page"

// 偏移分页
req := page.NewRequest(1, 20)
offset, limit := req.Offset(), req.Limit()
resp := page.NewResponse(1, 20, 100)

// 游标分页
cursor := page.EncodeIDCursor(lastID, lastCreatedAt)
id, createdAt, _ := page.DecodeIDCursor(cursor)

// 游标请求
cursorReq := page.NewCursorRequest(cursor, 20)
cursorResp := page.NewCursorResponse(nextCursor, hasMore)
```

### validate - 参数验证

```go
import "github.com/funcdfs/lesser/pkg/validate"

// 链式验证
v := validate.New()
v.Required("username", req.Username).
  Username("username", req.Username).
  Required("email", req.Email).
  Email("email", req.Email).
  Password("password", req.Password)

if v.HasErrors() {
    return v.ToGRPCError()
}

// 快捷验证
if err := validate.UUID("user_id", userID); err != nil {
    return err
}

if err := validate.Required("content", content); err != nil {
    return err
}

// 分页参数验证
page, pageSize := validate.Pagination(req.Page, req.PageSize)
```

### errors - 错误处理

```go
import "github.com/funcdfs/lesser/pkg/errors"

// 预定义错误
if err == errors.ErrNotFound {
    return errors.ErrUserNotFound.ToGRPC()
}

// 自定义错误
err := errors.New(codes.InvalidArgument, "参数无效")
err = err.WithMessagef("用户 %s 不存在", userID)

// 错误检查
if errors.IsNotFound(err) {
    // 处理 NotFound
}
```

## ⚠️ 注意事项

1. **不要在 pkg 中放置只有单个服务使用的代码**
2. **修改 pkg 代码需要考虑对所有服务的影响**
3. **新增功能需要添加对应的文档和示例**
4. **保持向后兼容，避免破坏性变更**

## 🔧 开发指南

### 添加新包

1. 在 `service/pkg/` 下创建新目录
2. 添加包文档注释
3. 实现功能并添加测试
4. 更新本 README

### 代码规范

- 所有注释使用中文
- 导出函数必须有文档注释
- 错误信息使用中文
- 遵循 Go 标准库风格

### 包命名规范

遵循 Go 官方包命名最佳实践：

1. **简短**: 使用简短、清晰的名称（`db` 而非 `database`）
2. **小写**: 全部小写，无下划线或驼峰
3. **单数**: 使用单数形式
4. **动词/名词**: 根据功能选择（`validate` 动词，`config` 名词）
5. **避免通用名**: 不使用 `util`、`common`、`misc` 等

## 📁 目录结构

```
service/pkg/
├── app/                    # 应用生命周期管理
│   └── app.go
├── auth/                   # 认证模块
│   ├── jwt.go              # JWT 管理
│   ├── password.go         # 密码哈希
│   └── context.go          # 认证上下文
├── config/                 # 配置管理
│   └── config.go
├── db/                     # 数据存储
│   ├── postgres.go         # PostgreSQL
│   ├── redis.go            # Redis
│   ├── lock.go             # 分布式锁
│   ├── batch.go            # 批量操作
│   └── config.go           # 配置
├── errors/                 # 错误处理
│   └── errors.go
├── grpc/                   # gRPC 相关
│   ├── client/             # 客户端
│   │   ├── pool.go         # 连接池
│   │   ├── config.go       # 配置
│   │   └── interceptor.go  # 客户端拦截器
│   ├── server/             # 服务端
│   │   └── server.go       # 服务器封装
│   └── interceptor/        # 通用拦截器
│       ├── recovery.go     # panic 恢复
│       ├── logging.go      # 日志
│       ├── trace.go        # 链路追踪
│       └── ratelimit.go    # 限流
├── health/                 # 健康检查
│   └── health.go
├── id/                     # ID 生成
│   ├── id.go               # UUID
│   └── snowflake.go        # 雪花 ID
├── log/                    # 日志
│   └── logger.go           # 结构化日志
├── mq/                     # 消息队列
│   ├── publisher.go        # 发布者
│   ├── worker.go           # 消费者
│   └── events.go           # 事件定义
├── page/                   # 分页
│   └── pagination.go
├── trace/                  # 分布式追踪
│   └── tracer.go           # OpenTelemetry
├── validate/               # 参数验证
│   └── validator.go
├── gen_protos/             # 生成的 proto
│   └── common/
├── pkg_test/               # 测试文件
│   ├── errors_property_test.go
│   ├── service_communication_test.go
│   └── structure_property_test.go
├── go.mod
└── go.sum
```
