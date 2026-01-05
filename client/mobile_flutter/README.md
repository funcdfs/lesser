# Lesser Flutter 客户端

社交平台 Flutter 客户端，采用 gRPC 与后端通信。

---

## 目录结构

```text
lib/
├── gen_protos/         # protoc 生成代码【禁止手动修改】
├── pkg/                # 公共库
│   ├── constants/      # 端点、颜色常量
│   ├── network/        # gRPC Channel 管理
│   ├── errors/         # 异常处理
│   ├── logs/           # 日志工具
│   ├── ui/             # 主题、通用组件
│   └── utils/          # 工具函数
├── features/           # 业务模块
│   ├── auth/           # 登录页
│   ├── home/           # Tab 1: 首页
│   ├── channel/        # Tab 2: 频道
│   ├── chat/           # Tab 3: 聊天
│   └── profile/        # Tab 4: 我的
├── app.dart
└── main.dart
```

---

## Feature 模块结构

每个 Feature 模块遵循统一分层：

```text
features/<name>/
├── handler/            # 业务逻辑层（状态管理）
├── data_access/        # 数据访问层（gRPC 调用）
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
- **原子化**: 颜色、字体、间距引用 `pkg/constants/`，禁止硬编码

### 2. 状态管理

- 使用 Riverpod + StateNotifier
- Handler 负责业务逻辑，Pages 只负责渲染
- 保持 State 扁平化，避免不必要的重绘

### 3. 导出规范

每个目录建立 `index.dart` 统一导出：

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

| Tab | 名称 | Feature | 后端服务 |
|-----|------|---------|---------|
| 1 | 首页 | home | Timeline + Content + Comment + Interaction + Search |
| 2 | 频道 | channel | Channel (广播频道服务) |
| 3 | 聊天 | chat | Chat (私聊/群聊) + Notification |
| 4 | 我的 | profile | User |

登录页（auth）独立，不在底部导航栏。

---

## 运行

```bash
# 安装依赖
flutter pub get

# 生成 Proto 代码
devlesser proto dart

# 运行
flutter run
```
