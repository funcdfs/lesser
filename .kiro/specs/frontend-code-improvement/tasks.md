# Implementation Plan: Frontend Code Improvement

## Overview

本实施计划将前端代码完善工作分为 9 个阶段，从高优先级的代码质量修复开始，逐步完善各功能模块。每个阶段都可独立交付价值。

## Tasks

- [ ] 1. Phase 1: 代码质量修复（高优先级）

- [ ] 1.1 修复 Riverpod API 弃用警告
  - 将 `ApiClientRef` 改为 `Ref` in `api_provider.dart`
  - 将 `UserRepositoryRef` 改为 `Ref` in `user_provider.dart`
  - 将 `CurrentUserRef` 改为 `Ref` in `user_provider.dart`
  - 将 `FeedsRepositoryRef` 改为 `Ref` in `feeds_provider.dart`
  - 将 `FeedsListRef` 改为 `Ref` in `feeds_provider.dart`
  - 运行 `dart run build_runner build` 重新生成代码
  - _Requirements: 1.1, 1.2_

- [ ] 1.2 修复 Freezed 模型 JsonKey 注解警告
  - 在 `user.dart` 顶部添加 `// ignore_for_file: invalid_annotation_target`
  - 在 `post.dart` 顶部添加 `// ignore_for_file: invalid_annotation_target`
  - 运行 `dart run build_runner build` 重新生成代码
  - _Requirements: 2.1, 2.2_

- [ ] 1.3 移除未使用的导入
  - 移除 `mock_data.dart` 中未使用的 `post.dart` 导入
  - 移除 `user.dart` 中不必要的 `json_annotation` 导入
  - 移除 `post.dart` 中不必要的 `json_annotation` 导入
  - 运行 `dart analyze` 确认无警告
  - _Requirements: 10.1_

- [ ] 1.4 添加模型序列化属性测试
  - **Property 1: Model Serialization Round-Trip**
  - 创建 `test/property/models/user_property_test.dart`
  - 创建 `test/property/models/post_property_test.dart`
  - 使用 glados 库实现 round-trip 测试
  - **Validates: Requirements 2.3**

- [ ] 1.5 Checkpoint - 确保代码分析无警告
  - 运行 `dart analyze frontend` 确认无警告
  - 确保所有测试通过，如有问题请询问用户


- [ ] 2. Phase 2: 基础设施完善

- [ ] 2.1 实现统一错误处理系统
  - 创建 `core/error/app_exception.dart` - 定义 AppException 基类
  - 创建 `core/error/network_exception.dart` - 网络异常
  - 创建 `core/error/auth_exception.dart` - 认证异常
  - 创建 `core/error/validation_exception.dart` - 验证异常
  - 创建 `core/error/error_handler.dart` - 错误处理器
  - _Requirements: 3.1, 3.2, 3.3_

- [ ] 2.2 添加错误处理属性测试
  - **Property 3: Error Handling Consistency**
  - 创建 `test/unit/core/error/app_exception_test.dart`
  - 测试所有 HTTP 状态码映射到正确的异常类型
  - 测试所有异常的 userMessage 非空
  - **Validates: Requirements 3.2, 3.3**

- [ ] 2.3 实现输入验证系统
  - 创建 `core/validation/validation_rules.dart` - 验证规则常量
  - 创建 `core/validation/validators.dart` - 验证器函数
  - 实现 validateEmail, validateUsername, validatePassword, validatePostContent
  - _Requirements: 4.1, 4.2, 4.3, 4.5_

- [ ] 2.4 添加验证器属性测试
  - **Property 2: Input Validation Correctness**
  - 创建 `test/property/validation/validators_property_test.dart`
  - 测试有效邮箱通过验证，无效邮箱被拒绝
  - 测试用户名长度和字符规则
  - 测试密码长度规则
  - 测试空白内容被拒绝
  - **Validates: Requirements 4.1, 4.2, 4.3, 4.5**

- [ ] 2.5 Checkpoint - 确保基础设施测试通过
  - 运行所有测试确认通过
  - 确保所有测试通过，如有问题请询问用户


- [ ] 3. Phase 3: Auth 模块完善

- [ ] 3.1 增强登录表单验证
  - 在 `login_screen.dart` 中集成 Validators
  - 添加邮箱/用户名格式验证
  - 添加密码长度验证
  - 显示验证错误消息
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [ ] 3.2 增强注册表单验证
  - 在 `register_screen.dart` 中集成 Validators
  - 添加邮箱格式验证
  - 添加用户名格式验证
  - 添加密码长度验证
  - 添加确认密码匹配验证
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [ ] 3.3 完善登出功能
  - 在 `auth_provider.dart` 的 logout() 中清除 token
  - 登出后导航到登录页面
  - 在 `profile_screen.dart` 的退出登录按钮中调用 logout
  - _Requirements: 8.4_

- [ ] 3.4 添加 Auth 单元测试
  - 创建 `test/unit/features/auth/auth_repository_test.dart`
  - 测试 login, register, logout 方法
  - 使用 mocktail 模拟 API 响应
  - _Requirements: 9.1_

- [ ] 3.5 Checkpoint - 确保 Auth 功能正常
  - 测试登录流程
  - 测试注册流程
  - 测试登出流程
  - 确保所有测试通过，如有问题请询问用户

- [ ] 4. Phase 4: Feeds 模块完善

- [ ] 4.1 实现评论数据层
  - 创建 `features/feeds/data/comments_repository.dart`
  - 实现 getComments(postId, page) 方法
  - 实现 createComment(postId, content) 方法
  - 实现 deleteComment(commentId) 方法
  - 在 `chopper_api_service.dart` 中添加评论 API 端点
  - _Requirements: 相关功能需求_

- [ ] 4.2 创建评论模型
  - 创建 `features/feeds/domain/models/comment.dart`
  - 使用 Freezed 定义 Comment 模型
  - 包含 id, postId, userId, username, content, createdAt, likesCount
  - _Requirements: 相关功能需求_

- [ ] 4.3 实现评论 Provider
  - 创建 `features/feeds/presentation/providers/comments_provider.dart`
  - 实现 commentsProvider(postId) - 评论列表
  - 实现 addComment(postId, content) - 添加评论
  - 实现 deleteComment(commentId) - 删除评论
  - _Requirements: 相关功能需求_

- [ ] 4.4 实现帖子点赞/收藏功能
  - 创建 `features/feeds/data/post_repository.dart`
  - 实现 likePost(id), unlikePost(id) 方法
  - 实现 bookmarkPost(id), unbookmarkPost(id) 方法
  - 在 Provider 中添加 toggleLike, toggleBookmark 方法
  - _Requirements: 相关功能需求_

- [ ] 4.5 添加 Feeds 单元测试
  - 创建 `test/unit/features/feeds/feeds_repository_test.dart`
  - 创建 `test/unit/features/feeds/comments_repository_test.dart`
  - 测试 getFeeds, getComments 方法
  - _Requirements: 9.1_

- [ ] 4.6 Checkpoint - 确保 Feeds 功能正常
  - 确保所有测试通过，如有问题请询问用户


- [ ] 5. Phase 5: Search 模块实现

- [ ] 5.1 实现搜索数据层
  - 创建 `features/search/data/search_repository.dart`
  - 实现 search(query, type, page) 方法
  - 实现 getHotList() 方法
  - 实现 getHotTags() 方法
  - 在 `chopper_api_service.dart` 中添加搜索 API 端点
  - _Requirements: 7.1, 7.2, 7.5_

- [ ] 5.2 实现搜索历史本地存储
  - 创建 `features/search/data/search_history_repository.dart`
  - 使用 SharedPreferences 存储搜索历史
  - 实现 getHistory(), addHistory(query), removeHistory(query), clearHistory()
  - _Requirements: 7.4_

- [ ] 5.3 添加搜索历史属性测试
  - **Property 5: Search History Persistence**
  - 创建 `test/property/features/search/search_history_property_test.dart`
  - 测试历史记录存储后读取返回相同顺序的相同记录
  - **Validates: Requirements 7.4**

- [ ] 5.4 创建搜索模型
  - 创建 `features/search/domain/models/search_result.dart`
  - 创建 `features/search/domain/models/search_filter.dart`
  - 创建 `features/search/domain/models/hot_item.dart`
  - _Requirements: 7.2_

- [ ] 5.5 实现搜索 Provider
  - 创建 `features/search/presentation/providers/search_provider.dart`
  - 实现 searchQueryProvider, searchResultProvider
  - 实现 search(query), loadMore() 方法
  - 创建 `features/search/presentation/providers/search_history_provider.dart`
  - 创建 `features/search/presentation/providers/hot_content_provider.dart`
  - _Requirements: 7.1, 7.2, 7.4, 7.5_

- [ ] 5.6 更新 SearchScreen 连接真实数据
  - 移除 `search_screen.dart` 中的硬编码 mock 数据
  - 使用 Provider 获取热门榜单和热门标签
  - 实现搜索功能调用
  - 显示搜索历史
  - _Requirements: 7.1, 7.3, 7.4, 7.5_

- [ ] 5.7 Checkpoint - 确保 Search 功能正常
  - 确保所有测试通过，如有问题请询问用户

- [ ] 6. Phase 6: Settings 模块完善

- [ ] 6.1 实现设置本地存储
  - 创建 `features/settings/data/settings_repository.dart`
  - 使用 SharedPreferences 存储用户设置
  - 实现 getSettings(), saveSettings(settings), getThemeMode(), setThemeMode(mode)
  - _Requirements: 8.5_

- [ ] 6.2 创建设置模型
  - 创建 `features/settings/domain/models/user_settings.dart`
  - 使用 Freezed 定义 UserSettings 模型
  - 包含 themeMode, notificationsEnabled, language
  - _Requirements: 8.3, 8.5_

- [ ] 6.3 添加设置持久化属性测试
  - **Property 6: Settings Persistence Round-Trip**
  - 创建 `test/property/features/settings/settings_property_test.dart`
  - 测试设置存储后读取返回等价对象
  - **Validates: Requirements 8.3, 8.5**

- [ ] 6.4 实现主题切换功能
  - 创建 `features/settings/presentation/providers/theme_provider.dart`
  - 实现 themeModeProvider, setThemeMode(mode)
  - 在 `app.dart` 中使用 themeModeProvider 控制主题
  - _Requirements: 8.3_

- [ ] 6.5 实现设置 Provider
  - 创建 `features/settings/presentation/providers/settings_provider.dart`
  - 实现 userSettingsProvider, updateSettings(settings)
  - _Requirements: 8.5_

- [ ] 6.6 创建设置页面
  - 创建 `features/settings/presentation/screens/settings_screen.dart`
  - 实现账户设置、外观设置、通知设置、关于等区域
  - 创建 `features/settings/presentation/widgets/theme_selector.dart`
  - _Requirements: 8.3_

- [ ] 6.7 Checkpoint - 确保 Settings 功能正常
  - 测试主题切换
  - 测试设置持久化
  - 确保所有测试通过，如有问题请询问用户


- [ ] 7. Phase 7: Create 模块完善

- [ ] 7.1 实现内容验证
  - 在 `new_post_screen.dart` 中集成 Validators.validatePostContent
  - 阻止提交空白内容
  - 显示字数统计和限制提示
  - _Requirements: 4.5_

- [ ] 7.2 实现草稿本地存储
  - 创建 `features/create/data/draft_repository.dart`
  - 使用 SharedPreferences 或 SQLite 存储草稿
  - 实现 saveDraft(draft), getDrafts(), getDraft(id), deleteDraft(id)
  - _Requirements: 相关功能需求_

- [ ] 7.3 创建草稿模型
  - 创建 `features/create/domain/models/draft.dart`
  - 使用 Freezed 定义 Draft 模型
  - 包含 id, content, location, createdAt, updatedAt
  - _Requirements: 相关功能需求_

- [ ] 7.4 实现草稿 Provider
  - 创建 `features/create/presentation/providers/draft_provider.dart`
  - 实现 draftsProvider, saveDraft(), deleteDraft(id)
  - _Requirements: 相关功能需求_

- [ ] 7.5 更新发帖界面
  - 在 `new_post_screen.dart` 中添加保存草稿按钮
  - 添加发布成功/失败反馈（SnackBar）
  - 创建 `features/create/presentation/widgets/character_counter.dart`
  - _Requirements: 4.5_

- [ ] 7.6 Checkpoint - 确保 Create 功能正常
  - 测试内容验证
  - 测试草稿保存和加载
  - 确保所有测试通过，如有问题请询问用户

- [ ] 8. Phase 8: Chat 模块实现（可选）

- [ ] 8.1 创建聊天模型
  - 创建 `features/chat/domain/models/conversation.dart` - 会话模型
  - 创建 `features/chat/domain/models/chat_user.dart` - 聊天用户模型
  - 将 `message.dart` 转换为 Freezed 模型
  - _Requirements: 6.5_

- [ ] 8.2 实现消息本地存储
  - 创建 `features/chat/data/message_repository.dart`
  - 使用 SQLite 或 Hive 存储消息
  - 实现 saveMessageLocally(message), getLocalMessages(conversationId)
  - _Requirements: 6.5_

- [ ] 8.3 添加消息持久化属性测试
  - **Property 4: Message Persistence Round-Trip**
  - 创建 `test/property/features/chat/message_property_test.dart`
  - 测试消息存储后读取返回等价对象
  - **Validates: Requirements 6.5**

- [ ] 8.4 实现 WebSocket 服务
  - 创建 `features/chat/data/websocket_service.dart`
  - 实现 connect(), disconnect(), send(message)
  - 实现 onMessage 和 onConnectionState 流
  - _Requirements: 6.1, 6.4_

- [ ] 8.5 实现聊天 Provider
  - 创建 `features/chat/presentation/providers/chat_provider.dart`
  - 创建 `features/chat/presentation/providers/messages_provider.dart`
  - 创建 `features/chat/presentation/providers/connection_provider.dart`
  - _Requirements: 6.2, 6.3, 6.4_

- [ ] 8.6 更新 ChatScreen 连接真实数据
  - 移除 `chat_screen.dart` 中的硬编码 mock 数据
  - 使用 Provider 获取会话列表和消息
  - 实现消息发送功能
  - 显示连接状态
  - _Requirements: 6.2, 6.3, 6.4_

- [ ] 8.7 Checkpoint - 确保 Chat 功能正常
  - 测试消息发送和接收
  - 测试连接状态显示
  - 确保所有测试通过，如有问题请询问用户


- [ ] 9. Phase 9: 测试覆盖完善

- [ ] 9.1 补充 Repository 单元测试
  - 创建 `test/unit/features/create/create_post_repository_test.dart`
  - 创建 `test/unit/features/settings/settings_repository_test.dart`
  - 使用 mocktail 模拟依赖
  - _Requirements: 9.1_

- [ ] 9.2 补充 Provider 单元测试
  - 创建 `test/unit/features/auth/auth_provider_test.dart`
  - 创建 `test/unit/features/feeds/feeds_provider_test.dart`
  - 创建 `test/unit/features/settings/settings_provider_test.dart`
  - _Requirements: 9.2_

- [ ] 9.3 补充 Widget 测试
  - 创建 `test/widget/auth/login_screen_test.dart`
  - 创建 `test/widget/auth/register_screen_test.dart`
  - 创建 `test/widget/shared/error_display_test.dart`
  - 测试表单验证显示
  - 测试错误状态显示
  - _Requirements: 9.3_

- [ ] 9.4 运行测试覆盖率报告
  - 运行 `flutter test --coverage`
  - 生成覆盖率报告
  - 确认覆盖率达到 70% 目标
  - _Requirements: 9.5_

- [ ] 9.5 Final Checkpoint - 项目完成
  - 运行 `dart analyze` 确认无警告
  - 运行所有测试确认通过
  - 确认代码覆盖率达标
  - 确保所有测试通过，如有问题请询问用户

## Notes

- All tasks are required for comprehensive implementation
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- Phases can be executed independently after Phase 1-2 completion
