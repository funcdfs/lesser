# Design Document: Frontend Code Improvement

## Overview

本设计文档描述了 Flutter 前端代码库完善计划的技术实现方案。该计划分为多个阶段，从高优先级的代码质量修复开始，逐步完善功能实现和测试覆盖。

设计遵循以下原则：
- **渐进式改进**：按优先级分阶段实施，确保每个阶段都能独立交付价值
- **向后兼容**：修改不破坏现有功能
- **一致性**：建立统一的模式和规范，便于团队协作
- **可测试性**：所有新代码都应易于测试

## Architecture

### 现有架构

```
frontend/lib/
├── app/                    # 应用入口和配置
│   ├── app.dart           # 主应用组件
│   ├── app_router.dart    # 路由配置
│   └── app_theme.dart     # 主题配置
├── core/                   # 核心基础设施
│   ├── config/            # 配置管理
│   ├── data/              # 基础数据层
│   ├── navigation/        # 导航服务
│   ├── network/           # 网络层
│   └── utils/             # 工具类
├── features/              # 功能模块
│   ├── auth/              # 认证模块
│   ├── chat/              # 聊天模块
│   ├── create/            # 创建内容模块
│   ├── feeds/             # 动态流模块
│   ├── search/            # 搜索模块
│   └── settings/          # 设置模块
└── shared/                # 共享组件
    ├── data/              # 共享数据
    ├── models/            # 共享模型
    ├── theme/             # 主题系统
    ├── utils/             # 共享工具
    └── widgets/           # 共享组件
```


### 改进后的架构

```
frontend/lib/
├── app/                    # 应用入口和配置
│   ├── app.dart
│   ├── app_router.dart    # 使用 go_router 重构
│   └── app_theme.dart     # 合并主题定义
├── core/
│   ├── config/
│   │   ├── app_config.dart      # 统一配置入口
│   │   ├── constants.dart
│   │   └── environment.dart     # 环境配置
│   ├── error/                   # 新增：统一错误处理
│   │   ├── app_exception.dart   # 异常类型定义
│   │   ├── error_handler.dart   # 错误处理器
│   │   └── error_messages.dart  # 错误消息
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── api_interceptors.dart
│   │   └── token_manager.dart
│   ├── validation/              # 新增：输入验证
│   │   ├── validators.dart
│   │   └── validation_rules.dart
│   └── utils/
├── features/                    # 详见下方各模块详细结构
│   ├── auth/
│   ├── feeds/
│   ├── create/
│   ├── search/
│   ├── chat/
│   └── settings/
└── shared/
    ├── theme/
    │   └── app_theme.dart       # 统一主题
    └── widgets/
```


## Feature Modules Detail

### 1. Auth 模块（认证）

```
features/auth/
├── data/
│   ├── auth_repository.dart              ✅ 已实现
│   │   ├── register()                    ✅ 注册功能
│   │   ├── login()                       ✅ 登录功能
│   │   ├── logout()                      ✅ 登出功能
│   │   ├── isAuthenticated()             ✅ 认证检查
│   │   ├── getProfile()                  ✅ 获取用户资料
│   │   └── _handleAuthResponse()         ✅ 响应处理
│   └── user_repository.dart              ✅ 已实现
│       └── getCurrentUser()              ✅ 获取当前用户
├── domain/
│   └── models/
│       ├── user.dart                     ✅ 已实现（需修复 JsonKey）
│       │   ├── id: int
│       │   ├── username: String
│       │   ├── email: String
│       │   ├── firstName: String?
│       │   └── lastName: String?
│       ├── auth_state.dart               ✅ 已实现
│       │   ├── AuthState.initial()
│       │   ├── AuthState.loading()
│       │   ├── AuthState.authenticated(User)
│       │   ├── AuthState.unauthenticated()
│       │   └── AuthState.error(String)
│       └── auth_response.dart            🆕 新增：独立响应模型
│           ├── token: String
│           ├── userId: int
│           └── username: String
└── presentation/
    ├── providers/
    │   ├── auth_provider.dart            ✅ 已实现（需修复 Ref 类型）
    │   │   ├── checkAuthStatus()         ✅ 检查认证状态
    │   │   ├── login()                   ✅ 登录
    │   │   ├── register()                ✅ 注册
    │   │   └── logout()                  ✅ 登出
    │   └── user_provider.dart            ✅ 已实现（需修复 Ref 类型）
    │       └── currentUserProvider       ✅ 当前用户
    ├── screens/
    │   ├── login_screen.dart             ✅ 已实现（需增强验证）
    │   │   ├── _usernameController
    │   │   ├── _passwordController
    │   │   ├── _handleLogin()
    │   │   └── _buildForm()
    │   ├── register_screen.dart          ✅ 已实现（需增强验证）
    │   │   ├── _usernameController
    │   │   ├── _emailController
    │   │   ├── _passwordController
    │   │   ├── _confirmPasswordController
    │   │   └── _handleRegister()
    │   └── forgot_password_screen.dart   🆕 新增：忘记密码
    │       ├── _emailController
    │       └── _handleResetPassword()
    └── widgets/
        ├── auth_form_field.dart          🆕 新增：统一表单字段
        │   ├── label: String
        │   ├── controller: TextEditingController
        │   ├── validator: String? Function(String?)
        │   └── obscureText: bool
        └── social_login_buttons.dart     🆕 新增：社交登录按钮
            ├── _buildGoogleButton()
            └── _buildAppleButton()
```

**改进项：**
1. 修复 `user.dart` 中的 JsonKey 注解警告
2. 修复 Provider 中的弃用 Ref 类型
3. 增强登录/注册表单验证（邮箱格式、密码强度）
4. 实现登出功能（清除 token + 导航）
5. 添加忘记密码流程（可选）


---

### 2. Feeds 模块（动态流）

```
features/feeds/
├── data/
│   ├── feeds_repository.dart             ✅ 已实现
│   │   └── getFeeds(page, limit)         ✅ 获取动态列表
│   ├── post_repository.dart              🆕 新增：帖子操作
│   │   ├── getPostById(id)               🆕 获取帖子详情
│   │   ├── likePost(id)                  🆕 点赞帖子
│   │   ├── unlikePost(id)                🆕 取消点赞
│   │   ├── bookmarkPost(id)              🆕 收藏帖子
│   │   └── unbookmarkPost(id)            🆕 取消收藏
│   └── comments_repository.dart          🆕 新增：评论数据层
│       ├── getComments(postId, page)     🆕 获取评论列表
│       ├── createComment(postId, content)🆕 发布评论
│       └── deleteComment(commentId)      🆕 删除评论
├── domain/
│   └── models/
│       ├── post.dart                     ✅ 已实现（需修复 JsonKey）
│       │   ├── id: String
│       │   ├── username: String
│       │   ├── content: String
│       │   ├── createdAt: String
│       │   ├── likes: int
│       │   ├── location: String?
│       │   ├── imageUrls: List<String>
│       │   ├── commentsCount: int
│       │   ├── repostsCount: int
│       │   ├── bookmarksCount: int
│       │   ├── sharesCount: int
│       │   └── isLiked: bool
│       ├── story.dart                    ✅ 已实现
│       │   ├── id: String
│       │   ├── username: String
│       │   ├── avatarUrl: String
│       │   └── isViewed: bool
│       ├── comment.dart                  🆕 新增：评论模型
│       │   ├── id: String
│       │   ├── postId: String
│       │   ├── userId: String
│       │   ├── username: String
│       │   ├── content: String
│       │   ├── createdAt: DateTime
│       │   └── likesCount: int
│       └── feed_filter.dart              🆕 新增：筛选条件
│           ├── type: FeedType (all/following/trending)
│           └── timeRange: TimeRange?
└── presentation/
    ├── providers/
    │   ├── feeds_provider.dart           ✅ 已实现（需修复 Ref 类型）
    │   │   ├── feedsRepositoryProvider   ✅ Repository 提供者
    │   │   ├── pagedFeedsProvider        ✅ 分页动态
    │   │   └── fetchPage(page)           ✅ 获取指定页
    │   ├── post_detail_provider.dart     🆕 新增：帖子详情
    │   │   ├── postDetailProvider(id)    🆕 帖子详情
    │   │   ├── toggleLike(id)            🆕 切换点赞
    │   │   └── toggleBookmark(id)        🆕 切换收藏
    │   └── comments_provider.dart        🆕 新增：评论管理
    │       ├── commentsProvider(postId)  🆕 评论列表
    │       ├── addComment(postId, content)🆕 添加评论
    │       └── deleteComment(commentId)  🆕 删除评论
    ├── screens/
    │   ├── home_screen.dart              ✅ 已实现
    │   │   ├── _selectedTabIndex
    │   │   ├── _buildTabBar()
    │   │   └── _buildTabContent()
    │   ├── feed_screen.dart              ✅ 已实现
    │   │   ├── _refreshController
    │   │   ├── _onRefresh()
    │   │   └── _onLoadMore()
    │   ├── following_feed_screen.dart    ✅ 已实现
    │   ├── post_detail_screen.dart       ✅ 已实现
    │   │   ├── _buildPostContent()
    │   │   ├── _buildActions()
    │   │   └── _buildComments()
    │   └── story_screen.dart             ✅ 已实现
    │       ├── _currentIndex
    │       ├── _pageController
    │       └── _buildStoryView()
    └── widgets/
        ├── post_card.dart                ✅ 已实现
        │   ├── _buildHeader()
        │   ├── _buildContent()
        │   ├── _buildImages()
        │   └── _buildActions()
        ├── story_avatar.dart             ✅ 已实现
        │   ├── avatarUrl: String
        │   ├── username: String
        │   └── isViewed: bool
        ├── comment_item.dart             🆕 新增：评论组件
        │   ├── comment: Comment
        │   ├── onLike: VoidCallback
        │   └── onDelete: VoidCallback?
        ├── post_actions.dart             🆕 新增：帖子操作栏
        │   ├── likesCount: int
        │   ├── commentsCount: int
        │   ├── isLiked: bool
        │   ├── isBookmarked: bool
        │   ├── onLike: VoidCallback
        │   ├── onComment: VoidCallback
        │   ├── onBookmark: VoidCallback
        │   └── onShare: VoidCallback
        └── feed_shimmer.dart             🆕 新增：加载骨架屏
            └── _buildShimmerItem()
```

**改进项：**
1. 修复 `post.dart` 中的 JsonKey 注解警告
2. 修复 Provider 中的弃用 Ref 类型
3. 实现评论功能（列表、发布、删除）
4. 实现帖子点赞/收藏功能
5. 添加下拉刷新和加载更多的错误处理


---

### 3. Create 模块（创建内容）

```
features/create/
├── data/
│   ├── create_post_repository.dart       ✅ 已实现
│   │   └── createPost(content, location) ✅ 创建帖子
│   ├── media_upload_repository.dart      🆕 新增：媒体上传
│   │   ├── uploadImage(file)             🆕 上传图片
│   │   ├── uploadImages(files)           🆕 批量上传
│   │   └── deleteMedia(mediaId)          🆕 删除媒体
│   └── draft_repository.dart             🆕 新增：草稿存储
│       ├── saveDraft(draft)              🆕 保存草稿
│       ├── getDrafts()                   🆕 获取草稿列表
│       ├── getDraft(id)                  🆕 获取单个草稿
│       └── deleteDraft(id)               🆕 删除草稿
├── domain/
│   └── models/
│       ├── draft.dart                    🆕 新增：草稿模型
│       │   ├── id: String
│       │   ├── content: String
│       │   ├── location: String?
│       │   ├── mediaItems: List<MediaItem>
│       │   ├── createdAt: DateTime
│       │   └── updatedAt: DateTime
│       ├── media_item.dart               🆕 新增：媒体项模型
│       │   ├── id: String
│       │   ├── type: MediaType (image/video)
│       │   ├── localPath: String?
│       │   ├── remoteUrl: String?
│       │   └── uploadStatus: UploadStatus
│       └── create_post_state.dart        🆕 新增：创建状态
│           ├── CreatePostState.initial()
│           ├── CreatePostState.editing(content, media)
│           ├── CreatePostState.uploading(progress)
│           ├── CreatePostState.success(post)
│           └── CreatePostState.error(message)
└── presentation/
    ├── providers/
    │   ├── create_post_provider.dart     ✅ 已实现
    │   │   ├── createPostRepositoryProvider ✅
    │   │   └── createPostNotifierProvider   ✅
    │   ├── draft_provider.dart           🆕 新增：草稿管理
    │   │   ├── draftsProvider            🆕 草稿列表
    │   │   ├── saveDraft()               🆕 保存草稿
    │   │   └── deleteDraft(id)           🆕 删除草稿
    │   └── media_provider.dart           🆕 新增：媒体管理
    │       ├── selectedMediaProvider     🆕 已选媒体
    │       ├── addMedia(file)            🆕 添加媒体
    │       ├── removeMedia(index)        🆕 移除媒体
    │       └── uploadMedia()             🆕 上传媒体
    ├── screens/
    │   ├── new_post_screen.dart          ✅ 已实现
    │   │   ├── _contentController
    │   │   ├── _locationController
    │   │   ├── _selectedImages
    │   │   ├── _handleSubmit()
    │   │   ├── _buildContentInput()
    │   │   ├── _buildMediaPreview()
    │   │   └── _buildToolbar()
    │   └── drafts_screen.dart            🆕 新增：草稿箱
    │       ├── _buildDraftList()
    │       ├── _onDraftTap(draft)
    │       └── _onDraftDelete(draft)
    └── widgets/
        ├── create_post_floating_sheet.dart ✅ 已实现
        │   ├── _contentController
        │   ├── _handleSubmit()
        │   └── _buildQuickActions()
        ├── media_picker.dart             🆕 新增：媒体选择器
        │   ├── maxCount: int
        │   ├── onSelected: Function(List<File>)
        │   ├── _pickFromGallery()
        │   └── _pickFromCamera()
        ├── media_preview_grid.dart       🆕 新增：媒体预览网格
        │   ├── mediaItems: List<MediaItem>
        │   ├── onRemove: Function(int)
        │   └── _buildMediaTile(item)
        ├── location_picker.dart          🆕 新增：位置选择器
        │   ├── onLocationSelected: Function(String)
        │   ├── _getCurrentLocation()
        │   └── _searchLocation(query)
        └── character_counter.dart        🆕 新增：字数统计
            ├── currentLength: int
            ├── maxLength: int
            └── _buildCounter()
```

**改进项：**
1. 实现内容验证（非空、字数限制）
2. 实现图片上传功能
3. 实现草稿保存功能
4. 添加发布成功/失败反馈
5. 实现位置选择功能


---

### 4. Search 模块（搜索）

```
features/search/
├── data/
│   ├── search_repository.dart            🆕 新增：搜索 API
│   │   ├── search(query, type, page)     🆕 综合搜索
│   │   ├── searchUsers(query, page)      🆕 搜索用户
│   │   ├── searchPosts(query, page)      🆕 搜索帖子
│   │   ├── searchTags(query)             🆕 搜索标签
│   │   ├── getHotList()                  🆕 获取热门榜单
│   │   └── getHotTags()                  🆕 获取热门标签
│   └── search_history_repository.dart    🆕 新增：搜索历史（本地存储）
│       ├── getHistory()                  🆕 获取历史记录
│       ├── addHistory(query)             🆕 添加历史
│       ├── removeHistory(query)          🆕 删除单条历史
│       └── clearHistory()                🆕 清空历史
├── domain/
│   └── models/
│       ├── search_result.dart            🆕 新增：搜索结果
│       │   ├── users: List<User>
│       │   ├── posts: List<Post>
│       │   ├── tags: List<String>
│       │   └── hasMore: bool
│       ├── search_filter.dart            🆕 新增：搜索筛选
│       │   ├── type: SearchType (all/users/posts/tags)
│       │   ├── sortBy: SortBy (relevance/time/popularity)
│       │   └── timeRange: TimeRange?
│       ├── hot_item.dart                 🆕 新增：热门项
│       │   ├── title: String
│       │   ├── author: String
│       │   ├── heat: String
│       │   └── imageUrl: String
│       └── search_suggestion.dart        🆕 新增：搜索建议
│           ├── query: String
│           ├── type: SuggestionType
│           └── count: int?
└── presentation/
    ├── providers/
    │   ├── search_provider.dart          🆕 新增：搜索状态
    │   │   ├── searchQueryProvider       🆕 搜索关键词
    │   │   ├── searchResultProvider      🆕 搜索结果
    │   │   ├── searchFilterProvider      🆕 筛选条件
    │   │   ├── search(query)             🆕 执行搜索
    │   │   └── loadMore()                🆕 加载更多
    │   ├── search_history_provider.dart  🆕 新增：历史管理
    │   │   ├── searchHistoryProvider     🆕 历史列表
    │   │   ├── addToHistory(query)       🆕 添加历史
    │   │   └── clearHistory()            🆕 清空历史
    │   └── hot_content_provider.dart     🆕 新增：热门内容
    │       ├── hotListProvider           🆕 热门榜单
    │       └── hotTagsProvider           🆕 热门标签
    ├── screens/
    │   ├── search_screen.dart            ✅ 已实现（需连接 API）
    │   │   ├── _searchController
    │   │   ├── _selectedCategory
    │   │   ├── hotListItems              ⚠️ 硬编码数据
    │   │   ├── hotTags                   ⚠️ 硬编码数据
    │   │   ├── _buildHotListSection()
    │   │   └── _buildHotTagsSection()
    │   └── search_results_screen.dart    🆕 新增：搜索结果页
    │       ├── _query: String
    │       ├── _buildFilterTabs()
    │       ├── _buildUserResults()
    │       ├── _buildPostResults()
    │       └── _buildTagResults()
    └── widgets/
        ├── search_bar.dart               🆕 新增：搜索栏组件
        │   ├── controller: TextEditingController
        │   ├── onSubmitted: Function(String)
        │   ├── onChanged: Function(String)?
        │   └── _buildClearButton()
        ├── search_history_list.dart      🆕 新增：历史记录列表
        │   ├── history: List<String>
        │   ├── onTap: Function(String)
        │   ├── onDelete: Function(String)
        │   └── onClear: VoidCallback
        ├── hot_list_item.dart            ✅ 已实现（内联，需提取）
        │   ├── index: int
        │   ├── title: String
        │   ├── author: String
        │   ├── heat: String
        │   └── imageUrl: String
        ├── hot_tag_chip.dart             🆕 新增：热门标签芯片
        │   ├── tag: String
        │   └── onTap: VoidCallback
        ├── search_result_item.dart       🆕 新增：结果项组件
        │   ├── SearchUserItem
        │   ├── SearchPostItem
        │   └── SearchTagItem
        └── search_suggestion_list.dart   🆕 新增：搜索建议列表
            ├── suggestions: List<SearchSuggestion>
            └── onTap: Function(String)
```

**改进项：**
1. 实现搜索 API 调用
2. 实现搜索历史本地存储
3. 实现搜索结果分类展示（用户、帖子、标签）
4. 实现搜索建议/自动补全
5. 移除硬编码的 mock 数据
6. 提取内联组件为独立 Widget


---

### 5. Chat 模块（聊天）

```
features/chat/
├── data/
│   ├── chat_repository.dart              🆕 新增：聊天 API
│   │   ├── getConversations()            🆕 获取会话列表
│   │   ├── getConversation(id)           🆕 获取单个会话
│   │   ├── createConversation(userId)    🆕 创建会话
│   │   └── deleteConversation(id)        🆕 删除会话
│   ├── message_repository.dart           🆕 新增：消息存储（本地 + 远程）
│   │   ├── getMessages(conversationId, page) 🆕 获取消息列表
│   │   ├── sendMessage(conversationId, content) 🆕 发送消息
│   │   ├── markAsRead(messageId)         🆕 标记已读
│   │   ├── deleteMessage(messageId)      🆕 删除消息
│   │   ├── saveMessageLocally(message)   🆕 本地保存
│   │   └── getLocalMessages(conversationId) 🆕 获取本地消息
│   └── websocket_service.dart            🆕 新增：WebSocket 服务
│       ├── connect()                     🆕 建立连接
│       ├── disconnect()                  🆕 断开连接
│       ├── send(message)                 🆕 发送消息
│       ├── onMessage: Stream<Message>    🆕 消息流
│       ├── onConnectionState: Stream<ConnectionState> 🆕 连接状态流
│       └── reconnect()                   🆕 重新连接
├── domain/
│   └── models/
│       ├── message.dart                  ✅ 已实现（需转为 Freezed）
│       │   ├── id: String
│       │   ├── senderId: String
│       │   ├── receiverId: String
│       │   ├── content: String
│       │   ├── createdAt: DateTime
│       │   ├── isRead: bool
│       │   ├── status: MessageStatus
│       │   └── type: MessageType
│       ├── conversation.dart             🆕 新增：会话模型
│       │   ├── id: String
│       │   ├── participants: List<ChatUser>
│       │   ├── lastMessage: Message?
│       │   ├── unreadCount: int
│       │   ├── createdAt: DateTime
│       │   └── updatedAt: DateTime
│       ├── chat_user.dart                🆕 新增：聊天用户
│       │   ├── id: String
│       │   ├── username: String
│       │   ├── avatarUrl: String?
│       │   ├── isOnline: bool
│       │   └── lastSeen: DateTime?
│       └── connection_state.dart         🆕 新增：连接状态
│           ├── ConnectionState.disconnected
│           ├── ConnectionState.connecting
│           ├── ConnectionState.connected
│           └── ConnectionState.reconnecting
└── presentation/
    ├── providers/
    │   ├── chat_provider.dart            🆕 新增：聊天状态
    │   │   ├── conversationsProvider     🆕 会话列表
    │   │   ├── currentConversationProvider 🆕 当前会话
    │   │   └── unreadCountProvider       🆕 未读数量
    │   ├── messages_provider.dart        🆕 新增：消息管理
    │   │   ├── messagesProvider(conversationId) 🆕 消息列表
    │   │   ├── sendMessage(content)      🆕 发送消息
    │   │   ├── markAsRead(messageId)     🆕 标记已读
    │   │   └── loadMoreMessages()        🆕 加载更多
    │   └── connection_provider.dart      🆕 新增：连接状态
    │       ├── connectionStateProvider   🆕 连接状态
    │       ├── connect()                 🆕 建立连接
    │       └── disconnect()              🆕 断开连接
    ├── screens/
    │   ├── chat_screen.dart              ✅ 已实现（需连接后端）
    │   │   ├── _buildHeader()            ✅
    │   │   ├── _buildChatList()          ⚠️ 使用 mock 数据
    │   │   └── _buildSectionHeader()     ✅
    │   ├── chat_list_screen.dart         🆕 新增：会话列表
    │   │   ├── _buildConversationList()
    │   │   ├── _buildEmptyState()
    │   │   └── _onConversationTap(conversation)
    │   └── conversation_screen.dart      🆕 新增：对话详情
    │       ├── _conversationId: String
    │       ├── _messageController
    │       ├── _scrollController
    │       ├── _buildMessageList()
    │       ├── _buildInputBar()
    │       └── _handleSend()
    └── widgets/
        ├── chat_item.dart                ✅ 已实现
        │   ├── avatarUrl: String
        │   ├── username: String
        │   ├── lastMessage: String
        │   ├── time: String
        │   └── unreadCount: int
        ├── message_bubble.dart           🆕 新增：消息气泡
        │   ├── message: Message
        │   ├── isMe: bool
        │   ├── showAvatar: bool
        │   └── _buildBubble()
        ├── chat_input.dart               🆕 新增：输入框
        │   ├── controller: TextEditingController
        │   ├── onSend: Function(String)
        │   ├── onAttachment: VoidCallback?
        │   └── _buildSendButton()
        ├── connection_status.dart        🆕 新增：连接状态指示器
        │   ├── state: ConnectionState
        │   └── _buildStatusBanner()
        ├── typing_indicator.dart         🆕 新增：正在输入指示器
        │   └── _buildDots()
        └── message_status_icon.dart      🆕 新增：消息状态图标
            ├── status: MessageStatus
            └── _buildIcon()
```

**改进项：**
1. 实现 WebSocket 连接
2. 实现消息发送和接收
3. 实现消息本地持久化
4. 实现连接状态管理
5. 移除硬编码的 mock 数据
6. 将 Message 模型转为 Freezed


---

### 6. Settings 模块（设置）

```
features/settings/
├── data/
│   ├── settings_repository.dart          🆕 新增：设置存储（本地）
│   │   ├── getSettings()                 🆕 获取设置
│   │   ├── saveSettings(settings)        🆕 保存设置
│   │   ├── getThemeMode()                🆕 获取主题模式
│   │   ├── setThemeMode(mode)            🆕 设置主题模式
│   │   └── clearSettings()               🆕 清空设置
│   └── profile_repository.dart           🆕 新增：资料 API
│       ├── getProfile()                  🆕 获取资料
│       ├── updateProfile(data)           🆕 更新资料
│       ├── updateAvatar(file)            🆕 更新头像
│       └── changePassword(old, new)      🆕 修改密码
├── domain/
│   └── models/
│       ├── user_settings.dart            🆕 新增：用户设置
│       │   ├── themeMode: ThemeMode
│       │   ├── notificationsEnabled: bool
│       │   ├── language: String
│       │   ├── fontSize: FontSize
│       │   └── autoPlayVideos: bool
│       ├── app_preferences.dart          🆕 新增：应用偏好
│       │   ├── isFirstLaunch: bool
│       │   ├── lastSyncTime: DateTime?
│       │   └── cacheSize: int
│       └── profile_update.dart           🆕 新增：资料更新请求
│           ├── username: String?
│           ├── email: String?
│           ├── firstName: String?
│           ├── lastName: String?
│           └── bio: String?
└── presentation/
    ├── providers/
    │   ├── settings_provider.dart        🆕 新增：设置状态
    │   │   ├── userSettingsProvider      🆕 用户设置
    │   │   ├── updateSettings(settings)  🆕 更新设置
    │   │   └── resetSettings()           🆕 重置设置
    │   ├── theme_provider.dart           🆕 新增：主题管理
    │   │   ├── themeModeProvider         🆕 主题模式
    │   │   └── setThemeMode(mode)        🆕 设置主题
    │   └── profile_edit_provider.dart    🆕 新增：资料编辑
    │       ├── profileEditStateProvider  🆕 编辑状态
    │       ├── updateProfile(data)       🆕 更新资料
    │       └── updateAvatar(file)        🆕 更新头像
    ├── screens/
    │   ├── profile_screen.dart           ✅ 已实现
    │   │   ├── _UserCard                 ✅ 用户卡片（内联）
    │   │   ├── _RecordsSection           ✅ 记录区域（内联）
    │   │   ├── _TextManagementSection    ✅ 文字管理（内联）
    │   │   └── _SettingsSection          ✅ 设置区域（内联）
    │   ├── settings_screen.dart          🆕 新增：设置页面
    │   │   ├── _buildAccountSection()    🆕 账户设置
    │   │   ├── _buildAppearanceSection() 🆕 外观设置
    │   │   ├── _buildNotificationSection() 🆕 通知设置
    │   │   ├── _buildPrivacySection()    🆕 隐私设置
    │   │   └── _buildAboutSection()      🆕 关于
    │   ├── edit_profile_screen.dart      🆕 新增：编辑资料
    │   │   ├── _usernameController
    │   │   ├── _emailController
    │   │   ├── _bioController
    │   │   ├── _selectedAvatar
    │   │   ├── _handleSave()
    │   │   └── _handleAvatarChange()
    │   └── change_password_screen.dart   🆕 新增：修改密码
    │       ├── _currentPasswordController
    │       ├── _newPasswordController
    │       ├── _confirmPasswordController
    │       └── _handleChangePassword()
    └── widgets/
        ├── user_card.dart                🆕 新增：提取自 profile_screen
        │   ├── user: User
        │   ├── onEditTap: VoidCallback
        │   └── _buildStats()
        ├── settings_tile.dart            🆕 新增：设置项
        │   ├── title: String
        │   ├── subtitle: String?
        │   ├── leading: Widget?
        │   ├── trailing: Widget?
        │   ├── onTap: VoidCallback?
        │   └── isDestructive: bool
        ├── settings_section.dart         🆕 新增：设置分组
        │   ├── title: String
        │   └── children: List<Widget>
        ├── theme_selector.dart           🆕 新增：主题选择器
        │   ├── currentMode: ThemeMode
        │   ├── onChanged: Function(ThemeMode)
        │   └── _buildOption(mode)
        ├── avatar_picker.dart            🆕 新增：头像选择器
        │   ├── currentAvatar: String?
        │   ├── onChanged: Function(File)
        │   └── _showPickerDialog()
        └── logout_dialog.dart            🆕 新增：登出确认对话框
            ├── onConfirm: VoidCallback
            └── onCancel: VoidCallback
```

**改进项：**
1. 实现登出功能
2. 实现主题切换（浅色/深色/跟随系统）
3. 实现用户资料编辑
4. 实现设置本地持久化
5. 提取内联组件为独立 Widget
6. 实现修改密码功能


---

## Components and Interfaces

### 1. 统一错误处理系统

```dart
/// 应用异常基类
sealed class AppException implements Exception {
  String get message;
  String get userMessage;
}

/// 网络异常
class NetworkException extends AppException {
  final int? statusCode;
  final String message;
  
  NetworkException({this.statusCode, required this.message});
  
  @override
  String get userMessage => switch (statusCode) {
    401 => '登录已过期，请重新登录',
    403 => '没有权限执行此操作',
    404 => '请求的资源不存在',
    >= 500 => '服务器错误，请稍后重试',
    _ => '网络错误，请检查网络连接',
  };
}

/// 认证异常
class AuthException extends AppException {
  final AuthErrorType type;
  final String message;
  
  AuthException({required this.type, required this.message});
  
  @override
  String get userMessage => switch (type) {
    AuthErrorType.invalidCredentials => '用户名或密码错误',
    AuthErrorType.tokenExpired => '登录已过期，请重新登录',
    AuthErrorType.userNotFound => '用户不存在',
    AuthErrorType.emailTaken => '邮箱已被注册',
    AuthErrorType.usernameTaken => '用户名已被使用',
    _ => '认证失败，请重试',
  };
}

enum AuthErrorType {
  invalidCredentials,
  tokenExpired,
  userNotFound,
  emailTaken,
  usernameTaken,
  unknown,
}

/// 验证异常
class ValidationException extends AppException {
  final Map<String, String> fieldErrors;
  
  ValidationException(this.fieldErrors);
  
  @override
  String get message => fieldErrors.values.join(', ');
  
  @override
  String get userMessage => message;
}
```

### 2. 输入验证系统

```dart
/// 验证规则
class ValidationRules {
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static const int minPasswordLength = 8;
  static const int maxPostLength = 500;
  
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
}

/// 验证器
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return '请输入邮箱';
    if (!ValidationRules.emailRegex.hasMatch(value)) return '请输入有效的邮箱地址';
    return null;
  }
  
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return '请输入用户名';
    if (value.length < ValidationRules.minUsernameLength) {
      return '用户名至少需要 ${ValidationRules.minUsernameLength} 个字符';
    }
    if (value.length > ValidationRules.maxUsernameLength) {
      return '用户名不能超过 ${ValidationRules.maxUsernameLength} 个字符';
    }
    if (!ValidationRules.usernameRegex.hasMatch(value)) {
      return '用户名只能包含字母、数字和下划线';
    }
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return '请输入密码';
    if (value.length < ValidationRules.minPasswordLength) {
      return '密码至少需要 ${ValidationRules.minPasswordLength} 个字符';
    }
    return null;
  }
  
  static String? validatePostContent(String? value) {
    if (value == null || value.trim().isEmpty) return '内容不能为空';
    if (value.length > ValidationRules.maxPostLength) {
      return '内容不能超过 ${ValidationRules.maxPostLength} 个字符';
    }
    return null;
  }
}
```


### 3. 路由系统重构

```dart
/// 使用 go_router 的路由配置
final goRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = /* check auth state */;
    final isAuthRoute = state.matchedLocation == '/login' || 
                        state.matchedLocation == '/register';
    
    if (!isLoggedIn && !isAuthRoute) {
      return '/login?redirect=${state.matchedLocation}';
    }
    if (isLoggedIn && isAuthRoute) {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/login', name: 'login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', name: 'register', builder: (_, __) => const RegisterScreen()),
    ShellRoute(
      builder: (context, state, child) => MainScreen(child: child),
      routes: [
        GoRoute(path: '/', name: 'home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/search', name: 'search', builder: (_, __) => const SearchScreen()),
        GoRoute(path: '/chat', name: 'chat', builder: (_, __) => const ChatScreen()),
        GoRoute(path: '/settings', name: 'settings', builder: (_, __) => const SettingsScreen()),
        GoRoute(path: '/post/:id', name: 'postDetail', 
          builder: (_, state) => PostDetailScreen(postId: state.pathParameters['id']!)),
      ],
    ),
  ],
  errorBuilder: (context, state) => NotFoundScreen(),
);
```

## Data Models

### 现有模型修复

需要修复的模型文件：
- `frontend/lib/features/auth/domain/models/user.dart` - 添加 `// ignore_for_file: invalid_annotation_target`
- `frontend/lib/features/feeds/domain/models/post.dart` - 添加 `// ignore_for_file: invalid_annotation_target`

### 新增模型汇总

| 模块 | 模型 | 说明 |
|------|------|------|
| Auth | AuthResponse | 认证响应 |
| Feeds | Comment | 评论 |
| Feeds | FeedFilter | 筛选条件 |
| Create | Draft | 草稿 |
| Create | MediaItem | 媒体项 |
| Create | CreatePostState | 创建状态 |
| Search | SearchResult | 搜索结果 |
| Search | SearchFilter | 搜索筛选 |
| Search | HotItem | 热门项 |
| Search | SearchSuggestion | 搜索建议 |
| Chat | Conversation | 会话 |
| Chat | ChatUser | 聊天用户 |
| Chat | ConnectionState | 连接状态 |
| Settings | UserSettings | 用户设置 |
| Settings | AppPreferences | 应用偏好 |
| Settings | ProfileUpdate | 资料更新 |


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do.*

### Property 1: Model Serialization Round-Trip

*For any* valid Freezed 模型实例（User, Post, ChatMessage, UserSettings），将其序列化为 JSON 后再反序列化，应该产生与原始实例等价的对象。

**Validates: Requirements 2.3**

### Property 2: Input Validation Correctness

*For any* 输入字符串：
- 符合邮箱格式的字符串应该通过邮箱验证器
- 长度在 3-20 之间且只包含字母数字下划线的字符串应该通过用户名验证器
- 长度至少 8 字符的字符串应该通过密码验证器
- 纯空白字符串应该被帖子内容验证器拒绝

**Validates: Requirements 4.1, 4.2, 4.3, 4.5**

### Property 3: Error Handling Consistency

*For any* HTTP 错误状态码（4xx, 5xx），Repository 层应该抛出具有正确类型的 AppException，且该异常的 userMessage 属性应该返回非空的用户友好消息。

**Validates: Requirements 3.2, 3.3**

### Property 4: Message Persistence Round-Trip

*For any* 有效的 ChatMessage 对象，存储到本地数据库后再读取，应该返回与原始消息等价的对象。

**Validates: Requirements 6.5**

### Property 5: Search History Persistence

*For any* 搜索历史记录列表，存储后再读取应该返回相同顺序的相同记录。

**Validates: Requirements 7.4**

### Property 6: Settings Persistence Round-Trip

*For any* 有效的 UserSettings 对象，存储到本地后再读取，应该返回与原始设置等价的对象。

**Validates: Requirements 8.3, 8.5**

## Error Handling

### 错误处理策略

```
UI Layer          → 显示用户友好消息，提供重试选项
      ↑
Provider Layer    → 捕获异常，更新状态，记录日志
      ↑
Repository Layer  → 解析响应，转换为 AppException
      ↑
Network Layer     → 处理连接错误，超时，自动重试
```

### 错误类型映射

| HTTP 状态码 | 异常类型 | 用户消息 |
|------------|---------|---------|
| 400 | ValidationException | 请求参数错误 |
| 401 | AuthException (tokenExpired) | 登录已过期 |
| 403 | AuthException (forbidden) | 没有权限 |
| 404 | NetworkException | 资源不存在 |
| 409 | AuthException (conflict) | 用户名/邮箱已被使用 |
| 422 | ValidationException | 数据验证失败 |
| 500+ | NetworkException | 服务器错误 |
| 网络错误 | NetworkException | 网络连接失败 |


## Testing Strategy

### 测试框架配置

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0
  glados: ^0.5.0  # 属性测试库
  network_image_mock: ^2.1.1
```

### 测试目录结构

```
frontend/test/
├── unit/
│   ├── core/
│   │   ├── validation/validators_test.dart
│   │   └── error/app_exception_test.dart
│   └── features/
│       ├── auth/
│       │   ├── auth_repository_test.dart
│       │   └── auth_provider_test.dart
│       ├── feeds/feeds_repository_test.dart
│       ├── search/search_repository_test.dart
│       ├── chat/message_repository_test.dart
│       └── settings/settings_repository_test.dart
├── property/
│   ├── models/
│   │   ├── user_property_test.dart
│   │   ├── post_property_test.dart
│   │   └── settings_property_test.dart
│   └── validation/validators_property_test.dart
├── widget/
│   ├── auth/
│   │   ├── login_screen_test.dart
│   │   └── register_screen_test.dart
│   └── shared/error_display_test.dart
└── integration/auth_flow_test.dart
```

## Implementation Phases

### Phase 1: 代码质量修复（高优先级）
1. 修复 Riverpod API 弃用警告（11处）
2. 修复 Freezed 模型 JsonKey 注解（11处）
3. 移除未使用的导入
4. 添加模型序列化属性测试

### Phase 2: 基础设施完善
1. 实现统一错误处理系统 (`core/error/`)
2. 实现输入验证系统 (`core/validation/`)
3. 重构路由系统（使用 go_router）
4. 添加验证器属性测试

### Phase 3: Auth 模块完善
1. 增强登录/注册表单验证
2. 实现登出功能（清除 token + 导航）
3. 添加 Auth 相关测试

### Phase 4: Feeds 模块完善
1. 实现评论功能
2. 实现点赞/收藏功能
3. 添加错误处理和加载状态

### Phase 5: Search 模块实现
1. 实现搜索 API 调用
2. 实现搜索历史本地存储
3. 移除硬编码 mock 数据

### Phase 6: Settings 模块完善
1. 实现主题切换
2. 实现设置持久化
3. 实现资料编辑

### Phase 7: Create 模块完善
1. 实现内容验证
2. 实现草稿保存
3. 实现图片上传（可选）

### Phase 8: Chat 模块实现（可选）
1. 实现 WebSocket 连接
2. 实现消息发送和接收
3. 实现消息本地持久化

### Phase 9: 测试覆盖
1. 补充 Repository 单元测试
2. 补充 Provider 单元测试
3. 补充 Widget 测试
4. 达到 70% 代码覆盖率目标
