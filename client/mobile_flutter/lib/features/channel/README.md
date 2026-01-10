# Channel 频道模块

频道模块实现类似 Telegram Channel 的广播频道功能，支持频道消息、评论系统和深层链接导航。

## 实时推送架构

### 两层推送设计

频道模块采用两层推送架构，优化网络流量和用户体验：

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           两层推送架构                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    全局连接（列表页）                                  │   │
│  │                                                                       │   │
│  │  • 建立时机：用户打开频道列表页                                         │   │
│  │  • 推送范围：所有订阅频道                                              │   │
│  │  • 推送内容：轻量级通知                                                │   │
│  │    - 频道 ID、名称、头像                                               │   │
│  │    - 预览文本（截断）                                                  │   │
│  │    - 消息时间                                                         │   │
│  │    - 未读数                                                           │   │
│  │    - 是否有媒体                                                        │   │
│  │    - 作者名称                                                         │   │
│  │                                                                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    │ 用户进入详情页                          │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    频道连接（详情页）                                  │   │
│  │                                                                       │   │
│  │  • 建立时机：用户进入频道详情页（发送 FocusChannel）                     │   │
│  │  • 推送范围：仅当前打开的频道                                          │   │
│  │  • 推送内容：完整更新                                                  │   │
│  │    - 完整消息内容（文本、媒体、链接）                                    │   │
│  │    - 反应变化（emoji 计数、我的反应）                                   │   │
│  │    - 评论变化（新评论、删除、点赞）                                     │   │
│  │    - 消息编辑、删除、置顶                                              │   │
│  │                                                                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 事件流程

```mermaid
sequenceDiagram
    participant App as Flutter App
    participant Stream as gRPC Stream
    participant Server as Channel Service

    Note over App,Server: 1. 全局连接（列表页）

    App->>Stream: ClientConnectEvent
    Stream->>Server: 建立连接
    Server-->>Stream: ServerConnectedEvent (订阅频道摘要列表)
    Stream-->>App: 初始化列表

    loop 全局通知
        Server-->>Stream: ServerChannelNotifyEvent
        Stream-->>App: 更新列表项（预览、时间、未读数）
    end

    Note over App,Server: 2. 频道连接（进入详情页）

    App->>Stream: ClientFocusChannelEvent(channel_id)
    Server-->>Stream: ServerFocusedEvent
    Stream-->>App: 确认聚焦

    loop 详情页更新
        Server-->>Stream: ServerNewMessageEvent (完整消息)
        Stream-->>App: 添加消息到列表
        Server-->>Stream: ServerReactionUpdatedEvent
        Stream-->>App: 更新反应计数
        Server-->>Stream: ServerNewCommentEvent
        Stream-->>App: 更新评论计数
    end

    Note over App,Server: 3. 离开详情页

    App->>Stream: ClientUnfocusChannelEvent(channel_id)
    Server-->>Stream: ServerUnfocusedEvent
    Stream-->>App: 确认取消聚焦（继续接收全局通知）
```

### 客户端事件

| 事件 | 说明 | 使用场景 |
|------|------|---------|
| `ClientConnectEvent` | 建立全局连接 | 打开频道列表页 |
| `ClientDisconnectEvent` | 断开全局连接 | 关闭频道模块 |
| `ClientFocusChannelEvent` | 聚焦频道 | 进入频道详情页 |
| `ClientUnfocusChannelEvent` | 取消聚焦 | 离开频道详情页 |
| `ClientPingEvent` | 心跳 | 保持连接活跃 |
| `ClientMarkReadEvent` | 标记已读 | 用户阅读消息 |
| `ClientAckEvent` | 确认收到 | 可靠投递确认 |

### 服务端事件

| 事件 | 推送层级 | 说明 |
|------|---------|------|
| `ServerConnectedEvent` | 连接 | 全局连接成功，返回订阅频道摘要 |
| `ServerFocusedEvent` | 连接 | 频道聚焦成功 |
| `ServerUnfocusedEvent` | 连接 | 频道取消聚焦成功 |
| `ServerChannelNotifyEvent` | 全局 | 频道新消息通知（轻量） |
| `ServerNewMessageEvent` | 详情 | 新消息（完整内容） |
| `ServerMessageEditedEvent` | 详情 | 消息编辑 |
| `ServerMessageDeletedEvent` | 详情 | 消息删除 |
| `ServerReactionUpdatedEvent` | 详情 | 反应变化 |
| `ServerNewCommentEvent` | 详情 | 新评论 |
| `ServerCommentDeletedEvent` | 详情 | 评论删除 |
| `ServerCommentLikedEvent` | 详情 | 评论点赞变化 |
| `ServerChannelUpdatedEvent` | 全局 | 频道信息更新 |
| `ServerChannelDeletedEvent` | 全局 | 频道删除 |

### 数据结构

#### ChannelSummary（频道摘要，列表页使用）

```dart
class ChannelSummary {
  final String channelId;
  final String channelName;
  final String displayName;
  final String? avatarUrl;
  final String? lastMessagePreview;   // 最后消息预览
  final DateTime? lastMessageTime;    // 最后消息时间
  final int unreadCount;              // 未读数
  final bool isMuted;                 // 是否静音
  final bool isPinned;                // 是否置顶
}
```

#### ServerChannelNotifyEvent（频道通知，轻量级）

```dart
class ChannelNotify {
  final String channelId;
  final String channelName;
  final String? channelAvatarUrl;
  final String messageId;
  final String previewText;           // 预览文本（截断）
  final DateTime messageTime;
  final int unreadCount;
  final bool hasMedia;
  final String authorName;
}
```

## 模块结构

```
channel/
├── data_access/
│   ├── channel_data_source.dart         # 频道数据源接口
│   ├── channel_mock_data_source.dart    # 频道 Mock 数据源
│   ├── channel_comment_data_source.dart # 评论数据源
│   └── mock/
│       └── channel_mock_data.dart       # Mock 数据定义
├── handler/
│   └── channel_handler.dart             # 频道业务逻辑
├── models/
│   ├── channel_model.dart               # 频道模型
│   ├── channel_message_model.dart       # 频道消息模型
│   ├── channel_comment_model.dart       # 评论模型
│   └── channel_tag.dart                 # 频道标签模型
├── pages/
│   ├── channel_page.dart                # 频道列表页
│   ├── channel_detail_page.dart         # 频道详情页（消息列表）
│   └── channel_comment_page.dart        # 评论页
└── widgets/
    ├── channel_item.dart                # 频道列表项
    ├── channel_message.dart             # 消息组件
    ├── detail_app_bar.dart              # 详情页 AppBar
    ├── message_list_view.dart           # 消息列表视图
    ├── message_list_controller.dart     # 消息列表控制器（缓存+高亮）
    ├── comment_page_scaffold.dart       # 评论页脚手架
    └── ...
```

## 架构设计原则

### 分层架构

```
pages → handler → data_access → models
```

- `pages/`: UI 层，只负责渲染和用户交互
- `handler/`: 业务逻辑层，处理状态管理和业务规则
- `data_access/`: 数据访问层，抽象数据源（Mock/gRPC）
- `models/`: 数据模型层，纯数据结构

### 接口定义位置

- 数据源接口（如 `ChannelDataSource`）定义在 `data_access/` 目录
- Handler 通过依赖注入使用数据源接口

### Widget 拆分原则

- 私有方法返回 Widget 应改为私有 Widget 类
- 复杂页面拆分为独立组件（如 `DetailAppBar`、`MessageListView`）
- 缓存逻辑抽离到控制器类（如 `MessageListController`）

### 状态管理

- 选中状态由 UI 层管理（使用 `Set<String>`），不在 Model 中存储
- 临时 UI 状态（如高亮）通过控制器管理

## 数据模型关系

### ER 图

```mermaid
erDiagram
    Channel ||--o{ ChannelMessage : "1:N 包含"
    ChannelMessage ||--o{ Comment : "1:N 拥有"
    Comment ||--o{ Comment : "1:N 回复"

    Channel {
        string id PK "频道唯一标识"
        string name "频道名称"
        string description "频道描述"
        string avatarUrl "头像 URL"
        string ownerId FK "频道主用户 ID"
        int subscriberCount "订阅者数量"
        int messageCount "消息总数"
        bool isSubscribed "当前用户是否已订阅"
    }

    ChannelMessage {
        string id PK "消息唯一标识"
        string channelId FK "所属频道 ID → Channel.id"
        string authorId FK "作者用户 ID"
        string content "消息内容"
        datetime createdAt "创建时间"
        int viewCount "浏览量"
        int commentCount "评论数"
    }

    Comment {
        string id PK "评论唯一标识"
        string messageId FK "所属消息 ID → ChannelMessage.id"
        string channelId FK "所属频道 ID → Channel.id（冗余，便于查询）"
        string parentId FK "父评论 ID → Comment.id（根评论为 null）"
        string rootId FK "根评论 ID → Comment.id（根评论为 null）"
        string authorId FK "作者用户 ID"
        string content "评论内容"
        int likeCount "点赞数"
        int replyCount "回复数"
        bool isPinned "是否置顶"
        int createdAtMs "创建时间戳"
    }
```

### 键说明

| 模型 | 字段 | 类型 | 说明 |
|------|------|------|------|
| Channel | id | PK | 频道主键，全局唯一 |
| Channel | ownerId | FK | 外键，关联用户表 |
| ChannelMessage | id | PK | 消息主键，全局唯一 |
| ChannelMessage | channelId | FK | 外键，关联 Channel.id |
| Comment | id | PK | 评论主键，全局唯一 |
| Comment | messageId | FK | 外键，关联 ChannelMessage.id |
| Comment | channelId | FK | 冗余外键，便于按频道查询评论 |
| Comment | parentId | FK | 自引用外键，指向直接父评论（根评论为 null） |
| Comment | rootId | FK | 自引用外键，指向评论树根节点（根评论为 null） |

### 评论树结构

评论采用扁平化存储 + 双指针设计：

```
parentId: 指向直接父评论，用于显示"回复 @xxx"
rootId:   指向评论树根节点，用于加载整个线程

示例：
c1 (根评论)           → parentId: null, rootId: null
├── c1_r1 (回复 c1)   → parentId: c1,   rootId: c1
│   ├── c1_r1_r1      → parentId: c1_r1, rootId: c1
│   └── c1_r1_r2      → parentId: c1_r1, rootId: c1
└── c1_r2 (回复 c1)   → parentId: c1,   rootId: c1
```

这种设计的优势：
- 加载线程只需一次查询：`WHERE rootId = ?`
- 显示回复关系：通过 `parentId` 找到被回复的评论
- 深层链接导航：通过 `rootId` 快速定位根评论

## 页面导航流程

```mermaid
flowchart TD
    subgraph 频道模块
        A[ChannelPage<br/>频道列表] -->|点击频道| B[ChannelDetailPage<br/>频道详情/消息列表]
        B -->|点击评论入口| C[ChannelCommentPage<br/>评论页]
        C -->|点击查看回复| D[CommentPage<br/>评论线程]
        D -->|继续查看回复| D
    end

    subgraph 返回路径
        D -->|返回| C
        C -->|返回| B
        B -->|返回| A
        D -->|返回消息| C
    end
```

## 深层链接系统

### 链接格式

```
https://lesser.app/channel/{channelId}
https://lesser.app/channel/{channelId}/message/{messageId}
https://lesser.app/channel/{channelId}/message/{messageId}/comment/{commentId}
```

### 链接导航流程

```mermaid
flowchart TD
    subgraph 链接解析
        A[用户点击链接] --> B{LinkParser<br/>解析 URL}
        B -->|无效链接| C[显示错误提示]
        B -->|有效链接| D[LinkService<br/>处理导航]
    end

    subgraph 导航分发
        D --> E{链接类型?}
        E -->|channel| F[显示 ChannelCard<br/>频道名片弹窗]
        E -->|message| G[打开 ChannelDetailPage<br/>高亮目标消息]
        E -->|comment| H[解析根评论 ID]
    end

    subgraph 评论导航
        H --> I[LinkResolver<br/>resolveCommentRoot]
        I --> J[打开 ChannelCommentPage]
        J --> K[加载根评论线程]
        K --> L[滚动到目标评论]
        L --> M[HighlightEffect<br/>高亮动画]
    end

    subgraph 频道导航
        F -->|点击打开| N[打开 ChannelDetailPage]
        F -->|点击订阅| O[订阅/取消订阅]
    end
```

### 评论树导航示例

```mermaid
flowchart LR
    subgraph 评论树结构
        C1[c1<br/>根评论] --> C1R1[c1_r1<br/>回复]
        C1 --> C1R2[c1_r2<br/>回复]
        C1R1 --> C1R1R1[c1_r1_r1<br/>回复]
        C1R1 --> C1R1R2[c1_r1_r2<br/>回复]
        C1R1R1 --> C1R1R1R1[c1_r1_r1_r1<br/>回复]
    end

    subgraph 深层链接导航
        URL[链接指向 c1_r1_r1] --> ROOT[找到根评论 c1]
        ROOT --> THREAD[打开 c1 的线程]
        THREAD --> SCROLL[滚动到 c1_r1_r1]
        SCROLL --> HIGHLIGHT[高亮显示]
    end
```

## 高亮效果

消息和评论支持高亮动画效果，用于深层链接导航时吸引用户注意力：

```mermaid
sequenceDiagram
    participant User as 用户
    participant Link as LinkService
    participant Page as 页面
    participant Effect as HighlightEffect

    User->>Link: 点击深层链接
    Link->>Page: 导航到目标页面
    Page->>Page: 加载数据
    Page->>Page: 滚动到目标位置
    Page->>Effect: 设置 isHighlighted=true
    Effect->>Effect: 播放高亮动画 (1.5s)
    Effect->>Page: onHighlightComplete
    Page->>Page: 清除高亮状态
```

## 组件使用

### ChannelDetailPage

```dart
// 普通导航
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ChannelDetailPage(
      channelId: 'test',
      initialChannel: channel, // 可选，避免重复加载
    ),
  ),
);

// 深层链接导航（高亮消息）
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ChannelDetailPage(
      channelId: 'test',
      highlightMessageId: 'post_1', // 需要高亮的消息 ID
    ),
  ),
);
```

### ChannelCommentPage

```dart
// 普通导航（从消息进入评论）
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ChannelCommentPage(
      messageId: 'post_1',
      channelId: 'test',
    ),
  ),
);

// 深层链接导航（高亮评论）
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ChannelCommentPage(
      messageId: 'post_1',
      channelId: 'test',
      rootCommentId: 'c1',           // 根评论 ID
      targetCommentId: 'c1_r1_r1',   // 目标评论 ID
    ),
  ),
);
```

### LinkService 使用

```dart
// 初始化（在 main.dart 中）
LinkService.instance.init(
  dataSource: LinkMockDataSource(),
  onNavigateToChannel: _navigateToChannel,
  onNavigateToMessage: _navigateToMessage,
  onNavigateToComment: _navigateToComment,
);

// 导航到链接
await LinkService.instance.navigate(context, url);

// 获取链接元数据（用于渲染预览卡片）
final metadata = await LinkService.instance.getMetadata(url);
```

## UI 组件

### InlineLinkCard

内联链接卡片，用于在文本中渲染链接预览：

```
┌─────────────────────────────────┐
│ 🔗 频道：测试频道。评论：xxxx... │
└─────────────────────────────────┘
```

### ChannelCard

频道名片弹窗，点击频道链接时显示：

```
┌─────────────────────────────────┐
│         ─────                   │
│                                 │
│  [头像]  频道名称               │
│          1,234 订阅者           │
│                                 │
│  ┌─────────────────────────┐   │
│  │ 频道描述文本...          │   │
│  └─────────────────────────┘   │
│                                 │
│  [  订阅  ]    [  打开频道  ]   │
└─────────────────────────────────┘
```

## 相关模块

- `pkg/link/` - 深层链接公共组件
- `pkg/comment/` - 通用评论组件
- `pkg/ui/effects/` - UI 效果组件（高亮动画等）
