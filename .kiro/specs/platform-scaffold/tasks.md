# Implementation Plan: Platform Scaffold

## Overview

本任务列表将按照以下顺序实现脚手架：
1. 基础设施配置 (Docker, Traefik, PostgreSQL, Redis)
2. Proto 定义和代码生成脚本
3. Django 模块化单体服务
4. Go 聊天服务
5. Flutter 客户端架构
6. React Web 客户端架构
7. 开发脚本 (dev.sh, prod.sh)

## Tasks

- [x] 1. 基础设施配置
  - [x] 1.1 创建 infra 目录结构和环境变量文件
    - 创建 `infra/.env.dev` 和 `infra/.env.prod.example`
    - 定义数据库、Redis、服务端口等环境变量
    - _Requirements: 12.1, 12.3_
  - [x] 1.2 配置 Traefik 网关
    - 创建 `infra/gateway/traefik.yml` 静态配置
    - 创建 `infra/gateway/dynamic/routes.yml` 动态路由
    - 配置 REST/gRPC/WebSocket 路由规则
    - _Requirements: 3.2, 3.5_
  - [x] 1.3 配置 PostgreSQL 数据库
    - 创建 `infra/database/init.sql` 初始化脚本
    - 配置数据库用户和权限
    - _Requirements: 3.3_
  - [x] 1.4 配置 Redis 缓存
    - 创建 `infra/cache/redis.conf` 配置文件
    - _Requirements: 3.4_
  - [x] 1.5 创建 Docker Compose 配置
    - 创建 `infra/docker-compose.yml` 开发环境配置
    - 创建 `infra/docker-compose.prod.yml` 生产环境配置
    - 配置服务依赖和健康检查
    - _Requirements: 3.1, 3.6_

- [x] 2. Proto 定义和代码生成
  - [x] 2.1 创建共享 Proto 定义
    - 创建 `protos/common/common.proto`
    - 创建 `protos/auth/auth.proto`
    - 创建 `protos/feed/feed.proto`
    - 创建 `protos/post/post.proto`
    - 创建 `protos/chat/chat.proto`
    - 创建 `protos/notification/notification.proto`
    - _Requirements: 3.1_
  - [x] 2.2 创建 Proto 代码生成脚本
    - 创建 `scripts/proto/generate.sh`
    - 支持生成 Python, Go, Dart, TypeScript 代码
    - _Requirements: 3.1_

- [x] 3. Django 模块化单体服务
  - [x] 3.1 创建 Django 项目结构
    - 创建 `service/core_django/` 目录结构
    - 创建 `config/settings/base.py`, `dev.py`, `prod.py`
    - 创建 `config/urls.py`, `wsgi.py`, `asgi.py`
    - 创建 `requirements.txt` 和 `Dockerfile`
    - _Requirements: 4.1_
  - [x] 3.2 实现 users app (认证模块)
    - 创建 `apps/users/` 目录结构
    - 实现 User 模型和 Follow 模型
    - 实现 serializers, views, urls
    - 实现 gRPC 服务接口
    - _Requirements: 4.2, 4.3, 4.4, 4.5, 4.6_
  - [x] 3.3 实现 posts app (帖子模块)
    - 创建 `apps/posts/` 目录结构
    - 实现 Post 模型 (支持 story/short/column 类型)
    - 实现 serializers, views, urls
    - 实现 Celery 任务 (Story 24h 自动删除)
    - _Requirements: 6.1, 6.2, 6.3, 6.4_
  - [x] 3.4 实现 feeds app (互动模块)
    - 创建 `apps/feeds/` 目录结构
    - 实现 Like, Repost, Comment, Bookmark 模型
    - 实现 serializers, views, urls
    - _Requirements: 5.1, 5.2, 5.3, 5.4_
  - [x] 3.5 实现 search app (搜索模块)
    - 创建 `apps/search/` 目录结构
    - 实现搜索 views 和 urls
    - _Requirements: 7.1, 7.2, 7.3_
  - [x] 3.6 实现 notifications app (通知模块)
    - 创建 `apps/notifications/` 目录结构
    - 实现 Notification 模型
    - 实现 serializers, views, urls
    - _Requirements: 8.1, 8.2, 8.3_
  - [x] 3.7 实现 core 共享模块
    - 创建 `core/` 目录结构
    - 实现基础模型类、权限类、分页类
    - 实现中间件和工具函数
    - _Requirements: 4.1_
  - [x] 3.8 配置 gRPC 服务器
    - 创建 `grpc_server/` 目录
    - 实现 gRPC 服务器启动逻辑
    - 实现 gRPC 拦截器
    - _Requirements: 3.1_

- [x] 4. Go 聊天服务
  - [x] 4.1 创建 Go 项目结构
    - 创建 `service/chat_go/` 目录结构
    - 创建 `go.mod`, `Makefile`, `Dockerfile`
    - 创建 `cmd/server/main.go` 入口
    - _Requirements: 9.4_
  - [x] 4.2 实现配置和数据库连接
    - 创建 `internal/config/config.go`
    - 创建 `pkg/database/postgres.go`
    - 创建 `pkg/cache/redis.go`
    - _Requirements: 9.5_
  - [x] 4.3 实现数据模型和仓库层
    - 创建 `internal/model/` 目录
    - 实现 Conversation, Message 模型
    - 创建 `internal/repository/` 目录
    - _Requirements: 9.1, 9.2, 9.3, 9.5_
  - [x] 4.4 实现业务逻辑层
    - 创建 `internal/service/` 目录
    - 实现聊天业务逻辑
    - _Requirements: 9.1, 9.2, 9.3_
  - [x] 4.5 实现 HTTP/WebSocket 服务器
    - 创建 `internal/server/http.go`
    - 创建 `internal/handler/ws/hub.go`
    - 实现 WebSocket 连接管理
    - _Requirements: 9.4_
  - [x] 4.6 实现 gRPC 服务器
    - 创建 `internal/server/grpc.go`
    - 创建 `internal/handler/grpc/chat.go`
    - _Requirements: 9.4_

- [x] 5. Checkpoint - 后端服务验证
  - 确保 Docker Compose 能正常启动所有服务
  - 确保 Django 和 Go 服务能正常通信
  - 如有问题请询问用户

- [x] 6. Flutter 客户端架构，创建骨架。不要执行具体业务逻辑，并且创建登录注册登出的功能。用来和后端联动
  - [x] 6.1 配置 Flutter 项目
    - 更新 `pubspec.yaml` 添加依赖
    - 配置 `analysis_options.yaml`
    - _Requirements: 10.1, 10.8_
  - [x] 6.2 创建 core 模块
    - 创建 `lib/core/api/` API 客户端和 gRPC 客户端
    - 创建 `lib/core/constants/` 常量定义
    - 创建 `lib/core/theme/` 主题配置
    - 创建 `lib/core/utils/` 工具函数
    - 创建 `lib/core/di/` 依赖注入配置
    - _Requirements: 10.1_
  - [x] 6.3 创建 auth feature 模块
    - 创建 `lib/features/auth/data/` 数据层
    - 创建 `lib/features/auth/domain/` 领域层
    - 创建 `lib/features/auth/presentation/` 表现层
    - _Requirements: 10.1_
  - [x] 6.4 创建 feeds feature 模块
    - 创建 `lib/features/feeds/data/` 数据层
    - 创建 `lib/features/feeds/domain/` 领域层
    - 创建 `lib/features/feeds/presentation/` 表现层
    - _Requirements: 10.3_
  - [x] 6.5 创建 search feature 模块
    - 创建完整的 Clean Architecture 结构
    - _Requirements: 10.4_
  - [x] 6.6 创建 post feature 模块
    - 创建完整的 Clean Architecture 结构
    - 支持三种帖子类型选择
    - _Requirements: 10.5_
  - [x] 6.7 创建 notifications feature 模块
    - 创建完整的 Clean Architecture 结构
    - _Requirements: 10.6_
  - [x] 6.8 创建 chat feature 模块
    - 创建完整的 Clean Architecture 结构
    - 包含 gRPC 数据源
    - _Requirements: 10.1_
  - [x] 6.9 创建 profile feature 模块
    - 创建完整的 Clean Architecture 结构
    - _Requirements: 10.7_
  - [x] 6.10 创建 navigation 模块
    - 创建底部导航栏 (5 个 tab)
    - 创建主导航页面
    - _Requirements: 10.2_
  - [x] 6.11 创建 shared 模块
    - 创建共享 widgets
    - 创建共享 models
    - _Requirements: 10.1_
  - [x] 6.12 创建 前端通信流程图。用流程图绘制。说明每一个层的作用。和数据流向。


- [x] 7. 后端测试
  - [x] 7.1 Django 单元测试配置
    - 配置 pytest 和 pytest-django
    - 创建测试工厂和 fixtures
    - _Requirements: 4.1_
  - [x] 7.2 Django 模型测试
    - 测试 User, Post, Comment 等模型
    - 测试模型验证和约束
    - _Requirements: 4.2, 6.1, 5.1_
  - [x] 7.3 Django API 测试
    - 测试认证 API 端点
    - 测试 CRUD 操作
    - _Requirements: 4.2, 4.3, 4.4_
  - [x] 7.4 Go 单元测试
    - 测试 service 层业务逻辑
    - 测试 repository 层数据操作
    - _Requirements: 9.1, 9.2, 9.3_
  - [x] 7.5 集成测试
    - 测试 Django 和 Go 服务间 gRPC 通信
    - 测试 WebSocket 连接
    - _Requirements: 3.1, 9.4_


- [搁置：] 8. React Web 客户端架构
  - [ ] 8.1 初始化 Next.js 项目
    - 创建 `client/web_react/` 目录结构
    - 配置 `package.json`, `next.config.ts`, `tsconfig.json`
    - 配置 `tailwind.config.ts`
    - _Requirements: 11.1, 11.3, 11.4_
  - [ ] 8.2 创建 App Router 结构
    - 创建 `src/app/` 目录和页面路由
    - 创建 layout 和基础页面
    - _Requirements: 11.1, 11.2_
  - [ ] 8.3 创建 lib 模块
    - 创建 `src/lib/api/` API 客户端
    - 创建 `src/lib/utils/` 工具函数
    - _Requirements: 11.1_
  - [ ] 8.4 创建 features 模块
    - 创建各功能模块目录结构
    - _Requirements: 11.2_
  - [ ] 8.5 创建 components 模块
    - 创建 `src/components/ui/` 基础组件
    - 创建 `src/components/features/` 功能组件
    - _Requirements: 11.2_

- [x] 9. 开发脚本
  - [x] 9.1 完善 dev.sh 开发脚本，各种细节都要存在 --help 列出所有可能的配置。
    - 强化 start/stop/restart/logs 命令
    - 强化 service/client 子命令
    - 强化依赖检查和环境变量验证
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_
  - [x] 9.2 创建 prod.sh 生产脚本，可以暂时搁置。随意写就可以。 
    - 实现 start/stop 命令
    - 实现环境变量验证
    - _Requirements: 2.1, 2.2, 2.3, 2.4_
  - [x] 9.3 创建辅助脚本，dev.sh init 就会初始化。注意 dev.sh 是唯一的入口。 
    - 创建 `scripts/dev/setup.sh` 开发环境初始化
    - 更新 `scripts/proto/generate.sh` Proto 生成脚本
    - _Requirements: 3.1_

- [-] 10. 客户端测试
  - [x] 10.1 Flutter 单元测试
    - 测试 use cases 业务逻辑
    - 测试 repositories 数据层
    - _Requirements: 10.1_
  - [x] 10.2 Flutter Widget 测试
    - 测试核心 widgets
    - 测试页面组件

- [x] 11. 配置文件和文档
  - [x] 11.1 更新 .gitignore
    - 添加环境变量文件忽略规则，环境变量文件统一迁移到 infra/env 下面不要随便放。 
    - 添加生成代码忽略规则, 添加 ai 开发准则。确保后续开发的一致性。 
    - _Requirements: 12.2_
  - [x] 11.2 更新 README.md
    - 添加项目说明和快速开始指南
    - 添加架构说明
    - _Requirements: 3.1_

- [ ] 12. Final Checkpoint - 完整验证
  - 跑通整个 docker+django+grpc+frontend 的用户登录。注册流程。 
  - 运行 `./dev.sh start` 验证所有服务启动
  - 验证 API 端点可访问
  - 验证客户端能正常启动
  - 运行所有测试确保通过
  - 如有问题请询问用户

## Notes

- 任务按依赖顺序排列，请按顺序执行
- 每个任务完成后验证功能正常再继续
- Checkpoint 任务用于阶段性验证
- 所有代码应遵循各语言的最佳实践
- 测试任务已包含在内，确保代码质量
