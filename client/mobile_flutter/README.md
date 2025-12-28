# 🚀 Lesser Flutter 架构与开发规约

本项目是一个高性能、高复杂度的社交/聊天应用。为了应对 **“超级多组件”** 的挑战，我们采用 **Feature-based DDD (领域驱动设计)** 架构。

---

## 📂 核心目录索引 (The Structure)

```text
lib/
├── core/               # 【地基】完全独立，不引用任何 feature。包含 API 封装、全局主题、通用的 Utils。
├── shared/             # 【共享】业务相关但跨模块的组件。如：UserAvatar, BaseButton, GlobalModels。
├── features/           # 【业务】按 Tab 和功能拆分。
│   ├── feeds/          # 动态流：包含“热门”与“关注”的双 Feed 逻辑。
│   ├── search/         # 搜索：联想搜索、历史记录、结果过滤。
│   ├── post_editor/    # 发布器：多媒体选择、富文本编辑。
│   ├── chat/           # 聊天：Socket 连接、消息气泡、会话列表。
│   ├── profile/        # 个人中心：用户主页、作品集。
│   └── navigation/     # 导航：控制 5 个底部 Tab 的切换与状态保持。
└── main.dart           # 入口：初始化全局配置、环境注入。

```

---

## 🛠 开发守则 (The Rules)

### 1. 组件存放的“三原色”原则

* **Module-Private (模块私有)**: 仅在单个功能使用的组件（如 `ChatBubble`），**严禁** 放入 `shared`，必须留在 `features/chat/widgets`。
* **Shared (跨模块公用)**: 只有当一个组件在 3 个以上模块被用到时，才迁移至 `lib/shared/widgets`。
* **Atomic (原子化)**: 所有的间距、颜色、字体必须引用 `core/theme` 中的常量，严禁在 Widget 中硬编码颜色的十六进制值。

### 2. 状态管理规范 (Riverpod/Bloc)

* **View 只管渲染**: UI 文件（`views/`）中不得出现 `api.post()` 或 `json.decode()`。所有的业务逻辑必须封装在 `providers/` 或 `logic/` 中。
* **保持 State 扁平化**: 针对聊天这种高频刷新的场景，State 对象尽量拆细，避免一个变量改变导致整个页面重绘。

### 3. 组件导出规范 (The Barrel Pattern)

为了避免文件头部出现“Import 海”，每个 `widgets` 文件夹必须建立 `widgets.dart` (或 `index.dart`)：

```dart
// 统一导出
export 'feed_card.dart';
export 'feed_video_player.dart';

```

在 View 层只引用一行：`import '../widgets/widgets.dart';`

---

## 🧩 核心业务组件路线图 (Component Roadmap)

```
feed 
   ├── feed_card.dart
   ├── feed_video_player.dart
   ├── feed_recommendation.dart 
   ├── feed_following.dart
   feed_detail
         follwing_story widgets 

search 
   search_bar.dart
   search_result.dart
   search_suggestion.dart
   search_history.dart
   search_filter.dart
   search_detail.dart
   top_feed_recommendation.dart
   search_tags.dart

post_editor
   post_editor.dart
   post_editor_bar.dart
   post_editor_content.dart
   post_editor_footer.dart
   post_editor_tags.dart

chat 
   group line four badge:
      likepage
      comment page 
      bookmark_@ page 
      new follwers page 
   chat page:
      group chat 
      channel chat 
      friends chat 
      my follwoing my friend , my follwers
      crate group 
      crate channel 
      
settings 
   user_card 
   etc 
   todo 

```

