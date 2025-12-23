# Lesser - 邀请类文字信息流 App

这是一个使用 Flutter 开发的邀请制文字信息流应用程序。项目旨在提供一个简洁、高效的平台，让用户可以专注于高质量内容的分享与交流。

## ✨ 功能特性 (Features)

*   **文字信息流**: 简洁的卡片式设计，聚焦内容本身。
*   **Shadcn 风格**: 采用借鉴自 Shadcn UI 的设计系统，提供清爽、现代的视觉体验。
*   **模块化结构**: 清晰的代码组织，分为主页、信息流、搜索、通知、个人中心等模块。
*   **状态管理**: (在这里补充你使用的状态管理方案，如 Provider, Bloc, Riverpod 等)
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

### 核心代码 (Core Code) - `lib/`

项目的源代码主要存放于 `lib/` 目录下：

*   **`main.dart`**: 应用程序的入口文件。定义了 `main()` 函数，负责应用初始化、主题配置和路由管理。
*   **`config/`**: 全局配置文件。
    *   **`shadcn_theme.dart`**: 定义了 Shadcn 风格的颜色、间距、圆角等设计系统变量。
    *   **`theme.dart`**: 全局 App 主题配置。
*   **`models/`**: 数据模型。
    *   **`post.dart`**: 帖子 (Post) 的数据模型定义。
*   **`data/`**: 静态或模拟数据。
    *   **`mock_data.dart`**: 存放用于开发和测试的模拟用户和帖子数据。
*   **`widgets/`**: 可复用的 UI 组件。
    *   **`post_card.dart`**: 信息流中的单条帖子卡片组件。
    *   **`shadcn/`**: Shadcn 风格的基础原子组件库（如 `shadcn_avatar`, `shadcn_button`, `shadcn_card` 等）。
*   **`screens/`**: 应用程序的各个页面。
    *   **`main_screen.dart`**: 主屏幕框架，包含底部导航栏 (BottomNavigationBar) 和页面切换逻辑。
    *   **`home/`**: 首页模块。
        *   **`home_screen.dart`**: 新版首页，包含 "推荐" 和 "关注" 的 Tab 切换结构。
    *   **`feed/`**: 信息流模块。
        *   **`feed_screen.dart`**: 信息流页面容器。
        *   **`feed_list.dart`**: 帖子列表组件，支持滚动和下拉刷新逻辑。
        *   **`stories_bar.dart`**: 顶部的快拍 (Stories) 栏组件。
    *   **`detail_screen.dart`**: 帖子详情页。
    *   **`search/`**: 搜索模块。
        *   **`search_screen.dart`**: 搜索页面。
    *   **`chat_screen.dart`**: 聊天/消息页面。
    *   **`notification_screen.dart`**: 通知页面。
    *   **`profile_screen.dart`**: 个人主页。
    *   **`post_screen.dart`**: 发布帖子页面。
*   **`utils/`**: 工具类。
    *   **`logger/logger_service.dart`**: 日志服务工具。
*   **`services/`**: 后端服务层（预留）。

### 配置文件 (Configuration Files)

*   **`pubspec.yaml`**: Flutter 项目的核心配置文件。定义项目名称、版本、依赖库 (Dependencies) 和资源 (Assets)。
*   **`pubspec.lock`**: 锁定依赖版本的文件，确保团队协作环境一致。**请勿手动修改。**
*   **`analysis_options.yaml`**: Dart 代码静态分析和 Linting 规则配置。
*   **`.gitignore`**: Git 版本控制忽略配置。

### 平台特定代码 (Platform Specific)

*   **`android/`**, **`ios/`**, **`web/`**, **`macos/`**, **`windows/`**, **`linux/`**: 各个平台的原生工程代码和配置。

### 构建与工具 (Build & Tooling)

*   **`build/`**: 编译产物目录 (被 Git 忽略)。
*   **`.dart_tool/`**: Dart 工具链生成的临时文件。
*   **`.idea/`, `lesser.iml`**: IDE 配置文件。

---

## 🤝 贡献指南 (Contributing)

欢迎对 `Lesser` 项目做出贡献！如果你有好的想法或建议，请遵循以下步骤：

1.  **Fork** 本仓库。
2.  创建一个新的分支 (`git checkout -b feature/YourFeature`)。
3.  提交你的代码更改 (`git commit -m '''feat: Add some amazing feature'''`)。
4.  将你的分支推送到远程仓库 (`git push origin feature/YourFeature`)。
5.  创建一个 **Pull Request**。

---

## 📄 许可证 (License)

该项目基于 [MIT License](LICENSE) 进行分发。详情请查看 `LICENSE` 文件。
