# Lesser - 社交平台脚手架

一个类似 X.com (Twitter) 的社交平台脚手架，采用纯 gRPC 微服务架构。

## 🚀 特性

- **纯 gRPC 架构**: Gateway + Service Cluster，无 REST API
- **gRPC 双向流**: 替代 WebSocket 实现实时消息推送
- **Flutter 跨平台**: 移动端 + Web 端统一代码
- **完整功能**: 认证、Feed、帖子、搜索、通知、聊天
- **开发友好**: Docker 一键启动、热重载、统一脚本
- **共享公共库**: service/pkg 提供统一基础设施

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
│   (JWT验签/限流/路由)   │    │   (gRPC 双向流)             │
│      :50053             │    │      :50052                 │
└───────────┬─────────────┘    └───────────┬─────────────────┘
            │ gRPC                         │
            ▼                              │
┌─────────────────────────────────────────────────────────────┐
│                    Service Cluster                           │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │Auth      │ │User      │ │Post      │ │Feed      │ ...   │
│  │:50054    │ │:50055    │ │:50056    │ │:50057    │       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
└───────────┬─────────────────────────────┬───────────────────┘
            │                             │
            ▼                             ▼
┌─────────────────────────────────────────────────────────────┐
│                    Data Layer                                │
│  ┌─────────────────┐              ┌─────────────────┐       │
│  │   PostgreSQL    │              │     Redis       │       │
│  └─────────────────┘              └─────────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

## 🛠 技术栈

| 层级 | 技术 |
|------|------|
| **网关** | Traefik |
| **API 网关** | Go + gRPC |
| **业务服务** | Go + gRPC |
| **聊天服务** | Go + gRPC 双向流 |
| **消息队列** | RabbitMQ (仅次要异步) |
| **数据库** | PostgreSQL |
| **缓存** | Redis |
| **客户端** | Flutter (Riverpod) |
| **通信协议** | gRPC + gRPC 双向流 |

## 📁 目录结构

```
.
├── dev.sh                      # 开发环境入口脚本
├── prod.sh                     # 生产环境脚本
├── protos/                     # gRPC Proto 定义
│   ├── auth/
│   ├── chat/
│   ├── feed/
│   ├── post/
│   ├── user/
│   ├── notification/
│   ├── search/
│   └── gateway/
├── infra/                      # 基础设施配置
│   ├── docker-compose.yml
│   ├── .env.dev                # 开发环境变量
│   ├── gateway/                # Traefik 配置
│   ├── database/               # PostgreSQL 初始化
│   └── cache/                  # Redis 配置
├── service/                    # 后端服务
│   ├── gateway/                # Go API 网关
│   ├── auth/                   # 认证服务
│   ├── user/                   # 用户服务
│   ├── post/                   # 帖子服务
│   ├── feed/                   # Feed 服务
│   ├── search/                 # 搜索服务
│   ├── notification/           # 通知服务
│   ├── chat/                   # 聊天服务 (gRPC 双向流)
│   └── pkg/                    # 共享公共库
├── client/                     # 前端客户端
│   └── mobile_flutter/         # Flutter 移动端 + Web
├── scripts/                    # 辅助脚本
└── docs/                       # 文档
```

## 🚀 快速开始

### 前置要求

- Docker & Docker Compose
- (可选) Flutter SDK - 客户端开发

### 1. 初始化环境

```bash
# 首次使用，初始化开发环境
./dev.sh init
```

### 2. 启动服务

```bash
# 启动所有后端服务
./dev.sh start

# 或只启动后端
./dev.sh start service

# 或只启动客户端
./dev.sh start client
```

### 3. 验证服务

```bash
# 查看服务状态
./dev.sh status

# 测试服务连通性
./dev.sh test
```

### 4. 访问服务

| 服务 | 地址 |
|------|------|
| Gateway gRPC | localhost:50053 |
| Traefik gRPC | localhost:50050 |
| Traefik Dashboard | http://localhost:8088 |
| RabbitMQ Management | http://localhost:15672 |
| Dozzle (日志) | http://localhost:9999 |
| Flutter Web | http://localhost:3000 |

## 📋 常用命令

```bash
# 服务管理
./dev.sh start [service|client|all]   # 启动服务
./dev.sh stop                          # 停止服务
./dev.sh restart [service]             # 重启服务
./dev.sh logs [service]                # 查看日志
./dev.sh status                        # 查看状态

# 数据库操作
./dev.sh db:shell                      # 进入数据库

# 开发调试
./dev.sh enter db                      # 进入 PostgreSQL
./dev.sh enter redis                   # 进入 Redis

# 构建部署
./dev.sh build [service]               # 构建镜像
./dev.sh rebuild [service]             # 重新构建
./dev.sh proto [target]                # 生成 Proto 代码

# 查看帮助
./dev.sh --help
```

## 🔌 gRPC API

### 服务端口

| 服务 | gRPC 端口 | 说明 |
|------|-----------|------|
| Gateway | 50053 | API 网关 (JWT验签/限流/路由) |
| Auth | 50054 | 认证服务 |
| User | 50055 | 用户服务 |
| Post | 50056 | 帖子服务 |
| Feed | 50057 | Feed 服务 |
| Search | 50058 | 搜索服务 |
| Notification | 50059 | 通知服务 |
| Chat | 50052 | 聊天服务 (双向流) |

### Chat 双向流 API

```protobuf
// 双向流 RPC - 替代 WebSocket
rpc StreamEvents(stream ClientEvent) returns (stream ServerEvent);

// 客户端事件: Subscribe, Unsubscribe, SendMessage, Typing, Ping
// 服务端事件: NewMessage, MessageRead, TypingIndicator, Pong, Error
```

详细 Proto 定义请参考 `protos/` 目录。

## ⚙️ 环境变量

主要配置项 (`infra/.env.dev`):

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `POSTGRES_USER` | 数据库用户 | lesser |
| `POSTGRES_PASSWORD` | 数据库密码 | lesser_dev_password |
| `RABBITMQ_USER` | RabbitMQ 用户 | guest |
| `RABBITMQ_PASSWORD` | RabbitMQ 密码 | guest |

## 📚 文档

- [开发准则](docs/开发准则.md) - 代码规范和最佳实践
- [架构梳理](docs/架构梳理.md) - 详细架构设计

## 📄 许可证

MIT License
