# Lesser - 社交平台脚手架

一个类似 X.com (Twitter) 的社交平台脚手架，采用 Go 微服务架构：Gateway + RabbitMQ + Worker 集群。

## 🚀 特性

- **微服务架构**: Go Gateway + Worker 集群 + 消息队列
- **多端支持**: Flutter 移动端 + React Web 端
- **实时通信**: WebSocket + gRPC
- **完整功能**: 认证、Feed、帖子、搜索、通知、聊天
- **开发友好**: Docker 一键启动、热重载、统一脚本
- **共享公共库**: service/pkg 提供统一基础设施

## 📐 架构概览

```
┌─────────────────────────────────────────────────────────────┐
│                        Clients                               │
│  ┌─────────────────┐              ┌─────────────────┐       │
│  │  Flutter Mobile │              │   React Web     │       │
│  └────────┬────────┘              └────────┬────────┘       │
└───────────┼────────────────────────────────┼────────────────┘
            │                                │
            ▼                                ▼
┌─────────────────────────────────────────────────────────────┐
│                   Traefik Gateway                            │
│              (REST / gRPC-Web / WebSocket)                   │
└───────────┬────────────────────────────────┬────────────────┘
            │                                │
            ▼                                ▼
┌─────────────────────────┐    ┌─────────────────────────────┐
│     Go Gateway          │    │     Go Chat Service         │
│   (gRPC API 入口)       │    │  (WebSocket, Real-time)     │
└───────────┬─────────────┘    └───────────┬─────────────────┘
            │                              │
            ▼                              │
┌─────────────────────────┐                │
│       RabbitMQ          │                │
│     (消息队列)          │                │
└───────────┬─────────────┘                │
            │                              │
            ▼                              │
┌─────────────────────────────────────────────────────────────┐
│                    Worker 集群                               │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │Auth      │ │Post      │ │Feed      │ │Notif     │ ...   │
│  │Worker    │ │Worker    │ │Worker    │ │Worker    │       │
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

## 🔄 数据流程图

### 请求处理流程

```
┌──────────────────────────────────────────────────────────────────────────┐
│                           完整请求流程                                    │
└──────────────────────────────────────────────────────────────────────────┘

用户请求
    │
    ▼
┌─────────────┐
│   Client    │  Flutter / React
└──────┬──────┘
       │ HTTP/WebSocket/gRPC-Web
       ▼
┌─────────────┐
│   Traefik   │  路由分发
└──────┬──────┘
       │
       ├─────────────────────────────────────┐
       │ /grpc/*                             │ /api/v1/chat, /ws/chat
       ▼                                     ▼
┌─────────────┐                       ┌─────────────┐
│  Gateway    │                       │   Go Chat   │
│  (gRPC)     │                       │   Service   │
└──────┬──────┘                       └──────┬──────┘
       │                                     │
       ▼                                     │
┌─────────────┐                              │
│  RabbitMQ   │                              │
└──────┬──────┘                              │
       │                                     │
       ▼                                     │
┌─────────────┐                              │
│   Workers   │                              │
│ (Auth/Post/ │                              │
│  Feed/...)  │                              │
└──────┬──────┘                              │
       │                                     │
       ├──────────────┬──────────────────────┤
       ▼              ▼                      ▼
┌─────────────┐ ┌─────────────┐       ┌─────────────┐
│ PostgreSQL  │ │    Redis    │       │  WebSocket  │
│  (持久化)   │ │   (缓存)    │       │   (实时)    │
└─────────────┘ └─────────────┘       └─────────────┘
```

### 新增路由修改流程

添加新 API 路由时，需要修改以下文件（按顺序）：

```
┌──────────────────────────────────────────────────────────────────────────┐
│                        新增路由完整修改清单                               │
└──────────────────────────────────────────────────────────────────────────┘

1. Proto 定义 (gRPC 通信)
   └── protos/<service>/<service>.proto

2. 后端服务
   ├── Gateway (gRPC 入口)
   │   └── service/gateway/internal/server/
   │
   ├── Worker (业务处理)
   │   ├── service/<xxx>_worker/internal/worker/
   │   └── service/<xxx>_worker/internal/service/
   │
   └── Go Chat (如涉及聊天功能)
       ├── service/chat_gin/internal/model/*.go
       ├── service/chat_gin/internal/repository/*.go
       ├── service/chat_gin/internal/service/*.go
       ├── service/chat_gin/internal/handler/*.go
       └── service/chat_gin/internal/server/http.go

3. 网关路由 (如需新路径前缀)
   └── infra/gateway/dynamic/routes.yml

4. 客户端
   ├── Flutter
   │   ├── client/mobile_flutter/lib/features/<module>/data/
   │   ├── client/mobile_flutter/lib/features/<module>/domain/
   │   └── client/mobile_flutter/lib/features/<module>/presentation/
   │
   └── React
       └── client/web_react/src/features/<module>/
```

### 简化版新增清单

| 步骤 | 文件/目录 | 说明 |
|------|----------|------|
| 1 | `protos/` | gRPC 定义 |
| 2 | `service/gateway/` | Gateway 处理器 |
| 3 | `service/<xxx>_worker/` | Worker 业务逻辑 |
| 4 | `routes.yml` | 网关路由 (可选) |
| 5 | `features/<module>/` | 客户端模块 |

## 🛠 技术栈

| 层级 | 技术 |
|------|------|
| **网关** | Traefik |
| **API 网关** | Go + gRPC |
| **消息队列** | RabbitMQ |
| **Worker 服务** | Go |
| **聊天服务** | Go + Gin + gRPC |
| **数据库** | PostgreSQL |
| **缓存** | Redis |
| **移动端** | Flutter (Riverpod) |
| **Web 端** | React + Next.js |
| **通信协议** | gRPC + WebSocket |

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
│   ├── env/                    # 环境变量 (统一管理)
│   ├── gateway/                # Traefik 配置
│   ├── database/               # PostgreSQL 初始化
│   └── cache/                  # Redis 配置
├── service/                    # 后端服务
│   ├── gateway/                # Go API 网关
│   ├── pkg/                    # 共享公共库
│   ├── auth_worker/            # 认证 Worker
│   ├── user_worker/            # 用户 Worker
│   ├── post_worker/            # 帖子 Worker
│   ├── feed_worker/            # Feed Worker
│   ├── notification_worker/    # 通知 Worker
│   ├── search_worker/          # 搜索 Worker
│   ├── chat_worker/            # 聊天任务 Worker
│   └── chat_gin/               # Go 聊天服务
├── client/                     # 前端客户端
│   ├── mobile_flutter/         # Flutter 移动端
│   └── web_react/              # React Web 端
├── scripts/                    # 辅助脚本
└── docs/                       # 文档
```

## 🚀 快速开始

### 前置要求

- Docker & Docker Compose
- (可选) Flutter SDK - 移动端开发
- (可选) Node.js - Web 端开发

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
| Gateway (统一入口) | http://localhost |
| Gateway gRPC | localhost:50053 |
| Chat API | http://localhost:8081 |
| Traefik Dashboard | http://localhost:8088 |
| RabbitMQ Management | http://localhost:15672 |
| Dozzle (日志) | http://localhost:9999 |
| Flutter Web | http://localhost:3000 |
| React Web | http://localhost:3001 |

## 📋 常用命令

```bash
# 服务管理
./dev.sh start [service|client|all]   # 启动服务
./dev.sh stop                          # 停止服务
./dev.sh restart [service]             # 重启服务
./dev.sh logs [service]                # 查看日志
./dev.sh status                        # 查看状态

# 数据库操作
./dev.sh migrate                       # 执行迁移
./dev.sh makemigrations [app]          # 生成迁移
./dev.sh createsuperuser               # 创建管理员
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

## 🔌 API 端点

### 聊天 API (REST)

```bash
# 获取会话列表
GET /api/v1/chat/conversations/

# 创建会话
POST /api/v1/chat/conversations/
{
  "type": "private",
  "member_ids": ["user-uuid"]
}

# 发送消息
POST /api/v1/chat/conversations/{id}/messages/
{
  "content": "Hello"
}

# WebSocket 连接
ws://localhost/ws/chat?user_id={uuid}
```

### gRPC API (通过 Gateway)

所有业务 API 通过 gRPC-Web 调用 Gateway，Gateway 将请求发布到 RabbitMQ，由对应 Worker 处理。

详细 Proto 定义请参考 `protos/` 目录。

## ⚙️ 环境变量

环境变量统一放在 `infra/env/` 目录下：

```
infra/env/
├── dev.env.example    # 开发环境模板
├── dev.env            # 开发环境配置 (git ignored)
├── prod.env.example   # 生产环境模板
└── prod.env           # 生产环境配置 (git ignored)
```

主要配置项：

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `POSTGRES_USER` | 数据库用户 | lesser |
| `POSTGRES_PASSWORD` | 数据库密码 | lesser_dev_password |
| `RABBITMQ_USER` | RabbitMQ 用户 | guest |
| `RABBITMQ_PASSWORD` | RabbitMQ 密码 | guest |
| `JWT_SECRET_KEY` | JWT 密钥 | (开发用) |

## 🧪 测试

```bash
# Go 测试
docker compose -f infra/docker-compose.yml exec chat go test ./...

# Flutter 测试
cd client/mobile_flutter && flutter test
```

## 📚 文档

- [开发准则](docs/开发准则.md) - 代码规范和最佳实践
- [架构设计](.kiro/specs/platform-scaffold/design.md) - 详细架构设计
- [需求文档](.kiro/specs/platform-scaffold/requirements.md) - 功能需求

## 🤝 贡献

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'feat: add amazing feature'`)
4. 推送分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

## 📄 许可证

MIT License
