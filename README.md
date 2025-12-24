# Lesser - 邀请类文字信息流 App

这是一个使用 Flutter 开发的邀请制文字信息流应用程序。项目旨在提供一个简洁、高效的平台，让用户可以专注于高质量内容的分享与交流。

## ✨ 功能特性 (Features)

*   **文字信息流**: 简洁的卡片式设计，聚焦内容本身。
*   **Shadcn 风格**: 采用借鉴自 Shadcn UI 的设计系统，提供清爽、现代的视觉体验。
*   **模块化结构**: 清晰的代码组织，按五个主要功能模块（首页、搜索、发布、聊天、个人资料）组织代码。
*   **响应式布局**: 支持移动端和桌面端的自适应布局。
*   **跨平台支持**: 一套代码库可编译运行于 iOS, Android, Web, macOS 等多个平台。

## 📸 运行截图 (Screenshots)

*(在这里可以添加你的应用截图，以更直观地展示项目)*

| 首页 | 帖子详情 | 个人主页 |
| :---: | :---: | :---: |
| ![首页](https://via.placeholder.com/300x600.png?text=Home+Screen) | ![帖子详情](https://via.placeholder.com/300x600.png?text=Detail+Screen) | ![个人主页](https://via.placeholder.com/300x600.png?text=Profile+Screen) |

---

## 🚀 快速开始 (Getting Started)

1.  **环境配置**: 确保本地已安装 Flutter SDK (推荐 3.x+)。
2.  **获取依赖**:
    ```bash
    flutter pub get
    ```
3.  **运行应用**:
    *   **Chrome**: `flutter run -d chrome`
    *   **macOS**: `flutter run -d macos`

---

## 📂 项目结构与文件说明 (Project Structure & Files)

项目采用模块化架构，按功能划分为五个主要模块，每个模块包含自己的 `screens/` 和 `widgets/` 目录。共享代码统一放在 `common/` 目录下。

### 核心入口

#### `lib/main.dart`
应用程序的入口文件。定义了 `main()` 函数和 `LesserApp` 根组件，负责：
- 应用初始化
- 主题配置（Shadcn 风格）
- 设置主屏幕（包含底部导航栏）

---

### 🏠 Home 模块 - 首页功能

首页模块包含信息流展示、帖子卡片、故事栏等核心功能。

#### Screens（屏幕）

- **`home/screens/home_screen.dart`**
  - 首页主屏幕组件
  - 包含"推荐"和"关注"两个 Tab 切换
  - 使用 `TabController` 管理选项卡切换
  - 集成内部拖拽锁定机制，避免与横向滑动冲突

- **`home/screens/feed/feed_screen.dart`**
  - 帖子动态流屏幕容器
  - 根据 `feedMode` 参数展示不同的帖子列表（推荐/关注）
  - 使用 `CustomScrollView` 结合 Sliver 列表，便于扩展顶部刷新或吸顶效果

- **`home/screens/feed/feed_list.dart`**
  - 动态流列表组件
  - 支持骨架屏加载状态
  - 模拟下拉刷新和向上平滑滚动
  - 基于 `NestedScrollView` 的滚动容器适配
  - 帖子列表渲染及加载更多模拟
  - 悬浮快捷按钮组（刷新、回到顶部）

- **`home/screens/feed/stories_bar.dart`**
  - 故事栏组件（Stories Bar）
  - 展示在"关注"动态流的顶部
  - 包含横向滚动的用户头像列表
  - 点击头像可进入全屏故事浏览模式
  - 支持未读故事标识（彩色圆环）

- **`home/screens/feed/story_view_screen.dart`**
  - 全屏故事浏览屏幕
  - 模拟 Instagram/Threads 的故事交互逻辑
  - 支持左右点击切换故事
  - 支持滑动切换不同用户
  - 带有顶部进度条
  - 支持简单的私信和点赞交互模拟

#### Widgets（组件）

- **`home/widgets/post_card.dart`**
  - 帖子卡片组件
  - 负责展示单个帖子的核心信息流视图
  - 包含作者头像、作者信息、帖子正文、操作栏
  - 支持点赞状态管理和乐观更新
  - 点击可跳转到详情页

- **`home/widgets/post_actions_bar.dart`**
  - 帖子底部操作栏组件
  - 包含点赞、评论、转发、收藏、分享等操作按钮
  - 支持响应式布局：根据屏幕宽度自动切换宽屏（一行显示）或窄屏（两行显示）布局
  - 点赞特效：集成了波纹扩散和粒子爆发动画
  - 通过回调函数通知父组件执行具体的业务逻辑

- **`home/widgets/post_card_skeleton.dart`**
  - 帖子卡片骨架屏组件
  - 用于加载状态时的占位显示
  - 提供流畅的加载体验

- **`home/widgets/post_images_widget.dart`**
  - 帖子图片展示组件
  - 支持多图片展示
  - 处理图片加载和错误状态

- **`home/widgets/expandable_text.dart`**
  - 可展开/折叠的文本组件
  - 支持长文本的展开和收起功能
  - 提供"展开更多"和"收起"按钮

- **`home/widgets/animated_like_button.dart`**
  - 动画点赞按钮组件
  - 提供点赞动画效果
  - 支持点赞状态切换

- **`home/widgets/index.dart`**
  - Home 模块组件的导出文件
  - 统一导出所有组件，方便外部引用

---

### 🔍 Search 模块 - 搜索功能

搜索模块提供内容搜索和发现功能。

#### Screens（屏幕）

- **`search/screens/search_screen.dart`**
  - 搜索与发现屏幕
  - 顶部提供交互式搜索栏
  - 中间展示多类别的"热门榜单"，支持切换分类浏览热门文章
  - 底部展示"热门标签"墙
  - 支持搜索设置（历史、过滤、高级设置）

#### Widgets（组件）

- 预留位置，未来可添加搜索相关的专用组件

---

### ✍️ Post 模块 - 发布功能

发布模块包含帖子发布和详情查看功能。

#### Screens（屏幕）

- **`post/screens/post_screen.dart`**
  - 发布帖子屏幕
  - 提供文本输入框
  - 支持添加话题、图片、GIF、表情等
  - 包含发布按钮和取消按钮
  - 支持回复选项设置

- **`post/screens/detail_screen.dart`**
  - 帖子详情屏幕
  - 展示单条帖子的完整内容
  - 包括帖子正文、图片、位置和精确发布时间
  - 交互操作栏（点赞、评论、转发等）
  - 评论列表占位符
  - 针对帖子的管理操作菜单（不感兴趣、屏蔽、举报等）

#### Widgets（组件）

- 预留位置，未来可添加发布相关的专用组件

---

### 💬 Chat 模块 - 聊天功能

聊天模块提供消息中心和即时通讯功能。

#### Screens（屏幕）

- **`chat/screens/chat_screen.dart`**
  - 消息列表/聊天中心屏幕
  - 顶部提供分类导航（收到的喜欢、评论回复、收藏@、新增粉丝）
  - 中间部分展示活跃聊天列表（群组、频道、私聊）
  - 底部展示特殊功能入口（发现周围的朋友）以及快捷操作按钮（我的互关、创建群聊/频道）

#### Widgets（组件）

- **`chat/widgets/chat_item.dart`**
  - 单个聊天会话/功能项样式组件
  - 展示聊天项的头像、标题、副标题、时间
  - 支持未读消息数量显示
  - 支持箭头指示器

- **`chat/widgets/section_header.dart`**
  - 聊天列表的分组标题组件
  - 用于区分不同的聊天分类（如"聊天"、"网络邻居"）

- **`chat/widgets/top_icon_item.dart`**
  - 顶部功能入口图标项组件
  - 用于展示"收到的喜欢"、"评论和回复"等快捷入口
  - 包含图标和标签文字

- **`chat/widgets/index.dart`**
  - Chat 模块组件的导出文件

---

### 👤 Profile 模块 - 个人资料功能

个人资料模块提供用户个人信息管理和设置功能。

#### Screens（屏幕）

- **`profile/screens/profile_screen.dart`**
  - 个人中心屏幕
  - 仿微信/现代社交应用的个人页布局
  - 包含个人资料卡片（头像、昵称、ID、个人简介）
  - 数据统计（关注、粉丝、发布数）
  - 会员中心及个性化设置入口
  - 内容管理面板（我的文章、草稿箱、我的收藏、数据统计）
  - 意见反馈与联系客服入口
  - 应用设置（深色模式切换、通知、语言、隐私、关于）

#### Widgets（组件）

- 预留位置，未来可添加个人资料相关的专用组件

---

### 🔧 Common 模块 - 共享代码

Common 模块包含所有跨功能模块共享的代码，包括基础组件、工具类、配置、数据模型等。

#### Navigation（导航）

- **`common/navigation/main_screen.dart`**
  - 应用程序主外壳屏幕
  - 负责处理底部导航栏（移动端）与侧边导航栏（桌面端）的切换
  - 多页面状态管理（使用 `IndexedStack` 保持页面状态）
  - 响应式布局：在宽屏上显示侧边栏，窄屏上显示底部导航
  - 包含五个主要导航项：首页、搜索、发布、聊天、个人资料

#### Config（配置）

- **`common/config/shadcn_theme.dart`**
  - Shadcn 风格的主题配置
  - 定义了 Shadcn 风格的颜色、间距、圆角等设计系统变量
  - 包含 `ShadcnColors`、`ShadcnSpacing`、`ShadcnRadius` 等常量类
  - 提供 `ShadcnThemeData` 用于 MaterialApp 主题配置

- **`common/config/theme.dart`**
  - 全局 App 主题配置
  - 定义应用的整体主题样式

#### Models（数据模型）

- **`common/models/post.dart`**
  - 帖子（Post）的数据模型定义
  - 包含帖子的所有属性：ID、作者信息、内容、图片、时间戳、互动数据等
  - 提供数据序列化和反序列化方法

#### Data（数据）

- **`common/data/mock_data.dart`**
  - 存放用于开发和测试的模拟数据
  - 包含模拟用户数据、帖子数据、故事数据等
  - 用于开发和测试阶段，不用于生产环境

#### Utils（工具类）

- **`common/utils/constants.dart`**
  - 应用常量定义
  - 包含布局宽度阈值、动画时长等常量
  - 定义 `AppConstants` 类

- **`common/utils/inner_drag_lock.dart`**
  - 内部拖拽锁定工具
  - 用于解决横向滑动与垂直滑动的冲突问题
  - 在故事栏和 TabBarView 之间协调滚动行为

- **`common/utils/number_formatter.dart`**
  - 数字格式化工具
  - 将大数字格式化为易读形式（如：1000 -> 1K，1000000 -> 1M）

- **`common/utils/time_formatter.dart`**
  - 时间格式化工具
  - 提供相对时间格式化（如："2小时前"）
  - 提供绝对时间格式化（如："2023年12月23日 14:30"）

- **`common/utils/theme_constants.dart`**
  - 主题相关常量
  - 定义图标颜色、尺寸、动画时长等主题常量
  - 包含 `ThemeConstants`、`PostThemeConstants`、`ActionButtonThemeConstants` 等类

- **`common/utils/logger/logger_service.dart`**
  - 日志服务工具
  - 提供统一的日志记录接口
  - 支持不同级别的日志输出（Info、Warning、Error 等）

#### Widgets（共享组件）

- **`common/widgets/shadcn/shadcn_avatar.dart`**
  - Shadcn 风格的头像组件
  - 支持网络图片和本地图片
  - 支持占位符和初始字母显示
  - 可自定义尺寸

- **`common/widgets/shadcn/shadcn_button.dart`**
  - Shadcn 风格的按钮组件
  - 支持不同样式（Primary、Secondary、Outline 等）
  - 支持禁用状态
  - 可自定义文本和图标

- **`common/widgets/shadcn/shadcn_card.dart`**
  - Shadcn 风格的卡片组件
  - 提供统一的卡片容器样式
  - 支持自定义内边距和子组件

- **`common/widgets/shadcn/shadcn_chip.dart`**
  - Shadcn 风格的标签组件
  - 用于展示标签、分类等信息
  - 支持自定义样式

- **`common/widgets/shadcn/shadcn_icon_container.dart`**
  - Shadcn 风格的图标容器组件
  - 提供统一的图标背景容器
  - 支持自定义图标、颜色和尺寸

- **`common/widgets/shadcn/shadcn_list_tile.dart`**
  - Shadcn 风格的列表项组件
  - 用于构建列表项
  - 支持前导图标、标题、副标题、尾随组件
  - 支持点击事件

- **`common/widgets/shadcn/index.dart`**
  - Shadcn 组件的统一导出文件
  - 方便外部引用所有 Shadcn 组件

---

## 🏗️ 架构设计 (Architecture)

### 模块化设计

项目采用模块化架构，每个功能模块（Home、Search、Post、Chat、Profile）都是独立的，包含：

- **`screens/`**: 该模块的屏幕组件
- **`widgets/`**: 该模块专用的 UI 组件
- **预留扩展**: 未来可添加 `models/`、`services/` 等子目录

### 共享代码管理

所有跨模块共享的代码统一放在 `common/` 目录下：

- **`common/widgets/`**: 共享的 UI 组件（如 Shadcn UI 组件库）
- **`common/models/`**: 共享的数据模型
- **`common/utils/`**: 共享的工具类
- **`common/config/`**: 全局配置
- **`common/data/`**: 共享的模拟数据
- **`common/navigation/`**: 主导航框架

### 优势

- ✅ **模块化**: 每个 tab 页面的代码独立组织，便于维护
- ✅ **可扩展**: 每个模块可以独立添加 screens、widgets、models、services
- ✅ **清晰**: 代码归属明确，易于理解项目结构
- ✅ **共享**: 通用代码统一管理，避免重复

---

## 📝 开发规范 (Development Guidelines)

### 文件命名

- 使用小写字母和下划线：`post_card.dart`、`home_screen.dart`
- 组件文件使用描述性名称：`shadcn_avatar.dart`、`post_actions_bar.dart`

### 目录结构

- 每个功能模块包含 `screens/` 和 `widgets/` 子目录
- 共享代码放在 `common/` 目录下
- 使用 `index.dart` 统一导出模块内的组件

### Import 路径

- 模块内引用：使用相对路径 `../widgets/post_card.dart`
- 跨模块引用：使用绝对路径 `../../common/config/shadcn_theme.dart`
- 共享组件：从 `common/` 目录引用

---

## 🤝 贡献指南 (Contributing)

欢迎对 `Lesser` 项目做出贡献！如果你有好的想法或建议，请遵循以下步骤：

1.  **Fork** 本仓库。
2.  创建一个新的分支 (`git checkout -b feature/YourFeature`)。
3.  提交你的代码更改 (`git commit -m '''feat: Add some amazing feature'''`)。
4.  将你的分支推送到远程仓库 (`git push origin feature/YourFeature`)。
5.  创建一个 **Pull Request**。

### 代码规范

- 遵循 Dart 官方代码风格指南
- 使用有意义的变量和函数名
- 添加必要的注释说明复杂逻辑
- 保持代码简洁和可读性

---

## 📄 许可证 (License)

该项目基于 [MIT License](LICENSE) 进行分发。详情请查看 `LICENSE` 文件。

---

## 📞 联系方式 (Contact)

如有问题或建议，欢迎通过 Issue 或 Pull Request 与我们联系。
