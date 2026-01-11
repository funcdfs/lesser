# Lesser - 社交平台

类似 X.com 的社交平台，纯 gRPC 微服务架构。

## 特性

- 纯 gRPC 架构（Gateway + Service Cluster）
- gRPC 双向流实时通信（Chat / Channel）
- Flutter 跨平台客户端
- Docker 一键启动 + CLI 工具管理

## 技术栈

| 层级 | 技术 |
|------|------|
| 客户端 | Flutter |
| 网关 | Traefik + Go Gateway |
| 业务服务 | Go + gRPC |
| 数据层 | PostgreSQL + Redis + RabbitMQ |

## 快速开始

```bash
# 安装 CLI
cargo install --path infra/cli

# 初始化
devlesser init

# 启动
devlesser start

# 查看状态
devlesser status
```

## 常用命令

```bash
devlesser start              # 启动所有服务
devlesser start infra        # 只启动基础设施
devlesser start flutter      # 启动 Flutter 客户端
devlesser stop               # 停止服务
devlesser proto              # 生成 Proto 代码
devlesser test               # 运行测试
devlesser clean              # 清理环境
```

## 访问地址

| 服务 | 地址 |
|------|------|
| gRPC 入口 | localhost:50050 |
| Flutter Web | http://localhost:3000 |
| Traefik Dashboard | http://localhost:8088 |
| RabbitMQ | http://localhost:15672 |
| Dozzle 日志 | http://localhost:9999 |

## 文档

| 文档 | 说明 |
|------|------|
| [架构梳理](docs/架构梳理.md) | 服务架构、端口、目录结构 |
| [开发准则](docs/开发准则.md) | 代码规范、CLI 命令、调试方法 |
| [UI 细节](docs/UI%20细节.md) | UI 设计规范 |

## License

MIT
