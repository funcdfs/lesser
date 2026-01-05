# Flutter UI 开发准则 - shadcn 风格

本文档定义 Flutter 客户端的 UI 实现规范，采用 shadcn/ui 的设计哲学：简洁、可组合、无侵入。

---

## 1. 设计哲学

### 1.1 核心原则

- **Copy-Paste 优先**: 组件代码直接放在项目中，而非依赖外部包，便于定制
- **无样式侵入**: 组件只提供结构和行为，样式通过 Theme 统一控制
- **可组合性**: 小组件组合成大组件，避免"上帝组件"
- **Radix 式语义**: 组件命名和 API 设计参考 Radix UI 的语义化思路

### 1.2 与 shadcn 的对应关系

| shadcn/ui (Web) | Flutter 实现 |
|-----------------|-------------|
| Tailwind CSS | Theme + Extension Methods |
| Radix Primitives | 自定义 Primitive Widgets |
| CSS Variables | ThemeExtension |
| cn() utility | context.theme.xxx |

---

## 2. 颜色系统

### 2.1 语义化颜色定义

```dart
// lib/pkg/ui/theme/colors.dart

/// shadcn 风格的语义化颜色
/// 不直接使用 Colors.xxx，而是通过语义命名
class AppColors {
  // 背景层级
  final Color background;      // 最底层背景
  final Color foreground;      // 背景上的文字
  
  final Color card;            // 卡片背景
  final Color cardForeground;  // 卡片上的文字
  
  final Color popover;         // 弹出层背景
  final Color popoverForeground;
  
  // 主色调
  final Color primary;         // 主要操作色
  final Color primaryForeground;
  
  // 次要色
  final Color secondary;       // 次要操作
  final Color secondaryForeground;
  
  // 静音色（低对比度）
  final Color muted;           // 禁用/占位背景
  final Color mutedForeground; // 次要文字、时间戳
  
  // 强调色
  final Color accent;          // 悬停/选中态
  final Color accentForeground;
  
  // 功能色
  final Color destructive;     // 危险操作（删除、退出）
  final Color destructiveForeground;
  
  // 边框
  final Color border;          // 默认边框
  final Color input;           // 输入框边框
  final Color ring;            // 焦点环
}
```

### 2.2 暗色/亮色主题

```dart
// 亮色主题 - 参考 shadcn zinc 色板
static const light = AppColors(
  background: Color(0xFFFFFFFF),
  foreground: Color(0xFF09090B),       // zinc-950
  card: Color(0xFFFFFFFF),
  cardForeground: Color(0xFF09090B),
  popover: Color(0xFFFFFFFF),
  popoverForeground: Color(0xFF09090B),
  primary: Color(0xFF18181B),          // zinc-900
  primaryForeground: Color(0xFFFAFAFA),
  secondary: Color(0xFFF4F4F5),        // zinc-100
  secondaryForeground: Color(0xFF18181B),
  muted: Color(0xFFF4F4F5),
  mutedForeground: Color(0xFF71717A),  // zinc-500
  accent: Color(0xFFF4F4F5),
  accentForeground: Color(0xFF18181B),
  destructive: Color(0xFFEF4444),      // red-500
  destructiveForeground: Color(0xFFFAFAFA),
  border: Color(0xFFE4E4E7),           // zinc-200
  input: Color(0xFFE4E4E7),
  ring: Color(0xFF18181B),
);

// 暗色主题
static const dark = AppColors(
  background: Color(0xFF09090B),       // zinc-950
  foreground: Color(0xFFFAFAFA),
  card: Color(0xFF09090B),
  cardForeground: Color(0xFFFAFAFA),
  popover: Color(0xFF09090B),
  popoverForeground: Color(0xFFFAFAFA),
  primary: Color(0xFFFAFAFA),
  primaryForeground: Color(0xFF18181B),
  secondary: Color(0xFF27272A),        // zinc-800
  secondaryForeground: Color(0xFFFAFAFA),
  muted: Color(0xFF27272A),
  mutedForeground: Color(0xFFA1A1AA),  // zinc-400
  accent: Color(0xFF27272A),
  accentForeground: Color(0xFFFAFAFA),
  destructive: Color(0xFF7F1D1D),      // red-900
  destructiveForeground: Color(0xFFFAFAFA),
  border: Color(0xFF27272A),
  input: Color(0xFF27272A),
  ring: Color(0xFFD4D4D8),             // zinc-300
);
```

---

## 3. 排版系统

### 3.1 字体层级

```dart
// lib/pkg/ui/theme/typography.dart

/// shadcn 风格的排版系统
/// 基于 Inter 字体（或系统默认）
class AppTypography {
  // 大标题 - 页面标题
  static const h1 = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.025 * 36,  // tracking-tight
    height: 1.1,
  );
  
  static const h2 = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.025 * 30,
    height: 1.2,
  );
  
  static const h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.025 * 24,
    height: 1.3,
  );
  
  static const h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.025 * 20,
    height: 1.4,
  );
  
  // 正文
  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.75,  // leading-7
  );
  
  static const bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  // 辅助文字
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  // 标签/按钮
  static const label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );
}
```

---

## 4. 间距系统

### 4.1 基于 4px 的间距

```dart
// lib/pkg/ui/theme/spacing.dart

/// 间距常量 - 基于 4px 网格
abstract class Spacing {
  static const double xs = 4;    // 0.25rem
  static const double sm = 8;    // 0.5rem
  static const double md = 12;   // 0.75rem
  static const double lg = 16;   // 1rem
  static const double xl = 24;   // 1.5rem
  static const double xxl = 32;  // 2rem
  static const double xxxl = 48; // 3rem
}

/// 圆角常量
abstract class Radii {
  static const double none = 0;
  static const double sm = 4;     // rounded-sm
  static const double md = 6;     // rounded-md (shadcn 默认)
  static const double lg = 8;     // rounded-lg
  static const double xl = 12;    // rounded-xl
  static const double full = 9999; // rounded-full
}
```

---

## 5. 组件规范

### 5.1 Button 组件

```dart
// lib/pkg/ui/components/button.dart

enum ButtonVariant {
  primary,     // 主要操作
  secondary,   // 次要操作
  outline,     // 边框按钮
  ghost,       // 透明按钮
  destructive, // 危险操作
  link,        // 链接样式
}

enum ButtonSize {
  sm,   // h: 36, px: 12, text: 14
  md,   // h: 40, px: 16, text: 14 (默认)
  lg,   // h: 44, px: 32, text: 16
  icon, // h: 40, w: 40
}

/// shadcn 风格按钮
/// 
/// 用法:
/// ```dart
/// AppButton(
///   variant: ButtonVariant.primary,
///   size: ButtonSize.md,
///   onPressed: () {},
///   child: Text('发布'),
/// )
/// ```
class AppButton extends StatelessWidget {
  final ButtonVariant variant;
  final ButtonSize size;
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  
  // ... 实现
}
```

### 5.2 Input 组件

```dart
// lib/pkg/ui/components/input.dart

/// shadcn 风格输入框
/// 
/// 特点:
/// - 简洁的边框样式
/// - 焦点时显示 ring
/// - 支持前缀/后缀图标
class AppInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? errorText;
  final bool enabled;
  
  // 样式规范:
  // - 高度: 40px
  // - 圆角: 6px (Radii.md)
  // - 边框: 1px border color
  // - 焦点: 2px ring + ring-offset
  // - 内边距: horizontal 12px, vertical 8px
}
```

### 5.3 Card 组件

```dart
// lib/pkg/ui/components/card.dart

/// shadcn 风格卡片
/// 
/// 用于内容容器，如帖子卡片、用户卡片
class AppCard extends StatelessWidget {
  final Widget? header;   // CardHeader
  final Widget? content;  // CardContent
  final Widget? footer;   // CardFooter
  final EdgeInsets? padding;
  
  // 样式规范:
  // - 背景: card color
  // - 圆角: 8px (Radii.lg)
  // - 边框: 1px border color
  // - 阴影: 无（shadcn 风格不使用阴影）
}
```

### 5.4 Avatar 组件

```dart
// lib/pkg/ui/components/avatar.dart

enum AvatarSize {
  xs,  // 24px
  sm,  // 32px
  md,  // 40px (默认)
  lg,  // 48px
  xl,  // 64px
}

/// 头像组件
/// 
/// 支持图片、文字回退、在线状态指示
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? fallbackText;  // 无图片时显示首字母
  final AvatarSize size;
  final bool showOnlineIndicator;
  
  // 样式规范:
  // - 圆形 (rounded-full)
  // - 背景: muted color
  // - 文字: mutedForeground
}
```

### 5.5 Badge 组件

```dart
// lib/pkg/ui/components/badge.dart

enum BadgeVariant {
  primary,
  secondary,
  outline,
  destructive,
}

/// 标签/徽章组件
class AppBadge extends StatelessWidget {
  final BadgeVariant variant;
  final Widget child;
  
  // 样式规范:
  // - 高度: 22px
  // - 圆角: full
  // - 内边距: horizontal 10px
  // - 字体: 12px, medium
}
```

---

## 6. 布局模式

### 6.1 页面结构

```dart
/// 标准页面结构
class StandardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        // shadcn 风格: 无阴影，底部细线分隔
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            color: context.colors.border,
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: // 内容
      ),
    );
  }
}
```

### 6.2 列表间距

```dart
/// Feed 流列表
ListView.separated(
  padding: EdgeInsets.symmetric(vertical: Spacing.lg),
  separatorBuilder: (_, __) => Divider(
    height: 1,
    thickness: 1,
    color: context.colors.border,
  ),
  itemBuilder: (context, index) => PostCard(post: posts[index]),
)
```

### 6.3 表单布局

```dart
/// 表单字段间距
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    AppInput(label: '用户名'),
    SizedBox(height: Spacing.lg),  // 字段间距 16px
    AppInput(label: '密码', obscureText: true),
    SizedBox(height: Spacing.xl),  // 按钮前间距 24px
    AppButton(
      variant: ButtonVariant.primary,
      child: Text('登录'),
    ),
  ],
)
```

---

## 7. 动效规范

### 7.1 时长常量

```dart
abstract class Durations {
  static const fast = Duration(milliseconds: 150);    // 微交互
  static const normal = Duration(milliseconds: 200);  // 常规过渡
  static const slow = Duration(milliseconds: 300);    // 页面切换
}
```

### 7.2 缓动曲线

```dart
abstract class Curves {
  // shadcn 默认使用 ease-in-out
  static const standard = Curves.easeInOut;
  
  // 弹出动画
  static const popup = Curves.easeOutBack;
  
  // 收起动画
  static const dismiss = Curves.easeIn;
}
```

### 7.3 交互反馈

```dart
/// 点击缩放效果
class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;  // 默认 0.98
  
  // 点击时轻微缩小，释放时恢复
}

/// 点赞动画
class LikeAnimation extends StatefulWidget {
  // 心形图标 + 缩放弹跳 + 粒子效果（可选）
}
```

---

## 8. 暗色模式

### 8.1 主题切换

```dart
// lib/pkg/ui/theme/theme_provider.dart

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  
  ThemeMode get mode => _mode;
  
  void setTheme(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }
  
  void toggle() {
    _mode = _mode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    notifyListeners();
  }
}
```

### 8.2 Context Extension

```dart
// lib/pkg/ui/theme/extensions.dart

extension ThemeExtensions on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  
  TextStyle get h1 => AppTypography.h1.copyWith(color: colors.foreground);
  TextStyle get h2 => AppTypography.h2.copyWith(color: colors.foreground);
  TextStyle get body => AppTypography.body.copyWith(color: colors.foreground);
  TextStyle get caption => AppTypography.caption.copyWith(color: colors.mutedForeground);
  
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
```

---

## 9. 组件目录结构

```
lib/pkg/ui/
├── theme/
│   ├── colors.dart          # 颜色定义
│   ├── typography.dart      # 排版定义
│   ├── spacing.dart         # 间距/圆角常量
│   ├── extensions.dart      # Context 扩展
│   └── theme_provider.dart  # 主题状态管理
├── components/
│   ├── button.dart          # 按钮
│   ├── input.dart           # 输入框
│   ├── card.dart            # 卡片
│   ├── avatar.dart          # 头像
│   ├── badge.dart           # 徽章
│   ├── dialog.dart          # 对话框
│   ├── sheet.dart           # 底部抽屉
│   ├── toast.dart           # 轻提示
│   ├── skeleton.dart        # 骨架屏
│   └── separator.dart       # 分隔线
├── animations/
│   ├── tap_scale.dart       # 点击缩放
│   ├── fade_in.dart         # 淡入
│   └── slide_in.dart        # 滑入
└── index.dart               # 统一导出
```

---

## 10. 使用示例

### 10.1 帖子卡片

```dart
class PostCard extends StatelessWidget {
  final Post post;
  
  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: () => Navigator.push(...),
      child: Container(
        padding: EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部: 头像 + 用户名 + 时间
            Row(
              children: [
                AppAvatar(
                  imageUrl: post.author.avatarUrl,
                  fallbackText: post.author.username,
                  size: AvatarSize.md,
                ),
                SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.author.displayName, style: context.body),
                      Text(
                        '@${post.author.username} · ${post.timeAgo}',
                        style: context.caption,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz),
                  onPressed: () => _showOptions(context),
                ),
              ],
            ),
            
            SizedBox(height: Spacing.md),
            
            // 正文
            Text(post.content, style: context.body),
            
            SizedBox(height: Spacing.lg),
            
            // 操作栏
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  count: post.replyCount,
                ),
                _ActionButton(
                  icon: Icons.repeat,
                  count: post.repostCount,
                ),
                _ActionButton(
                  icon: post.isLiked 
                      ? Icons.favorite 
                      : Icons.favorite_border,
                  count: post.likeCount,
                  isActive: post.isLiked,
                  activeColor: Colors.red,
                ),
                _ActionButton(
                  icon: Icons.bookmark_border,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 11. 禁止事项

- ❌ 直接使用 `Colors.xxx`，应通过 `context.colors.xxx`
- ❌ 硬编码字体大小，应使用 `AppTypography` 或 `context.body`
- ❌ 硬编码间距数值，应使用 `Spacing.xxx`
- ❌ 使用 Material 默认阴影，shadcn 风格偏向扁平
- ❌ 组件自带外边距，外边距由父容器控制
- ❌ 过度使用动画，保持克制和功能性

## 12. 推荐做法

- ✅ 语义化命名颜色和样式
- ✅ 组件小而专注，通过组合构建复杂 UI
- ✅ 使用 `const` 构造函数优化性能
- ✅ 暗色模式下测试所有组件
- ✅ 交互元素提供触觉反馈
- ✅ 加载状态使用骨架屏而非 Spinner
