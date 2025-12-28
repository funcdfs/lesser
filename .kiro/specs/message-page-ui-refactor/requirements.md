# Requirements Document

## Introduction

本规范定义了 Message 页面的 UI 重构需求，基于最新设计稿实现全新的消息页面布局。重构涵盖顶部通知分类、最近聊天列表、好友/关注切换区域以及快捷操作入口。设计遵循项目 Flutter 组件开发准则，使用 AppColors、AppSpacing、AppRadius 等主题系统。

## Glossary

- **Message_Page**: 消息页面主组件，包含所有消息相关功能入口
- **Notification_Bar**: 顶部通知分类栏，包含 Likes、Replies、Mentions、Follows 四个入口
- **Chat_List**: 最近聊天列表区域，显示私聊、群聊、频道等会话
- **Chat_Item**: 单个聊天会话项，显示头像、名称、最后消息、时间和未读数
- **User_Tab_Section**: 好友/关注切换区域，包含 FRIENDS 和 FOLLOWING 两个标签页
- **User_Avatar_Row**: 横向滚动的用户头像列表
- **Quick_Action_Cell**: 快捷操作入口项，如创建群聊、创建频道、添加好友
- **Chat_Type_Badge**: 聊天类型标识，显示群组图标或频道图标
- **Unread_Badge**: 未读消息数量徽章

## Requirements

### Requirement 1: Notification Bar

**User Story:** As a user, I want to see categorized notification entries at the top of the message page, so that I can quickly access different types of notifications.

#### Acceptance Criteria

1. THE Notification_Bar SHALL display four icon buttons in a horizontal row with equal spacing
2. WHEN displaying notification icons, THE Notification_Bar SHALL show: 喜欢 (heart icon), 回复 (chat bubble icon), 收藏 (bookmark icon), 关注 (person add icon)
3. THE Notification_Bar SHALL display each icon inside a rounded rectangle container with `AppColors.secondary` background
4. THE Notification_Bar SHALL display a label text below each icon using `AppColors.foreground` color
5. WHEN a notification icon is tapped, THE Notification_Bar SHALL navigate to the corresponding notification list page

### Requirement 2: Recent Chats Section

**User Story:** As a user, I want to see my recent chat conversations, so that I can quickly continue conversations.

#### Acceptance Criteria

1. THE Chat_List SHALL display a section header with text "最近聊天" using `AppColors.mutedForeground` color
2. THE Chat_List SHALL display chat items in a vertical list ordered by last message time (newest first)
3. WHEN displaying a Chat_Item, THE Chat_List SHALL show: avatar (48px), title, subtitle (last message), time, and optional unread badge
4. THE Chat_Item SHALL display the avatar on the left with a Chat_Type_Badge overlay at bottom-right position
5. WHEN the chat is a group, THE Chat_Type_Badge SHALL display a group icon (双人图标)
6. WHEN the chat is a channel, THE Chat_Type_Badge SHALL display a hashtag icon (#)
7. THE Chat_Item SHALL display the time on the right side using `AppColors.mutedForeground` color with 12px font size
8. WHEN there are unread messages, THE Chat_Item SHALL display an Unread_Badge with the count using `AppColors.info` background
9. WHEN the unread count exceeds 99, THE Unread_Badge SHALL display "99+"

### Requirement 3: User Tab Section

**User Story:** As a user, I want to switch between friends, followers, and following lists, so that I can quickly find and contact people.

#### Acceptance Criteria

1. THE User_Tab_Section SHALL display three tab buttons: "好友", "粉丝", "关注"
2. WHEN a tab is selected, THE User_Tab_Section SHALL show an underline indicator below the selected tab text
3. THE selected tab text SHALL use `AppColors.foreground` color with bold font weight
4. THE unselected tab text SHALL use `AppColors.mutedForeground` color with normal font weight
5. WHEN the 好友 tab is selected, THE User_Avatar_Row SHALL display the user's friends list
6. WHEN the 粉丝 tab is selected, THE User_Avatar_Row SHALL display the user's followers list
7. WHEN the 关注 tab is selected, THE User_Avatar_Row SHALL display the user's following list

### Requirement 4: User Avatar Row

**User Story:** As a user, I want to see a horizontal scrollable list of user avatars, so that I can quickly start a conversation with someone.

#### Acceptance Criteria

1. THE User_Avatar_Row SHALL display user avatars in a horizontal scrollable list
2. THE User_Avatar_Row SHALL display each avatar as a circular image with 48px diameter
3. THE User_Avatar_Row SHALL display the user's name below each avatar with 12px font size
4. THE User_Avatar_Row SHALL include a "查看全部" button at the end with a chevron-right icon
5. WHEN a user avatar is tapped, THE User_Avatar_Row SHALL navigate to that user's chat or profile page
6. THE User_Avatar_Row SHALL maintain `AppSpacing.md` (12px) horizontal spacing between avatars

### Requirement 5: Quick Action Cells

**User Story:** As a user, I want quick access to create groups, channels, and add friends, so that I can easily expand my network.

#### Acceptance Criteria

1. THE Message_Page SHALL display three Quick_Action_Cell items below the User_Tab_Section
2. THE Quick_Action_Cell items SHALL be: "创建群聊" (描述: 创建新的群组聊天), "创建频道" (描述: 创建新的频道), "添加好友" (描述: 通过ID或二维码添加)
3. EACH Quick_Action_Cell SHALL display: left icon, title text, description text, and right arrow icon
4. THE Quick_Action_Cell left icon SHALL use appropriate icons: group icon for 创建群聊, hashtag icon for 创建频道, person-add icon for 添加好友
5. THE Quick_Action_Cell SHALL use `AppSpacing.lg` (16px) horizontal padding
6. WHEN a Quick_Action_Cell is tapped, THE Message_Page SHALL navigate to the corresponding action page

### Requirement 6: Chat Item Avatar with Type Badge

**User Story:** As a user, I want to distinguish between private chats, group chats, and channels at a glance, so that I can understand the conversation context.

#### Acceptance Criteria

1. THE Chat_Item avatar SHALL be a circular image or icon container with 48px diameter
2. WHEN the chat has a custom avatar, THE Chat_Item SHALL display the avatar image
3. WHEN the chat has no custom avatar, THE Chat_Item SHALL display a default icon based on chat type
4. THE Chat_Type_Badge SHALL be positioned at the bottom-right corner of the avatar, overlapping slightly
5. THE Chat_Type_Badge SHALL have a small circular background (16px diameter) with appropriate icon
6. FOR group chats, THE Chat_Type_Badge SHALL display a dual-person icon with `AppColors.mutedForeground` color
7. FOR channel chats, THE Chat_Type_Badge SHALL display a hashtag (#) icon with `AppColors.mutedForeground` color
8. FOR private chats, THE Chat_Type_Badge SHALL NOT be displayed

### Requirement 7: Visual Styling Compliance

**User Story:** As a developer, I want all components to follow the Flutter development guidelines, so that the UI is consistent and maintainable.

#### Acceptance Criteria

1. ALL components SHALL use colors from `AppColors` class only
2. ALL components SHALL use spacing values from `AppSpacing` class only
3. ALL components SHALL use border radius values from `AppRadius` class only
4. THE Message_Page background SHALL use `AppColors.background` color
5. ALL text styles SHALL follow the project's typography system
6. ALL interactive elements SHALL have appropriate touch feedback using `AppColors.hoverBackground` or `AppColors.pressedBackground`
