# 日志风格指南

> 基于 Go 1.25.5 标准库 `log/slog`

## 核心原则

1. **结构化日志**: 使用 JSON 格式，便于日志聚合和查询
2. **统一字段**: 所有服务使用相同的字段命名
3. **链路追踪**: 通过 `trace_id` 串联跨服务调用
4. **最小化噪音**: 只记录有价值的信息

---

## 日志级别

| 级别 | 用途 | 示例 |
|------|------|------|
| `DEBUG` | 开发调试信息，生产环境关闭 | 变量值、执行路径 |
| `INFO` | 正常业务流程 | 请求处理、状态变更 |
| `WARN` | 潜在问题，不影响主流程 | 重试、降级、慢查询 |
| `ERROR` | 错误，需要关注 | 请求失败、外部服务异常 |
| `FATAL` | 致命错误，服务无法继续 | 启动失败、配置错误 |

---

## 标准字段

### 必填字段

```json
{
  "time": "2026-01-02T10:30:00.123Z",
  "level": "INFO",
  "service": "chat",
  "msg": "消息发送成功"
}
```

### 链路追踪字段

```json
{
  "trace_id": "abc123-def456",
  "user_id": "user_001"
}
```

### 请求相关字段

```json
{
  "method": "chat.ChatService/SendMessage",
  "latency_ms": 15.5,
  "status": "OK"
}
```

### 错误相关字段

```json
{
  "error": "connection refused",
  "source": "service/chat/internal/service/chat.go:123"
}
```

---

## Go 服务日志规范

### 初始化

```go
import "github.com/lesser/pkg/logger"

// 服务启动时初始化
log := logger.New("chat")
defer log.Sync()
```

### 基础用法

```go
// 简单日志
log.Info("服务启动", slog.Int("port", 50052))

// 带上下文的日志（自动注入 trace_id, user_id）
log.WithContext(ctx).Info("消息发送成功",
    slog.String("conversation_id", convID),
    slog.String("message_id", msgID),
)

// 错误日志
log.WithContext(ctx).Error("发送消息失败",
    slog.Any("error", err),
    slog.String("conversation_id", convID),
)
```

### gRPC 请求日志

```go
// 请求开始
log.WithContext(ctx).Debug("处理请求",
    slog.String("method", "SendMessage"),
)

// 请求完成
log.WithContext(ctx).Info("请求完成",
    slog.String("method", "SendMessage"),
    slog.Duration("latency", time.Since(start)),
    slog.String("status", "OK"),
)

// 请求失败
log.WithContext(ctx).Warn("请求失败",
    slog.String("method", "SendMessage"),
    slog.Duration("latency", time.Since(start)),
    slog.String("status", "INVALID_ARGUMENT"),
    slog.Any("error", err),
)
```

### 数据库操作日志

```go
// 慢查询警告（超过 100ms）
log.WithContext(ctx).Warn("慢查询",
    slog.String("sql", "SELECT * FROM messages WHERE..."),
    slog.Duration("latency", duration),
    slog.Int64("rows", rowsAffected),
)

// 查询错误
log.WithContext(ctx).Error("数据库查询失败",
    slog.Any("error", err),
    slog.String("table", "messages"),
)
```

### 使用 LogAttrs 提升性能

```go
// 高频日志场景使用 LogAttrs 避免内存分配
log.WithContext(ctx).LogAttrs(ctx, slog.LevelInfo, "消息发送成功",
    slog.String("conversation_id", convID),
    slog.String("message_id", msgID),
)
```

### 使用 DiscardHandler 禁用日志

```go
// Go 1.25+ 提供 slog.DiscardHandler，用于测试或禁用日志
import "log/slog"

// 测试环境禁用日志输出
testLogger := slog.New(slog.DiscardHandler)

// DiscardHandler.Enabled() 对所有级别返回 false
// 可用于性能测试或不需要日志的场景
```

### 使用 GroupAttrs 组织相关字段

```go
// 使用 GroupAttrs 将相关属性分组（比 Group 更高效）
log.Info("请求完成",
    slog.GroupAttrs("request",
        slog.String("method", method),
        slog.String("path", path),
    ),
    slog.GroupAttrs("response",
        slog.Int("status", statusCode),
        slog.Duration("latency", duration),
    ),
)

// 输出: {"request":{"method":"POST","path":"/api"},"response":{"status":200,"latency":"15ms"}}
```

---

## Flutter 客户端日志规范

### 初始化

```dart
import 'package:mobile_flutter/core/utils/app_logger.dart';

// 使用全局 log 实例
log.init();
```

### 基础用法

```dart
// 调试信息
log.d('gRPC 连接状态: $state');

// 普通信息
log.i('用户登录成功', {'user_id': userId});

// 警告
log.w('Token 即将过期', {'expires_in': seconds});

// 错误
log.e('发送消息失败', error: e, stackTrace: stack);
```

### 网络请求日志

```dart
// 请求发送
log.d('gRPC 请求', {
  'method': 'SendMessage',
  'conversation_id': convId,
});

// 请求成功
log.i('gRPC 响应', {
  'method': 'SendMessage',
  'latency_ms': stopwatch.elapsedMilliseconds,
});

// 请求失败
log.e('gRPC 错误', {
  'method': 'SendMessage',
  'code': e.code.name,
  'message': e.message,
});
```

---

## 最佳实践

### ✅ 推荐

```go
// 使用结构化字段，不要拼接字符串
log.Info("用户登录",
    slog.String("user_id", userID),
    slog.String("ip", clientIP),
)

// 错误日志包含上下文
log.Error("创建会话失败",
    slog.Any("error", err),
    slog.String("creator_id", creatorID),
    slog.Any("member_ids", memberIDs),
)

// 敏感信息脱敏
log.Info("用户注册",
    slog.String("email", maskEmail(email)),  // t***@example.com
)

// 使用 LogValuer 延迟计算昂贵的值
type expensiveValue struct { arg int }

func (e expensiveValue) LogValue() slog.Value {
    return slog.StringValue(computeExpensive(e.arg))
}

// 只有日志级别启用时才会调用 computeExpensive
log.Debug("调试信息", slog.Any("value", expensiveValue{arg: 42}))
```

### ❌ 避免

```go
// 不要拼接字符串
log.Info(fmt.Sprintf("用户 %s 登录", userID))  // ❌

// 不要记录敏感信息
log.Info("登录", slog.String("password", password))  // ❌

// 不要记录大量数据
log.Debug("消息列表", slog.Any("messages", messages))  // ❌ 可能很大

// 不要在循环中频繁打日志
for _, msg := range messages {
    log.Debug("处理消息", slog.String("id", msg.ID))  // ❌
}
// 应该批量记录
log.Debug("批量处理消息", slog.Int("count", len(messages)))  // ✅
```

---

## Trace ID 传递

### 客户端生成

```dart
// Flutter 端生成 trace_id
final traceId = const Uuid().v4();
final metadata = {'x-trace-id': traceId};
```

### 服务端提取

```go
// 从 gRPC metadata 提取
func extractTraceID(ctx context.Context) string {
    md, ok := metadata.FromIncomingContext(ctx)
    if !ok {
        return uuid.New().String()
    }
    if values := md.Get("x-trace-id"); len(values) > 0 {
        return values[0]
    }
    return uuid.New().String()
}

// 注入到 context
ctx = logger.ContextWithTraceID(ctx, traceID)
```

### 跨服务传递

```go
// 调用下游服务时传递 trace_id
md := metadata.Pairs("x-trace-id", logger.TraceIDFromContext(ctx))
ctx = metadata.NewOutgoingContext(ctx, md)
resp, err := client.SomeMethod(ctx, req)
```

---

## 日志输出

### 开发环境

Text 格式输出，便于阅读：

```
time=2026-01-02T10:30:00.123+08:00 level=INFO service=chat msg="消息发送成功" trace_id=abc123 conversation_id=conv_001
time=2026-01-02T10:30:00.456+08:00 level=ERROR service=chat msg="发送失败" trace_id=abc123 error="connection refused"
```

### 生产环境

JSON 格式输出到 stdout，由日志收集系统处理：

```json
{"time":"2026-01-02T10:30:00.123Z","level":"INFO","service":"chat","msg":"消息发送成功","trace_id":"abc123","conversation_id":"conv_001"}
```

### 查看日志

```bash
# 实时查看所有服务日志
docker compose -f infra/docker-compose.yml logs -f

# 查看单个服务
docker compose -f infra/docker-compose.yml logs -f chat

# 使用 Dozzle Web 界面
open http://localhost:9999
```

---

## 日志过滤

日志过滤在日志收集端（Dozzle/ELK）配置，不在应用层过滤。

### Dozzle 过滤示例

```
# 只看错误
level:ERROR

# 按 trace_id 追踪
trace_id:abc123

# 排除健康检查
NOT method:/health
```

---

## slog 常用 API 速查

| 函数 | 说明 |
|------|------|
| `slog.String(key, value)` | 字符串属性 |
| `slog.Int(key, value)` | 整数属性 |
| `slog.Int64(key, value)` | int64 属性 |
| `slog.Uint64(key, value)` | uint64 属性 |
| `slog.Float64(key, value)` | 浮点数属性 |
| `slog.Bool(key, value)` | 布尔属性 |
| `slog.Time(key, value)` | 时间属性 |
| `slog.Duration(key, value)` | 时长属性 |
| `slog.Any(key, value)` | 任意类型属性 |
| `slog.Group(key, attrs...)` | 属性分组 |
| `slog.GroupAttrs(key, attrs...)` | 属性分组（仅接受 Attr） |
| `slog.DiscardHandler` | 丢弃所有日志的 Handler |
| `slog.SetLogLoggerLevel(level)` | 设置 log 包的日志级别 |
