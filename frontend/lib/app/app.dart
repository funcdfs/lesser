import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../features/features.dart';
import '../features/settings/presentation/providers/theme_provider.dart';
import '../shared/theme/colors.dart';
import '../shared/widgets/app_bottom_nav_bar.dart';
import 'app_theme.dart';
import 'app_router.dart';
import '../features/create/presentation/widgets/create_post_floating_sheet.dart';

class LesserApp extends ConsumerWidget {
  const LesserApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return TDTheme(
      data: isDark ? AppTheme.tdDarkTheme : AppTheme.tdLightTheme,
      child: MaterialApp(
        title: 'Lesser',
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: themeMode,
        initialRoute: '/',
        onGenerateRoute: AppRouter.routeGenerator,
        navigatorKey: AppRouter.navigatorKey,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// 应用程序主框架屏幕
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
  /// 当前选中的导航索引（用于 IndexedStack）
  int _selectedIndex = 0;

  /// 底部导航栏当前选中的索引（不包含中心按钮）
  int _bottomNavIndex = 0;

  /// 导航对应的子屏幕列表
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const SearchScreen(),
      Container(), // 中间按钮的占位符，因为其功能是弹窗
      const ChatScreen(),
      const ProfileScreen(),
    ];
  }

  /// 将底部导航栏索引映射到屏幕索引
  int _mapBottomNavToScreen(int bottomNavIndex) {
    // 底部导航栏: [Home(0), Search(1), Chat(2), Profile(3)]
    // 屏幕索引:   [Home(0), Search(1), Create(2), Chat(3), Profile(4)]
    if (bottomNavIndex >= 2) {
      return bottomNavIndex + 1; // Chat(2->3), Profile(3->4)
    }
    return bottomNavIndex; // Home(0->0), Search(1->1)
  }

  /// 将屏幕索引映射到底部导航栏索引
  int _mapScreenToBottomNav(int screenIndex) {
    if (screenIndex >= 3) {
      return screenIndex - 1; // Chat(3->2), Profile(4->3)
    }
    return screenIndex; // Home(0->0), Search(1->1)
  }

  /// 处理导航项点击
  void _onItemTapped(int index) {
    // 如果点击的是添加按钮（中心按钮），显示悬浮框而不是导航
    if (index == 2) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) =>
            const SizedBox(height: 600, child: CreatePostFloatingSheet()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
        _bottomNavIndex = _mapScreenToBottomNav(index);
      });
    }
  }

  /// 处理底部导航栏点击（移动端）
  void _onBottomNavTapped(int bottomNavIndex) {
    final screenIndex = _mapBottomNavToScreen(bottomNavIndex);
    setState(() {
      _selectedIndex = screenIndex;
      _bottomNavIndex = bottomNavIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 当宽度大于等于 640 时，使用桌面/平板布局
        if (constraints.maxWidth >= 640) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧导航栏 (Sidebar) - 紧贴内容区域
                SizedBox(
                  height: double.infinity,
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 1100,
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _onItemTapped,
                    backgroundColor: Colors.transparent,
                    indicatorColor: AppColors.surfaceVariant,
                    selectedIconTheme: IconThemeData(
                      color: AppColors.foreground,
                    ),
                    unselectedIconTheme: IconThemeData(
                      color: AppColors.mutedForeground,
                    ),
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 16,
                      ),
                      child: Text(
                        'Lesser',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.foreground,
                        ),
                      ),
                    ),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.search_outlined),
                        selectedIcon: Icon(Icons.search),
                        label: Text('Search'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.add_circle_outline),
                        label: Text('Post'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.message_outlined),
                        selectedIcon: Icon(Icons.message),
                        label: Text('Messages'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person_outline),
                        selectedIcon: Icon(Icons.person),
                        label: Text('Profile'),
                      ),
                    ],
                  ),
                ),

                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.divider,
                ),

                // 中间/主要内容区域 - 使用 Expanded 包裹以解决垂直溢出问题并限制最大宽度
                const SizedBox(width: 40),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: _screens,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          );
        }

        // 移动端布局 (带有底部导航栏)
        return Scaffold(
          backgroundColor: AppColors.background,
          body: IndexedStack(index: _selectedIndex, children: _screens),
          bottomNavigationBar: AppBottomNavBar.withCenterButton(
            currentIndex: _bottomNavIndex,
            onTap: _onBottomNavTapped,
            onCenterTap: () => _onItemTapped(2),
            showLabels: false,
            items: const [
              AppBottomNavBarItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
              ),
              AppBottomNavBarItem(
                icon: Icons.search_outlined,
                selectedIcon: Icons.search,
              ),
              // 中心按钮后的项目
              AppBottomNavBarItem(
                icon: Icons.chat_bubble_outline,
                selectedIcon: Icons.chat_bubble,
              ),
              AppBottomNavBarItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
              ),
            ],
          ),
        );
      },
    );
  }
}
