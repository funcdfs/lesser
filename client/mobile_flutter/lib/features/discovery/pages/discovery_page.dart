import 'package:flutter/material.dart';
import '../widgets/discovery_actor_list.dart';
import '../widgets/discovery_collection_list.dart';
import '../widgets/discovery_horizontal_list.dart';
import '../widgets/discovery_section_header.dart';
import '../widgets/discovery_tag_list.dart';
import '../widgets/discovery_news_list.dart';

class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('发现'),
            floating: true,
          ),
          const DiscoverySectionHeader(title: "今日热门"),
          const DiscoveryHorizontalList(count: 10, labelPrefix: "电影", baseColor: Colors.redAccent),
          
          const DiscoverySectionHeader(title: "本周热门"),
          const DiscoveryHorizontalList(count: 10, labelPrefix: "剧集", baseColor: Colors.blueAccent),
          
          const DiscoverySectionHeader(title: "热门标签"),
          const DiscoveryTagList(tags: ["科幻", "动作", "爱情", "惊悚", "历史", "喜剧"]),
          
          const DiscoverySectionHeader(title: "人气明星"),
          const DiscoveryActorList(count: 10),
          
          const DiscoverySectionHeader(title: "精选片单"),
          const DiscoveryCollectionList(),

          const DiscoverySectionHeader(title: "资讯动态"),
          const DiscoveryNewsList(),
          // Add extra padding for bottom nav
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}

