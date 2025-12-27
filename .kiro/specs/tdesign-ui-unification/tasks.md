# Implementation Plan: TDesign UI Unification

## Overview

本实现计划将 Flutter 前端 UI 组件统一迁移到腾讯 TDesign 组件库，并建立黑色基调的主题系统。迁移分为 6 个主要阶段，确保应用在迁移过程中保持可用。

## Tasks

- [x] 1. 依赖管理和项目配置
  - [x] 1.1 更新 pubspec.yaml，添加 tdesign_flutter 依赖并移除 forui 依赖
    - 添加 `tdesign_flutter: ^0.1.8` 到 dependencies
    - 移除 `forui: ^0.17.0` 依赖
    - 运行 `flutter pub get` 验证依赖安装
    - _Requirements: 1.1, 1.2, 1.3_

- [x] 2. 主题系统重构
  - [x] 2.1 创建新的颜色令牌系统 (AppColors)
    - 在 `frontend/lib/shared/theme/` 创建 `colors.dart`
    - 定义黑色基调的颜色系统（gray950 作为背景，gray900 作为表面色）
    - 定义语义化颜色令牌（primary, secondary, background, surface, error 等）
    - _Requirements: 2.1, 2.2_
  
  - [x] 2.2 创建间距和圆角令牌系统
    - 在 `frontend/lib/shared/theme/` 创建 `spacing.dart`
    - 定义基于 4px 网格的间距系统
    - 定义统一的圆角系统
    - _Requirements: 2.4, 2.5_
  
  - [x] 2.3 重构 AppTheme 类以集成 TDesign 主题
    - 更新 `frontend/lib/app/app_theme.dart`
    - 配置 TDTheme 使用黑色基调
    - 确保 MaterialApp 使用新主题
    - _Requirements: 2.3, 2.6_
  
  - [x] 2.4 更新 app.dart 应用新主题
    - 修改 `frontend/lib/app/app.dart`
    - 包装 TDTheme 到应用根部
    - 设置 TDesign 主题为默认
    - _Requirements: 2.3_

- [x] 3. 按钮组件迁移
  - [x] 3.1 创建 AppButton 组件封装 TDButton
    - 在 `frontend/lib/shared/widgets/` 创建 `app_button.dart`
    - 实现 primary, secondary, outline, text, danger 类型
    - 支持 loading 和 disabled 状态
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_
  
  - [x] 3.2 迁移登录页面按钮
    - 更新 `frontend/lib/features/auth/presentation/screens/login_screen.dart`
    - 将 FButton 替换为 AppButton
    - 将 TextButton 替换为 AppButton(type: text)
    - _Requirements: 3.1, 3.6_
  
  - [x] 3.3 迁移注册页面按钮
    - 更新 `frontend/lib/features/auth/presentation/screens/register_screen.dart`
    - 将 FButton 替换为 AppButton
    - 将 TextButton 替换为 AppButton(type: text)
    - _Requirements: 3.1, 3.6_
  
  - [x] 3.4 迁移其他页面按钮
    - 更新 `frontend/lib/features/settings/presentation/screens/profile_screen.dart`
    - 更新 `frontend/lib/features/chat/presentation/screens/chat_screen.dart`
    - 更新 `frontend/lib/features/create/presentation/screens/new_post_screen.dart`
    - 更新 `frontend/lib/features/test/presentation/screens/api_test_screen.dart`
    - _Requirements: 3.6_

- [x] 4. 输入组件迁移
  - [x] 4.1 创建 AppInput 组件封装 TDInput
    - 在 `frontend/lib/shared/widgets/` 创建 `app_input.dart`
    - 支持普通文本和密码输入
    - 支持验证错误显示、placeholder、前后缀图标
    - _Requirements: 4.1, 4.2, 4.4, 4.5, 4.6_
  
  - [x] 4.2 迁移登录页面输入框
    - 更新 `frontend/lib/features/auth/presentation/screens/login_screen.dart`
    - 将 FTextField 替换为 AppInput
    - _Requirements: 4.1, 4.2, 4.3_
  
  - [x] 4.3 迁移注册页面输入框
    - 更新 `frontend/lib/features/auth/presentation/screens/register_screen.dart`
    - 将 FTextField 替换为 AppInput
    - _Requirements: 4.1, 4.2, 4.3_

- [x] 5. Checkpoint - 验证按钮和输入组件迁移
  - 确保所有测试通过
  - 验证登录和注册页面正常工作
  - 如有问题请询问用户

- [x] 6. 导航组件迁移
  - [x] 6.1 创建 AppNavBar 组件封装 TDNavBar
    - 在 `frontend/lib/shared/widgets/` 创建 `app_nav_bar.dart`
    - 支持标题、返回按钮、操作按钮
    - 应用深色主题样式
    - _Requirements: 5.2, 5.3_
  
  - [x] 6.2 创建 AppBottomNavBar 组件封装 TDBottomTabBar
    - 在 `frontend/lib/shared/widgets/` 创建 `app_bottom_nav_bar.dart`
    - 支持图标和标签
    - 应用深色主题样式
    - _Requirements: 5.1, 5.3_
  
  - [x] 6.3 更新主页导航
    - 更新 `frontend/lib/features/feeds/presentation/screens/home_screen.dart`
    - 使用新的导航组件
    - _Requirements: 5.1, 5.2, 5.4_

- [x] 7. 卡片和列表组件迁移
  - [x] 7.1 创建 AppCell 组件封装 TDCell
    - 在 `frontend/lib/shared/widgets/` 创建 `app_cell.dart`
    - 支持标题、描述、图标、箭头
    - 应用深色主题样式
    - _Requirements: 6.1, 6.2, 6.3, 6.4_
  
  - [x] 7.2 更新帖子卡片组件
    - 更新 `frontend/lib/features/feeds/presentation/widgets/post_card.dart`
    - 使用设计令牌替换硬编码颜色
    - _Requirements: 6.3_
  
  - [x] 7.3 更新聊天列表组件
    - 更新 `frontend/lib/features/chat/presentation/widgets/` 下的组件
    - 使用 AppCell 和设计令牌
    - _Requirements: 6.2, 6.3_

- [-] 8. 对话框和提示组件迁移
  - [x] 8.1 创建 AppDialog 工具类封装 TDDialog
    - 在 `frontend/lib/shared/widgets/` 创建 `app_dialog.dart`
    - 提供 confirm, alert, custom 方法
    - 应用深色主题样式
    - _Requirements: 7.1, 7.4_
  
  - [x] 8.2 创建 AppToast 工具类封装 TDToast
    - 在 `frontend/lib/shared/widgets/` 创建 `app_toast.dart`
    - 提供 success, error, info, warning 方法
    - 应用深色主题样式
    - _Requirements: 7.2_
  
  - [x] 8.3 更新现有对话框使用
    - 更新 `frontend/lib/features/settings/presentation/screens/profile_screen.dart` 中的对话框
    - 使用 AppDialog 替换 AlertDialog
    - _Requirements: 7.1_

- [x] 9. 头像和图片组件迁移
  - [x] 9.1 创建 AppAvatar 组件封装 TDAvatar
    - 在 `frontend/lib/shared/widgets/` 创建 `app_avatar.dart`
    - 支持 small, medium, large 尺寸
    - 支持图片和文字头像
    - _Requirements: 8.1, 8.3_
  
  - [x] 9.2 更新现有头像使用
    - 更新 `frontend/lib/shared/widgets/avatar.dart`
    - 使用 TDAvatar 替换自定义实现
    - _Requirements: 8.1_
  
  - [x] 9.3 创建 AppImage 组件封装 TDImage
    - 在 `frontend/lib/shared/widgets/` 创建 `app_image.dart`
    - 支持 placeholder 和 error 状态
    - _Requirements: 8.2, 8.4_

- [x] 10. 加载和状态组件迁移
  - [x] 10.1 创建 AppLoading 组件封装 TDLoading
    - 在 `frontend/lib/shared/widgets/` 创建 `app_loading.dart`
    - 支持不同尺寸
    - 应用深色主题样式
    - _Requirements: 9.1, 9.4_
  
  - [x] 10.2 更新 shimmer 组件使用 TDSkeleton
    - 更新 `frontend/lib/shared/widgets/shimmer.dart`
    - 使用 TDSkeleton 替换自定义实现
    - _Requirements: 9.2_
  
  - [x] 10.3 创建 AppEmpty 组件封装 TDEmpty
    - 在 `frontend/lib/shared/widgets/` 创建 `app_empty.dart`
    - 支持自定义图标和文字
    - _Requirements: 9.3_

- [x] 11. Checkpoint - 验证所有组件迁移
  - 确保所有测试通过
  - 验证所有页面正常渲染
  - 如有问题请询问用户

- [x] 12. 清理遗留代码
  - [x] 12.1 移除 forui 相关代码
    - 删除所有 forui 导入
    - 删除 `frontend/lib/shared/widgets/autocomplete.dart` 中的 forui 依赖
    - _Requirements: 10.1_
  
  - [x] 12.2 清理重复的自定义组件
    - 审查 `frontend/lib/shared/widgets/` 目录
    - 移除与 TDesign 功能重复的组件
    - _Requirements: 10.2_
  
  - [x] 12.3 清理硬编码颜色值
    - 扫描所有 UI 组件文件
    - 将硬编码颜色替换为设计令牌
    - _Requirements: 10.3_
  
  - [x] 12.4 更新 shared widgets index
    - 更新 `frontend/lib/shared/widgets/index.dart`
    - 导出所有新的 TDesign 封装组件
    - _Requirements: 10.4_

- [x] 13. 删除旧主题文件
  - [x] 13.1 清理旧的主题定义
    - 移除 `frontend/lib/shared/theme/theme.dart` 中的废弃代码
    - 保留必要的设计令牌
    - _Requirements: 10.2_

- [x] 14. 属性测试
  - [x] 14.1 编写 Property 1 测试：无遗留 UI 导入
    - **Property 1: No Legacy UI Imports**
    - **Validates: Requirements 1.2, 4.3, 10.1**
    - 扫描所有 Dart 文件验证无 forui 导入
  
  - [x] 14.2 编写 Property 2 测试：无硬编码颜色
    - **Property 2: No Hardcoded Colors in UI Components**
    - **Validates: Requirements 2.7, 10.3**
    - 扫描 UI 组件文件验证无硬编码颜色值
  
  - [x] 14.3 编写 Property 4 测试：头像尺寸一致性
    - **Property 4: Avatar Size Consistency**
    - **Validates: Requirements 8.3**
    - 验证所有有效尺寸渲染正确

- [x] 15. Widget 测试
  - [x] 15.1 编写按钮组件测试
    - 测试各种按钮类型渲染
    - 测试 loading 和 disabled 状态
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_
  
  - [x] 15.2 编写输入框组件测试
    - 测试文本和密码输入
    - 测试错误状态显示
    - _Requirements: 4.1, 4.2, 4.4_
  
  - [x] 15.3 编写导航组件测试
    - 测试导航栏渲染
    - 测试底部导航切换
    - _Requirements: 5.1, 5.2, 5.4_

- [ ] 16. Final Checkpoint - 最终验证
  - 确保所有测试通过
  - 验证应用完整功能
  - 确认无遗留的 forui 或硬编码颜色
  - 如有问题请询问用户

## Notes

- 所有任务都是必须完成的
- 每个任务都引用了具体的需求以便追溯
- Checkpoint 任务用于增量验证
- 属性测试验证通用的正确性属性
- 单元测试验证具体的示例和边界情况
