import 'package:flutter/material.dart';
import '../widgets/stories_bar.dart';
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
      appBar: AppBar(
        title: const Text('Lesser'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'For You'),
            Tab(text: 'Following'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 日常状态栏 (Stories Bar)
          const StoriesBar(),
          // Feed 列表
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 推荐信息流
                const FeedScreen(),
                // 关注信息流
                const FollowingFeedScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
