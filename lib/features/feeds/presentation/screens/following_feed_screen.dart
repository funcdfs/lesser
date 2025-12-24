import 'package:flutter/material.dart';
import '../widgets/feed_list.dart';

/// 关注信息流页面
///
/// 显示用户关注的人发布的帖子
class FollowingFeedScreen extends StatefulWidget {
  const FollowingFeedScreen({super.key});

  @override
  State<FollowingFeedScreen> createState() => _FollowingFeedScreenState();
}

class _FollowingFeedScreenState extends State<FollowingFeedScreen> {
  @override
  Widget build(BuildContext context) {
    return FeedList(feedType: FeedListType.following);
  }
}
