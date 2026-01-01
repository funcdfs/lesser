# DevLesser CLI

Lesser 项目开发环境管理 CLI 工具，使用 Rust 实现。

## 安装

```bash
cd infra/cli
cargo install --path .
```

## 命令

```
devlesser --help

命令:
  start    🚀 启动服务
  stop     🛑 停止服务
  restart  🔄 重启服务
  clean    🗑️  清理环境
  init     ⚡ 初始化开发环境
  status   📊 查看服务状态
  proto    🔧 生成 Proto 代码
```

## 使用示例

### 初始化开发环境

```bash
# 首次使用，初始化环境并创建测试用户
devlesser init

# 跳过确认
devlesser init -f
```

初始化会:
1. 启动基础设施 (PostgreSQL, Redis, RabbitMQ, Traefik)
2. 启动后端服务 (Gateway, Workers, Chat)
3. 创建测试用户 (testuser1, testuser2)

### 服务管理

```bash
# 启动所有服务
devlesser start

# 启动指定目标
devlesser start infra     # 仅基础设施
devlesser start service   # 仅后端服务
devlesser start flutter   # Flutter Web 开发服务器

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
devlesser proto          # 生成所有
devlesser proto go       # 仅 Go
devlesser proto dart     # 仅 Dart
```

## 测试账号

| 用户名 | 邮箱 | 密码 |
|--------|------|------|
| testuser1 | testuser1@example.com | testtesttest |
| testuser2 | testuser2@example.com | testtesttest |

## 服务端口

| 服务 | 端口 | 说明 |
|------|------|------|
| Gateway gRPC | 50053 | API 网关 |
| Chat gRPC | 50052 | 聊天服务 |
| Chat WebSocket | 8081 | 实时消息 |
| Traefik Dashboard | 8088 | 管理界面 |
| RabbitMQ Management | 15672 | 管理界面 |
| Dozzle | 9999 | 日志查看器 |
