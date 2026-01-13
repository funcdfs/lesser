---
inclusion: always
---

# 项目架构概览

> 详细架构图和 Messaging 层说明见 `docs/架构梳理.md`

## 技术栈

- 后端: Go + gRPC + PostgreSQL + Redis + RabbitMQ
- 前端: Flutter (Mobile/Web) + gRPC-Web
- 网关: Traefik + Gateway (JWT/限流/路由)

## 服务列表

| 服务 | 端口 | 类型 |
|------|------|------|
| Gateway | 50051 | API 网关 |
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
| Channel | 50062 | 广播频道 (双向流) |

## 目录结构

```
service/<name>/internal/
├── handler/      # gRPC 处理器
├── logic/        # 业务逻辑
├── remote/       # 跨服务调用
├── data_access/  # 数据库操作
└── messaging/    # RabbitMQ 消息

lib/features/<name>/
├── pages/        # 页面
├── handler/      # 业务逻辑
├── data_access/  # gRPC 调用
├── models/       # 数据模型
└── widgets/      # 组件
```

## 调用链路

```
Flutter:  pages → handler → data_access → gRPC → Gateway → Service
Go:       handler → logic → data_access/remote/messaging
```

## 通信方式

| 场景 | 方式 |
|------|------|
| 对外 API | gRPC-Web via Gateway |
| 内部服务 | gRPC 同步调用 |
| 实时通信 | gRPC 双向流 |
| 异步任务 | RabbitMQ |
