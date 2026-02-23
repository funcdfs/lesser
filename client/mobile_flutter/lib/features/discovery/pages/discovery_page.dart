import 'package:flutter/material.dart';
import '../widgets/discovery_actor_list.dart';
import '../widgets/discovery_collection_list.dart';
import '../widgets/discovery_section_header.dart';
import '../widgets/discovery_tag_list.dart';
import '../widgets/discovery_news_list.dart';
import '../widgets/discovery_trending_section.dart';

/// Discovery 页面 - 发现内容
///
/// ⚠️ 当前为 UI 原型阶段，使用假数据展示
///
/// TODO: 实现完整的数据驱动架构
/// - [ ] 创建 models/discovery_content_model.dart
/// - [ ] 创建 handler/discovery_handler.dart
/// - [ ] 创建 data_access/discovery_data_source.dart
/// - [ ] 连接后端 TimelineService.GetHotFeed API (time_range: day/week/month/year)
class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Sticky header
          SliverAppBar(
            pinned: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(
              context,
            ).scaffoldBackgroundColor.withValues(alpha: 0.9),
            title: const Text(
              'Discovery',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),

          // Trending Now section
          const DiscoveryTrendingSection(),

          // Popular Tags
          const DiscoverySectionHeader(title: 'Popular Tags'),
          const DiscoveryTagList(),

          // Actors
          const DiscoverySectionHeader(title: 'Actors'),
          const DiscoveryActorList(),

          // Curated Playlists
          const DiscoverySectionHeader(
            title: 'Curated Playlists',
            showViewAll: true,
          ),
          const DiscoveryCollectionList(),

          // Latest News
          const DiscoverySectionHeader(title: 'Latest News', showViewAll: true),
          const DiscoveryNewsList(),

          // Bottom padding for navigation bar
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}
