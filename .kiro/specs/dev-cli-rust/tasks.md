# Implementation Plan: Dev CLI (Rust)

## Overview

将 `dev.sh` bash 脚本重构为 Rust CLI 工具，使用 clap 进行命令解析，提供 shell 补全、彩色输出和交互式提示。

## Tasks

- [x] 1. 研究和项目初始化
  - [x] 1.1 搜索 Rust CLI 最新最佳实践
    - 搜索 2024-2025 年 Rust CLI 最佳实践和新特性
    - 搜索 clap v4.x 最新用法和推荐模式
    - 搜索 indicatif, console, dialoguer 最新 API
    - 搜索 tokio 异步 CLI 最佳实践
    - 确认依赖版本是否为最新稳定版
    - _Requirements: 1.1, 2.1, 2.2, 2.3, 12.1_
  - [x] 1.2 创建 Cargo.toml 和项目结构
    - 在 `infra/cli/` 创建 Rust 项目
    - 配置依赖: clap, console, indicatif, dialoguer, anyhow, thiserror, tokio
    - 使用搜索到的最新版本号
    - _Requirements: 13.1, 13.2, 13.4_
  - [x] 1.3 实现 main.rs 入口和 cli.rs 命令定义
    - 使用 clap derive 宏定义所有命令和子命令
    - 配置 --help, --version, --debug 全局选项
    - 应用搜索到的最新 clap 模式
    - _Requirements: 1.1, 1.6, 1.7, 1.8_
  - [x] 1.4 实现 error.rs 错误类型定义
    - 使用 thiserror 定义 DevError 枚举
    - 包含所有错误类型: DockerNotAvailable, EnvFileNotFound 等
    - _Requirements: 11.1, 11.2_

- [x] 2. 配置管理模块
  - [x] 2.1 搜索 Rust 配置管理最佳实践
    - 搜索 dotenvy vs dotenv 最新推荐
    - 搜索 Rust 项目根目录查找最佳实践
    - 搜索环境变量验证模式
    - _Requirements: 10.1, 10.2_
  - [x] 2.2 实现 config/paths.rs 路径常量
    - 定义项目根目录查找逻辑
    - 定义 compose 文件、env 文件路径
    - _Requirements: 10.1, 10.2_
  - [x] 2.3 实现 config/env.rs 环境变量管理
    - 加载 .env 文件
    - 验证必需环境变量
    - _Requirements: 10.5, 10.6_
  - [ ]* 2.4 编写属性测试: 缺失环境变量报告
    - **Property 5: Missing environment variable reporting**
    - **Validates: Requirements 10.6**

- [x] 3. 终端 UI 模块
  - [x] 3.1 搜索终端 UI 最新最佳实践
    - 搜索 indicatif 0.17.x 最新 API 和模式
    - 搜索 console crate 最新用法
    - 搜索 dialoguer 0.11.x 最新交互模式
    - 搜索 Rust 终端彩色输出最佳实践
    - _Requirements: 2.1, 2.2, 2.3_
  - [x] 3.2 实现 ui/output.rs 输出格式化
    - 实现 success, warn, error, info, step 函数
    - 实现 header, separator, url 函数
    - 支持 NO_COLOR 环境变量
    - _Requirements: 2.4, 2.5, 2.8_
  - [x] 3.3 实现 ui/spinner.rs Spinner 封装
    - 封装 indicatif ProgressBar
    - 提供 new, set_message, finish 方法
    - _Requirements: 2.2, 2.6_
  - [x] 3.4 实现 ui/prompt.rs 交互提示
    - 封装 dialoguer Confirm, Select, Input
    - _Requirements: 2.3_
  - [ ]* 3.5 编写属性测试: NO_COLOR 环境变量支持
    - **Property 3: NO_COLOR environment variable respect**
    - **Validates: Requirements 2.8**

- [x] 4. Docker 操作模块
  - [x] 4.1 搜索 Rust 进程管理最佳实践
    - 搜索 tokio::process 最新用法
    - 搜索 Rust 子进程流式输出最佳实践
    - 搜索 Rust 交互式进程处理
    - 搜索 Ctrl+C 信号处理最佳实践
    - _Requirements: 12.1, 12.4_
  - [x] 4.2 实现 docker/compose.rs DockerCompose 结构
    - 实现 up, down, restart, logs, exec, build 方法
    - 支持流式输出和交互式执行
    - _Requirements: 3.1, 3.2, 3.3, 3.4_
  - [x] 4.3 实现 docker/health.rs 健康检查
    - 使用 reqwest 检查服务健康端点
    - 返回 HealthCheckResult
    - _Requirements: 3.7_

- [x] 5. Checkpoint - 基础模块完成
  - 确保所有基础模块编译通过
  - 运行现有测试

- [x] 6. 核心命令实现 - 服务管理
  - [x] 6.1 实现 commands/start.rs
    - 支持 all, service, infra, django, chat, client, flutter, react 目标
    - 显示 spinner 等待服务启动
    - _Requirements: 3.1, 3.8, 3.9_
  - [x] 6.2 实现 commands/stop.rs
    - 停止指定服务或所有服务
    - _Requirements: 3.2_
  - [x] 6.3 实现 commands/restart.rs
    - 重启指定服务
    - _Requirements: 3.3_
  - [x] 6.4 实现 commands/logs.rs
    - 支持 --lines 和 --follow 选项
    - 流式输出日志
    - _Requirements: 3.4, 3.5_
  - [x] 6.5 实现 commands/status.rs
    - 显示服务状态表格
    - 显示资源使用和访问 URL
    - _Requirements: 3.6, 3.10_
  - [x] 6.6 实现 commands/test.rs
    - 测试 Django, Chat, Gateway 健康端点
    - _Requirements: 3.7_

- [x] 7. 核心命令实现 - 数据库操作
  - [x] 7.1 实现 commands/migrate.rs
    - 执行 Django 数据库迁移
    - _Requirements: 4.1_
  - [x] 7.2 实现 commands/db.rs (shell, reset 子命令)
    - db shell: 进入 psql
    - db reset: 确认后重置数据库
    - _Requirements: 4.3, 4.4, 4.6_

- [x] 8. 核心命令实现 - 构建和清理
  - [x] 8.1 实现 commands/build.rs 和 commands/rebuild.rs
    - 构建 Docker 镜像
    - rebuild 使用 --no-cache
    - _Requirements: 5.1, 5.2, 5.5_
  - [x] 8.2 实现 commands/proto.rs
    - 调用 scripts/proto/generate.sh
    - _Requirements: 5.3, 5.4_
  - [x] 8.3 实现 commands/clean.rs
    - 支持 containers, volumes 子命令
    - 支持 --force 跳过确认
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_

- [x] 9. Checkpoint - 核心命令完成
  - 确保所有核心命令可执行
  - 手动测试主要功能

- [x] 10. 辅助命令实现
  - [x] 10.1 实现 commands/init.rs 和 commands/check.rs
    - init: 检查依赖、创建 env、生成 proto、构建镜像
    - check: 显示依赖状态和版本
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_
  - [x] 10.2 实现 commands/update.rs
    - 重新生成 proto、重建服务、运行迁移
    - _Requirements: 5.6_
  - [x] 10.3 实现 commands/enter.rs, commands/shell.rs, commands/bash.rs
    - 进入容器交互式 shell
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_
  - [x] 10.4 实现 commands/env.rs 和 commands/urls.rs
    - env: 显示环境变量 (掩码敏感值)
    - urls: 显示服务访问地址
    - _Requirements: 10.3, 10.4_
  - [ ]* 10.5 编写属性测试: 敏感值掩码
    - **Property 4: Sensitive value masking**
    - **Validates: Requirements 10.3**

- [x] 11. Shell 补全实现
  - [x] 11.1 实现 commands/completion.rs
    - 使用 clap_complete 生成补全脚本
    - 支持 bash, zsh, fish
    - _Requirements: 1.2, 1.3, 1.4, 1.5_
  - [ ]* 11.2 编写属性测试: Shell 补全输出有效性
    - **Property 1: Shell completion output validity**
    - **Validates: Requirements 1.3, 1.4, 1.5**
  - [ ]* 11.3 编写属性测试: Help 标志可用性
    - **Property 2: Help flag availability**
    - **Validates: Requirements 1.6**

- [x] 12. 客户端管理命令
  - [x] 12.1 扩展 commands/start.rs 支持 flutter 和 react
    - 启动 Flutter Web 和 React 开发服务器
    - _Requirements: 9.1, 9.2, 9.5, 9.6, 9.7_
  - [x] 12.2 扩展 commands/stop.rs 支持 flutter 和 react
    - 停止客户端进程
    - _Requirements: 9.3, 9.4_

- [x] 13. 最终测试和文档
  - [ ]* 13.1 编写属性测试: 退出码一致性
    - **Property 6: Exit code consistency**
    - **Validates: Requirements 11.7**
  - [x] 13.2 创建 README.md
    - 安装说明
    - 使用示例
    - Shell 补全配置
    - _Requirements: 13.6_
  - [x] 13.3 更新项目文档
    - 更新 docs/架构梳理.md 添加 CLI 工具说明
    - 更新 docs/开发准则.md 添加 CLI 使用指南

- [x] 14. Final Checkpoint
  - 确保所有测试通过
  - 确保 `cargo build --release` 成功
  - 确保 `cargo install --path infra/cli` 可用

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
