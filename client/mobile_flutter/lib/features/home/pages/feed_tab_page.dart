// Feed Tab 页面 - 包含 Timeline（推荐流）和 Discovery（发现页）两个子选项卡

import 'package:flutter/material.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../timeline/pages/timeline_page.dart';
import '../../discovery/pages/discovery_page.dart';

/// Feed Tab 页面 - 顶部有两个选项卡切换
class FeedTabPage extends StatefulWidget {
  const FeedTabPage({super.key});

  @override
  State<FeedTabPage> createState() => _FeedTabPageState();
}

class _FeedTabPageState extends State<FeedTabPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              pinned: true,
              elevation: 0,
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(
                context,
              ).scaffoldBackgroundColor.withValues(alpha: 0.9),
              title: const Text(
                'Lesser',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _CustomTabBar(
                      controller: _tabController,
                      tabs: const ['推荐', '发现'],
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [TimelinePage(), DiscoveryPage()],
        ),
      ),
    );
  }
}

/// 自定义 TabBar 样式
class _CustomTabBar extends StatelessWidget {
  const _CustomTabBar({required this.controller, required this.tabs});

  final TabController controller;
  final List<String> tabs;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: colors.surfaceElevated.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: colors.divider,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: colors.textPrimary,
        unselectedLabelColor: colors.textTertiary,
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        tabs: tabs.map((label) => Tab(text: label)).toList(),
      ),
    );
  }
}
