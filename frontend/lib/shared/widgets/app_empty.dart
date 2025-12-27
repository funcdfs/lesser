import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// 空状态类型枚举
enum AppEmptyType {
  /// 默认空状态
  plain,

  /// 无数据
  noData,

  /// 无网络
  noNetwork,

  /// 搜索无结果
  noSearch,

  /// 操作失败
  fail,
}

/// 统一空状态组件 - 基于 TDesign 风格
///
/// 提供一致的空状态显示，支持多种类型和自定义内容。
/// 应用深色主题样式。
///
/// 示例用法:
/// ```dart
/// // 基础用法
/// AppEmpty()
///
/// // 自定义文字
/// AppEmpty(
///   title: '暂无数据',
///   description: '请稍后再试',
/// )
///
/// // 带操作按钮
/// AppEmpty.noNetwork(
///   onRetry: () => refresh(),
/// )
/// ```
class AppEmpty extends StatelessWidget {
  /// 空状态类型
  final AppEmptyType type;

  /// 标题文字
  final String? title;

  /// 描述文字
  final String? description;

  /// 自定义图标
  final IconData? icon;

  /// 自定义图片组件
  final Widget? image;

  /// 操作按钮文字
  final String? actionText;

  /// 操作按钮回调
  final VoidCallback? onAction;

  const AppEmpty({
    super.key,
    this.type = AppEmptyType.plain,
    this.title,
    this.description,
    this.icon,
    this.image,
    this.actionText,
    this.onAction,
  });

  /// 工厂方法：创建无数据空状态
  factory AppEmpty.noData({
    Key? key,
    String? title,
    String? description,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return AppEmpty(
      key: key,
      type: AppEmptyType.noData,
      title: title ?? '暂无数据',
      description: description,
      actionText: actionText,
      onAction: onAction,
    );
  }

  /// 工厂方法：创建无网络空状态
  factory AppEmpty.noNetwork({
    Key? key,
    String? title,
    String? description,
    VoidCallback? onRetry,
  }) {
    return AppEmpty(
      key: key,
      type: AppEmptyType.noNetwork,
      title: title ?? '网络连接失败',
      description: description ?? '请检查网络设置后重试',
      actionText: '重新加载',
      onAction: onRetry,
    );
  }

  /// 工厂方法：创建搜索无结果空状态
  factory AppEmpty.noSearch({
    Key? key,
    String? title,
    String? description,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return AppEmpty(
      key: key,
      type: AppEmptyType.noSearch,
      title: title ?? '未找到相关内容',
      description: description ?? '换个关键词试试',
      actionText: actionText,
      onAction: onAction,
    );
  }

  /// 工厂方法：创建操作失败空状态
  factory AppEmpty.fail({
    Key? key,
    String? title,
    String? description,
    VoidCallback? onRetry,
  }) {
    return AppEmpty(
      key: key,
      type: AppEmptyType.fail,
      title: title ?? '操作失败',
      description: description ?? '请稍后重试',
      actionText: '重试',
      onAction: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTitle = title ?? _getDefaultTitle();
    final effectiveDescription = description;
    final effectiveIcon = icon ?? _getDefaultIcon();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图片/图标区域
            image ?? _buildDefaultImage(effectiveIcon),
            const SizedBox(height: AppSpacing.lg),
            
            // 标题
            Text(
              effectiveTitle,
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            
            // 描述
            if (effectiveDescription != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                effectiveDescription,
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // 操作按钮
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              TDButton(
                text: actionText!,
                type: TDButtonType.outline,
                theme: TDButtonTheme.primary,
                size: TDButtonSize.medium,
                onTap: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 获取默认标题
  String _getDefaultTitle() {
    switch (type) {
      case AppEmptyType.plain:
        return '暂无内容';
      case AppEmptyType.noData:
        return '暂无数据';
      case AppEmptyType.noNetwork:
        return '网络连接失败';
      case AppEmptyType.noSearch:
        return '未找到相关内容';
      case AppEmptyType.fail:
        return '操作失败';
    }
  }

  /// 获取默认图标
  IconData _getDefaultIcon() {
    switch (type) {
      case AppEmptyType.plain:
      case AppEmptyType.noData:
        return TDIcons.folder_open;
      case AppEmptyType.noNetwork:
        return TDIcons.wifi_off;
      case AppEmptyType.noSearch:
        return TDIcons.search;
      case AppEmptyType.fail:
        return TDIcons.error_circle;
    }
  }

  /// 构建默认图片
  Widget _buildDefaultImage(IconData iconData) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 48,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

/// 空状态包装器
///
/// 根据数据状态显示空状态或内容
///
/// 示例用法:
/// ```dart
/// EmptyWrapper(
///   isEmpty: items.isEmpty,
///   child: ListView(...),
/// )
/// ```
class EmptyWrapper extends StatelessWidget {
  /// 是否为空
  final bool isEmpty;

  /// 子组件
  final Widget child;

  /// 空状态组件（可选，默认为 AppEmpty）
  final Widget? emptyWidget;

  /// 空状态类型
  final AppEmptyType emptyType;

  /// 空状态标题
  final String? emptyTitle;

  /// 空状态描述
  final String? emptyDescription;

  /// 操作按钮文字
  final String? actionText;

  /// 操作按钮回调
  final VoidCallback? onAction;

  const EmptyWrapper({
    super.key,
    required this.isEmpty,
    required this.child,
    this.emptyWidget,
    this.emptyType = AppEmptyType.noData,
    this.emptyTitle,
    this.emptyDescription,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return Center(
        child: emptyWidget ??
            AppEmpty(
              type: emptyType,
              title: emptyTitle,
              description: emptyDescription,
              actionText: actionText,
              onAction: onAction,
            ),
      );
    }
    return child;
  }
}
