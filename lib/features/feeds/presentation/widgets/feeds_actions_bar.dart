import 'package:flutter/material.dart';
import 'feeds_animated_like_button.dart';

/// Feed 操作栏
///
/// 负责显示：赞、评论、分享、保存等按钮
class FeedsActionsBar extends StatelessWidget {
  final bool isLiked;
  final VoidCallback onLikePressed;

  const FeedsActionsBar({
    super.key,
    required this.isLiked,
    required this.onLikePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          FeedsAnimatedLikeButton(isLiked: isLiked, onPressed: onLikePressed),
          const SizedBox(width: 20),
          IconButton(
            icon: const Icon(Icons.message_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 20),
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
