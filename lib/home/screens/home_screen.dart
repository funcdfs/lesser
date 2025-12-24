import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../common/utils/inner_drag_lock.dart';
import 'feed/feed_screen.dart';
import 'feed/following_feed_screen.dart';

/// 首页屏幕组件
///
/// 职责：只负责导航栏和推荐/关注切换
/// - 顶部导航栏：包含"推荐"和"关注"两个选项卡
/// - 内容区域：根据选中的选项卡显示对应的 feed 子组件
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  /// 用于控制顶部选项卡切换
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShadcnColors.background,
      appBar: AppBar(
        backgroundColor: ShadcnColors.background,
        elevation: 0,
        // 在 AppBar 中嵌套 TabBar 作为标题
        title: TabBar(
          controller: _tabController,
          indicatorColor: ShadcnColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: ShadcnColors.foreground,
          unselectedLabelColor: ShadcnColors.mutedForeground,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          tabs: const [
            Tab(text: '推荐'),
            Tab(text: '关注'),
          ],
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: InnerDragLock.isDragging,
        builder: (context, isDragging, child) {
          return TabBarView(
            controller: _tabController,
            // 当内部横向滑动发生时，禁用 TabBarView 的左右滑动以避免冲突
            physics: isDragging ? const NeverScrollableScrollPhysics() : null,
            children: const [
              // 推荐流（独立的 feed 子组件）
              FeedScreen(feedMode: 'trending'),
              // 关注流（独立的 feed 子组件，包含故事栏）
              FollowingFeedScreen(),
            ],
          );
        },
      ),
    );
  }
}
