import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';
import 'feed_screen.dart';
import 'following_feed_screen.dart';

/// 首页信息流入口
///
/// 负责：
/// - 显示两个 Tab：推荐 + 关注
/// - 包含上方的日常限时状态组件 (Stories Bar)
/// - 整体的骨架 page
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: TabBarView(
          controller: _tabController,
          children: [
            // 推荐信息流
            FeedScreen(tabController: _tabController),
            // 关注信息流
            FollowingFeedScreen(tabController: _tabController),
          ],
        ),
      ),
    );
  }
}
