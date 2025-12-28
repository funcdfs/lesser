# Implementation Plan: Message Page UI Refactor

## Overview

本任务列表将 Message 页面 UI 重构分解为可执行的编码任务。按照组件从底层到顶层的顺序实现，确保每个任务都能独立验证。

## Tasks

- [x] 1. 重构 ChatTypeBadge 组件
  - [x] 1.1 创建 ChatTypeBadge 组件
    - 在 `frontend/lib/features/chat/presentation/widgets/` 创建 `chat_type_badge.dart`
    - 实现根据 ChatType 显示不同图标的逻辑
    - 群聊显示双人图标，频道显示 # 图标，私聊不显示
    - 使用 AppColors、AppSpacing、AppRadius 主题系统
    - _Requirements: 2.5, 2.6, 6.5, 6.6, 6.7, 6.8_

  - [x] 1.2 编写 ChatTypeBadge 属性测试
    - **Property 2: Chat Type Badge Consistency**
    - **Validates: Requirements 2.5, 2.6, 6.5, 6.6, 6.7, 6.8**

- [x] 2. 重构 ChatItem 组件
  - [x] 2.1 更新 ChatItem 组件
    - 修改 `frontend/lib/features/chat/presentation/widgets/chat_item.dart`
    - 移除渐变色类型徽章，改用新的 ChatTypeBadge
    - 更新头像尺寸为 48px
    - 调整未读徽章使用 `AppColors.info` 背景
    - 实现 unreadCount > 99 显示 "99+" 逻辑
    - _Requirements: 2.3, 2.4, 2.7, 2.8, 2.9_

  - [x] 2.2 编写 UnreadBadge 属性测试
    - **Property 3: Unread Badge Display Logic**
    - **Validates: Requirements 2.8, 2.9**

- [x] 3. 重构 NotificationBar 组件
  - [x] 3.1 更新 NotificationBar 组件
    - 修改 `frontend/lib/features/chat/presentation/widgets/notify.dart`
    - 更新图标容器为 56x56px 圆角矩形，背景 `AppColors.secondary`
    - 更新标签为中文：喜欢、回复、收藏、关注
    - 添加点击回调支持
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

  - [x] 3.2 编写 NotificationBar 单元测试
    - 测试四个入口正确渲染
    - 测试点击回调正确触发
    - _Requirements: 1.1, 1.2, 1.5_

- [x] 4. 重构 UserTabSection 组件
  - [x] 4.1 创建 UserTabSection 组件
    - 在 `frontend/lib/features/chat/presentation/widgets/` 创建 `user_tab_section.dart`
    - 实现三个 tab：好友、粉丝、关注
    - 实现选中态下划线指示器
    - 实现选中/未选中样式切换
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

  - [x] 4.2 编写 UserTabSection 属性测试
    - **Property 4: Tab Selection State**
    - **Validates: Requirements 3.2, 3.3, 3.4**

  - [x] 4.3 创建 UserAvatarRow 组件
    - 在 `frontend/lib/features/chat/presentation/widgets/` 创建 `user_avatar_row.dart`
    - 实现横向滚动头像列表
    - 头像 48px 圆形，间距 12px
    - 末尾添加"查看全部"按钮
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6_

  - [x] 4.4 编写 Tab 内容切换属性测试
    - **Property 5: Tab Content Switching**
    - **Validates: Requirements 3.5, 3.6, 3.7**

- [ ] 5. Checkpoint - 组件测试验证
  - 确保所有组件测试通过
  - 如有问题请询问用户

- [x] 6. 更新 SectionHeader 组件
  - [x] 6.1 更新 SectionHeader 样式
    - 修改 `frontend/lib/features/chat/presentation/widgets/section_header.dart`
    - 确保标题使用 `AppColors.mutedForeground`
    - 调整内边距使用 AppSpacing 常量
    - _Requirements: 2.1_

- [x] 7. 重构 ChatScreen 主页面
  - [x] 7.1 更新 ChatScreen 布局
    - 修改 `frontend/lib/features/chat/presentation/screens/chat_screen.dart`
    - 移除 AppBar 标题，简化顶部设计
    - 调整页面结构：NotificationBar → SectionHeader → ChatList → UserTabSection → QuickActionCells
    - 使用 SingleChildScrollView 或 CustomScrollView 实现整体滚动
    - _Requirements: 2.1, 5.1_

  - [x] 7.2 集成 ChatList 排序逻辑
    - 确保聊天列表按 lastMessageTime 降序排序
    - _Requirements: 2.2_

  - [x] 7.3 编写 ChatList 排序属性测试
    - **Property 1: Chat List Sorting**
    - **Validates: Requirements 2.2**

  - [x] 7.4 集成 UserTabSection 组件
    - 替换现有 NetworkNeighborsWidget
    - 连接好友/粉丝/关注数据源
    - _Requirements: 3.5, 3.6, 3.7_

  - [x] 7.5 配置 QuickActionCells
    - 使用 AppCell 组件配置三个快捷操作
    - 创建群聊、创建频道、添加好友
    - _Requirements: 5.2, 5.3, 5.4, 5.5, 5.6_

- [ ] 8. Checkpoint - 集成测试验证
  - 确保页面整体功能正常
  - 验证滚动、点击、切换等交互
  - 如有问题请询问用户

- [x] 9. 清理和优化
  - [x] 9.1 移除废弃代码
    - 删除不再使用的 top_icon_item.dart（如果不再需要）
    - 清理 network_neighbors.dart 中的冗余代码
    - 更新组件导出文件

  - [x] 9.2 代码规范检查
    - 确保所有组件使用 AppColors、AppSpacing、AppRadius
    - 添加完整的文档注释
    - 检查无障碍支持
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_

- [ ] 10. Final Checkpoint - 最终验证
  - 确保所有测试通过
  - 验证 UI 与设计稿一致
  - 如有问题请询问用户

## Notes

- All tasks are required, including tests
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
