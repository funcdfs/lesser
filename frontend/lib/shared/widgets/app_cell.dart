import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// 单元格类型枚举
enum AppCellType {
  /// 默认类型 - 标准列表项
  normal,

  /// 卡片类型 - 带背景和圆角
  card,

  /// 分组类型 - 用于分组列表
  group,
}

/// 单元格尺寸枚举
enum AppCellSize {
  /// 小尺寸
  small,

  /// 中等尺寸（默认）
  medium,

  /// 大尺寸
  large,
}

/// 统一单元格组件 - 基于 TDesign 风格
///
/// 用于列表项、卡片项等场景，支持标题、描述、图标、箭头等。
/// 应用深色主题样式。
///
/// 示例用法:
/// ```dart
/// AppCell(
///   title: '设置',
///   description: '管理应用设置',
///   leftIcon: Icons.settings,
///   showArrow: true,
///   onTap: () => navigateToSettings(),
/// )
/// ```
class AppCell extends StatelessWidget {
  /// 标题文本
  final String title;

  /// 描述文本（可选）
  final String? description;

  /// 左侧图标（可选）
  final IconData? leftIcon;

  /// 左侧自定义组件（与 leftIcon 二选一）
  final Widget? leftWidget;

  /// 右侧文本（可选）
  final String? rightText;

  /// 右侧自定义组件（可选）
  final Widget? rightWidget;

  /// 是否显示右侧箭头
  final bool showArrow;

  /// 是否显示底部分割线
  final bool showDivider;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 单元格类型
  final AppCellType type;

  /// 单元格尺寸
  final AppCellSize size;

  /// 是否禁用
  final bool isDisabled;

  /// 自定义内边距
  final EdgeInsetsGeometry? padding;

  /// 自定义背景色
  final Color? backgroundColor;

  /// 左侧图标颜色
  final Color? leftIconColor;

  /// 左侧图标背景色
  final Color? leftIconBackgroundColor;

  /// 是否必填（显示红色星号）
  final bool required;

  /// 徽章数量（显示在右侧）
  final int? badgeCount;

  /// 徽章是否静音样式
  final bool badgeMuted;

  const AppCell({
    super.key,
    required this.title,
    this.description,
    this.leftIcon,
    this.leftWidget,
    this.rightText,
    this.rightWidget,
    this.showArrow = false,
    this.showDivider = false,
    this.onTap,
    this.onLongPress,
    this.type = AppCellType.normal,
    this.size = AppCellSize.medium,
    this.isDisabled = false,
    this.padding,
    this.backgroundColor,
    this.leftIconColor,
    this.leftIconBackgroundColor,
    this.required = false,
    this.badgeCount,
    this.badgeMuted = false,
  });

  /// 工厂方法：创建带图标的单元格
  factory AppCell.icon({
    Key? key,
    required String title,
    required IconData icon,
    String? description,
    bool showArrow = true,
    VoidCallback? onTap,
    Color? iconColor,
    Color? iconBackgroundColor,
  }) {
    return AppCell(
      key: key,
      title: title,
      description: description,
      leftIcon: icon,
      leftIconColor: iconColor,
      leftIconBackgroundColor: iconBackgroundColor,
      showArrow: showArrow,
      onTap: onTap,
    );
  }

  /// 工厂方法：创建带头像的单元格
  factory AppCell.avatar({
    Key? key,
    required String title,
    required Widget avatar,
    String? description,
    String? rightText,
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    return AppCell(
      key: key,
      title: title,
      description: description,
      leftWidget: avatar,
      rightText: rightText,
      showArrow: showArrow,
      onTap: onTap,
    );
  }

  /// 工厂方法：创建导航单元格
  factory AppCell.navigation({
    Key? key,
    required String title,
    String? description,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return AppCell(
      key: key,
      title: title,
      description: description,
      leftIcon: icon,
      showArrow: true,
      onTap: onTap,
    );
  }

  /// 工厂方法：创建卡片样式单元格
  factory AppCell.card({
    Key? key,
    required String title,
    String? description,
    IconData? icon,
    Widget? leftWidget,
    Widget? rightWidget,
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    return AppCell(
      key: key,
      title: title,
      description: description,
      leftIcon: icon,
      leftWidget: leftWidget,
      rightWidget: rightWidget,
      showArrow: showArrow,
      onTap: onTap,
      type: AppCellType.card,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? _getPadding();
    final effectiveBackgroundColor = backgroundColor ?? _getBackgroundColor();

    Widget content = Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: type == AppCellType.card ? AppRadius.borderMd : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          onLongPress: isDisabled ? null : onLongPress,
          borderRadius: type == AppCellType.card ? AppRadius.borderMd : null,
          child: Padding(
            padding: effectivePadding,
            child: Row(
              children: [
                // 左侧内容
                if (leftWidget != null || leftIcon != null) ...[
                  _buildLeftContent(),
                  SizedBox(width: AppSpacing.md),
                ],

                // 中间内容
                Expanded(child: _buildCenterContent()),

                // 右侧内容
                _buildRightContent(),
              ],
            ),
          ),
        ),
      ),
    );

    // 添加分割线
    if (showDivider) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          Padding(
            padding: EdgeInsets.only(
              left: leftWidget != null || leftIcon != null
                  ? effectivePadding.horizontal / 2 + _getLeftContentWidth() + AppSpacing.md
                  : effectivePadding.horizontal / 2,
            ),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.divider,
            ),
          ),
        ],
      );
    }

    return content;
  }

  /// 构建左侧内容
  Widget _buildLeftContent() {
    if (leftWidget != null) {
      return leftWidget!;
    }

    if (leftIcon != null) {
      final iconSize = _getIconSize();
      final containerSize = _getIconContainerSize();
      final effectiveIconColor = leftIconColor ?? AppColors.mutedForeground;
      final effectiveBackgroundColor = leftIconBackgroundColor ?? AppColors.secondary;

      return Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(containerSize / 2),
        ),
        child: Icon(
          leftIcon,
          size: iconSize,
          color: effectiveIconColor,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// 构建中间内容
  Widget _buildCenterContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标题行
        Row(
          children: [
            if (required)
              Text(
                '* ',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: _getTitleFontSize(),
                ),
              ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: _getTitleFontSize(),
                  fontWeight: FontWeight.w500,
                  color: isDisabled
                      ? AppColors.disabledForeground
                      : AppColors.foreground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        // 描述
        if (description != null) ...[
          SizedBox(height: AppSpacing.xxs),
          Text(
            description!,
            style: TextStyle(
              fontSize: _getDescriptionFontSize(),
              color: isDisabled
                  ? AppColors.disabledForeground
                  : AppColors.mutedForeground,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  /// 构建右侧内容
  Widget _buildRightContent() {
    final List<Widget> rightItems = [];

    // 徽章
    if (badgeCount != null && badgeCount! > 0) {
      rightItems.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: badgeMuted ? AppColors.mutedForeground : AppColors.error,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            badgeCount! > 99 ? '99+' : badgeCount.toString(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      );
    }

    // 右侧文本
    if (rightText != null) {
      rightItems.add(
        Text(
          rightText!,
          style: TextStyle(
            fontSize: _getDescriptionFontSize(),
            color: AppColors.mutedForeground,
          ),
        ),
      );
    }

    // 右侧自定义组件
    if (rightWidget != null) {
      rightItems.add(rightWidget!);
    }

    // 箭头
    if (showArrow) {
      rightItems.add(
        Icon(
          Icons.chevron_right,
          size: 20,
          color: AppColors.mutedForeground,
        ),
      );
    }

    if (rightItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: rightItems.map((item) {
        final index = rightItems.indexOf(item);
        if (index > 0) {
          return Padding(
            padding: EdgeInsets.only(left: AppSpacing.sm),
            child: item,
          );
        }
        return item;
      }).toList(),
    );
  }

  /// 获取内边距
  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case AppCellSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
      case AppCellSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        );
      case AppCellSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        );
    }
  }

  /// 获取背景色
  Color _getBackgroundColor() {
    switch (type) {
      case AppCellType.normal:
        return Colors.transparent;
      case AppCellType.card:
        return AppColors.surface;
      case AppCellType.group:
        return AppColors.surface;
    }
  }

  /// 获取图标尺寸
  double _getIconSize() {
    switch (size) {
      case AppCellSize.small:
        return 16;
      case AppCellSize.medium:
        return 20;
      case AppCellSize.large:
        return 24;
    }
  }

  /// 获取图标容器尺寸
  double _getIconContainerSize() {
    switch (size) {
      case AppCellSize.small:
        return 32;
      case AppCellSize.medium:
        return 40;
      case AppCellSize.large:
        return 48;
    }
  }

  /// 获取左侧内容宽度（用于分割线对齐）
  double _getLeftContentWidth() {
    if (leftWidget != null) {
      return 48; // 默认头像宽度
    }
    if (leftIcon != null) {
      return _getIconContainerSize();
    }
    return 0;
  }

  /// 获取标题字体大小
  double _getTitleFontSize() {
    switch (size) {
      case AppCellSize.small:
        return 14;
      case AppCellSize.medium:
        return 16;
      case AppCellSize.large:
        return 17;
    }
  }

  /// 获取描述字体大小
  double _getDescriptionFontSize() {
    switch (size) {
      case AppCellSize.small:
        return 12;
      case AppCellSize.medium:
        return 13;
      case AppCellSize.large:
        return 14;
    }
  }
}

/// 单元格分组组件
///
/// 用于将多个 AppCell 组合成一个分组
class AppCellGroup extends StatelessWidget {
  /// 分组标题
  final String? title;

  /// 子单元格列表
  final List<Widget> children;

  /// 是否显示分割线
  final bool showDivider;

  /// 是否使用卡片样式
  final bool isCard;

  /// 自定义内边距
  final EdgeInsetsGeometry? padding;

  const AppCellGroup({
    super.key,
    this.title,
    required this.children,
    this.showDivider = true,
    this.isCard = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 分组标题
        if (title != null)
          Padding(
            padding: padding ??
                const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
            child: Text(
              title!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedForeground,
                letterSpacing: 0.5,
              ),
            ),
          ),

        // 单元格列表
        if (isCard)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderMd,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildChildrenWithDividers(),
            ),
          )
        else
          Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildChildrenWithDividers(),
          ),
      ],
    );
  }

  /// 构建带分割线的子组件列表
  List<Widget> _buildChildrenWithDividers() {
    if (!showDivider || children.isEmpty) {
      return children;
    }

    final List<Widget> result = [];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.lg),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.divider,
            ),
          ),
        );
      }
    }
    return result;
  }
}
