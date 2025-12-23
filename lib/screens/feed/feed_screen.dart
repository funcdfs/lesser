import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/post.dart';
import '../../widgets/post_card.dart';
import '../detail_screen.dart';

/// 帖子动态流屏幕
///
/// 作为一个通用的列表架构，根据 [feedMode] 展示不同的帖子列表。
class FeedScreen extends StatelessWidget {
  /// 流类型：例如 'trending' (推荐) 或 'following' (关注)
  final String feedMode;

  const FeedScreen({super.key, required this.feedMode});

  @override
  Widget build(BuildContext context) {
    // 使用 CustomScrollView 结合 Sliver 列表，便于将来扩展顶部刷新或吸顶效果
    return CustomScrollView(slivers: [FeedList(feedMode: feedMode)]);
  }
}

/// 实际执行列表渲染的部分 (Sliver 组件)
class FeedList extends StatelessWidget {
  final String feedMode;

  const FeedList({super.key, required this.feedMode});

  /// 跳转至帖子详情页
  void _navigateToDetail(BuildContext context, Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen(post: post)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取模拟数据
    // TODO: 根据 feedMode 从 Service 层获取真实的分页数据
    final posts = mockPosts;

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        // 重复利用模拟数据展示长列表
        final post = posts[index % posts.length];
        return PostCard(
          post: post,
          onTap: () => _navigateToDetail(context, post),
        );
      }, childCount: 10),
    );
  }
}
