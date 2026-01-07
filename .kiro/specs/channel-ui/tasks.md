# Implementation Plan: Channel UI

## Overview

实现 Channel（频道）UI 功能，包括频道列表页和频道详情页。使用 Flutter 实现，遵循项目现有架构模式，使用 mock 数据。

## Tasks

- [x] 1. 创建数据模型和 Mock 数据
  - [x] 1.1 创建 Channel、ChannelMessage、Reaction 数据模型
    - 在 `lib/features/channel/models/` 目录下创建模型文件
    - 包含所有必要字段和构造函数
    - _Requirements: 1.1, 1.2, 4.2, 5.1_

  - [x] 1.2 创建 Mock 数据和 ChannelHandler
    - 在 `lib/features/channel/handler/` 目录下创建 handler 文件
    - 提供 mock 频道列表和消息数据
    - 实现 getChannels、getMessages、toggleMute 方法
    - _Requirements: 1.1, 4.1_

- [x] 2. 实现频道列表页
  - [x] 2.1 创建 ChannelItem 组件
    - 在 `lib/features/channel/widgets/` 目录下创建组件
    - 显示头像、名称、订阅数、最后消息、时间、未读数
    - 使用 TapScale 实现点击效果
    - _Requirements: 1.2, 1.3, 2.3_

  - [x] 2.2 更新 ChannelPage 实现频道列表
    - 使用 ListView.builder 显示频道列表
    - 实现下拉刷新功能
    - 实现空状态显示
    - 点击跳转到详情页
    - _Requirements: 1.1, 1.4, 2.1, 2.2_

- [x] 3. 实现频道详情页组件
  - [x] 3.1 创建 ChannelMessageWidget 组件
    - 显示消息内容、时间、浏览数、评论数
    - 显示反应表情和计数
    - 支持链接显示
    - _Requirements: 4.2, 4.3, 4.5, 5.1, 5.2, 5.3_

  - [x] 3.2 创建 DateSeparator 组件
    - 居中显示日期文本
    - 左右分隔线样式
    - _Requirements: 4.4_

  - [x] 3.3 创建 PinnedMessageBanner 组件
    - 图钉图标 + 消息预览
    - 可关闭功能
    - _Requirements: 3.3_

  - [x] 3.4 创建 ChannelBottomBar 组件
    - 搜索、静音切换、评论、设置按钮
    - 静音状态文字切换
    - _Requirements: 6.1, 6.2, 6.3_

- [x] 4. 实现频道详情页
  - [x] 4.1 创建 ChannelDetailPage 页面
    - AppBar 显示频道信息
    - 消息列表（带日期分隔符）
    - 置顶消息横幅
    - 底部操作栏
    - _Requirements: 3.1, 3.2, 4.1, 4.4_

- [x] 5. Checkpoint - 验证 UI 功能
  - 确保所有页面正常渲染
  - 确保明暗主题切换正常
  - 确保导航流程正确
  - 如有问题请告知用户

- [ ]* 6. 属性测试（可选）
  - [ ]* 6.1 编写频道排序属性测试
    - **Property 1: 频道列表排序一致性**
    - **Validates: Requirements 1.1**

  - [ ]* 6.2 编写反应计数格式化属性测试
    - **Property 6: 反应计数格式化**
    - **Validates: Requirements 5.3**

## Notes

- 任务标记 `*` 为可选任务，可跳过以加快 MVP 开发
- 每个任务引用具体需求以便追溯
- 使用项目现有的 UI 组件（TapScale、AvatarButton、AppColors）
- 遵循项目代码风格：中文注释、简洁直接的代码
