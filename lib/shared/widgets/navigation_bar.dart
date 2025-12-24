import 'package:flutter/material.dart';
import 'package:lesser/shared/theme/theme.dart';

/// 应用主导航栏组件
///
/// 支持两种布局模式：
/// - 移动端：底部导航栏
/// - 桌面端：侧边导航栏
class AppNavigationBar extends StatelessWidget {
  /// 当前选中的导航索引
  final int selectedIndex;

  /// 导航项点击回调
  final ValueChanged<int> onItemTapped;

  /// 是否为侧边栏模式（桌面端）
  final bool isSidebar;

  const AppNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.isSidebar = false,
  });

  /// 创建底部导航栏（移动端）
  factory AppNavigationBar.bottom({
    required int selectedIndex,
    required ValueChanged<int> onItemTapped,
  }) {
    return AppNavigationBar(
      selectedIndex: selectedIndex,
      onItemTapped: onItemTapped,
      isSidebar: false,
    );
  }

  /// 创建侧边导航栏（桌面端）
  factory AppNavigationBar.sidebar({
    required int selectedIndex,
    required ValueChanged<int> onItemTapped,
  }) {
    return AppNavigationBar(
      selectedIndex: selectedIndex,
      onItemTapped: onItemTapped,
      isSidebar: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isSidebar) {
      return _buildSidebar();
    } else {
      return _buildBottomBar();
    }
  }

  /// 构建侧边栏
  Widget _buildSidebar() {
    return Container(
      width: 88,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          _NavBarItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            isSelected: selectedIndex == 0,
            onTap: () => onItemTapped(0),
            isSidebar: true,
          ),
          _NavBarItem(
            icon: Icons.search,
            selectedIcon: Icons.search,
            isSelected: selectedIndex == 1,
            onTap: () => onItemTapped(1),
            isSidebar: true,
          ),
          // 侧边栏风格的发布按钮
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: GestureDetector(
              onTap: () => onItemTapped(2),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.foreground,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.background,
                  size: 28,
                ),
              ),
            ),
          ),
          _NavBarItem(
            icon: Icons.chat_bubble_outline,
            selectedIcon: Icons.chat_bubble,
            isSelected: selectedIndex == 3,
            onTap: () => onItemTapped(3),
            isSidebar: true,
          ),
          _NavBarItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            isSelected: selectedIndex == 4,
            onTap: () => onItemTapped(4),
            isSidebar: true,
          ),
          const Spacer(),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  /// 构建底部导航栏
  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.xl2, // 适配全面屏底部
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            isSelected: selectedIndex == 0,
            onTap: () => onItemTapped(0),
          ),
          _NavBarItem(
            icon: Icons.search,
            selectedIcon: Icons.search,
            isSelected: selectedIndex == 1,
            onTap: () => onItemTapped(1),
          ),
          // 中心加号发布按钮
          GestureDetector(
            onTap: () => onItemTapped(2),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.foreground,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.background,
                size: 24,
              ),
            ),
          ),
          _NavBarItem(
            icon: Icons.chat_bubble_outline,
            selectedIcon: Icons.chat_bubble,
            isSelected: selectedIndex == 3,
            onTap: () => onItemTapped(3),
          ),
          _NavBarItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            isSelected: selectedIndex == 4,
            onTap: () => onItemTapped(4),
          ),
        ],
      ),
    );
  }
}

/// 导航项组件
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isSidebar;

  const _NavBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
    this.isSidebar = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: isSidebar
            ? const EdgeInsets.symmetric(vertical: AppSpacing.lg)
            : const EdgeInsets.all(AppSpacing.sm),
        child: Icon(
          isSelected ? selectedIcon : icon,
          size: 28,
          color: isSelected ? AppColors.foreground : AppColors.mutedForeground,
        ),
      ),
    );
  }
}
