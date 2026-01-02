# 项目结构

```
.
├── protos/                     # gRPC Proto 定义 (所有服务共享)
│   ├── common/                 # 通用类型 (Pagination, Timestamp, etc.)
│   ├── auth/                   # 认证服务
│   ├── chat/                   # 聊天服务 (双向流)
│   ├── feed/                   # Feed 服务
│   ├── post/                   # 帖子服务
│   ├── user/                   # 用户服务
│   ├── search/                 # 搜索服务
│   ├── notification/           # 通知服务
│   └── gateway/                # 网关服务
│
├── service/                    # Go 后端服务
│   ├── pkg/                    # 共享公共库 (必须优先使用)
│   │   ├── app/                # 应用生命周期
│   │   ├── broker/             # RabbitMQ 客户端
│   │   ├── cache/              # Redis 封装
│   │   ├── config/             # 环境变量配置
│   │   ├── database/           # PostgreSQL 连接
│   │   ├── grpcclient/         # gRPC 客户端连接池
│   │   └── logger/             # Zap 日志封装
│   │
│   ├── gateway/                # API 网关 (JWT验签/限流/路由)
│   ├── auth/                   # 认证服务 :50054
│   ├── user/                   # 用户服务 :50055
│   ├── post/                   # 帖子服务 :50056
│   ├── feed/                   # Feed 服务 :50057
│   ├── search/                 # 搜索服务 :50058
│   ├── notification/           # 通知服务 :50059
│   └── chat/                   # 聊天服务 :50052 (gRPC 双向流)
│
├── client/
│   └── mobile_flutter/         # Flutter 客户端
│       └── lib/
│           ├── core/           # 核心基础设施
│           │   ├── grpc/       # gRPC 客户端
│           │   ├── network/    # 网络层 (统一客户端/双向流)
│           │   ├── di/         # 依赖注入 (GetIt)
│           │   ├── router/     # 路由 (GoRouter)
│           │   ├── theme/      # 主题
│           │   └── storage/    # 本地存储
│           │
│           ├── features/       # 功能模块 (Clean Architecture)
│           │   └── <module>/
│           │       ├── data/           # 数据层
│           │       │   ├── datasources/
│           │       │   ├── models/
│           │       │   └── repositories/
│           │       ├── domain/         # 领域层
│           │       │   ├── entities/
│           │       │   ├── repositories/
│           │       │   └── usecases/
│           │       └── presentation/   # 展示层
│           │           ├── pages/
│           │           ├── providers/
│           │           └── widgets/
│           │
│           ├── shared/         # 共享组件
│           └── generated/      # Proto 生成代码
│
├── infra/                      # 基础设施配置
│   ├── docker-compose.yml      # 开发环境
│   ├── docker-compose.prod.yml # 生产环境
│   ├── env/                    # 环境变量
│   ├── gateway/                # Traefik 配置
│   ├── database/               # PostgreSQL 初始化
│   ├── cache/                  # Redis 配置
│   └── cli/                    # Rust CLI 工具
│
├── scripts/                    # 脚本文件 (所有脚本必须放这里)
│   ├── proto/                  # Proto 生成脚本
│   └── database/               # 数据库脚本
│
├── docs/                       # 项目文档
└── logs/                       # 日志文件 (按服务分类)
```

## Go 服务内部结构

```
service/<name>/
├── cmd/server/main.go          # 入口
├── internal/
│   ├── handler/                # gRPC 处理器
│   ├── service/                # 业务逻辑
│   ├── repository/             # 数据访问
│   └── model/                  # 数据模型
├── proto/                      # 生成的 Proto 代码
├── Dockerfile
└── Dockerfile.dev
```

## 服务端口

| 服务 | 端口 |
|------|------|
| Traefik HTTP | 80 |
| Traefik gRPC | 50050 |
| Gateway | 50053 |
| Chat (双向流) | 50052 |
| Auth | 50054 |
| User | 50055 |
| Post | 50056 |
| Feed | 50057 |
| Search | 50058 |
| Notification | 50059 |
