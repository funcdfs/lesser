import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// 底部导航栏项配置
class AppBottomNavBarItem {
  /// 未选中时的图标
  final IconData icon;

  /// 选中时的图标
  final IconData? selectedIcon;

  /// 标签文字
  final String? label;

  /// 徽章数量（0 表示不显示，-1 表示显示红点）
  final int badge;

  const AppBottomNavBarItem({
    required this.icon,
    this.selectedIcon,
    this.label,
    this.badge = 0,
  });
}

/// 统一底部导航栏组件 - 基于 TDesign 风格
///
/// 提供一致的底部导航栏样式和行为，支持图标、标签、徽章。
/// 应用深色主题样式。
///
/// 示例用法:
/// ```dart
/// AppBottomNavBar(
///   currentIndex: _selectedIndex,
///   onTap: (index) => setState(() => _selectedIndex = index),
///   items: [
///     AppBottomNavBarItem(
///       icon: Icons.home_outlined,
///       selectedIcon: Icons.home,
///       label: '首页',
///     ),
///     AppBottomNavBarItem(
///       icon: Icons.search,
///       label: '搜索',
///     ),
///   ],
/// )
/// ```
class AppBottomNavBar extends StatelessWidget {
  /// 当前选中的索引
  final int currentIndex;

  /// 导航项点击回调
  final ValueChanged<int> onTap;

  /// 导航项列表
  final List<AppBottomNavBarItem> items;

  /// 背景色
  final Color? backgroundColor;

  /// 选中时的颜色
  final Color? selectedColor;

  /// 未选中时的颜色
  final Color? unselectedColor;

  /// 是否显示标签
  final bool showLabels;

  /// 是否显示顶部边框
  final bool showBorder;

  /// 中心按钮（可选，用于特殊的中心操作按钮）
  final Widget? centerButton;

  /// 中心按钮点击回调
  final VoidCallback? onCenterTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.showLabels = true,
    this.showBorder = true,
    this.centerButton,
    this.onCenterTap,
  });

  /// 工厂方法：创建带中心按钮的导航栏
  factory AppBottomNavBar.withCenterButton({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
    required List<AppBottomNavBarItem> items,
    required VoidCallback onCenterTap,
    Widget? centerButton,
    Color? backgroundColor,
    bool showLabels = true,
  }) {
    return AppBottomNavBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
      backgroundColor: backgroundColor,
      centerButton: centerButton,
      onCenterTap: onCenterTap,
      showLabels: showLabels,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.background;
    final effectiveSelectedColor = selectedColor ?? AppColors.foreground;
    final effectiveUnselectedColor =
        unselectedColor ?? AppColors.mutedForeground;

    // 如果有中心按钮，使用自定义布局
    if (centerButton != null || onCenterTap != null) {
      return _buildCustomBottomBar(
        context,
        effectiveBackgroundColor,
        effectiveSelectedColor,
        effectiveUnselectedColor,
      );
    }

    // 标准底部导航栏布局
    return _buildStandardBottomBar(
      context,
      effectiveBackgroundColor,
      effectiveSelectedColor,
      effectiveUnselectedColor,
    );
  }

  /// 构建标准底部导航栏
  Widget _buildStandardBottomBar(
    BuildContext context,
    Color backgroundColor,
    Color selectedColor,
    Color unselectedColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: showBorder
            ? Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 0.5,
                ),
              )
            : null,
      ),
      padding: EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          return _buildNavItem(
            entry.value,
            entry.key,
            selectedColor,
            unselectedColor,
          );
        }).toList(),
      ),
    );
  }

  /// 构建带中心按钮的自定义底部导航栏
  Widget _buildCustomBottomBar(
    BuildContext context,
    Color backgroundColor,
    Color selectedColor,
    Color unselectedColor,
  ) {
    // 将 items 分成左右两部分
    final leftItems = items.take((items.length / 2).floor()).toList();
    final rightItems = items.skip((items.length / 2).ceil()).toList();
    final leftStartIndex = 0;
    final rightStartIndex = (items.length / 2).ceil();

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: showBorder
            ? Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 0.5,
                ),
              )
            : null,
      ),
      padding: EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 左侧导航项
          ...leftItems.asMap().entries.map((entry) {
            final index = leftStartIndex + entry.key;
            return _buildNavItem(
              entry.value,
              index,
              selectedColor,
              unselectedColor,
            );
          }),
          // 中心按钮
          _buildCenterButton(),
          // 右侧导航项
          ...rightItems.asMap().entries.map((entry) {
            final index = rightStartIndex + entry.key;
            return _buildNavItem(
              entry.value,
              index,
              selectedColor,
              unselectedColor,
            );
          }),
        ],
      ),
    );
  }

  /// 构建单个导航项
  Widget _buildNavItem(
    AppBottomNavBarItem item,
    int index,
    Color selectedColor,
    Color unselectedColor,
  ) {
    final isSelected = index == currentIndex;
    final color = isSelected ? selectedColor : unselectedColor;
    final icon = isSelected ? (item.selectedIcon ?? item.icon) : item.icon;

    Widget iconWidget = Icon(
      icon,
      size: 26,
      color: color,
    );

    // 添加徽章
    if (item.badge != 0) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(
            right: -6,
            top: -4,
            child: item.badge == -1
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 14,
                    ),
                    child: Text(
                      item.badge > 99 ? '99+' : item.badge.toString(),
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

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            if (showLabels && item.label != null) ...[
              const SizedBox(height: 2),
              Text(
                item.label!,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建中心按钮
  Widget _buildCenterButton() {
    if (centerButton != null) {
      return GestureDetector(
        onTap: onCenterTap,
        child: centerButton,
      );
    }

    // 默认中心按钮样式
    return GestureDetector(
      onTap: onCenterTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.foreground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Icon(
          Icons.add,
          color: AppColors.background,
          size: 24,
        ),
      ),
    );
  }
}
