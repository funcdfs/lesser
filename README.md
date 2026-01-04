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
│      :50053             │    │      :50052                 │
└───────────┬─────────────┘    └─────────────────────────────┘
            │ gRPC
            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Service Cluster                           │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │Auth      │ │User      │ │Content   │ │Timeline  │ ...   │
│  │:50054    │ │:50055    │ │:50056    │ │:50062    │       │
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
| 业务服务 | Go + gRPC | Auth/User/Content/Interaction/Comment/Timeline/Search/Notification |
| 聊天服务 | Go + gRPC 双向流 | 高性能实时聊天 |
| 消息队列 | RabbitMQ | 仅用于次要异步任务 |
| 数据库 | PostgreSQL 17 + pgvector | 主数据存储 + 向量语义搜索 |
| 缓存 | Redis 7 | JWT 公钥缓存、会话缓存 |
| 监控 | PgHero | 数据库性能监控 |

## 📁 目录结构

```
.
├── protos/                     # gRPC Proto 定义
│   ├── auth/                   # 认证服务
│   ├── chat/                   # 聊天服务
│   ├── content/                # 内容服务
│   ├── interaction/            # 交互服务
│   ├── comment/                # 评论服务
│   ├── timeline/               # 时间线服务
│   ├── user/                   # 用户服务
│   ├── notification/           # 通知服务
│   ├── search/                 # 搜索服务
│   └── gateway/                # 网关服务
├── infra/                      # 基础设施配置
│   ├── docker-compose.yml      # 开发环境
│   ├── docker-compose.prod.yml # 生产环境
│   ├── env/                    # 环境变量
│   ├── gateway/                # Traefik 配置
│   ├── database/               # PostgreSQL 初始化
│   ├── cache/                  # Redis 配置
│   └── cli/                    # devlesser CLI 工具
├── service/                    # 后端服务
│   ├── gateway/                # Go API 网关
│   ├── auth/                   # 认证服务
│   ├── user/                   # 用户服务
│   ├── content/                # 内容服务 (Story/Short/Article)
│   ├── interaction/            # 交互服务 (点赞/收藏/转发)
│   ├── comment/                # 评论服务
│   ├── timeline/               # 时间线服务 (Feed 流聚合)
│   ├── search/                 # 搜索服务
│   ├── notification/           # 通知服务
│   ├── chat/                   # 聊天服务 (gRPC 双向流)
│   └── pkg/                    # 共享公共库
├── client/                     # 前端客户端
│   └── mobile_flutter/         # Flutter 移动端 + Web
├── scripts/                    # 辅助脚本
│   ├── proto/                  # Proto 代码生成
│   └── database/               # 数据库初始化
├── logs/                       # 日志文件
└── docs/                       # 文档
```

## 🚀 快速开始

### 前置要求

- Docker & Docker Compose
- Rust (用于 CLI 工具)
- (可选) Flutter SDK - 客户端开发
- (可选) Go - 后端开发

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
| Gateway gRPC | localhost:50053 |
| Chat gRPC (双向流) | localhost:50052 |
| Traefik Dashboard | http://localhost:8088 |
| RabbitMQ Management | http://localhost:15672 |
| Dozzle (日志) | http://localhost:9999 |
| Jaeger (链路追踪) | http://localhost:16686 |
| RedisInsight | http://localhost:5540 |
| PgHero (数据库监控) | http://localhost:8080 |
| Flutter Web | http://localhost:3000 |

## 📋 CLI 命令

所有脚本功能已完全内置到 CLI 中，无需依赖外部 shell 脚本。

```bash
# 服务管理
devlesser start [infra|service|flutter|flutter-web|flutter-android]
devlesser stop
devlesser restart [service]
devlesser status

# 初始化（含 hosts 配置）
devlesser init               # 完整初始化
devlesser init --skip-hosts  # 跳过 hosts 配置

# Proto 代码生成
devlesser proto              # 生成所有 (别名: devlesser gen)
devlesser proto go           # 仅生成 Go
devlesser proto dart         # 仅生成 Dart

# 测试
devlesser test               # 运行所有测试
devlesser test services      # 仅服务测试
devlesser test search        # 仅搜索测试

# hosts 配置
devlesser hosts              # 配置本地域名 (需要 sudo)

# 生产环境管理
devlesser prod start         # 启动生产环境
devlesser prod stop          # 停止生产环境
devlesser prod restart       # 重启服务
devlesser prod status        # 查看状态
devlesser prod logs [service]  # 查看日志
devlesser prod deploy        # 部署更新
devlesser prod backup        # 备份数据库
devlesser prod validate      # 验证环境变量

# 清理
devlesser clean              # 清理所有
devlesser clean containers   # 仅清理容器
devlesser clean volumes      # 清理数据卷
```

## 🔌 gRPC API

### 服务端口

| 服务 | gRPC 端口 | 说明 |
|------|-----------|------|
| Traefik | 50050 | gRPC 统一入口 |
| Gateway | 50053 | API 网关 (JWT验签/限流/路由) |
| Auth | 50054 | 认证服务 |
| User | 50055 | 用户服务 |
| Content | 50056 | 内容服务 (Story/Short/Article CRUD) |
| Search | 50058 | 搜索服务 |
| Notification | 50059 | 通知服务 |
| Interaction | 50060 | 交互服务 (点赞/收藏/转发) |
| Comment | 50061 | 评论服务 |
| Timeline | 50062 | 时间线服务 (Feed 流聚合) |
| Chat | 50052 | 聊天服务 (双向流) |

### Chat 双向流 API

```protobuf
// 双向流 RPC - 替代 WebSocket
rpc StreamEvents(stream ClientEvent) returns (stream ServerEvent);

// 客户端事件: Subscribe, Unsubscribe, SendMessage, Typing, Ping
// 服务端事件: NewMessage, MessageRead, TypingIndicator, Pong, Error
```

## 🔧 调试

### 开发工具安装

```bash
# ghz - gRPC 压测工具
brew install ghz

# buf - Proto 管理工具（lint、格式化、breaking change 检测）
brew install bufbuild/buf/buf

# grpcurl - gRPC 命令行客户端
brew install grpcurl
```

### 使用 ghz 压测

```bash
# 压测登录接口（100 并发，10000 请求）
ghz --insecure \
  --proto protos/auth/auth.proto \
  --call auth.AuthService/Login \
  -d '{"email":"test@example.com","password":"password123"}' \
  -c 100 -n 10000 \
  localhost:50053

# 压测带 Token 的接口
ghz --insecure \
  --proto protos/timeline/timeline.proto \
  --call timeline.TimelineService/GetHomeFeed \
  -d '{"user_id":"xxx","pagination":{"page":1,"page_size":20}}' \
  -H 'authorization: Bearer YOUR_TOKEN' \
  -c 50 -n 5000 \
  localhost:50053
```

### 使用 buf 管理 Proto

```bash
# 初始化 buf 配置（已配置则跳过）
buf config init

# lint 检查
buf lint protos/

# 格式化
buf format -w protos/

# 检测 breaking changes
buf breaking protos/ --against '.git#branch=main'
```

### 使用 grpcurl 测试

```bash
# 安装 grpcurl
brew install grpcurl

# 注册用户
grpcurl -plaintext \
  -d '{"username":"testuser","email":"test@example.com","password":"password123","display_name":"Test User"}' \
  localhost:50053 auth.AuthService/Register

# 登录
grpcurl -plaintext \
  -d '{"email":"test@example.com","password":"password123"}' \
  localhost:50053 auth.AuthService/Login

# 带 Token 请求
grpcurl -plaintext \
  -H "authorization: Bearer $TOKEN" \
  -d '{"user_id":"用户ID","pagination":{"page":1,"page_size":20}}' \
  localhost:50053 chat.ChatService/GetConversations
```

### 查看日志

```bash
# 使用 Dozzle Web 界面
open http://localhost:9999

# 或使用 Docker 命令
docker compose -f infra/docker-compose.yml logs -f [service]
```

## 📚 文档

| 文档 | 说明 |
|------|------|
| [架构梳理](docs/架构梳理.md) | 详细架构设计和数据流程 |
| [开发准则](docs/开发准则.md) | 代码规范和最佳实践 |
| [gRPC双向流指南](docs/gRPC双向流指南.md) | Flutter 端双向流使用指南 |
| [gRPC单任务调试教程](docs/grpc%20单任务调试教程.md) | 服务调试方法 |
| [日志风格指南](docs/log%20风格指南.md) | 日志规范 |
| [UI细节](docs/UI%20细节.md) | UI 设计准则 |

## 📄 许可证

MIT License
