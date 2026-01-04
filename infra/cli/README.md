# DevLesser CLI

Lesser 项目开发环境管理 CLI 工具，使用 Rust 实现。

所有脚本功能已完全内置到 CLI 中，无需依赖外部 shell 脚本。

## 安装

```bash
cd infra/cli
cargo install --path .
```

## 命令概览

```
devlesser --help

命令:
  start    🚀 启动服务
  stop     🛑 停止服务
  restart  🔄 重启服务
  clean    🗑️  清理环境
  init     ⚡ 初始化开发环境
  status   📊 查看服务状态
  proto    🔧 生成 Proto 代码 (别名: gen)
  test     🧪 运行测试
  hosts    🌐 配置本地 hosts
  prod     🏭 生产环境管理
```

## 开发环境命令

### 初始化开发环境

```bash
# 完整初始化（含 hosts 配置）
devlesser init

# 跳过确认
devlesser init -f

# 跳过 hosts 配置
devlesser init --skip-hosts
```

初始化会:
1. 配置本地 hosts（需要 sudo 权限）
2. 启动基础设施 (PostgreSQL, Redis, RabbitMQ, Traefik)
3. 启动后端服务 (Gateway, Workers, Chat)
4. 创建超级管理员和测试用户

### 服务管理

```bash
# 启动所有服务
devlesser start

# 启动指定目标
devlesser start infra     # 仅基础设施
devlesser start service   # 仅后端服务

# Flutter 开发
devlesser start flutter   # 交互式选择平台 (Web/Android/iOS)
devlesser start fw        # Flutter Web (别名: flutter-web)
devlesser start fa        # Flutter Android (别名: flutter-android)

# 停止服务
devlesser stop
devlesser stop gateway    # 停止指定服务

# 重启服务
devlesser restart
devlesser restart chat    # 重启指定服务

# 查看状态
devlesser status
```

### 清理环境

```bash
# 清理所有 (容器 + 数据卷)
devlesser clean

# 仅清理容器 (保留数据)
devlesser clean containers

# 清理数据卷
devlesser clean volumes

# 清理聊天数据
devlesser clean chat

# 清理用户数据
devlesser clean users

# 跳过确认
devlesser clean -f
```

### Proto 代码生成

```bash
devlesser proto          # 生成所有 (别名: devlesser gen)
devlesser proto go       # 仅 Go
devlesser proto dart     # 仅 Dart
devlesser gen dart       # 使用别名
```

### 运行测试

```bash
devlesser test           # 运行所有服务测试
devlesser test auth      # Auth 服务测试（注册/登录/登出）
devlesser test user      # User 服务测试（关注/屏蔽/资料）
devlesser test content   # Content 服务测试（发布/更新/删除）
devlesser test comment   # Comment 服务测试（评论/回复/点赞）
devlesser test interaction  # Interaction 服务测试（点赞/收藏/转发）
devlesser test timeline  # Timeline 服务测试（Feed 流）
devlesser test search    # Search 服务测试（搜索帖子/用户/评论）
devlesser test notification  # Notification 服务测试（通知列表/已读）
devlesser test chat      # Chat 服务测试（私聊/消息/已读回执）
devlesser test gateway   # Gateway 路由测试（认证/路由转发）
devlesser test superuser # SuperUser 服务测试（管理员操作）
devlesser test su        # SuperUser 别名
```

测试功能完全内置，每个服务测试会:
- 创建测试用户
- 模拟真实用户行为
- 测试完整的 API 流程
- 自动清理测试数据
- 输出测试结果汇总

### 配置本地 hosts

```bash
devlesser hosts          # 配置本地域名 (需要 sudo)
```

配置后可通过以下域名访问服务:
- http://traefik.local → Traefik Dashboard
- http://rabbitmq.local → RabbitMQ Management
- http://redis.local → RedisInsight
- http://pghero.local → PgHero (PostgreSQL 监控)
- http://jaeger.local → Jaeger UI (链路追踪)
- http://dozzle.local → Dozzle (容器日志)

## 生产环境命令

```bash
# 启动生产环境
devlesser prod start

# 停止生产环境
devlesser prod stop
devlesser prod stop -f   # 跳过确认

# 重启服务
devlesser prod restart

# 查看状态
devlesser prod status

# 查看日志
devlesser prod logs              # 所有服务
devlesser prod logs gateway      # 指定服务
devlesser prod logs -n 200       # 指定行数

# 部署更新
devlesser prod deploy

# 备份数据库
devlesser prod backup

# 验证环境变量
devlesser prod validate
```

生产环境需要配置 `infra/env/prod.env` 文件，必需的环境变量:
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`
- `POSTGRES_DB`
- `JWT_SECRET_KEY`
- `REDIS_URL`

## 测试账号

| 用户名 | 邮箱 | 密码 | 说明 |
|--------|------|------|------|
| funcdfs | funcdfs@gmail.com | fw142857 | 超级管理员 |
| testuser1 | testuser1@example.com | testtesttest | 测试用户 |
| testuser2 | testuser2@example.com | testtesttest | 测试用户 |

## 服务端口

| 服务 | 端口 | 说明 |
|------|------|------|
| Traefik gRPC | 50050 | gRPC 入口 |
| Gateway gRPC | 50053 | API 网关 |
| Auth gRPC | 50054 | 认证服务 |
| User gRPC | 50055 | 用户服务 |
| Content gRPC | 50056 | 内容服务 |
| Search gRPC | 50058 | 搜索服务 |
| Notification gRPC | 50059 | 通知服务 |
| Interaction gRPC | 50060 | 交互服务 |
| Comment gRPC | 50061 | 评论服务 |
| Timeline gRPC | 50062 | 时间线服务 |
| Chat gRPC | 50052 | 聊天服务 |
| SuperUser gRPC | 50063 | 超级管理员服务 |
| Traefik Dashboard | 8088 | 管理界面 |
| RabbitMQ Management | 15672 | 管理界面 |
| Dozzle | 9999 | 日志查看器 |

## 依赖要求

- Docker & Docker Compose
- Rust (编译 CLI)
- protoc (Proto 代码生成)
- grpcurl (测试功能)
- Go (生成 Go 代码)
- Dart (生成 Dart 代码)

安装依赖:
```bash
# macOS
brew install protobuf grpcurl

# Go protoc 插件 (自动安装)
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Dart protoc 插件 (自动安装)
dart pub global activate protoc_plugin
```
