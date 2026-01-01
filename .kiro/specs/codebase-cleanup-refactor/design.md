# Design Document: Codebase Cleanup and Refactor

## Overview

本设计文档描述了代码库清理和重构的技术方案，包括：
1. 根目录清理 - 移动错误放置的文件
2. Worker 服务统一化 - 迁移到共享 `pkg` 库
3. 扩展 `pkg` 功能 - 添加 Redis 缓存和 gRPC 客户端封装
4. Django 服务删除 - 验证并安全移除遗留服务

## Architecture

### 当前架构问题

```
/                           # 根目录
├── gateway/                # ❌ 错误位置：应在 service/ 下
│   ├── gateway.pb.go
│   └── gateway_grpc.pb.go
├── service/
│   ├── auth_worker/
│   │   └── internal/
│   │       ├── broker/     # ❌ 重复实现
│   │       └── database/   # ❌ 重复实现
│   ├── chat_worker/        # ❌ 同样有重复实现
│   ├── feed_worker/        # ❌ 同样有重复实现
│   ├── ...
│   └── pkg/                # ✅ 共享库（已创建）
└── ...
```

### 目标架构

```
/                           # 根目录（保持整洁）
├── service/
│   ├── auth_worker/
│   │   ├── cmd/worker/main.go    # 简化的入口
│   │   └── internal/
│   │       ├── service/          # 业务逻辑
│   │       └── worker/           # Worker 处理器
│   ├── chat_worker/              # 同样结构
│   ├── feed_worker/              # 同样结构
│   ├── gateway/
│   │   └── proto/                # 移动后的 proto 生成文件
│   └── pkg/                      # 共享库
│       ├── app/                  # 应用生命周期
│       ├── broker/               # RabbitMQ 封装
│       ├── cache/                # Redis 缓存（新增）
│       ├── config/               # 配置管理
│       ├── database/             # PostgreSQL 封装
│       ├── grpc/                 # gRPC 客户端（新增）
│       └── logger/               # 日志封装
└── ...
```

## Components and Interfaces

### 1. pkg/cache - Redis 缓存封装

基于现有 `chat_gin/pkg/cache` 的实现，提取到共享 `pkg` 中。

```go
// pkg/cache/redis.go
package cache

import (
    "context"
    "time"
    "github.com/redis/go-redis/v9"
)

// Config Redis 配置
type Config struct {
    // URL Redis 连接 URL，优先使用
    URL string
    // 以下字段在 URL 为空时使用
    Host     string
    Port     string
    Password string
    DB       int
    // 连接池配置
    PoolSize     int
    MinIdleConns int
}

// ConfigFromEnv 从环境变量读取配置
func ConfigFromEnv() Config

// Client Redis 客户端封装
type Client struct {
    client *redis.Client
}

// NewClient 创建新的 Redis 客户端
func NewClient(cfg Config) (*Client, error)

// Close 关闭连接
func (c *Client) Close() error

// Get 获取值并反序列化到 target
func (c *Client) Get(ctx context.Context, key string, target interface{}) error

// Set 序列化并存储值
func (c *Client) Set(ctx context.Context, key string, value interface{}, expiration time.Duration) error

// Delete 删除键
func (c *Client) Delete(ctx context.Context, keys ...string) error

// Exists 检查键是否存在
func (c *Client) Exists(ctx context.Context, key string) (bool, error)

// SetNX 仅当键不存在时设置（用于分布式锁）
func (c *Client) SetNX(ctx context.Context, key string, value interface{}, expiration time.Duration) (bool, error)

// GetClient 返回底层 Redis 客户端
func (c *Client) GetClient() *redis.Client

// 错误定义
var ErrKeyNotFound = errors.New("key not found")
```

### 2. pkg/grpc - gRPC 客户端封装

```go
// pkg/grpc/client.go
package grpc

import (
    "context"
    "google.golang.org/grpc"
)

// ClientConfig gRPC 客户端配置
type ClientConfig struct {
    // Target 服务地址
    Target string
    // Insecure 是否使用不安全连接
    Insecure bool
    // Timeout 连接超时
    Timeout time.Duration
    // MaxRetries 最大重试次数
    MaxRetries int
    // RetryBackoff 重试退避时间
    RetryBackoff time.Duration
}

// ClientPool gRPC 客户端连接池
type ClientPool struct {
    conns   map[string]*grpc.ClientConn
    configs map[string]ClientConfig
    mu      sync.RWMutex
    log     *logger.Logger
}

// NewClientPool 创建客户端连接池
func NewClientPool(log *logger.Logger) *ClientPool

// Register 注册服务配置
func (p *ClientPool) Register(name string, cfg ClientConfig)

// GetConn 获取服务连接
func (p *ClientPool) GetConn(ctx context.Context, name string) (*grpc.ClientConn, error)

// Close 关闭所有连接
func (p *ClientPool) Close() error
```

### 3. pkg/grpc - 拦截器

```go
// pkg/grpc/interceptors.go
package grpc

import (
    "context"
    "google.golang.org/grpc"
)

// TraceInterceptor 创建 trace_id 传递拦截器
func TraceInterceptor() grpc.UnaryClientInterceptor

// LoggingInterceptor 创建日志拦截器
func LoggingInterceptor(log *logger.Logger) grpc.UnaryClientInterceptor

// RetryInterceptor 创建重试拦截器
func RetryInterceptor(maxRetries int, backoff time.Duration) grpc.UnaryClientInterceptor
```

### 4. pkg/app - 扩展生命周期管理

更新 `pkg/app` 以支持 Redis 和 gRPC：

```go
// pkg/app/app.go (扩展)
type App struct {
    name       string
    log        *logger.Logger
    db         *sql.DB
    worker     *broker.Worker
    cache      *cache.Client      // 新增
    grpcPool   *grpc.ClientPool   // 新增
    components []Component
    mu         sync.Mutex
}

type Config struct {
    Name        string
    RabbitMQURL string
    Database    database.Config
    Redis       cache.Config       // 新增
    EnableRedis bool               // 新增
    EnableGRPC  bool               // 新增
}

// Cache 返回 Redis 客户端
func (a *App) Cache() *cache.Client

// GRPCPool 返回 gRPC 连接池
func (a *App) GRPCPool() *grpc.ClientPool
```

### 5. Worker 迁移模式

迁移后的 Worker 代码结构：

```go
// service/auth_worker/cmd/worker/main.go
package main

import (
    "context"
    "github.com/lesser/pkg/app"
    "github.com/lesser/pkg/broker"
    "github.com/lesser/auth_worker/internal/service"
)

func main() {
    ctx := context.Background()

    // 1. 从环境变量初始化配置
    cfg := app.ConfigFromEnv("auth-worker")
    
    // 2. 创建应用实例
    application, err := app.New(cfg)
    if err != nil {
        panic(err)
    }

    // 3. 创建业务服务
    authSvc := service.NewAuthService(application.DB(), application.Logger())

    // 4. 配置队列消费
    brokerConfigs := []broker.Config{
        {Queue: "auth.register", Handler: authSvc.HandleRegister},
        {Queue: "auth.login", Handler: authSvc.HandleLogin},
    }

    // 5. 启动应用
    if err := application.Run(ctx, brokerConfigs...); err != nil {
        panic(err)
    }
}
```

## Data Models

### Redis 缓存键设计

| 键模式 | 用途 | TTL |
|--------|------|-----|
| `unread:{user_id}:{conv_id}` | 未读消息数 | 24h |
| `session:{token}` | 用户会话 | 7d |
| `rate:{user_id}:{action}` | 速率限制 | 1min |

### 环境变量配置

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `REDIS_URL` | - | Redis 连接 URL（优先） |
| `REDIS_HOST` | `localhost` | Redis 主机 |
| `REDIS_PORT` | `6379` | Redis 端口 |
| `REDIS_PASSWORD` | - | Redis 密码 |
| `REDIS_DB` | `0` | Redis 数据库编号 |
| `GRPC_AUTH_ADDR` | `auth:50051` | Auth 服务 gRPC 地址 |
| `GRPC_USER_ADDR` | `user:50051` | User 服务 gRPC 地址 |

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Worker 组件统一性

*For any* Worker 服务，其 main.go 文件应该导入并使用 `github.com/lesser/pkg/app`、`github.com/lesser/pkg/broker` 等共享组件，而不是内部重复实现。

**Validates: Requirements 2.1-2.16**

### Property 2: Redis 缓存 Round-Trip 一致性

*For any* 可 JSON 序列化的 Go 值 `v`，执行 `Set(key, v)` 然后 `Get(key, &result)` 后，`result` 应该等于 `v`。

**Validates: Requirements 4.3, 4.5**

### Property 3: gRPC Trace ID 传递

*For any* 带有 `trace_id` 的 `context.Context`，通过 gRPC 客户端发起调用时，下游服务收到的请求应该包含相同的 `trace_id`。

**Validates: Requirements 5.4**

### Property 4: 文件系统清理验证

*For any* 完成迁移后的代码库状态，根目录不应包含 `/gateway` 目录，且各 Worker 的 `internal/` 目录不应包含 `broker/` 或 `database/` 子目录。

**Validates: Requirements 1.1, 1.2, 3.1, 3.2**

## Error Handling

### Redis 连接错误

```go
// 连接失败时返回明确错误
func NewClient(cfg Config) (*Client, error) {
    // ...
    if err := client.Ping(ctx).Err(); err != nil {
        return nil, fmt.Errorf("failed to connect to Redis at %s: %w", cfg.URL, err)
    }
    // ...
}

// Get 操作时区分"键不存在"和"其他错误"
func (c *Client) Get(ctx context.Context, key string, target interface{}) error {
    data, err := c.client.Get(ctx, key).Bytes()
    if err != nil {
        if err == redis.Nil {
            return ErrKeyNotFound  // 明确的"键不存在"错误
        }
        return fmt.Errorf("redis get failed: %w", err)
    }
    // ...
}
```

### gRPC 调用错误

```go
// 统一的错误处理和重试
func RetryInterceptor(maxRetries int, backoff time.Duration) grpc.UnaryClientInterceptor {
    return func(ctx context.Context, method string, req, reply interface{}, 
                cc *grpc.ClientConn, invoker grpc.UnaryInvoker, opts ...grpc.CallOption) error {
        var lastErr error
        for i := 0; i <= maxRetries; i++ {
            err := invoker(ctx, method, req, reply, cc, opts...)
            if err == nil {
                return nil
            }
            lastErr = err
            
            // 只对可重试的错误进行重试
            if !isRetryable(err) {
                return err
            }
            
            time.Sleep(backoff * time.Duration(i+1))
        }
        return fmt.Errorf("max retries exceeded: %w", lastErr)
    }
}
```

## Testing Strategy

### 单元测试

1. **pkg/cache 测试**
   - 测试 `ConfigFromEnv` 正确读取环境变量
   - 测试 `Get`/`Set`/`Delete` 基础操作（使用 miniredis 模拟）
   - 测试 `ErrKeyNotFound` 错误处理

2. **pkg/grpc 测试**
   - 测试拦截器正确传递 trace_id
   - 测试重试逻辑
   - 测试连接池管理

### 属性测试

使用 `gopter` 或 `rapid` 进行属性测试：

1. **Redis Round-Trip 属性测试**
   ```go
   // 使用 rapid 库
   func TestRedisRoundTrip(t *testing.T) {
       rapid.Check(t, func(t *rapid.T) {
           // 生成随机结构体
           value := rapid.Make[TestStruct]().Draw(t, "value")
           key := rapid.String().Draw(t, "key")
           
           // Set then Get
           err := client.Set(ctx, key, value, time.Hour)
           require.NoError(t, err)
           
           var result TestStruct
           err = client.Get(ctx, key, &result)
           require.NoError(t, err)
           
           // 验证 round-trip
           assert.Equal(t, value, result)
       })
   }
   ```

2. **Trace ID 传递属性测试**
   ```go
   func TestTraceIDPropagation(t *testing.T) {
       rapid.Check(t, func(t *rapid.T) {
           traceID := rapid.StringMatching(`[a-f0-9]{32}`).Draw(t, "traceID")
           ctx := logger.ContextWithTraceID(context.Background(), traceID)
           
           // 调用 gRPC 并验证 trace_id 被传递
           // ...
       })
   }
   ```

### 集成测试

1. **Worker 启动测试** - 验证迁移后的 Worker 能正常启动
2. **端到端测试** - 验证消息从 Gateway 到 Worker 的完整流程
3. **健康检查测试** - 验证所有服务的健康检查端点

### 测试配置

- 属性测试最少运行 100 次迭代
- 使用 `testcontainers-go` 进行 Redis/PostgreSQL 集成测试
- 使用 `miniredis` 进行 Redis 单元测试
