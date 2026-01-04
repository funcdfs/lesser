# Lesser - 社交平台

一个类似 X.com (Twitter) 的社交平台，采用纯 gRPC 微服务架构。

## 🚀 特性

- **纯 gRPC 架构**: Gateway + Service Cluster，无 REST API
- **gRPC 双向流**: 替代 WebSocket 实现实时消息推送
- **Flutter 跨平台**: 移动端 + Web 端统一代码
- **完整功能**: 认证、Feed、帖子、搜索、通知、实时聊天
- **开发友好**: Docker 一键启动、CLI 工具管理
- **共享公共库**: `service/pkg` 提供统一基础设施

## 📐 架构概览

```
┌─────────────────────────────────────────────────────────────┐
│                        Clients                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Flutter Mobile/Web                      │    │
│  └────────────────────────┬────────────────────────────┘    │
└───────────────────────────┼─────────────────────────────────┘
                            │ gRPC / gRPC-Web
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   Traefik Gateway                            │
│                  (gRPC :50050 / HTTP :80)                    │
└───────────┬────────────────────────────────┬────────────────┘
            │                                │
            ▼                                ▼
┌─────────────────────────┐    ┌─────────────────────────────┐
│     Go Gateway          │    │     Go Chat Service         │
│   (JWT验签/限流/路由)    │    │   (gRPC 双向流)             │
│      :50051             │    │      :50060                 │
└───────────┬─────────────┘    └─────────────────────────────┘
            │ gRPC
            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Service Cluster                           │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │Auth      │ │User      │ │Content   │ │Timeline  │ ...   │
│  │:50052    │ │:50053    │ │:50054    │ │:50057    │       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
└───────────┬─────────────────────────────┬───────────────────┘
            │                             │
            ▼                             ▼
┌─────────────────────────────────────────────────────────────┐
│                    Data Layer                                │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐  │
│  │   PostgreSQL    │  │     Redis       │  │  RabbitMQ   │  │
│  └─────────────────┘  └─────────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 🛠 技术栈

| 层级 | 技术 | 说明 |
|------|------|------|
| 客户端 | Flutter 3.x | 跨平台移动端 + Web |
| 网关 | Traefik 3.x | 反向代理、负载均衡、gRPC 支持 |
| API 网关 | Go + gRPC | JWT 验签、限流、路由转发 |
| 业务服务 | Go + gRPC | Auth/User/Content/Comment/Interaction/Timeline/Search/Notification/SuperUser |
| 聊天服务 | Go + gRPC 双向流 | 高性能实时聊天 |
| 消息队列 | RabbitMQ | 异步事件（通知推送、搜索索引） |
| 数据库 | PostgreSQL 17 + pgvector | 主数据存储 + 向量语义搜索 |
| 缓存 | Redis 7 | JWT 公钥缓存、会话缓存、Pub/Sub |

## 🔌 服务端口

| 服务 | 端口 | 说明 |
|------|------|------|
| Traefik HTTP | 80 | HTTP 入口 |
| Traefik gRPC | 50050 | gRPC 统一入口 |
| Gateway | 50051 | API 网关 (JWT/限流/路由) |
| Auth | 50052 | 认证服务 |
| User | 50053 | 用户服务 |
| Content | 50054 | 内容服务 |
| Comment | 50055 | 评论服务 |
| Interaction | 50056 | 交互服务 |
| Timeline | 50057 | 时间线服务 |
| Search | 50058 | 搜索服务 |
| Notification | 50059 | 通知服务 |
| Chat | 50060 | 聊天服务 (gRPC 双向流) |
| SuperUser | 50061 | 超级用户服务 |

## 🚀 快速开始

### 前置要求

- Docker & Docker Compose
- Rust (用于 CLI 工具)
- (可选) Flutter SDK - 客户端开发
- (可选) Go 1.25+ - 后端开发

### 1. 安装 CLI 工具

```bash
cargo install --path infra/cli
```

### 2. 初始化环境

```bash
devlesser init
```

### 3. 启动服务

```bash
# 启动所有服务
devlesser start

# 只启动基础设施 (PostgreSQL/Redis/RabbitMQ/Traefik)
devlesser start infra

# 只启动后端服务
devlesser start service

# 启动 Flutter 客户端
devlesser start flutter
```

### 4. 验证服务

```bash
devlesser status
```

### 5. 访问服务

| 服务 | 地址 |
|------|------|
| Traefik gRPC | localhost:50050 |
| Gateway gRPC | localhost:50051 |
| Chat gRPC (双向流) | localhost:50060 |
| Traefik Dashboard | http://localhost:8088 |
| RabbitMQ Management | http://localhost:15672 |
| Dozzle (日志) | http://localhost:9999 |
| Jaeger (链路追踪) | http://localhost:16686 |
| PgHero (数据库监控) | http://localhost:8080 |
| Flutter Web | http://localhost:3000 |

## 📋 CLI 命令

```bash
# 服务管理
devlesser start [infra|service|flutter|flutter-web|flutter-android]
devlesser stop
devlesser restart [service]
devlesser status

# 初始化（含 hosts 配置）
devlesser init
devlesser init --skip-hosts

# Proto 代码生成
devlesser proto              # 生成所有 (别名: devlesser gen)
devlesser proto go           # 仅生成 Go
devlesser proto dart         # 仅生成 Dart

# 测试
devlesser test               # 运行所有服务测试
devlesser test <service>     # 单个服务测试
devlesser test full          # 完整三轮测试

# 生产环境
devlesser prod start|stop|deploy|backup|logs

# 清理
devlesser clean
devlesser clean volumes
```

## 🔧 调试

```bash
# 安装 grpcurl
brew install grpcurl

# 注册
grpcurl -plaintext \
  -d '{"username":"test","email":"test@example.com","password":"123456"}' \
  localhost:50051 auth.AuthService/Register

# 登录
grpcurl -plaintext \
  -d '{"email":"test@example.com","password":"123456"}' \
  localhost:50051 auth.AuthService/Login

# 带 Token 请求
grpcurl -plaintext \
  -H "authorization: Bearer $TOKEN" \
  -d '{"user_id":"xxx"}' \
  localhost:50051 timeline.TimelineService/GetHomeFeed
```

## 📚 文档

| 文档 | 说明 |
|------|------|
| [架构梳理](docs/架构梳理.md) | 详细架构设计和数据流程 |
| [开发准则](docs/开发准则.md) | 代码规范和最佳实践 |
| [UI细节](docs/UI%20细节.md) | UI 设计准则 |

## 📄 许可证

MIT License
