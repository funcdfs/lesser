# Design Document: Gateway Async Architecture

## Overview

本设计实现一个统一网关 + 异步消息队列的后端架构，替代传统 RESTful API 同步模式。

核心组件：
- **Gateway Service**: Go 实现的统一入口，接收 gRPC 请求，分发到 RabbitMQ
- **Auth Worker**: Go 实现的认证服务，消费队列处理注册/登录
- **RabbitMQ**: 消息队列，解耦网关和业务服务

```
┌─────────────┐     gRPC/Protobuf     ┌─────────────┐     AMQP      ┌─────────────┐
│   Flutter   │ ──────────────────▶   │   Gateway   │ ──────────▶   │  RabbitMQ   │
│   Client    │                       │   Service   │               │   Broker    │
└─────────────┘                       └─────────────┘               └──────┬──────┘
                                                                          │
                                            ┌─────────────────────────────┤
                                            ▼                             ▼
                                     ┌─────────────┐              ┌─────────────┐
                                     │ Auth Worker │              │ Other Worker│
                                     │   (Go)      │              │   (Future)  │
                                     └──────┬──────┘              └─────────────┘
                                            │
                                            ▼
                                     ┌─────────────┐
                                     │  PostgreSQL │
                                     └─────────────┘
```

## Architecture

### 请求流程

1. Flutter 客户端通过 gRPC 发送 `GatewayRequest` 到 Gateway
2. Gateway 解析 action，将任务发布到对应的 RabbitMQ 队列
3. Gateway 立即返回 `request_id` 给客户端
4. Worker 消费队列，处理业务逻辑
5. Worker 将结果发布到响应队列
6. 客户端通过轮询或 WebSocket 获取结果

### 消息格式

采用 gRPC/Protobuf 格式，强类型、高性能。

## Components and Interfaces

### 1. Gateway Service

```go
// Gateway 服务入口
type GatewayServer struct {
    rabbitConn *amqp.Connection
    channel    *amqp.Channel
}

// 处理所有请求的统一入口
func (s *GatewayServer) Process(ctx context.Context, req *pb.GatewayRequest) (*pb.GatewayResponse, error)
```

### 2. Auth Worker

```go
// Auth Worker 消费认证相关任务
type AuthWorker struct {
    db         *sql.DB
    rabbitConn *amqp.Connection
}

// 处理注册
func (w *AuthWorker) HandleRegister(msg *pb.RegisterRequest) (*pb.AuthResponse, error)

// 处理登录
func (w *AuthWorker) HandleLogin(msg *pb.LoginRequest) (*pb.AuthResponse, error)
```

### 3. RabbitMQ 队列设计

```
Exchanges:
  - gateway.direct (direct exchange)

Queues:
  - auth.register    # 注册任务
  - auth.login       # 登录任务
  - response.{request_id}  # 响应队列（临时）
```

## Data Models

### Proto 定义

```protobuf
// 统一网关请求
message GatewayRequest {
  string action = 1;           // 操作类型: USER_REGISTER, USER_LOGIN
  string version = 1;          // API 版本
  bytes payload = 3;           // 序列化的具体请求
  string request_id = 4;       // 请求唯一标识
}

// 统一网关响应
message GatewayResponse {
  string request_id = 1;
  bool accepted = 2;           // 是否接受处理
  string error_code = 3;       // 错误码（如有）
  string error_message = 4;    // 错误信息（如有）
}

// 任务结果（Worker 发布到响应队列）
message TaskResult {
  string request_id = 1;
  bool success = 2;
  bytes payload = 3;           // 序列化的具体响应
  string error_code = 4;
  string error_message = 5;
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system.*

根据需求分析，本架构的可测试属性较少，主要是架构设计和集成验证。以下是可形式化的属性：

**Property 1: 请求必达性**
*For any* 有效的 GatewayRequest，Gateway 必须将其发布到 RabbitMQ 队列，且返回 accepted=true
**Validates: Requirements 2.1, 2.3**

**Property 2: 消息格式一致性**
*For any* Protobuf 消息，序列化后再反序列化应得到等价对象（round-trip）
**Validates: Requirements 1.3**

## Error Handling

| 场景 | 错误码 | 处理方式 |
|------|--------|----------|
| 无效 action | INVALID_ACTION | Gateway 直接返回错误 |
| Protobuf 解析失败 | INVALID_PAYLOAD | Gateway 直接返回错误 |
| RabbitMQ 连接失败 | BROKER_UNAVAILABLE | Gateway 返回服务不可用 |
| 用户已存在 | USER_EXISTS | Worker 返回业务错误 |
| 凭证无效 | INVALID_CREDENTIALS | Worker 返回业务错误 |

## Testing Strategy

由于明确要求「拒绝测试」，本设计不包含详细测试计划。

验证方式：通过 Flutter 客户端手动测试注册和登录流程。
