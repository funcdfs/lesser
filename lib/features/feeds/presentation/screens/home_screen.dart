import 'dart:ui';
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                toolbarHeight: 0,
                floating: true,
                snap: true,
                pinned: false,
                forceElevated: innerBoxIsScrolled,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48.5),
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        height: 48.5,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.8),
                          border: const Border(
                            bottom: BorderSide(
                              color: AppColors.border,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.center,
                          dividerColor: Colors.transparent,
                          indicatorColor: AppColors.primary,
                          indicatorSize: TabBarIndicatorSize.label,
                          indicatorWeight: 3,
                          indicatorPadding: const EdgeInsets.only(top: 44),
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.mutedForeground,
                          labelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.2,
                          ),
                          overlayColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                          tabs: const [
                            Tab(text: '推荐'),
                            Tab(text: '关注'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // 推荐信息流
            FeedScreen(),
            // 关注信息流
            FollowingFeedScreen(),
          ],
        ),
      ),
    );
  }
}
