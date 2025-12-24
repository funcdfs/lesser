import 'package:flutter/material.dart';
import '../widgets/feed_list.dart';

/// 推荐信息流页面
///
/// 显示根据算法推荐的帖子列表
class FeedScreen extends StatefulWidget {
  final TabController tabController;
  const FeedScreen({super.key, required this.tabController});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return FeedList(feedType: 'trending', tabController: widget.tabController);
  }
}
