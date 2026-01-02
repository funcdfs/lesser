# Lesser - 社交平台

## 概述

Lesser 是一个类似 X.com (Twitter) 的社交平台。采用纯 gRPC 微服务架构。

## 核心功能

- 用户认证（登录/注册/Token管理）
- 用户资料与关注关系
- 帖子发布与管理
- Feed 信息流（点赞/评论/收藏）
- 实时聊天（gRPC 双向流）
- 搜索（用户/帖子）
- 通知推送

## 架构特点

- **纯 gRPC 架构**: Gateway + Service Cluster，无 REST API
- **gRPC 双向流**: 替代 WebSocket 实现实时消息推送
- **Flutter 跨平台**: 移动端 + Web 端统一代码
- **共享公共库**: `service/pkg` 提供统一基础设施

## 语言规范

- 代码注释统一使用中文
- 文档使用中文
