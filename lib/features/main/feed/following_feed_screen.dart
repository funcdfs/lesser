import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import 'stories_bar.dart';
import 'feed_list.dart';

/// 关注流屏幕组件
///
/// 这是 home 的一个子组件，专门用于展示关注流内容。
/// 包含：
/// - 顶部故事栏（StoriesBar）
/// - 动态列表（FeedList）
class FollowingFeedScreen extends StatelessWidget {
  const FollowingFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 顶部横向滚动的故事栏
        const SliverToBoxAdapter(child: StoriesBar()),
        const SliverToBoxAdapter(
          child: Divider(color: AppColors.border, thickness: 1, height: 1),
        ),

        // 动态列表部分（使用 SliverList 实现）
        const FeedList(feedType: 'following'),
      ],
    );
  }
}
