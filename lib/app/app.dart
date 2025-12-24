import 'package:flutter/material.dart';
import '../features/features.dart';
import '../shared/theme/theme.dart' as shared_theme;
import 'app_theme.dart';

class LesserApp extends StatelessWidget {
  const LesserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lesser',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.light,
      home: const MainScreen(),
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
    // 索引为 2 的是中心"发布"按钮，触发模态框
    if (index == 2) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true, // 允许模态框高度超过屏幕一半
        backgroundColor: Colors.transparent, // 使模态框背景透明
        builder: (context) {
          // 使用 FractionallySizedBox 控制模态框的高度为屏幕的 90%
          return FractionallySizedBox(
            heightFactor: 0.9,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16.0),
              ),
              child: const NewPostScreen(),
            ),
          );
        },
      );
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
            backgroundColor: shared_theme.AppColors.background,
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧导航栏 (Sidebar)
                SizedBox(
                  width: 280,
                  child: Scaffold(
                    appBar: AppBar(title: const Text('Lesser'), elevation: 0),
                    body: NavigationRail(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: _onItemTapped,
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.home),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.search),
                          label: Text('Search'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.add_circle_outline),
                          label: Text('Post'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.message),
                          label: Text('Messages'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.person),
                          label: Text('Profile'),
                        ),
                      ],
                    ),
                  ),
                ),

                // 主内容区域
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _screens,
                  ),
                ),
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
