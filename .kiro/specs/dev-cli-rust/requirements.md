# Requirements Document

## Introduction

本项目旨在将现有的 `dev.sh` bash 脚本（1294 行）重构为一个 Rust CLI 工具 `dev`，提供：
- Shell 命令补全（bash/zsh/fish）
- 类型安全和更好的可维护性
- 丰富的终端 UI（进度条、彩色输出、交互式提示）
- 异步命令执行和实时日志流

CLI 工具代码位于 `infra/cli/` 目录，编译后的二进制文件命名为 `dev`。

## Glossary

- **CLI**: Command Line Interface，命令行界面工具
- **DevCLI**: 本项目开发的 Rust CLI 工具，二进制名称为 `dev`
- **Service**: Docker Compose 管理的后端服务（Django、Chat、PostgreSQL、Redis、Traefik 等）
- **Client**: 前端客户端应用（Flutter Web、React Web）
- **Proto**: Protocol Buffers 定义文件及其生成的代码
- **Migration**: 数据库迁移文件和操作
- **Spinner**: 终端中的加载动画指示器
- **Progress Bar**: 终端中的进度条组件

## Requirements

### Requirement 1: CLI 框架和命令补全

**User Story:** As a developer, I want a CLI tool with shell completion support, so that I can quickly discover and execute commands without memorizing them.

#### Acceptance Criteria

1. THE DevCLI SHALL use clap (v4.x) crate with derive macros for command parsing
2. THE DevCLI SHALL use clap_complete crate for shell completion generation
3. WHEN a user runs `dev completion bash`, THE DevCLI SHALL output bash completion script to stdout
4. WHEN a user runs `dev completion zsh`, THE DevCLI SHALL output zsh completion script to stdout
5. WHEN a user runs `dev completion fish`, THE DevCLI SHALL output fish completion script to stdout
6. THE DevCLI SHALL support `--help` and `-h` flags for all commands and subcommands
7. THE DevCLI SHALL support `--version` and `-V` flags to display version information
8. THE DevCLI SHALL use subcommand aliases (e.g., `ps` as alias for `status`)

### Requirement 2: 终端 UI 和输出格式

**User Story:** As a developer, I want beautiful and informative terminal output, so that I can easily understand the status and progress of operations.

#### Acceptance Criteria

1. THE DevCLI SHALL use console crate for terminal styling and emoji support
2. THE DevCLI SHALL use indicatif crate for progress bars and spinners
3. THE DevCLI SHALL use dialoguer crate for interactive prompts (confirm, select, input)
4. THE DevCLI SHALL display colored output: green for success (✓), yellow for warnings (⚠), red for errors (✗), cyan for info (ℹ)
5. THE DevCLI SHALL display emoji icons consistent with the original script (🚀🐳🗄🔌🌐📱⚙)
6. WHEN executing long-running operations, THE DevCLI SHALL display a spinner with descriptive message
7. WHEN displaying service status, THE DevCLI SHALL use formatted tables with aligned columns
8. THE DevCLI SHALL respect NO_COLOR environment variable to disable colors
9. THE DevCLI SHALL auto-detect terminal capabilities and adjust output accordingly

### Requirement 3: 服务管理命令

**User Story:** As a developer, I want to manage Docker services easily, so that I can start, stop, and monitor the development environment.

#### Acceptance Criteria

1. WHEN a user runs `dev start [target]`, THE DevCLI SHALL start the specified services using docker compose
2. WHEN a user runs `dev stop [target]`, THE DevCLI SHALL stop the specified services
3. WHEN a user runs `dev restart [service]`, THE DevCLI SHALL restart the specified service
4. WHEN a user runs `dev logs [service] [--lines N]`, THE DevCLI SHALL display service logs with optional line limit (default 100)
5. WHEN a user runs `dev logs [service] -f`, THE DevCLI SHALL follow logs in real-time
6. WHEN a user runs `dev status` or `dev ps`, THE DevCLI SHALL display service status table with name, state, health, and ports
7. WHEN a user runs `dev test`, THE DevCLI SHALL test service connectivity by calling health endpoints
8. THE DevCLI SHALL support start targets: all (default), service, infra, django, chat, client, flutter, react
9. WHEN services are starting, THE DevCLI SHALL display a spinner and wait for health checks
10. WHEN displaying status, THE DevCLI SHALL show resource usage (CPU%, Memory) for running containers

### Requirement 4: 数据库操作命令

**User Story:** As a developer, I want to manage database migrations and access, so that I can maintain the database schema and debug data issues.

#### Acceptance Criteria

1. WHEN a user runs `dev migrate`, THE DevCLI SHALL execute Django database migrations
2. WHEN a user runs `dev makemigrations [app]`, THE DevCLI SHALL generate Django migration files for the specified app
3. WHEN a user runs `dev db shell`, THE DevCLI SHALL open a PostgreSQL interactive shell (psql)
4. WHEN a user runs `dev db reset`, THE DevCLI SHALL prompt for confirmation using dialoguer and reset the database
5. WHEN a user runs `dev createsuperuser`, THE DevCLI SHALL create a Django superuser interactively
6. IF database reset is confirmed, THEN THE DevCLI SHALL stop dependent services, drop and recreate database, restart services, and run migrations

### Requirement 5: 构建和部署命令

**User Story:** As a developer, I want to build and rebuild Docker images, so that I can update services with code changes.

#### Acceptance Criteria

1. WHEN a user runs `dev build [service]`, THE DevCLI SHALL build Docker images for the specified service or all services
2. WHEN a user runs `dev rebuild [service]`, THE DevCLI SHALL rebuild images with --no-cache flag and restart services
3. WHEN a user runs `dev proto [target]`, THE DevCLI SHALL generate Protocol Buffer code by calling scripts/proto/generate.sh
4. THE DevCLI SHALL support proto targets: all (default), python, go, dart, typescript
5. WHEN building images, THE DevCLI SHALL display a progress indicator with build output
6. WHEN a user runs `dev update`, THE DevCLI SHALL regenerate proto code, rebuild services, and run all migrations

### Requirement 6: 清理操作命令

**User Story:** As a developer, I want to clean up containers and volumes, so that I can reset the development environment when needed.

#### Acceptance Criteria

1. WHEN a user runs `dev clean`, THE DevCLI SHALL prompt for confirmation and remove all containers, volumes, and orphans
2. WHEN a user runs `dev clean containers`, THE DevCLI SHALL remove only containers (no confirmation needed)
3. WHEN a user runs `dev clean volumes`, THE DevCLI SHALL prompt for confirmation and remove data volumes
4. IF a destructive operation is requested, THEN THE DevCLI SHALL use dialoguer::Confirm for user confirmation
5. THE DevCLI SHALL display a warning message in yellow before destructive operations
6. WHEN a user runs `dev clean --force` or `-f`, THE DevCLI SHALL skip confirmation prompts

### Requirement 7: 初始化和依赖检查命令

**User Story:** As a developer, I want to initialize and verify the development environment, so that I can set up and maintain my local development setup.

#### Acceptance Criteria

1. WHEN a user runs `dev init`, THE DevCLI SHALL check dependencies, create env files, generate proto code, and build images
2. WHEN a user runs `dev check`, THE DevCLI SHALL verify all required dependencies are installed and display versions
3. THE DevCLI SHALL check for: Docker, Docker Compose, Python3 (required); Flutter, Node.js (optional)
4. WHEN checking dependencies, THE DevCLI SHALL display ✅ for installed and ❌ for missing dependencies
5. WHEN a dependency is missing, THE DevCLI SHALL display installation instructions with URLs
6. WHEN init completes, THE DevCLI SHALL display next steps guide

### Requirement 8: 开发调试命令

**User Story:** As a developer, I want to access container shells and debug services, so that I can troubleshoot issues directly.

#### Acceptance Criteria

1. WHEN a user runs `dev enter <service>`, THE DevCLI SHALL open an interactive shell in the specified container
2. WHEN a user runs `dev shell`, THE DevCLI SHALL open Django Python shell (manage.py shell)
3. WHEN a user runs `dev bash [service]`, THE DevCLI SHALL open a sh shell in the container (default: django)
4. THE DevCLI SHALL support entering: django/python, chat/go, postgres/db, redis/cache, traefik/gateway
5. WHEN entering postgres, THE DevCLI SHALL use psql with correct credentials
6. WHEN entering redis, THE DevCLI SHALL use redis-cli

### Requirement 9: 客户端管理命令

**User Story:** As a developer, I want to manage frontend clients, so that I can start and stop Flutter and React development servers.

#### Acceptance Criteria

1. WHEN a user runs `dev start flutter`, THE DevCLI SHALL start Flutter Web development server
2. WHEN a user runs `dev start react`, THE DevCLI SHALL start React development server
3. WHEN a user runs `dev stop flutter`, THE DevCLI SHALL stop Flutter processes (pkill flutter)
4. WHEN a user runs `dev stop react`, THE DevCLI SHALL stop React processes (pkill next/npm)
5. THE DevCLI SHALL read FLUTTER_WEB_PORT (default: 3000) and REACT_PORT (default: 3001) from environment
6. WHEN starting clients, THE DevCLI SHALL first run dependency installation (flutter pub get / npm install)
7. WHEN client starts successfully, THE DevCLI SHALL display the access URL

### Requirement 10: 配置管理

**User Story:** As a developer, I want the CLI to manage configuration files, so that environment settings are properly handled.

#### Acceptance Criteria

1. THE DevCLI SHALL read configuration from `infra/env/dev.env` file
2. THE DevCLI SHALL support fallback to legacy location `infra/.env.dev` if new location doesn't exist
3. WHEN a user runs `dev env`, THE DevCLI SHALL display current environment variables with sensitive values masked (PASSWORD, SECRET)
4. WHEN a user runs `dev urls`, THE DevCLI SHALL display all service access URLs in a formatted list
5. THE DevCLI SHALL validate required environment variables (POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB, REDIS_URL, DJANGO_SECRET_KEY) before executing commands
6. IF required env vars are missing, THEN THE DevCLI SHALL display error with list of missing variables

### Requirement 11: 错误处理和用户体验

**User Story:** As a developer, I want clear error messages and feedback, so that I can understand and resolve issues quickly.

#### Acceptance Criteria

1. THE DevCLI SHALL use anyhow crate for application error handling with context
2. THE DevCLI SHALL use thiserror crate for defining custom error types
3. IF a required dependency is missing, THEN THE DevCLI SHALL display installation instructions with clickable URLs
4. IF a command fails, THEN THE DevCLI SHALL display a clear error message with suggested actions
5. THE DevCLI SHALL use consistent colored output: green (success), yellow (warning), red (error), cyan (info), dim (secondary)
6. WHEN DEBUG=true environment variable is set, THE DevCLI SHALL output debug information
7. THE DevCLI SHALL exit with code 0 on success and non-zero on failure
8. WHEN a docker command fails, THE DevCLI SHALL suggest running `dev logs` to check service logs

### Requirement 12: 异步执行和性能

**User Story:** As a developer, I want the CLI to execute commands efficiently, so that I don't waste time waiting for operations.

#### Acceptance Criteria

1. THE DevCLI SHALL use tokio runtime for async command execution
2. WHEN executing docker compose commands, THE DevCLI SHALL stream output in real-time
3. WHEN starting multiple services, THE DevCLI SHALL display a multi-progress bar using indicatif::MultiProgress
4. THE DevCLI SHALL handle Ctrl+C gracefully and clean up child processes
5. WHEN waiting for services to start, THE DevCLI SHALL poll health endpoints with configurable timeout
6. THE DevCLI SHALL cache docker compose file path resolution for performance

### Requirement 13: 项目结构和可维护性

**User Story:** As a developer, I want the CLI codebase to be well-organized, so that it's easy to maintain and extend.

#### Acceptance Criteria

1. THE DevCLI project SHALL be located in `infra/cli/` directory
2. THE DevCLI SHALL use Rust 2021 edition
3. THE DevCLI SHALL organize code into modules: cli (command definitions), commands (implementations), config, docker, ui, utils
4. THE DevCLI SHALL have a Cargo.toml with appropriate metadata (name="dev", version, authors, description)
5. THE DevCLI binary SHALL be named `dev` for easy invocation
6. THE DevCLI SHALL include a README.md with installation and usage instructions
7. THE DevCLI SHALL support installation via `cargo install --path infra/cli`
