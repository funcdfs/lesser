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
  bool _canScroll = true;

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
        body: Listener(
          // 限制横向滑动触发区域：
          // 1. 推荐页 -> 发现页：必须从屏幕右侧 25% 区域开始滑动
          // 2. 发现页 -> 推荐页：必须从屏幕左侧 25% 区域开始滑动
          onPointerDown: (event) {
            final x = event.position.dx;
            final width = MediaQuery.of(context).size.width;

            if (_tabController.index == 0) {
              // 在推荐页，只有从右侧 25% 开始滑动才能到发现页
              _canScroll = x > width * 0.75;
            } else {
              // 在发现页，只有从左侧 25% 开始滑动才能到推荐页
              _canScroll = x < width * 0.25;
            }
            setState(() {});
          },
          child: TabBarView(
            controller: _tabController,
            // 根据 _canScroll 状态动态切换滚动物理效果
            // 如果不在指定区域，使用 NeverScrollableScrollPhysics 禁用滑动切换
            physics: _canScroll
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            children: const [TimelinePage(), DiscoveryPage()],
          ),
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
