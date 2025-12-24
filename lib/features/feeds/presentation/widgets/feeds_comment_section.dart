import 'package:flutter/material.dart';

/// Feed 评论区域
///
/// 负责：
/// - 显示评论列表
/// - 提供评论输入框
class FeedsCommentSection extends StatelessWidget {
  const FeedsCommentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const Text('View all comments'),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(radius: 15),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
