import 'package:flutter/material.dart';
import 'feed_list.dart';

/// 推荐流屏幕组件
///
/// 这是 home 的一个子组件，专门用于展示推荐流内容。
/// 作为一个通用的列表架构，根据 [feedMode] 展示不同的帖子列表。
class FeedScreen extends StatelessWidget {
  /// 流类型：例如 'trending' (推荐) 或 'following' (关注)
  final String feedMode;

  const FeedScreen({super.key, required this.feedMode});

  @override
  Widget build(BuildContext context) {
    // 使用 CustomScrollView 结合 Sliver 列表，便于将来扩展顶部刷新或吸顶效果
    return CustomScrollView(
      slivers: [
        FeedList(feedType: feedMode),
      ],
    );
  }
}
