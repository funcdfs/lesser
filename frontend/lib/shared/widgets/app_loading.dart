import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../theme/colors.dart';

/// 加载指示器尺寸枚举
enum AppLoadingSize {
  /// 小尺寸 - 16px
  small,

  /// 中等尺寸 - 24px（默认）
  medium,

  /// 大尺寸 - 32px
  large,
}

/// 加载指示器类型枚举
enum AppLoadingType {
  /// 圆形旋转（默认）
  circular,

  /// 点状加载
  dots,

  /// 文字加载
  text,
}

/// 统一加载指示器组件 - 基于 TDesign TDLoading
///
/// 提供一致的加载状态显示，支持多种尺寸和类型。
/// 应用深色主题样式。
///
/// 示例用法:
/// ```dart
/// // 基础用法
/// AppLoading()
///
/// // 指定尺寸
/// AppLoading(size: AppLoadingSize.large)
///
/// // 带文字
/// AppLoading.withText('加载中...')
///
/// // 全屏加载
/// AppLoading.fullscreen(context)
/// ```
class AppLoading extends StatelessWidget {
  /// 加载指示器尺寸
  final AppLoadingSize size;

  /// 加载指示器类型
  final AppLoadingType type;

  /// 加载文字（可选）
  final String? text;

  /// 自定义颜色
  final Color? color;

  /// 是否垂直布局（文字在下方）
  final bool vertical;

  const AppLoading({
    super.key,
    this.size = AppLoadingSize.medium,
    this.type = AppLoadingType.circular,
    this.text,
    this.color,
    this.vertical = true,
  });

  /// 工厂方法：创建带文字的加载指示器
  factory AppLoading.withText(
    String text, {
    Key? key,
    AppLoadingSize size = AppLoadingSize.medium,
    Color? color,
    bool vertical = true,
  }) {
    return AppLoading(
      key: key,
      size: size,
      text: text,
      color: color,
      vertical: vertical,
    );
  }

  /// 工厂方法：创建小尺寸加载指示器
  factory AppLoading.small({
    Key? key,
    String? text,
    Color? color,
  }) {
    return AppLoading(
      key: key,
      size: AppLoadingSize.small,
      text: text,
      color: color,
    );
  }

  /// 工厂方法：创建大尺寸加载指示器
  factory AppLoading.large({
    Key? key,
    String? text,
    Color? color,
  }) {
    return AppLoading(
      key: key,
      size: AppLoadingSize.large,
      text: text,
      color: color,
    );
  }

  /// 显示全屏加载遮罩
  static void showFullscreen(
    BuildContext context, {
    String? text,
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: AppColors.overlay,
      builder: (context) => PopScope(
        canPop: barrierDismissible,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: AppLoading.withText(
              text ?? '加载中...',
              size: AppLoadingSize.large,
            ),
          ),
        ),
      ),
    );
  }

  /// 隐藏全屏加载遮罩
  static void hideFullscreen(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.brand;
    final tdSize = _mapToTDSize();

    if (text != null) {
      return TDLoading(
        size: tdSize,
        icon: TDLoadingIcon.circle,
        iconColor: effectiveColor,
        text: text,
        textColor: AppColors.onSurfaceVariant,
        axis: vertical ? Axis.vertical : Axis.horizontal,
      );
    }

    return TDLoading(
      size: tdSize,
      icon: TDLoadingIcon.circle,
      iconColor: effectiveColor,
    );
  }

  /// 映射到 TDesign 尺寸
  TDLoadingSize _mapToTDSize() {
    switch (size) {
      case AppLoadingSize.small:
        return TDLoadingSize.small;
      case AppLoadingSize.medium:
        return TDLoadingSize.medium;
      case AppLoadingSize.large:
        return TDLoadingSize.large;
    }
  }
}

/// 加载状态包装器
///
/// 根据加载状态显示加载指示器或内容
///
/// 示例用法:
/// ```dart
/// LoadingWrapper(
///   isLoading: isLoading,
///   child: YourContent(),
/// )
/// ```
class LoadingWrapper extends StatelessWidget {
  /// 是否正在加载
  final bool isLoading;

  /// 子组件
  final Widget child;

  /// 加载时显示的组件（可选，默认为 AppLoading）
  final Widget? loadingWidget;

  /// 加载文字
  final String? loadingText;

  /// 加载指示器尺寸
  final AppLoadingSize loadingSize;

  const LoadingWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingWidget,
    this.loadingText,
    this.loadingSize = AppLoadingSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: loadingWidget ??
            AppLoading(
              size: loadingSize,
              text: loadingText,
            ),
      );
    }
    return child;
  }
}
