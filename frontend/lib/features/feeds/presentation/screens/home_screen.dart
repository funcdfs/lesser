import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import 'feed_screen.dart';
import 'following_feed_screen.dart';

/// 首页信息流入口
///
/// 负责：
/// - 显示两个 Tab：推荐 + 关注
/// - 包含上方的日常限时状态组件 (Stories Bar)
/// - 整体的骨架 page
///
/// 使用 TDesign 深色主题设计令牌，确保与应用整体风格一致。
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
                  child: _buildTabBarContainer(),
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
    );
  }

  /// 构建带毛玻璃效果的 TabBar 容器
  Widget _buildTabBarContainer() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 48.5,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: AppColors.border,
                width: 0.5,
              ),
            ),
          ),
          child: _buildTabBar(),
        ),
      ),
    );
  }

  /// 构建 TabBar 组件
  ///
  /// 使用 TDesign 深色主题的颜色令牌：
  /// - 选中状态使用 foreground 颜色（白色）
  /// - 未选中状态使用 mutedForeground 颜色（灰色）
  /// - 指示器使用 foreground 颜色
  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.center,
      dividerColor: Colors.transparent,
      // 使用 foreground 作为选中指示器颜色，与深色主题一致
      indicatorColor: AppColors.foreground,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorWeight: 3,
      indicatorPadding: const EdgeInsets.only(top: 44),
      // 选中标签使用 foreground 颜色
      labelColor: AppColors.foreground,
      // 未选中标签使用 mutedForeground 颜色
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
    );
  }
}
