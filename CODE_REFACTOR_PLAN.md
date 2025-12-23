# Lesser 代码结构优化方案

## 📋 现状分析

### 冗余问题识别

#### 1. **点赞逻辑重复** ❌
- **PostCard** 中有完整的 `_isLiked` 状态管理和 `_toggleLike()` 方法
- **PostActionsBar** 中也有相同的状态管理逻辑
- **AnimatedLikeButton** 是独立的点赞按钮组件
- **问题**: 三个地方维护相同逻辑，容易不同步

#### 2. **时间格式化分散**
- PostCard 中存在 `_getRelativeTime()` 和 `_getAbsoluteTime()` 两个方法
- 应该抽取到统一的 utils 文件

#### 3. **组件层级混乱**
- `PostCard` 依赖 `PostActionsBar` 依赖 `AnimatedLikeButton`
- 每个都有自己的点赞管理逻辑

#### 4. **数据模型不完整**
- `Post` 模型缺少一些必要的字段（如是否已点赞状态）
- 缺少 DTO (Data Transfer Object) 模式

#### 5. **Shadcn 主题使用不一致**
- 某些颜色使用硬编码值（如 `Color(0xAA999999)`）
- 应该统一从 `ShadcnTheme` 引用

---

## 🎯 优化方案

### Phase 1: 提取公共工具和常量

#### 1.1 创建 `lib/utils/constants.dart`
- 集中管理所有常量（文本标签、时间格式等）
- 提高可维护性和i18n支持

#### 1.2 创建 `lib/utils/time_formatter.dart`
- 提取 `_getRelativeTime()` 和 `_getAbsoluteTime()`
- 作为可复用的工具函数

#### 1.3 创建 `lib/utils/theme_constants.dart`
- 定义所有使用的 `ShadcnColors` 组合
- 替换硬编码的颜色值

---

### Phase 2: 优化点赞逻辑

#### 2.1 重构点赞状态管理
- 在 `Post` 模型中添加 `isLiked` 字段
- 创建 `LikeService` 或 `LikeProvider` 处理点赞逻辑
- PostCard、PostActionsBar、AnimatedLikeButton 统一使用同一个源

#### 2.2 创建 `LikedPostState` 类
```dart
class LikedPostState {
  final bool isLiked;
  final int likeCount;
  
  LikedPostState({
    required this.isLiked,
    required this.likeCount,
  });
}
```

---

### Phase 3: 组件整合和抽象

#### 3.1 优化 PostActionsBar
- 移除内部点赞状态管理
- 接收 `LikedPostState` 作为参数
- 简化组件职责

#### 3.2 优化 PostCard
- 简化点赞逻辑，委托给 PostActionsBar
- 使用统一的时间格式化工具

#### 3.3 创建 `PostCardHeader` 组件
```dart
lib/widgets/components/
  ├── post_card_header.dart        // 用户信息、时间、菜单
  ├── post_card_content.dart       // 文本内容
  └── post_card_footer.dart        // 操作栏
```

---

### Phase 4: 目录结构优化

#### 当前结构
```
lib/
├── widgets/
│   ├── post_card.dart
│   ├── post_actions_bar.dart
│   ├── animated_like_button.dart
│   ├── expandable_text.dart
│   ├── post_images_widget.dart
│   ├── post_card_skeleton.dart
│   └── shadcn/
```

#### 优化后结构
```
lib/
├── widgets/
│   ├── components/                 # 原子组件
│   │   ├── action_button.dart      # 单个操作按钮
│   │   ├── post_card_header.dart   # 卡片头部
│   │   └── post_card_footer.dart   # 卡片底部
│   │
│   ├── posts/                      # 帖子相关组件
│   │   ├── post_card.dart          # 主卡片
│   │   ├── post_actions_bar.dart   # 操作栏
│   │   ├── post_images_widget.dart # 图片组件
│   │   └── post_card_skeleton.dart # 骨架屏
│   │
│   ├── common/                     # 通用组件
│   │   ├── expandable_text.dart
│   │   └── animated_like_button.dart
│   │
│   └── shadcn/                     # Shadcn 设计系统组件
│
├── utils/
│   ├── constants.dart              # 常量定义
│   ├── time_formatter.dart         # 时间格式化
│   ├── theme_constants.dart        # 主题常量
│   ├── number_formatter.dart
│   └── logger/
```

---

### Phase 5: 变量重命名规范

#### 问题
- 私有变量命名不一致：`_isLiked`, `_likeAnimationController`
- 布尔值变量名不够清晰：`isNarrow`, `initiallyLiked`
- 方法名过于简洁：`_toggleLike`, `_showActionMenu`

#### 规范
- **私有变量**: `_camelCase`（已规范）
- **布尔值**: `is/has/should` 前缀 ✓
- **方法**: 动词开头，清晰表达意图
  - ❌ `_toggleLike()` → ✅ `_handleLikeTap()` 或 `_togglePostLike()`
  - ❌ `_getRelativeTime()` → ✅ `_formatRelativeTime()` 或 `getFormattedRelativeTime()`

#### 具体重命名
| 原名 | 新名 | 原因 |
|-----|-----|-----|
| `_isLiked` | `_userLiked` 或 `_postIsLiked` | 区分是哪个对象被点赞 |
| `_toggleLike` | `_handleLikeTap` | 更清晰的意图 |
| `_getRelativeTime` | `_formatRelativeTime` | 动词 format 更准确 |
| `_likeAnimationController` | `_likeScaleAnimController` | 说明动画类型 |
| `isNarrow` | `isNarrowLayout` | 更清晰的上下文 |
| `_ActionButton` | `PostActionButton` | 类应该在私有类前加上父类/作用域前缀 |

---

## 🔧 实施步骤

### 第一步：创建新的 Utils 文件
1. `time_formatter.dart` - 时间格式化
2. `constants.dart` - 常量定义
3. `theme_constants.dart` - 主题颜色常量

### 第二步：重构点赞逻辑
1. 更新 `Post` 模型
2. 优化 `PostActionsBar`
3. 简化 `PostCard`

### 第三步：创建组件层级
1. 创建 `post_card_header.dart`
2. 创建 `post_card_footer.dart`
3. 创建 `action_button.dart`

### 第四步：重组织目录
1. 创建新目录
2. 移动文件
3. 更新导入

### 第五步：重命名变量
1. 批量替换变量名
2. 验证功能正常

---

## 📊 预期改进

| 指标 | 当前 | 优化后 | 改进 |
|-----|-----|--------|------|
| 代码重复度 | 高 | 低 | ↓50% |
| 文件数量 | 28 | 35+ | +维护性 |
| 平均文件行数 | 200 | 100-150 | ↓ 明显 |
| 组件内聚力 | 中 | 高 | ↑ |
| 可测试性 | 差 | 好 | ↑ |

---

## 🎁 额外建议

1. **状态管理**: 考虑使用 Provider 或 Riverpod 进行全局点赞状态管理
2. **测试**: 为 utils 函数添加单元测试
3. **文档**: 为复杂组件添加 dartdoc 注释
4. **性能**: 考虑使用 `const` 构造函数优化性能
5. **可访问性**: 添加 Semantics 和无障碍标签

