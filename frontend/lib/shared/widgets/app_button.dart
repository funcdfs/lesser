import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// 按钮类型枚举
enum AppButtonType {
  /// 主要按钮 - 深色背景，用于主要操作
  primary,

  /// 次要按钮 - 浅色背景，用于次要操作
  secondary,

  /// 轮廓按钮 - 透明背景带边框
  outline,

  /// 文字按钮 - 无背景，仅文字
  text,

  /// 危险按钮 - 红色，用于破坏性操作
  danger,

  /// 幽灵按钮 - 透明背景，用于图标按钮等
  ghost,
}

/// 按钮尺寸枚举
enum AppButtonSize {
  /// 小尺寸
  small,

  /// 中等尺寸（默认）
  medium,

  /// 大尺寸
  large,
}

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
  /// 按钮文字
  final String? text;

  /// 按钮子组件（与 text 二选一）
  final Widget? child;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 按钮类型
  final AppButtonType type;

  /// 按钮尺寸
  final AppButtonSize size;

  /// 是否显示加载状态
  final bool isLoading;

  /// 是否禁用
  final bool isDisabled;

  /// 前置图标
  final IconData? icon;

  /// 是否占满宽度
  final bool isBlock;

  /// 自定义宽度
  final double? width;

  /// 自定义高度
  final double? height;

  const AppButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.isBlock = false,
    this.width,
    this.height,
  }) : assert(text != null || child != null, 'text 或 child 必须提供一个');

  /// 工厂方法：创建主要按钮
  factory AppButton.primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    bool isBlock = false,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      type: AppButtonType.primary,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      isBlock: isBlock,
    );
  }

  /// 工厂方法：创建次要按钮
  factory AppButton.secondary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    bool isBlock = false,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      type: AppButtonType.secondary,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      isBlock: isBlock,
    );
  }

  /// 工厂方法：创建轮廓按钮
  factory AppButton.outline({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    bool isBlock = false,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      type: AppButtonType.outline,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      isBlock: isBlock,
    );
  }

  /// 工厂方法：创建文字按钮
  factory AppButton.text({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      type: AppButtonType.text,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
    );
  }

  /// 工厂方法：创建危险按钮
  factory AppButton.danger({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    bool isBlock = false,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      type: AppButtonType.danger,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      isBlock: isBlock,
    );
  }

  /// 工厂方法：创建幽灵图标按钮
  factory AppButton.ghost({
    Key? key,
    required IconData icon,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    bool isDisabled = false,
    Color? iconColor,
    double? iconSize,
  }) {
    final double actualIconSize = iconSize ?? _getIconSizeStatic(size);
    return AppButton(
      key: key,
      onPressed: onPressed,
      type: AppButtonType.ghost,
      size: size,
      isDisabled: isDisabled,
      child: Icon(
        icon,
        size: actualIconSize,
        color: iconColor ?? AppColors.mutedForeground,
      ),
    );
  }

  /// 工厂方法：创建带文本和图标的幽灵按钮
  factory AppButton.ghostText({
    Key? key,
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    bool isDisabled = false,
    Color? color,
  }) {
    return AppButton(
      key: key,
      onPressed: onPressed,
      type: AppButtonType.ghost,
      size: size,
      isDisabled: isDisabled,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? AppColors.mutedForeground,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color ?? AppColors.mutedForeground,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static double _getIconSizeStatic(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool effectiveDisabled = isDisabled || isLoading;
    final buttonStyle = _getButtonStyle();
    final buttonHeight = height ?? _getButtonHeight();
    final buttonWidth = isBlock ? double.infinity : width;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: Material(
        color: buttonStyle.backgroundColor,
        borderRadius: BorderRadius.circular(buttonStyle.borderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: effectiveDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(buttonStyle.borderRadius),
          child: Container(
            decoration: buttonStyle.border != null
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(buttonStyle.borderRadius),
                    border: buttonStyle.border,
                  )
                : null,
            padding: _getPadding(),
            child: Row(
              mainAxisSize: isBlock ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                ] else if (icon != null) ...[
                  Icon(
                    icon,
                    size: _getIconSizeStatic(size),
                    color: buttonStyle.foregroundColor,
                  ),
                  if (text != null) const SizedBox(width: 8),
                ],
                if (child != null)
                  child!
                else if (text != null)
                  Text(
                    text!,
                    style: TextStyle(
                      color: buttonStyle.foregroundColor,
                      fontSize: _getFontSize(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 获取加载指示器尺寸
  double _getLoadingSize() {
    switch (size) {
      case AppButtonSize.small:
        return 14;
      case AppButtonSize.medium:
        return 18;
      case AppButtonSize.large:
        return 22;
    }
  }

  /// 获取按钮高度
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

  /// 获取字体大小
  double _getFontSize() {
    switch (size) {
      case AppButtonSize.small:
        return 13;
      case AppButtonSize.medium:
        return 14;
      case AppButtonSize.large:
        return 16;
    }
  }

  /// 获取内边距
  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
    }
  }

  /// 获取按钮样式
  _ButtonStyleConfig _getButtonStyle() {
    final bool effectiveDisabled = isDisabled || isLoading;

    switch (type) {
      case AppButtonType.primary:
        return _ButtonStyleConfig(
          backgroundColor:
              effectiveDisabled ? AppColors.disabledBackground : AppColors.white,
          foregroundColor:
              effectiveDisabled ? AppColors.disabledForeground : AppColors.black,
          border: null,
          borderRadius: AppRadius.md,
        );
      case AppButtonType.secondary:
        return _ButtonStyleConfig(
          backgroundColor:
              effectiveDisabled ? AppColors.disabledBackground : AppColors.secondary,
          foregroundColor:
              effectiveDisabled ? AppColors.disabledForeground : AppColors.secondaryForeground,
          border: null,
          borderRadius: AppRadius.md,
        );
      case AppButtonType.outline:
        return _ButtonStyleConfig(
          backgroundColor: Colors.transparent,
          foregroundColor:
              effectiveDisabled ? AppColors.disabledForeground : AppColors.foreground,
          border: Border.all(
            color: effectiveDisabled ? AppColors.disabledForeground : AppColors.border,
          ),
          borderRadius: AppRadius.md,
        );
      case AppButtonType.text:
        return _ButtonStyleConfig(
          backgroundColor: Colors.transparent,
          foregroundColor:
              effectiveDisabled ? AppColors.disabledForeground : AppColors.brand,
          border: null,
          borderRadius: AppRadius.md,
        );
      case AppButtonType.danger:
        return _ButtonStyleConfig(
          backgroundColor:
              effectiveDisabled ? AppColors.disabledBackground : AppColors.error,
          foregroundColor:
              effectiveDisabled ? AppColors.disabledForeground : AppColors.errorForeground,
          border: null,
          borderRadius: AppRadius.md,
        );
      case AppButtonType.ghost:
        return _ButtonStyleConfig(
          backgroundColor: Colors.transparent,
          foregroundColor:
              effectiveDisabled ? AppColors.disabledForeground : AppColors.foreground,
          border: null,
          borderRadius: AppRadius.md,
        );
    }
  }
}

/// 按钮样式配置
class _ButtonStyleConfig {
  final Color backgroundColor;
  final Color foregroundColor;
  final Border? border;
  final double borderRadius;

  const _ButtonStyleConfig({
    required this.backgroundColor,
    required this.foregroundColor,
    this.border,
    this.borderRadius = AppRadius.md,
  });
}
