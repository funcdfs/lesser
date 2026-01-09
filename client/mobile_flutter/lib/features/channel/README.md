# Channel 频道模块

频道模块实现类似 Telegram Channel 的广播频道功能，支持频道消息、评论系统和深层链接导航。

## 模块结构

```
channel/
├── data_access/
│   ├── channel_mock_data_source.dart    # 频道 Mock 数据源
│   └── channel_comment_data_source.dart # 评论数据源
├── handler/
│   ├── channel_handler.dart             # 频道业务逻辑
│   └── channel_mock_data.dart           # Mock 数据定义
├── models/
│   ├── channel_model.dart               # 频道模型
│   ├── channel_message_model.dart       # 频道消息模型
│   └── channel_comment_model.dart       # 评论模型
├── pages/
│   ├── channel_page.dart                # 频道列表页
│   ├── channel_detail_page.dart         # 频道详情页（消息列表）
│   └── channel_comment_page.dart        # 评论页
└── widgets/
    ├── channel_item.dart                # 频道列表项
    ├── channel_message.dart             # 消息组件
    └── ...
```

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
