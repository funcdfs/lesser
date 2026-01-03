# service/pkg - 共享公共库

为 Lesser 项目所有 Go 微服务提供统一的基础设施代码。

## 📦 包列表

| 包名 | 说明 | 使用场景 |
|------|------|----------|
| `app` | 应用生命周期管理 | 服务启动、优雅关闭、组件注册 |
| `auth` | JWT 认证、密码哈希 | 用户认证、Token 管理 |
| `broker` | RabbitMQ 消息队列 | 异步任务、事件发布 |
| `cache` | Redis 客户端封装 | 缓存、分布式锁、Pub/Sub |
| `config` | 环境变量配置 | 配置读取 |
| `convert` | 类型转换工具 | 指针转换、切片操作 |
| `database` | PostgreSQL 连接 | 数据库操作、事务管理 |
| `errors` | 统一错误处理 | gRPC 错误、业务错误 |
| `grpcclient` | gRPC 客户端连接池 | 服务间调用 |
| `grpcserver` | gRPC 服务器封装 | 服务启动、健康检查 |
| `health` | 健康检查 | 服务健康状态 |
| `id` | ID 生成 | UUID、雪花 ID |
| `logger` | 日志封装 | 结构化日志、链路追踪 |
| `middleware` | gRPC 中间件 | 日志、恢复、限流 |
| `pagination` | 分页处理 | 偏移分页、游标分页 |
| `retry` | 重试机制 | 指数退避、错误重试 |
| `timeutil` | 时间工具 | 格式化、时区转换 |
| `validator` | 参数验证 | 字段验证、gRPC 错误 |

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
    "github.com/funcdfs/lesser/pkg/logger"
)

func main() {
    // 创建应用
    cfg := app.ConfigFromEnv("my-service")
    application, err := app.New(cfg)
    if err != nil {
        panic(err)
    }

    // 获取组件
    log := application.Logger()
    db := application.DB()
    cache := application.Cache()

    log.Info("服务启动中...")

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

### cache - Redis 缓存

```go
import "github.com/funcdfs/lesser/pkg/cache"

// 基础操作
client.Set(ctx, "key", value, time.Hour)
client.Get(ctx, "key", &target)
client.Delete(ctx, "key")

// 分布式锁
lock := cache.NewDistributedLock(client, "resource", 30*time.Second)
lock.Lock(ctx)
defer lock.Unlock(ctx)

// Hash 操作
client.HSet(ctx, "user:123", "name", "张三", "age", 25)
client.HGet(ctx, "user:123", "name")

// 有序集合
client.ZAdd(ctx, "leaderboard", redis.Z{Score: 100, Member: "user1"})
```

### database - 数据库

```go
import "github.com/funcdfs/lesser/pkg/database"

// 事务
database.WithTransaction(ctx, db, func(tx *sql.Tx) error {
    // 在事务中执行操作
    return nil
})

// 批量插入
builder := database.NewBatchInsert("users", "id", "name", "email")
builder.Add("1", "张三", "zhang@example.com")
builder.Add("2", "李四", "li@example.com")
builder.Execute(ctx, db)
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

### validator - 参数验证

```go
import "github.com/funcdfs/lesser/pkg/validator"

// 链式验证
v := validator.New()
v.Required("username", req.Username).
  Username("username", req.Username).
  Required("email", req.Email).
  Email("email", req.Email).
  Password("password", req.Password)

if v.HasErrors() {
    return v.ToGRPCError()
}

// 快捷验证
if err := validator.ValidateUUID("user_id", userID); err != nil {
    return err
}
```

### middleware - gRPC 中间件

```go
import "github.com/funcdfs/lesser/pkg/middleware"

// 创建服务器
server := grpc.NewServer(
    grpc.ChainUnaryInterceptor(
        middleware.RecoveryInterceptor(log),
        middleware.TraceInterceptor(),
        middleware.LoggingInterceptor(log),
    ),
)

// 限流
limiter := middleware.NewPerKeyRateLimiter(100, 200)
interceptor := middleware.RateLimitInterceptor(limiter, middleware.UserIDKeyExtractor)
```

### pagination - 分页

```go
import "github.com/funcdfs/lesser/pkg/pagination"

// 偏移分页
req := pagination.NewPageRequest(page, pageSize)
offset, limit := req.Offset(), req.Limit()
resp := pagination.NewPageResponse(page, pageSize, total)

// 游标分页
cursor := pagination.EncodeIDCursor(lastID, lastCreatedAt)
id, createdAt, _ := pagination.DecodeIDCursor(cursor)
```

### retry - 重试

```go
import "github.com/funcdfs/lesser/pkg/retry"

// 带重试执行
err := retry.Do(ctx, func() error {
    return someOperation()
}, 
    retry.WithMaxRetries(3),
    retry.WithInitialDelay(100*time.Millisecond),
)

// 带返回值
result, err := retry.DoWithResult(ctx, func() (string, error) {
    return fetchData()
})
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
