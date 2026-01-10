# Channel Proto 文档

频道服务 (Channel Service) 的 Protocol Buffers 定义文档。

## 文件结构

```
protos/channel/
├── service.proto     # 服务定义、RPC 方法、请求/响应消息
├── entities.proto    # 核心实体（Channel、Message、Comment、Poll 等）
├── stream.proto      # 双向流事件定义（两层推送架构）
└── README.md         # 本文档
```

## 服务概述

Channel Service 是一个类似 Telegram Channel 的单向广播频道服务，支持：

- 频道管理（创建、更新、删除、设置、所有权转移）
- 订阅管理（订阅、取消订阅、静音、置顶、封禁）
- 管理员管理（添加、移除、权限设置、自定义头衔）
- 邀请链接管理（创建、撤销、统计、审批加入）
- 消息发布（仅管理员可发布，支持定时发送、转发）
- 投票功能（普通投票、问答投票、匿名投票）
- 反应和评论（支持置顶评论）
- 频道发现（分类、搜索、推荐、趋势）
- 数据统计（管理员可见的详细统计）
- gRPC 双向流实时更新（两层推送架构）

**端口**: 50062

## 核心功能模块

### 1. 频道管理

| RPC 方法 | 说明 |
|---------|------|
| CreateChannel | 创建频道 |
| GetChannel | 获取频道信息 |
| GetChannelByName | 通过标识符获取频道 |
| UpdateChannel | 更新频道信息 |
| UpdateChannelSettings | 更新频道设置 |
| DeleteChannel | 删除频道 |
| TransferOwnership | 转移所有权 |

### 2. 频道发现

| RPC 方法 | 说明 |
|---------|------|
| SearchChannels | 搜索频道 |
| GetCategories | 获取频道分类 |
| GetChannelsByCategory | 按分类获取频道 |
| GetRecommendedChannels | 获取推荐频道 |
| GetTrendingChannels | 获取趋势频道 |
| GetNearbyChannels | 获取附近频道 |

### 3. 订阅管理

| RPC 方法 | 说明 |
|---------|------|
| Subscribe | 订阅频道 |
| Unsubscribe | 取消订阅 |
| MuteChannel | 静音频道 |
| PinChannel | 置顶频道 |
| BanSubscriber | 封禁订阅者 |

### 4. 邀请链接管理

| RPC 方法 | 说明 |
|---------|------|
| CreateInviteLink | 创建邀请链接 |
| GetInviteLinks | 获取邀请链接列表 |
| RevokeInviteLink | 撤销邀请链接 |
| JoinByInviteLink | 通过邀请链接加入 |

### 5. 消息管理

| RPC 方法 | 说明 |
|---------|------|
| PublishMessage | 发布消息 |
| EditMessage | 编辑消息 |
| DeleteMessages | 批量删除消息 |
| ForwardMessage | 转发消息 |
| SearchMessages | 搜索消息 |

### 6. 定时消息

| RPC 方法 | 说明 |
|---------|------|
| ScheduleMessage | 创建定时消息 |
| EditScheduledMessage | 编辑定时消息 |
| CancelScheduledMessage | 取消定时消息 |
| SendScheduledMessageNow | 立即发送 |

### 7. 投票管理

| RPC 方法 | 说明 |
|---------|------|
| CreatePoll | 创建投票 |
| VotePoll | 投票 |
| RetractVote | 撤回投票 |
| ClosePoll | 关闭投票 |
| GetPollVoters | 获取投票者列表 |

### 8. 数据统计

| RPC 方法 | 说明 |
|---------|------|
| GetChannelStats | 获取频道统计 |
| GetMessageStats | 获取消息统计 |

## 两层推送架构

第一层（列表页）：轻量级通知，推送所有订阅频道的新消息预览
第二层（详情页）：完整推送，只推当前聚焦频道的完整消息内容

## 相关文档

- [架构梳理](../../docs/架构梳理.md)
