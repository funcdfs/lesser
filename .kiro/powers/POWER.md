---
name: "go-flutter-fullstack"
displayName: "Go 1.25 + Flutter 全栈开发专家"
description: "为 Lesser 社交平台提供 Go 后端和 Flutter 前端的专业开发指导，集成多种 MCP 工具增强开发效率。"
keywords: ["go", "golang", "flutter", "dart", "grpc", "protobuf", "microservices", "postgresql", "redis", "rabbitmq", "docker", "traefik"]
---

# Power: Go & Flutter 全栈开发专家

专为 **Lesser 社交平台** 定制的开发助手，精通 Go 1.25 微服务后端和 Flutter 跨平台客户端开发。

## 🎯 核心能力

- **Go 微服务开发**: gRPC 服务、分层架构、高并发处理
- **Flutter 跨平台**: Material 3 UI、状态管理、gRPC-Web 集成
- **基础设施**: Docker Compose、Traefik 网关、PostgreSQL、Redis、RabbitMQ
- **协议设计**: Protocol Buffers、gRPC 双向流

## 🔧 集成的 MCP 工具

### 1. Fetch Server (`fetch`) - 官方文档抓取
网页内容抓取，获取最新官方文档和技术资料。

**工具列表:**
- `fetch` - 抓取网页内容并转换为 Markdown

**核心文档源:**
- **Go 官方**: `go.dev/doc`, `go.dev/blog`, `pkg.go.dev` (标准库最新版)
- **Flutter 官方**: `docs.flutter.dev`, `api.flutter.dev`, `pub.dev`
- **gRPC 官方**: `grpc.io/docs`
- **Protobuf**: `protobuf.dev`

**使用场景:**
- 查询 Go 1.25 最新特性和标准库文档
- 获取 Flutter/Dart 官方 API 文档
- 查阅 gRPC/Protobuf 最佳实践

### 2. Git Server (`git`) - 本地仓库操作
Git 仓库操作，代码版本管理。

**工具列表:**
- `git_status` - 查看工作区状态
- `git_log` - 查看提交历史
- `git_diff` - 查看文件差异
- `git_show` - 查看特定提交内容
- `git_diff_staged` - 查看暂存区差异
- `git_diff_unstaged` - 查看未暂存差异
- `git_commit` - 提交更改
- `git_add` - 暂存文件
- `git_reset` - 重置更改
- `git_branch_list` - 列出分支

**使用场景:**
- 代码审查前查看变更
- 分析提交历史
- 自动生成 commit message

### 3. GitHub Server (`github`) [需配置 Token]
GitHub API 集成，仓库管理和代码搜索。

**工具列表:**
- `search_repositories` - 搜索仓库
- `search_code` - 搜索代码
- `get_file_contents` - 获取文件内容
- `list_issues` - 列出 Issues
- `create_issue` - 创建 Issue
- `create_pull_request` - 创建 PR

**使用场景:**
- 搜索 Go/Flutter 开源项目参考实现
- 查看热门库的源码和最佳实践
- 管理项目 Issues 和 PR

**启用方式:**
1. 在 `mcp.json` 中设置 `GITHUB_PERSONAL_ACCESS_TOKEN`
2. 将 `disabled` 改为 `false`

### 4. Sequential Thinking (`sequential-thinking`)
结构化思维工具，用于复杂问题分析。

**工具列表:**
- `sequentialthinking` - 逐步分析复杂问题

**使用场景:**
- 架构设计决策
- Bug 根因分析
- 性能优化方案制定
- 复杂业务逻辑梳理

### 5. Memory Server (`memory`)
知识图谱持久化记忆，跨会话保存上下文。

**工具列表:**
- `create_entities` - 创建实体节点
- `create_relations` - 创建实体关系
- `search_nodes` - 搜索知识图谱
- `open_nodes` - 打开特定节点
- `delete_entities` - 删除实体
- `delete_relations` - 删除关系

**使用场景:**
- 记录项目架构决策
- 保存常用代码模式
- 跟踪技术债务
- 维护服务依赖关系图

## 📚 技术栈速查

### Go 1.25 新特性
- **容器感知 GOMAXPROCS**: 自动根据 cgroup CPU 限制调整
- **实验性 GC**: `GOEXPERIMENT=greenteagc` 降低 10-40% GC 开销
- **sync.WaitGroup.Go**: 更简洁的 goroutine 创建方式
- **testing/synctest**: 并发测试正式可用

### Lesser 项目架构
```
┌─────────────────────────────────────────────────────────────┐
│  Flutter Client (gRPC-Web)                                  │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│  Traefik (:50050)  →  Gateway (:50051)  →  Services         │
└─────────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│  PostgreSQL  │  Redis  │  RabbitMQ                          │
└─────────────────────────────────────────────────────────────┘
```

### 服务端口速查
| 服务 | 端口 | 说明 |
|------|------|------|
| Traefik gRPC | 50050 | 统一入口 |
| Gateway | 50051 | JWT/限流/路由 |
| Auth | 50052 | 认证 |
| User | 50053 | 用户 |
| Content | 50054 | 内容 |
| Comment | 50055 | 评论 |
| Interaction | 50056 | 交互 |
| Timeline | 50057 | 时间线 |
| Search | 50058 | 搜索 |
| Notification | 50059 | 通知 |
| Chat | 50060 | 聊天 (双向流) |
| SuperUser | 50061 | 超级用户 |

## 🛠️ 开发指南

### Go 后端规范
```go
// 服务目录结构
service/<name>/
├── cmd/server/main.go      // 入口
├── internal/
│   ├── handler/            // gRPC 处理器
│   ├── logic/              // 业务逻辑
│   ├── remote/             // 跨服务调用
│   ├── data_access/        // 数据访问
│   └── messaging/          // MQ 发布/订阅
└── gen_protos/             // 生成代码 [禁止手动修改]

// 错误处理
import "google.golang.org/grpc/status"
import "google.golang.org/grpc/codes"

if req.UserId == "" {
    return nil, status.Error(codes.InvalidArgument, "用户ID不能为空")
}

// Go 1.25 新特性
var wg sync.WaitGroup
wg.Go(func() { /* 并发任务 */ })  // 新的便捷方法
```

### Flutter 客户端规范
```dart
// 功能模块结构
lib/features/<name>/
├── handler/        // 业务逻辑
├── data_access/    // gRPC 数据源
├── models/         // 数据模型
├── pages/          // 页面
└── widgets/        // 组件

// 调用链路
pages → handler → data_access → gRPC → Gateway → Service
```

### CLI 常用命令
```bash
devlesser start              # 启动所有服务
devlesser start infra        # 只启动基础设施
devlesser proto              # 生成 Proto 代码
devlesser test <service>     # 运行服务测试
devlesser status             # 查看服务状态
```

## 📖 Steering 文件

深入技术指导请参考:
- `steering/go-effective.md` - Go 编码规范和最佳实践
- `steering/flutter-best.md` - Flutter 组件架构和状态管理

## ⚡ 快速激活

当检测到以下关键词时自动激活:
- Go/Golang 相关: `go`, `golang`, `grpc`, `protobuf`, `microservice`
- Flutter 相关: `flutter`, `dart`, `widget`, `riverpod`
- 基础设施: `docker`, `traefik`, `postgresql`, `redis`, `rabbitmq`
