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
    return const CustomScrollView(
      slivers: [
        // Trending Now section
        DiscoveryTrendingSection(),

        // Popular Tags
        DiscoverySectionHeader(title: '热门标签'),
        DiscoveryTagList(),

        // Actors
        DiscoverySectionHeader(title: '演员'),
        DiscoveryActorList(),

        // Curated Playlists
        DiscoverySectionHeader(title: '精选合集', showViewAll: true),
        DiscoveryCollectionList(),

        // Latest News
        DiscoverySectionHeader(title: '最新资讯', showViewAll: true),
        DiscoveryNewsList(),

        // Bottom padding for navigation bar
        SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}
