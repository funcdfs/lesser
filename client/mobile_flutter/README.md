# Lesser Flutter 客户端

影视聚合评价平台 Flutter 客户端，采用 gRPC 与后端通信。

---

## 目录结构

```text
lib/
├── gen_protos/         # protoc 生成代码【禁止手动修改】
├── pkg/                # 公共库
│   ├── comment/        # 通用评论组件
│   ├── link/           # 深层链接处理
│   ├── models/         # 通用数据模型
│   ├── ui/             # 主题、通用 UI 组件
│   └── utils/          # 工具函数
├── features/           # 业务模块
│   ├── home/           # 首页容器 (Bottom Navigation)
│   ├── discovery/      # Tab 1: 首页 (Discovery)
│   ├── subject/        # Tab 2: 书影音 (Subject) - 原 Series
│   ├── tracker/        # Tab 3: 追踪 (Tracker) - 原 Watchlist
│   ├── profile/        # Tab 4: 我的 (Profile)
│   └── auth/           # 登录认证 (独立模块)
├── app.dart
└── main.dart
```

---

## Feature 模块结构

每个 Feature 模块遵循统一分层：

```text
features/<name>/
├── handler/            # 业务逻辑层（状态管理）
├── data_access/        # 数据访问层（gRPC 调用 / Mock）
├── models/             # 模型层（业务对象）
├── pages/              # 页面
└── widgets/            # 组件
```

### 调用链路

```
pages → handler → data_access → gRPC → Gateway → Service
```

---

## 各层职责

| 层 | 目录 | 职责 |
|---|------|------|
| 页面层 | `pages/` | UI 布局、用户交互 |
| 组件层 | `widgets/` | 可复用 UI 组件 |
| 业务逻辑层 | `handler/` | 状态管理，连接 UI 和数据访问 |
| 数据访问层 | `data_access/` | gRPC 调用，本地缓存 |
| 模型层 | `models/` | 业务模型，封装 Proto 对象 |

---

## 开发规范

### 1. 组件存放原则

- **模块私有**: 仅在单个模块使用的组件，放在 `features/<name>/widgets/`
- **跨模块公用**: 多个模块共用的组件，放在 `pkg/ui/`
- **原子化**: 颜色、字体、间距引用 `pkg/ui/theme/`，禁止硬编码

### 2. 状态管理

- 使用 Riverpod + StateNotifier / ChangeNotifier
- Handler 负责业务逻辑，Pages 只负责渲染
- 保持 State 扁平化，避免不必要的重绘

### 3. 导出规范

每个目录建立 `index.dart` 统一导出（推荐但不强制）：

```dart
// widgets/index.dart
export 'feed_card.dart';
export 'feed_video_player.dart';
```

引用时只需一行：

```dart
import '../widgets/index.dart';
```

---

## 底部导航栏

| Tab | 名称 | Feature | 对应页面 | 功能描述 |
|-----|------|---------|---------|----------|
| 1 | 首页 | discovery | `DiscoveryPage` | 推荐内容、热门榜单 (Discovery) |
| 2 | 书影音 | subject | `SubjectPage` | 书影音列表、详情 (原 Series) |
| 3 | 追踪 | tracker | `TrackerPage` | 追剧日历、续播记录、收藏列表 (原 Watchlist) |
| 4 | 我的 | profile | `ProfilePage` | 用户个人中心 |

---

## 运行

```bash
# 安装依赖
flutter pub get

# 生成 Proto 代码 (如果需要)
# devlesser proto dart

# 运行 (Profile 模式推荐用于真机/模拟器性能测试)
flutter run --profile

# 运行 (Debug 模式)
flutter run
```
