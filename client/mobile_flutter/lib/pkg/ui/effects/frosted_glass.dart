// 毛玻璃效果组件

import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 毛玻璃效果容器
///
/// 用法：
/// ```dart
/// FrostedGlass(
///   blur: 20,
///   child: Container(
///     padding: EdgeInsets.all(16),
///     child: Text('内容'),
///   ),
/// )
/// ```
class FrostedGlass extends StatelessWidget {
  const FrostedGlass({
    super.key,
    required this.child,
    this.blur = 20.0,
    this.opacity = 0.7,
    this.color,
    this.borderRadius,
    this.border,
  });

  final Widget child;

  /// 模糊程度，默认 20
  final double blur;

  /// 背景透明度，默认 0.7
  final double opacity;

  /// 背景颜色，默认使用主题的 surfaceBase
  final Color? color;

  /// 圆角
  final BorderRadius? borderRadius;

  /// 边框
  final Border? border;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bgColor = color ?? colors.surfaceBase;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor.withValues(alpha: opacity),
            borderRadius: borderRadius,
            border: border,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 毛玻璃 AppBar
///
/// 用于需要透明模糊效果的顶部导航栏
class FrostedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FrostedAppBar({
    super.key,
    this.leading,
    this.title,
    this.actions,
    this.blur = 20.0,
    this.opacity = 0.8,
    this.height = kToolbarHeight,
    this.border,
  });

  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final double blur;
  final double opacity;
  final double height;
  final Border? border;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          height: height + MediaQuery.paddingOf(context).top,
          padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
          decoration: BoxDecoration(
            color: colors.surfaceNav.withValues(alpha: opacity),
            border:
                border ??
                Border(bottom: BorderSide(color: colors.divider, width: 0.5)),
          ),
          child: Row(
            children: [
              if (leading != null) leading!,
              if (title != null) Expanded(child: title!),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}

/// 毛玻璃底部导航栏
///
/// 用于需要透明模糊效果的底部导航
class FrostedBottomBar extends StatelessWidget {
  const FrostedBottomBar({
    super.key,
    required this.child,
    this.blur = 20.0,
    this.opacity = 0.8,
    this.height = 56.0,
  });

  final Widget child;
  final double blur;
  final double opacity;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          height: height + bottomPadding,
          padding: EdgeInsets.only(bottom: bottomPadding),
          decoration: BoxDecoration(
            color: colors.surfaceNav.withValues(alpha: opacity),
            border: Border(
              top: BorderSide(color: colors.navBorder, width: 0.5),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
