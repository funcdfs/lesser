import 'package:flutter/material.dart';
import '../features/features.dart';
import '../shared/theme/theme.dart' as shared_theme;
import 'app_theme.dart';
import 'app_router.dart';
import '../features/create/presentation/widgets/create_post_floating_sheet.dart';

class LesserApp extends StatelessWidget {
  const LesserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lesser',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.light,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
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
  /// 当前选中的导航索引
  int _selectedIndex = 0;

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

  /// 处理导航项点击
  void _onItemTapped(int index) {
    // 如果点击的是添加按钮，显示悬浮框而不是导航
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 当宽度大于等于 640 时，使用桌面/平板布局
        if (constraints.maxWidth >= 640) {
          return Scaffold(
            backgroundColor: shared_theme.AppColors.background,
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
                    indicatorColor: shared_theme.AppColors.primary.withValues(
                      alpha: 0.1,
                    ),
                    selectedIconTheme: const IconThemeData(
                      color: shared_theme.AppColors.primary,
                    ),
                    unselectedIconTheme: const IconThemeData(
                      color: shared_theme.AppColors.mutedForeground,
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
                          color: shared_theme.AppColors.primary,
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

                const VerticalDivider(width: 1, thickness: 1),

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
          body: IndexedStack(index: _selectedIndex, children: _screens),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                label: 'Post',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
