import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// 统一顶部导航栏组件 - 基于深色主题设计
///
/// 提供一致的顶部导航栏样式和行为，支持标题、返回按钮、操作按钮。
/// 应用深色主题样式。
///
/// 示例用法:
/// ```dart
/// AppNavBar(
///   title: '页面标题',
///   onBack: () => Navigator.pop(context),
///   actions: [
///     AppNavBarAction(
///       icon: Icons.more_vert,
///       onPressed: () {},
///     ),
///   ],
/// )
/// ```
class AppNavBar extends StatelessWidget implements PreferredSizeWidget {
  /// 导航栏标题
  final String? title;

  /// 自定义标题组件（与 title 二选一）
  final Widget? titleWidget;

  /// 返回按钮点击回调，为 null 时不显示返回按钮
  final VoidCallback? onBack;

  /// 是否显示返回按钮（默认根据 onBack 是否为 null 判断）
  final bool? showBack;

  /// 自定义返回按钮图标
  final IconData? backIcon;

  /// 右侧操作按钮列表
  final List<Widget>? actions;

  /// 是否居中标题
  final bool centerTitle;

  /// 导航栏背景色
  final Color? backgroundColor;

  /// 标题文字颜色
  final Color? titleColor;

  /// 导航栏高度
  final double height;

  /// 是否显示底部边框
  final bool showBorder;

  /// 自定义左侧组件
  final Widget? leading;

  const AppNavBar({
    super.key,
    this.title,
    this.titleWidget,
    this.onBack,
    this.showBack,
    this.backIcon,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.titleColor,
    this.height = 44.0,
    this.showBorder = true,
    this.leading,
  });

  /// 工厂方法：创建简单标题导航栏
  factory AppNavBar.simple({
    Key? key,
    required String title,
    VoidCallback? onBack,
    List<Widget>? actions,
  }) {
    return AppNavBar(
      key: key,
      title: title,
      onBack: onBack,
      actions: actions,
    );
  }

  /// 工厂方法：创建透明背景导航栏
  factory AppNavBar.transparent({
    Key? key,
    String? title,
    Widget? titleWidget,
    VoidCallback? onBack,
    List<Widget>? actions,
    Color titleColor = AppColors.white,
  }) {
    return AppNavBar(
      key: key,
      title: title,
      titleWidget: titleWidget,
      onBack: onBack,
      actions: actions,
      backgroundColor: Colors.transparent,
      titleColor: titleColor,
      showBorder: false,
    );
  }

  /// 工厂方法：创建带自定义标题组件的导航栏
  factory AppNavBar.custom({
    Key? key,
    required Widget titleWidget,
    VoidCallback? onBack,
    List<Widget>? actions,
    Color? backgroundColor,
  }) {
    return AppNavBar(
      key: key,
      titleWidget: titleWidget,
      onBack: onBack,
      actions: actions,
      backgroundColor: backgroundColor,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.background;
    final effectiveTitleColor = titleColor ?? AppColors.onSurface;
    final effectiveShowBack = showBack ?? (onBack != null);

    return Container(
      height: height + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: height,
          child: Row(
            children: [
              // 左侧区域
              SizedBox(
                width: 56,
                child: _buildLeading(effectiveShowBack, effectiveTitleColor),
              ),
              // 标题区域
              Expanded(
                child: centerTitle
                    ? Center(
                        child: titleWidget ??
                            _buildTitleWidget(effectiveTitleColor),
                      )
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: titleWidget ??
                            _buildTitleWidget(effectiveTitleColor),
                      ),
              ),
              // 右侧操作区域
              _buildActions(effectiveTitleColor),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建标题组件
  Widget? _buildTitleWidget(Color titleColor) {
    if (title == null) return null;
    return Text(
      title!,
      style: TextStyle(
        color: titleColor,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 构建左侧组件
  Widget? _buildLeading(bool showBack, Color iconColor) {
    if (leading != null) {
      return leading;
    }

    if (showBack) {
      return GestureDetector(
        onTap: onBack,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            backIcon ?? Icons.arrow_back_ios_new,
            size: 22,
            color: iconColor,
          ),
        ),
      );
    }

    return null;
  }

  /// 构建右侧操作按钮
  Widget _buildActions(Color iconColor) {
    if (actions == null || actions!.isEmpty) {
      return const SizedBox(width: 56);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actions!,
    );
  }
}

/// 导航栏操作按钮 - 便捷组件
///
/// 用于在 AppNavBar 的 actions 中使用
class AppNavBarAction extends StatelessWidget {
  /// 图标
  final IconData icon;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 图标颜色
  final Color? color;

  /// 图标大小
  final double size;

  /// 徽章数量（0 表示不显示）
  final int badge;

  const AppNavBarAction({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 22,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.onSurface;

    Widget iconWidget = GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Icon(
          icon,
          size: size,
          color: effectiveColor,
        ),
      ),
    );

    if (badge > 0) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                badge > 99 ? '99+' : badge.toString(),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    return iconWidget;
  }
}

/// 导航栏文字按钮 - 便捷组件
class AppNavBarTextAction extends StatelessWidget {
  /// 按钮文字
  final String text;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 文字颜色
  final Color? color;

  /// 是否禁用
  final bool isDisabled;

  const AppNavBarTextAction({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isDisabled
        ? AppColors.disabledForeground
        : (color ?? AppColors.brand);

    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: effectiveColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
