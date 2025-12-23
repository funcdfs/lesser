import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'post_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import '../config/shadcn_theme.dart';

/// 应用程序主外壳屏幕
///
/// 负责处理：
/// 1. 底部导航栏（移动端）与侧边导航栏（桌面端）的切换。
/// 2. 多页面状态管理（使用 IndexedStack 保持页面状态）。
/// 3. 响应式布局：在宽屏上显示侧边栏，窄屏上显示底部导航。
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  /// 当前选中的导航索引
  int _selectedIndex = 0;

  /// 导航对应的子屏幕列表
  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const PostScreen(), // 占位：发布面
    const ChatScreen(),
    const ProfileScreen(),
  ];

  /// 处理导航项点击
  void _onItemTapped(int index) {
    if (index == 2) {
      // 索引为 2 的是中心“发布”按钮，触发模态框
      // TODO: 实现发布帖子的模态弹出框
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('打开发布模态框')));
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 当宽度大于等于 640 时，使用桌面/平板布局
        if (constraints.maxWidth >= 640) {
          return Scaffold(
            backgroundColor: ShadcnColors.background,
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧导航栏 (Sidebar)
                Container(
                  width: 88, // 侧边栏固定宽度
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: ShadcnColors.border),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: ShadcnSpacing.xl),

                      // 导航项
                      _NavBarItem(
                        icon: Icons.home_outlined,
                        selectedIcon: Icons.home,
                        isSelected: _selectedIndex == 0,
                        onTap: () => _onItemTapped(0),
                        isSidebar: true,
                      ),
                      _NavBarItem(
                        icon: Icons.search,
                        selectedIcon: Icons.search,
                        isSelected: _selectedIndex == 1,
                        onTap: () => _onItemTapped(1),
                        isSidebar: true,
                      ),

                      // 侧边栏风格的发布按钮
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: ShadcnSpacing.lg,
                        ),
                        child: GestureDetector(
                          onTap: () => _onItemTapped(2),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: ShadcnColors.foreground,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: ShadcnColors.background,
                              size: 28,
                            ),
                          ),
                        ),
                      ),

                      _NavBarItem(
                        icon: Icons.chat_bubble_outline,
                        selectedIcon: Icons.chat_bubble,
                        isSelected: _selectedIndex == 3,
                        onTap: () => _onItemTapped(3),
                        isSidebar: true,
                      ),
                      _NavBarItem(
                        icon: Icons.person_outline,
                        selectedIcon: Icons.person,
                        isSelected: _selectedIndex == 4,
                        onTap: () => _onItemTapped(4),
                        isSidebar: true,
                      ),

                      const Spacer(),
                      const SizedBox(height: ShadcnSpacing.xl),
                    ],
                  ),
                ),

                // 主内容区域（居中显示，并限制最大宽度）
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 900),
                      decoration: BoxDecoration(
                        border: const Border.symmetric(
                          vertical: BorderSide(
                            color: ShadcnColors.border,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: _screens,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // 移动端布局 (带有底部导航栏)
        return Scaffold(
          body: IndexedStack(index: _selectedIndex, children: _screens),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: ShadcnColors.background,
              border: Border(
                top: BorderSide(color: ShadcnColors.border, width: 1.0),
              ),
            ),
            padding: const EdgeInsets.only(
              top: ShadcnSpacing.sm,
              bottom: ShadcnSpacing.xl2, // 适配全面屏底部
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  isSelected: _selectedIndex == 0,
                  onTap: () => _onItemTapped(0),
                ),
                _NavBarItem(
                  icon: Icons.search,
                  selectedIcon: Icons.search,
                  isSelected: _selectedIndex == 1,
                  onTap: () => _onItemTapped(1),
                ),
                // 中心加号发布按钮
                GestureDetector(
                  onTap: () => _onItemTapped(2),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: ShadcnColors.foreground,
                      borderRadius: BorderRadius.circular(ShadcnRadius.lg),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: ShadcnColors.background,
                      size: 24,
                    ),
                  ),
                ),
                _NavBarItem(
                  icon: Icons.chat_bubble_outline,
                  selectedIcon: Icons.chat_bubble,
                  isSelected: _selectedIndex == 3,
                  onTap: () => _onItemTapped(3),
                ),
                _NavBarItem(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  isSelected: _selectedIndex == 4,
                  onTap: () => _onItemTapped(4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 内部使用的导航项组件
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
            ? const EdgeInsets.symmetric(vertical: ShadcnSpacing.lg)
            : const EdgeInsets.all(ShadcnSpacing.sm),
        child: Icon(
          isSelected ? selectedIcon : icon,
          size: 28,
          color: isSelected
              ? ShadcnColors.foreground
              : ShadcnColors.mutedForeground,
        ),
      ),
    );
  }
}
