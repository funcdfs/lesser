import 'package:flutter/material.dart';
import '../widgets/feed_list.dart';
import '../widgets/stories_bar.dart';

/// 关注信息流页面
///
/// 显示用户关注的人发布的帖子
class FollowingFeedScreen extends StatefulWidget {
  final TabController tabController;
  const FollowingFeedScreen({super.key, required this.tabController});

  @override
  State<FollowingFeedScreen> createState() => _FollowingFeedScreenState();
}

class _FollowingFeedScreenState extends State<FollowingFeedScreen> {
  @override
  Widget build(BuildContext context) {
    return FeedList(
      feedType: 'following',
      header: const StoriesBar(),
      tabController: widget.tabController,
    );
  }
}
