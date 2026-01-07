# Requirements Document

## Introduction

实现 Channel（频道）功能的 UI 界面，包括频道列表页和频道详情页。频道是类似 Telegram Channel 的广播频道功能，用户可以订阅频道并接收频道发布的消息。本次实现专注于 UI 整体功能和典雅设计，使用 mock 数据。

## Glossary

- **Channel_List_Page**: 频道列表页面，显示用户已订阅的所有频道
- **Channel_Detail_Page**: 频道详情页面，显示单个频道内的消息流
- **Channel_Item**: 频道列表中的单个频道条目
- **Channel_Message**: 频道内的单条消息
- **Pinned_Message**: 置顶消息，显示在频道详情页顶部
- **Reaction**: 消息的表情反应（点赞、爱心等）
- **Mock_Data**: 用于 UI 展示的模拟数据

## Requirements

### Requirement 1: 频道列表页展示

**User Story:** As a user, I want to see a list of my subscribed channels, so that I can quickly access any channel I'm interested in.

#### Acceptance Criteria

1. WHEN the Channel_List_Page loads, THE Channel_List_Page SHALL display a list of subscribed channels sorted by last message time (newest first)
2. WHEN displaying a Channel_Item, THE Channel_List_Page SHALL show the channel avatar, channel name, subscriber count, last message preview, and last message time
3. WHEN a channel has unread messages, THE Channel_Item SHALL display an unread badge with the count
4. WHEN the channel list is empty, THE Channel_List_Page SHALL display an empty state with guidance text

### Requirement 2: 频道列表交互

**User Story:** As a user, I want to interact with the channel list, so that I can navigate to channels and manage my subscriptions.

#### Acceptance Criteria

1. WHEN a user taps on a Channel_Item, THE Channel_List_Page SHALL navigate to the Channel_Detail_Page for that channel
2. WHEN a user pulls down on the channel list, THE Channel_List_Page SHALL trigger a refresh animation
3. WHEN a user taps on a Channel_Item, THE Channel_Item SHALL display a subtle press feedback animation

### Requirement 3: 频道详情页头部

**User Story:** As a user, I want to see channel information at the top of the detail page, so that I know which channel I'm viewing.

#### Acceptance Criteria

1. WHEN the Channel_Detail_Page loads, THE Channel_Detail_Page SHALL display a header with channel avatar, channel name, and subscriber count
2. WHEN a user taps the back button, THE Channel_Detail_Page SHALL navigate back to the Channel_List_Page
3. WHEN a Pinned_Message exists, THE Channel_Detail_Page SHALL display it in a dismissible banner below the header

### Requirement 4: 频道消息列表

**User Story:** As a user, I want to browse messages in a channel, so that I can read the content published by the channel.

#### Acceptance Criteria

1. WHEN the Channel_Detail_Page loads, THE Channel_Detail_Page SHALL display messages in reverse chronological order (newest at bottom)
2. WHEN displaying a Channel_Message, THE Channel_Detail_Page SHALL show the message content, timestamp, view count, and reactions
3. WHEN a message contains a link, THE Channel_Message SHALL display the link in a tappable format
4. WHEN messages are from different dates, THE Channel_Detail_Page SHALL display date separators between message groups
5. WHEN a message has comments, THE Channel_Message SHALL display a comment count indicator

### Requirement 5: 消息反应展示

**User Story:** As a user, I want to see reactions on messages, so that I can understand how others feel about the content.

#### Acceptance Criteria

1. WHEN a Channel_Message has reactions, THE Channel_Message SHALL display reaction emojis with their counts
2. WHEN displaying reactions, THE Channel_Message SHALL show up to 5 different reaction types
3. WHEN a reaction count exceeds 999, THE Channel_Message SHALL display it as "999+"

### Requirement 6: 频道详情页底部栏

**User Story:** As a user, I want to interact with the channel through a bottom bar, so that I can perform common actions.

#### Acceptance Criteria

1. THE Channel_Detail_Page SHALL display a bottom bar with search, mute toggle, comment, and settings actions
2. WHEN a user taps the mute toggle, THE Channel_Detail_Page SHALL toggle the mute state with visual feedback
3. WHEN the channel is muted, THE bottom bar SHALL display "取消静音" text

### Requirement 7: 视觉设计一致性

**User Story:** As a user, I want the channel UI to match the app's design language, so that I have a consistent experience.

#### Acceptance Criteria

1. THE Channel_List_Page and Channel_Detail_Page SHALL use the app's existing color scheme (AppColors)
2. THE Channel_List_Page and Channel_Detail_Page SHALL support both light and dark themes
3. WHEN theme changes, THE Channel pages SHALL animate the color transition smoothly
4. THE Channel pages SHALL use consistent typography with the rest of the app
