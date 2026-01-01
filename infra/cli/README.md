# DevLesser CLI

Lesser 项目开发环境管理 CLI 工具，使用 Rust 实现。

## 特性

- 🚀 Shell 命令补全 (bash/zsh/fish)
- 🎨 彩色终端输出和进度指示器
- 🔒 类型安全和更好的错误提示
- ⚡ 异步命令执行和实时日志流
- 🐳 Docker Compose 服务管理

## 安装

### 从源码安装

```bash
# 在项目根目录执行
cargo install --path infra/cli

# 或者在 cli 目录执行
cd infra/cli
cargo install --path .
```

### 构建发布版本

```bash
cd infra/cli
cargo build --release

# 二进制文件位于 target/release/devlesser
```

## Shell 补全配置

### Bash

```bash
# 添加到 ~/.bashrc
eval "$(devlesser completion bash)"

# 或者保存到文件
devlesser completion bash > ~/.local/share/bash-completion/completions/devlesser
```

### Zsh

```bash
# 添加到 ~/.zshrc
eval "$(devlesser completion zsh)"

# 或者保存到 fpath 目录
devlesser completion zsh > ~/.zfunc/_devlesser
# 确保 ~/.zfunc 在 fpath 中: fpath=(~/.zfunc $fpath)
```

### Fish

```bash
# 保存到 fish completions 目录
devlesser completion fish > ~/.config/fish/completions/devlesser.fish
```

## 使用示例

### 服务管理

```bash
# 启动所有服务
devlesser start

# 启动指定服务
devlesser start gateway
devlesser start chat
devlesser start infra    # PostgreSQL + Redis + RabbitMQ + Traefik

# 停止服务
devlesser stop
devlesser stop gateway

# 重启服务
devlesser restart gateway

# 查看服务状态
devlesser status
devlesser ps             # 别名

# 查看日志
devlesser logs gateway
devlesser logs gateway -f          # 实时跟踪
devlesser logs gateway -n 200      # 显示最近 200 行
```

### 数据库操作

```bash
# 进入数据库 shell
devlesser db shell

# 重置数据库 (会提示确认)
devlesser db reset
```

### 构建和更新

```bash
# 构建镜像
devlesser build
devlesser build gateway

# 重新构建 (无缓存)
devlesser rebuild gateway

# 生成 Proto 代码
devlesser proto
devlesser proto go

# 更新环境 (proto + rebuild)
devlesser update
```

### 开发调试

```bash
# 进入容器
devlesser enter gateway
devlesser enter chat
devlesser enter postgres
devlesser enter redis

# 进入容器 bash
devlesser bash gateway
devlesser bash chat
```

### 环境和配置

```bash
# 显示环境变量 (敏感值会被掩码)
devlesser env

# 显示服务访问地址
devlesser urls

# 检查依赖
devlesser check

# 初始化开发环境
devlesser init
```

### 清理

```bash
# 清理所有 (容器 + 数据卷)
devlesser clean

# 仅清理容器
devlesser clean containers

# 清理数据卷 (会提示确认)
devlesser clean volumes

# 跳过确认
devlesser clean --force
devlesser clean -f
```

### 客户端开发

```bash
# 启动 Flutter Web
devlesser start flutter

# 启动 React Web
devlesser start react

# 停止客户端
devlesser stop flutter
devlesser stop react
```

## 命令参考

| 命令 | 说明 |
|------|------|
| `devlesser start [target]` | 启动服务 (all/service/infra/gateway/chat/client/flutter/react) |
| `devlesser stop [target]` | 停止服务 |
| `devlesser restart [service]` | 重启服务 |
| `devlesser logs [service]` | 查看日志 |
| `devlesser status` / `devlesser ps` | 查看服务状态 |
| `devlesser test` | 测试服务连通性 |
| `devlesser init` | 初始化开发环境 |
| `devlesser check` | 检查依赖 |
| `devlesser update` | 更新环境 |
| `devlesser db shell` | 进入数据库 shell |
| `devlesser db reset` | 重置数据库 |
| `devlesser build [service]` | 构建镜像 |
| `devlesser rebuild [service]` | 重新构建镜像 |
| `devlesser proto [target]` | 生成 Proto 代码 |
| `devlesser clean [subcommand]` | 清理环境 |
| `devlesser enter <service>` | 进入容器 |
| `devlesser bash [service]` | 进入容器 sh |
| `devlesser env` | 显示环境变量 |
| `devlesser urls` | 显示服务访问地址 |
| `devlesser completion <shell>` | 生成 shell 补全脚本 |

## 全局选项

| 选项 | 说明 |
|------|------|
| `-d, --debug` | 启用调试输出 |
| `-h, --help` | 显示帮助信息 |
| `-V, --version` | 显示版本信息 |

## 环境变量

CLI 从 `infra/env/dev.env` 或 `infra/.env.dev` 读取配置。

必需的环境变量:
- `POSTGRES_USER` - PostgreSQL 用户名
- `POSTGRES_PASSWORD` - PostgreSQL 密码
- `POSTGRES_DB` - PostgreSQL 数据库名
- `REDIS_URL` - Redis 连接地址
- `JWT_SECRET_KEY` - JWT 密钥

可选的环境变量:
- `FLUTTER_WEB_PORT` - Flutter Web 端口 (默认: 3000)
- `REACT_PORT` - React 端口 (默认: 3001)
- `NO_COLOR` - 设置后禁用彩色输出
- `DEBUG` - 设置为 true 启用调试输出

## 开发

### 运行测试

```bash
cd infra/cli
cargo test
```

### 代码检查

```bash
cargo clippy
cargo fmt --check
```

## License

MIT
