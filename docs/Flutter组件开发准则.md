# Flutter 组件开发准则

本文档定义了项目中 Flutter 组件的开发规范，确保代码风格一致、可维护性高。所有 AI 和开发者在创建或修改组件时必须遵循这些准则。

## 1. 组件命名规范

### 1.1 文件命名
- 使用 `snake_case` 命名：`app_button.dart`、`app_input.dart`
- 统一前缀 `app_`：所有共享组件以 `app_` 开头
- 文件名与主类名对应：`app_button.dart` → `AppButton`

### 1.2 类命名
- 使用 `PascalCase`：`AppButton`、`AppInput`、`AppAvatar`
- 枚举类型后缀：`AppButtonType`、`AppButtonSize`
- 私有类前缀 `_`：`_ButtonStyleConfig`

### 1.3 枚举命名
```dart
/// 按钮类型枚举
enum AppButtonType {
  primary,    // 主要按钮
  secondary,  // 次要按钮
  outline,    // 轮廓按钮
  text,       // 文字按钮
  danger,     // 危险按钮
  ghost,      // 幽灵按钮
}

/// 尺寸枚举（通用）
enum AppButtonSize {
  small,
  medium,
  large,
}
```

## 2. 组件结构规范

### 2.1 标准组件结构
```dart
import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// 组件描述 - 简要说明组件用途
///
/// 详细说明组件的功能和使用场景。
/// 应用深色主题样式。
///
/// 示例用法:
/// ```dart
/// AppButton(
///   text: '登录',
///   onPressed: () => handleLogin(),
///   type: AppButtonType.primary,
/// )
/// ```
class AppButton extends StatelessWidget {
  // 1. 必需参数
  final String text;
  
  // 2. 可选参数（带默认值）
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  
  // 3. 回调函数
  final VoidCallback? onPressed;
  
  // 4. 构造函数
  const AppButton({
    super.key,
    required this.text,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.onPressed,
  });
  
  // 5. 工厂方法（可选）
  factory AppButton.primary({...}) => AppButton(...);
  
  // 6. build 方法
  @override
  Widget build(BuildContext context) {
    // 实现
  }
  
  // 7. 私有辅助方法
  double _getButtonHeight() {...}
}
```

### 2.2 参数顺序
1. 必需参数（required）
2. 可选参数（带默认值）
3. 回调函数
4. 子组件（child/children）

### 2.3 工厂方法
为常用配置提供工厂方法，简化使用：
```dart
factory AppButton.primary({...});
factory AppButton.secondary({...});
factory AppButton.outline({...});
factory AppButton.danger({...});
```

## 3. 主题系统使用

### 3.1 颜色使用
**必须使用 `AppColors` 中定义的颜色，禁止硬编码颜色值。**

```dart
// ✅ 正确
Container(color: AppColors.background)
Text('Hello', style: TextStyle(color: AppColors.foreground))

// ❌ 错误
Container(color: Color(0xFF000000))
Container(color: Colors.black)
```

#### 语义化颜色
| 颜色 | 用途 |
|------|------|
| `AppColors.primary` | 主要元素背景 |
| `AppColors.secondary` | 次要元素背景 |
| `AppColors.background` | 页面背景 |
| `AppColors.foreground` | 主要文字 |
| `AppColors.surface` | 卡片/容器背景 |
| `AppColors.border` | 边框 |
| `AppColors.mutedForeground` | 次要文字 |
| `AppColors.error` | 错误状态 |
| `AppColors.success` | 成功状态 |
| `AppColors.warning` | 警告状态 |

#### 交互状态颜色
```dart
AppColors.hoverBackground    // 悬停背景
AppColors.pressedBackground  // 按下背景
AppColors.disabledBackground // 禁用背景
AppColors.disabledForeground // 禁用文字
```

### 3.2 间距使用
**必须使用 `AppSpacing` 中定义的间距值。**

```dart
// ✅ 正确
Padding(padding: EdgeInsets.all(AppSpacing.md))
SizedBox(height: AppSpacing.lg)

// ❌ 错误
Padding(padding: EdgeInsets.all(12))
SizedBox(height: 16)
```

#### 间距值
| 名称 | 值 | 用途 |
|------|-----|------|
| `AppSpacing.xxs` | 2px | 极微小间距 |
| `AppSpacing.xs` | 4px | 极小间距 |
| `AppSpacing.sm` | 8px | 小间距 |
| `AppSpacing.md` | 12px | 中等间距 |
| `AppSpacing.lg` | 16px | 大间距 |
| `AppSpacing.xl` | 24px | 超大间距 |
| `AppSpacing.xxl` | 32px | 特大间距 |

#### 预定义 EdgeInsets
```dart
AppSpacing.allSm          // 所有方向 8px
AppSpacing.horizontalLg   // 水平 16px
AppSpacing.verticalMd     // 垂直 12px
AppSpacing.pagePadding    // 页面内边距
AppSpacing.cardPadding    // 卡片内边距
AppSpacing.listItemPadding // 列表项内边距
```

### 3.3 圆角使用
**必须使用 `AppRadius` 中定义的圆角值。**

```dart
// ✅ 正确
BorderRadius.circular(AppRadius.md)
AppRadius.borderLg

// ❌ 错误
BorderRadius.circular(8)
```

#### 圆角值
| 名称 | 值 | 用途 |
|------|-----|------|
| `AppRadius.xs` | 2px | 极小圆角 |
| `AppRadius.sm` | 4px | 小圆角 |
| `AppRadius.md` | 8px | 中等圆角（按钮、输入框） |
| `AppRadius.lg` | 12px | 大圆角（卡片） |
| `AppRadius.xl` | 16px | 超大圆角（对话框） |
| `AppRadius.full` | 9999px | 完全圆角（头像） |

## 4. TDesign 组件封装

### 4.1 封装原则
- 所有 TDesign 组件必须通过 `App*` 组件封装后使用
- 封装时应用项目主题样式
- 提供简化的 API，隐藏复杂配置

### 4.2 封装示例
```dart
class AppInput extends StatefulWidget {
  // 简化参数，隐藏 TDesign 复杂配置
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final AppInputType type;
  
  @override
  Widget build(BuildContext context) {
    return TDInput(
      // 应用项目主题
      backgroundColor: AppColors.surface,
      textStyle: TextStyle(color: AppColors.onSurface),
      // ... 其他配置
    );
  }
}
```

## 5. 状态管理

### 5.1 StatelessWidget vs StatefulWidget
- 无内部状态：使用 `StatelessWidget`
- 有内部状态（如密码可见性切换）：使用 `StatefulWidget`

### 5.2 状态初始化
```dart
class _AppInputState extends State<AppInput> {
  late bool _obscureText;
  late FocusNode _focusNode;
  
  @override
  void initState() {
    super.initState();
    _obscureText = widget.type == AppInputType.password;
    _focusNode = widget.focusNode ?? FocusNode();
  }
  
  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }
}
```

## 6. 文档注释规范

### 6.1 类注释
```dart
/// 统一按钮组件 - 基于 TDesign 风格
///
/// 提供一致的按钮样式和行为，支持多种类型和状态。
/// 应用深色主题样式。
///
/// 示例用法:
/// ```dart
/// AppButton(
///   text: '登录',
///   onPressed: () => handleLogin(),
///   type: AppButtonType.primary,
///   isLoading: isLoading,
/// )
/// ```
class AppButton extends StatelessWidget {
```

### 6.2 参数注释
```dart
/// 按钮文字
final String? text;

/// 点击回调
final VoidCallback? onPressed;

/// 是否显示加载状态
final bool isLoading;
```

### 6.3 枚举值注释
```dart
enum AppButtonType {
  /// 主要按钮 - 深色背景，用于主要操作
  primary,
  
  /// 次要按钮 - 浅色背景，用于次要操作
  secondary,
}
```

## 7. 尺寸规范

### 7.1 标准尺寸
组件应支持三种标准尺寸：

| 尺寸 | 高度 | 字体 | 图标 |
|------|------|------|------|
| small | 32px | 13px | 16px |
| medium | 40px | 14px | 20px |
| large | 48px | 16px | 24px |

### 7.2 尺寸实现
```dart
double _getButtonHeight() {
  switch (size) {
    case AppButtonSize.small:
      return 32;
    case AppButtonSize.medium:
      return 40;
    case AppButtonSize.large:
      return 48;
  }
}
```

## 8. 禁用状态处理

### 8.1 统一禁用样式
```dart
final bool effectiveDisabled = isDisabled || isLoading;

return Container(
  color: effectiveDisabled 
      ? AppColors.disabledBackground 
      : AppColors.primary,
  child: Text(
    text,
    style: TextStyle(
      color: effectiveDisabled 
          ? AppColors.disabledForeground 
          : AppColors.primaryForeground,
    ),
  ),
);
```

### 8.2 禁用交互
```dart
InkWell(
  onTap: effectiveDisabled ? null : onPressed,
  // ...
)
```

## 9. 加载状态处理

### 9.1 加载指示器
使用 TDesign 的 `TDLoading` 组件：
```dart
if (isLoading) ...[
  SizedBox(
    width: _getLoadingSize(),
    height: _getLoadingSize(),
    child: TDLoading(
      size: TDLoadingSize.small,
      icon: TDLoadingIcon.circle,
      iconColor: buttonStyle.foregroundColor,
    ),
  ),
  if (text != null) const SizedBox(width: 8),
]
```

## 10. 无障碍支持

### 10.1 语义化
```dart
Semantics(
  label: '登录按钮',
  button: true,
  enabled: !isDisabled,
  child: // 按钮实现
)
```

### 10.2 触摸目标
确保可点击区域至少 44x44 像素。

## 11. 组件导出

### 11.1 统一导出文件
在 `shared/widgets/index.dart` 中导出所有组件：
```dart
export 'app_button.dart';
export 'app_input.dart';
export 'app_avatar.dart';
// ...
```

### 11.2 使用方式
```dart
import 'package:your_app/shared/widgets/index.dart';
```

## 12. 代码检查清单

创建或修改组件时，确保：

- [ ] 使用 `AppColors` 中的颜色
- [ ] 使用 `AppSpacing` 中的间距
- [ ] 使用 `AppRadius` 中的圆角
- [ ] 提供完整的文档注释
- [ ] 支持 small/medium/large 尺寸
- [ ] 正确处理禁用状态
- [ ] 正确处理加载状态
- [ ] 提供工厂方法简化常用配置
- [ ] 在 `index.dart` 中导出
- [ ] 遵循参数顺序规范

## 13. 示例：完整组件模板

```dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// 组件类型枚举
enum AppExampleType {
  /// 主要类型
  primary,
  /// 次要类型
  secondary,
}

/// 组件尺寸枚举
enum AppExampleSize {
  small,
  medium,
  large,
}

/// 示例组件 - 组件用途描述
///
/// 详细说明组件的功能和使用场景。
///
/// 示例用法:
/// ```dart
/// AppExample(
///   title: '标题',
///   type: AppExampleType.primary,
/// )
/// ```
class AppExample extends StatelessWidget {
  /// 标题文本
  final String title;
  
  /// 组件类型
  final AppExampleType type;
  
  /// 组件尺寸
  final AppExampleSize size;
  
  /// 是否禁用
  final bool isDisabled;
  
  /// 点击回调
  final VoidCallback? onTap;

  const AppExample({
    super.key,
    required this.title,
    this.type = AppExampleType.primary,
    this.size = AppExampleSize.medium,
    this.isDisabled = false,
    this.onTap,
  });

  /// 工厂方法：创建主要类型
  factory AppExample.primary({
    Key? key,
    required String title,
    VoidCallback? onTap,
  }) {
    return AppExample(
      key: key,
      title: title,
      type: AppExampleType.primary,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        height: _getHeight(),
        padding: AppSpacing.horizontalLg,
        decoration: BoxDecoration(
          color: isDisabled 
              ? AppColors.disabledBackground 
              : _getBackgroundColor(),
          borderRadius: AppRadius.borderMd,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: _getFontSize(),
              color: isDisabled 
                  ? AppColors.disabledForeground 
                  : _getForegroundColor(),
            ),
          ),
        ),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case AppExampleSize.small:
        return 32;
      case AppExampleSize.medium:
        return 40;
      case AppExampleSize.large:
        return 48;
    }
  }

  double _getFontSize() {
    switch (size) {
      case AppExampleSize.small:
        return 13;
      case AppExampleSize.medium:
        return 14;
      case AppExampleSize.large:
        return 16;
    }
  }

  Color _getBackgroundColor() {
    switch (type) {
      case AppExampleType.primary:
        return AppColors.primary;
      case AppExampleType.secondary:
        return AppColors.secondary;
    }
  }

  Color _getForegroundColor() {
    switch (type) {
      case AppExampleType.primary:
        return AppColors.primaryForeground;
      case AppExampleType.secondary:
        return AppColors.secondaryForeground;
    }
  }
}
```

---

> 最后更新：2024年12月
> 
> 如有疑问或建议，请在项目中提出 Issue。
