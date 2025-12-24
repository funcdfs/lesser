import 'package:flutter/material.dart';
import '../../home/screens/home_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../post/screens/post_screen.dart';
import '../../chat/screens/chat_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../theme/theme.dart';
import '../../home/widgets/navigation_bar.dart';

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
  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    Container(), // 中间按钮的占位符，因为其功能是弹窗
    const ChatScreen(),
    const ProfileScreen(),
  ];

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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
              child: const PostScreen(),
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
            backgroundColor: AppColors.background,
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧导航栏 (Sidebar) - 使用导航栏组件
                AppNavigationBar.sidebar(
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onItemTapped,
                ),

                // 主内容区域（居中显示，并限制最大宽度）
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 900),
                      decoration: BoxDecoration(
                        border: const Border.symmetric(
                          vertical: BorderSide(
                            color: AppColors.border,
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

        // 移动端布局 (带有底部导航栏) - 使用导航栏组件
        return Scaffold(
          body: IndexedStack(index: _selectedIndex, children: _screens),
          bottomNavigationBar: AppNavigationBar.bottom(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
        );
      },
    );
  }
}
