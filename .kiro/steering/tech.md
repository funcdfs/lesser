# 技术栈

## 后端服务 (Go)

| 组件 | 技术 |
|------|------|
| 语言 | Go 1.23.x |
| 通信协议 | gRPC + Protocol Buffers |
| 数据库 | PostgreSQL 16 |
| 缓存 | Redis 7 |
| 消息队列 | RabbitMQ（仅次要异步任务） |
| 日志 | Uber Zap (JSON 格式) |
| 网关 | Traefik 3.x |

## 客户端 (Flutter)

| 组件 | 技术 |
|------|------|
| SDK | Flutter 3.x / Dart ^3.10.4 |
| 状态管理 | Riverpod 3.x |
| 路由 | GoRouter |
| 依赖注入 | GetIt + Injectable |
| gRPC | grpc + protobuf |
| 本地存储 | SharedPreferences + FlutterSecureStorage |

## 基础设施

- Docker + Docker Compose
- Traefik (反向代理/负载均衡)
- Dozzle (日志查看)

## 常用命令

### 开发环境管理 (Rust CLI: devlesser)

```bash
# 安装 CLI
cargo install --path infra/cli

# 服务管理
devlesser start              # 启动所有服务
devlesser start infra        # 只启动基础设施 (PostgreSQL/Redis/RabbitMQ/Traefik)
devlesser start service      # 只启动后端服务
devlesser start flutter      # Flutter 交互式选择平台
devlesser start flutter-web  # Flutter Web
devlesser start flutter-android  # Flutter Android
devlesser stop               # 停止服务
devlesser restart [service]  # 重启服务
devlesser status             # 查看状态

# Proto 代码生成
devlesser proto              # 生成所有 Proto 代码

# 清理
devlesser clean              # 清理所有
devlesser clean containers   # 仅清理容器
devlesser clean volumes      # 清理数据卷

# 初始化
devlesser init               # 初始化开发环境
```

### Flutter 客户端

```bash
cd client/mobile_flutter

# 依赖安装
flutter pub get

# 代码生成 (Riverpod/Freezed/Injectable)
dart run build_runner build --delete-conflicting-outputs

# 运行
flutter run -d chrome    # Web
flutter run              # 移动端
```

### Proto 代码生成

```bash
# 使用脚本
./scripts/proto/generate.sh

# 或使用 CLI
devlesser proto
```
