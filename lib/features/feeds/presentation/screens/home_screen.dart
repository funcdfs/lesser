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
        top: true,
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              /// 分段导航 - 浮动且支持 Snap，向上滚动隐藏，向下滚动显示
              SliverAppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                scrolledUnderElevation: 0,
                toolbarHeight: 0, // 隐藏标题栏以仅显示 TabBar
                floating: true,
                snap: true,
                pinned: false,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48.5),
                  child: Container(
                    height: 48.5,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.border, width: 0.5),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.center,
                      dividerColor: Colors.transparent,
                      indicatorColor: AppColors.primary,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorWeight: 2,
                      indicatorPadding: const EdgeInsets.only(top: 44),
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.mutedForeground,
                      labelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.2,
                      ),
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      tabs: const [
                        Tab(text: 'For You'),
                        Tab(text: 'Following'),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: const [
              // 推荐信息流
              FeedScreen(),
              // 关注信息流
              FollowingFeedScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
