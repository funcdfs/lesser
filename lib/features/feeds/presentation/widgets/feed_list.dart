import 'package:flutter/material.dart';
import 'feed_images_widget.dart';
import 'feeds_actions_bar.dart';

/// Feed 列表容器
///
/// 负责：
/// - 推荐流和关注流的列表展示
/// - 列表滚动、加载更多等逻辑
/// - 不直接包含单条 Feed UI（使用 FeedsCard 组件）

enum FeedListType {
  /// 推荐流
  recommendation,

  /// 关注流
  following,
}

class FeedList extends StatelessWidget {
  final FeedListType feedType;

  const FeedList({super.key, required this.feedType});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        return const FeedsCard();
      },
    );
  }
}

/// 单条 Feed UI 组件
///
/// 显示：
/// - 用户头像和名称
/// - Feed 图片
/// - Feed 内容
/// - 操作栏（赞、评论、分享等）
class FeedsCard extends StatefulWidget {
  const FeedsCard({super.key});

  @override
  State<FeedsCard> createState() => _FeedsCardState();
}

class _FeedsCardState extends State<FeedsCard> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(radius: 20, child: Text('U')),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Username',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '2 hours ago',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Feed 内容
          const FeedImagesWidget(),
          // 操作栏
          FeedsActionsBar(
            isLiked: _isLiked,
            onLikePressed: () {
              setState(() {
                _isLiked = !_isLiked;
              });
            },
          ),
        ],
      ),
    );
  }
}
