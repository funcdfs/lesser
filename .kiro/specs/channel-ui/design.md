# Design Document: Channel UI

## Overview

本设计文档描述 Channel（频道）UI 的实现方案，包括频道列表页和频道详情页。设计遵循项目现有的架构模式（pages → handler → data_access → models），使用 Flutter 实现，支持明暗主题切换。

本次实现专注于 UI 层，使用 mock 数据，后续可无缝对接真实的 gRPC 数据源。

## Architecture

### 目录结构

```
lib/features/channel/
├── models/
│   └── channel_models.dart      # 数据模型（Channel, ChannelMessage, Reaction）
├── handler/
│   └── channel_handler.dart     # 业务逻辑层（mock 数据提供）
├── pages/
│   ├── channel_page.dart        # 频道列表页（Tab 2 入口）
│   └── channel_detail_page.dart # 频道详情页
└── widgets/
    ├── channel_item.dart        # 频道列表项组件
    ├── channel_message.dart     # 频道消息组件
    ├── pinned_message_banner.dart # 置顶消息横幅
    ├── date_separator.dart      # 日期分隔符
    └── channel_bottom_bar.dart  # 底部操作栏
```

### 数据流

```
┌─────────────────────────────────────────────────────────────┐
│                      Channel UI Flow                         │
└─────────────────────────────────────────────────────────────┘

ChannelPage (列表页)
    │
    ├── ChannelHandler.getChannels() → List<Channel>
    │
    └── ListView.builder
            │
            └── ChannelItem (单个频道)
                    │
                    └── onTap → Navigator.push(ChannelDetailPage)

ChannelDetailPage (详情页)
    │
    ├── ChannelHandler.getChannelDetail(id) → Channel
    ├── ChannelHandler.getMessages(id) → List<ChannelMessage>
    │
    ├── AppBar (频道信息)
    ├── PinnedMessageBanner (置顶消息)
    ├── ListView.builder
    │       │
    │       ├── DateSeparator (日期分隔)
    │       └── ChannelMessageWidget (消息)
    │
    └── ChannelBottomBar (底部操作栏)
```

## Components and Interfaces

### 1. Channel Model

```dart
/// 频道数据模型
class Channel {
  final String id;
  final String name;
  final String? avatarUrl;
  final int subscriberCount;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isMuted;
  final String? pinnedMessage;
}

/// 频道消息模型
class ChannelMessage {
  final String id;
  final String content;
  final DateTime timestamp;
  final int viewCount;
  final int commentCount;
  final List<Reaction> reactions;
  final String? linkUrl;
  final String? linkTitle;
}

/// 反应模型
class Reaction {
  final String emoji;
  final int count;
  final bool isSelected;
}
```

### 2. ChannelHandler

```dart
/// 频道业务逻辑层（当前使用 mock 数据）
class ChannelHandler extends ChangeNotifier {
  List<Channel> _channels = [];
  bool _isLoading = false;
  
  /// 获取频道列表
  Future<List<Channel>> getChannels();
  
  /// 获取频道详情
  Future<Channel> getChannelDetail(String id);
  
  /// 获取频道消息
  Future<List<ChannelMessage>> getMessages(String channelId);
  
  /// 切换静音状态
  Future<void> toggleMute(String channelId);
  
  /// 刷新频道列表
  Future<void> refresh();
}
```

### 3. ChannelPage (频道列表页)

```dart
/// 频道列表页 - Tab 2 入口
class ChannelPage extends StatefulWidget {
  // 使用 RefreshIndicator 支持下拉刷新
  // 使用 ListView.builder 懒加载列表
  // 空状态显示引导文案
}
```

### 4. ChannelDetailPage (频道详情页)

```dart
/// 频道详情页
class ChannelDetailPage extends StatefulWidget {
  final String channelId;
  
  // AppBar: 返回按钮 + 频道头像 + 名称 + 订阅数
  // PinnedMessageBanner: 可关闭的置顶消息
  // ListView: 消息列表（带日期分隔符）
  // BottomBar: 搜索/静音/评论/设置
}
```

### 5. Widget Components

#### ChannelItem
- 左侧：频道头像（圆形，带默认占位符）
- 中间：频道名称 + 订阅数 + 最后消息预览
- 右侧：时间 + 未读数徽章
- 点击效果：TapScale 缩放动画

#### ChannelMessageWidget
- 消息内容（支持多行文本）
- 链接预览（如有）
- 底部：浏览数 + 时间 + 评论数
- 反应栏：表情 + 计数

#### PinnedMessageBanner
- 图钉图标 + 消息预览
- 右侧关闭按钮
- 点击展开完整消息

#### DateSeparator
- 居中显示日期文本
- 左右分隔线

#### ChannelBottomBar
- 搜索图标
- 静音切换（文字按钮）
- 评论图标
- 设置图标

## Data Models

### Mock 数据结构

```dart
// 频道列表 mock 数据
final mockChannels = [
  Channel(
    id: '1',
    name: '妙妙屋主日记',
    subscriberCount: 62633,
    lastMessage: '感觉TG又开始新一轮的大批量频道封禁了',
    lastMessageTime: DateTime.now().subtract(Duration(hours: 2)),
    unreadCount: 5,
  ),
  // ... 更多频道
];

// 频道消息 mock 数据
final mockMessages = [
  ChannelMessage(
    id: '1',
    content: 'GG，接近30w订阅的老妙妙屋严选频道的辉煌还是落幕了...',
    timestamp: DateTime(2024, 1, 5, 22, 35),
    viewCount: 10020,
    commentCount: 147,
    reactions: [
      Reaction(emoji: '👍', count: 38),
      Reaction(emoji: '🔥', count: 3),
    ],
  ),
  // ... 更多消息
];
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

由于本次实现主要是 UI 层，且使用 mock 数据，大部分需求涉及视觉展示和用户交互，不适合进行属性测试。以下是可测试的属性：

### Property 1: 频道列表排序一致性

*For any* list of channels with different lastMessageTime values, sorting the list SHALL always produce channels ordered by lastMessageTime in descending order (newest first).

**Validates: Requirements 1.1**

### Property 2: 消息列表排序一致性

*For any* list of messages with different timestamp values, the message list SHALL always be ordered by timestamp in ascending order (oldest first, newest at bottom).

**Validates: Requirements 4.1**

### Property 3: 未读数显示逻辑

*For any* channel, WHEN unreadCount > 0, the unread badge SHALL be visible; WHEN unreadCount == 0, no badge SHALL be displayed.

**Validates: Requirements 1.3**

### Property 4: 日期分隔符插入

*For any* list of messages, date separators SHALL be inserted between messages from different dates, and no separator SHALL appear between messages from the same date.

**Validates: Requirements 4.4**

### Property 5: 反应类型限制

*For any* message with reactions, at most 5 different reaction types SHALL be displayed, regardless of how many reaction types exist.

**Validates: Requirements 5.2**

### Property 6: 反应计数格式化

*For any* reaction count value, WHEN the count exceeds 999, the display SHALL show "999+" instead of the actual number; otherwise, the actual number SHALL be displayed.

**Validates: Requirements 5.3**

## Error Handling

### UI 层错误处理

1. **图片加载失败**: 使用默认占位符（首字母或图标）
2. **空列表状态**: 显示友好的空状态提示
3. **数据加载中**: 显示加载指示器
4. **刷新失败**: 保持当前数据，显示错误提示

### Mock 数据边界情况

- 空频道列表
- 无消息的频道
- 超长消息文本（截断显示）
- 超大数字（格式化显示）

## Testing Strategy

### 单元测试

1. **Model 测试**: 验证数据模型的序列化/反序列化
2. **Handler 测试**: 验证 mock 数据返回正确
3. **格式化函数测试**: 验证数字格式化、时间格式化

### Widget 测试

1. **ChannelItem 测试**: 验证各元素正确渲染
2. **ChannelMessageWidget 测试**: 验证消息内容、反应显示
3. **主题切换测试**: 验证明暗主题下颜色正确

### 属性测试

使用 `fast_check` 或类似库进行属性测试：

1. **排序属性**: 生成随机频道列表，验证排序正确性
2. **格式化属性**: 生成随机数字，验证格式化输出

### 测试配置

- 属性测试最少运行 100 次迭代
- 每个属性测试需标注对应的设计文档属性编号
