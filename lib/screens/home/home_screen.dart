import 'package:flutter/material.dart';
import '../../config/shadcn_theme.dart';
import '../feed/feed_screen.dart';
import '../feed/stories_bar.dart';

/// 首页屏幕组件
///
/// 包含了“推荐”和“关注”两个选项卡，用于切换不同的内容流。
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
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // 禁用左右滑动切换，防止与横向图片冲突
        children: const [
          // 推荐流（不带故事栏）
          FeedScreen(feedMode: 'trending'),
          // 关注流（带故事栏）
          _FollowFeed(),
        ],
      ),
    );
  }
}

/// 内部私有：关注流页面布局
/// 它由头部的“故事栏”和底部的“动态列表”组合而成。
class _FollowFeed extends StatelessWidget {
  const _FollowFeed();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 顶部横向滚动的故事栏
        const SliverToBoxAdapter(child: StoriesBar()),
        const SliverToBoxAdapter(
          child: Divider(color: ShadcnColors.border, thickness: 1, height: 1),
        ),

        // 动态列表部分（使用 SliverList 实现）
        const FeedList(feedMode: 'following'),
      ],
    );
  }
}
