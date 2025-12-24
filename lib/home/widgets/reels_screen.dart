import 'package:flutter/material.dart';
import '../screens/feed/feed_list.dart';

/// 推荐流（Reels）屏幕组件
///
/// 这是 home 的一个子组件，专门用于展示推荐流内容。
/// 作为一个通用的列表架构，展示热门/推荐的帖子列表。
class ReelsScreen extends StatelessWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 CustomScrollView 结合 Sliver 列表，便于将来扩展顶部刷新或吸顶效果
    return CustomScrollView(
      slivers: [
        FeedList(feedType: 'trending'),
      ],
    );
  }
}

