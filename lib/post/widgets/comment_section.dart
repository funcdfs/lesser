import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// 评论区组件
///
/// 用于在帖子详情页中显示评论列表。
/// 目前使用模拟数据，后续可接入真实的评论数据模型。
class CommentSection extends StatelessWidget {
  /// 评论数量（可选，用于显示评论总数）
  final int? commentCount;

  const CommentSection({
    super.key,
    this.commentCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: ShadcnColors.border, thickness: 8, height: 8),

        // 评论标题
        Container(
          padding: const EdgeInsets.all(ShadcnSpacing.lg),
          alignment: Alignment.centerLeft,
          child: Text(
            '评论${commentCount != null ? ' ($commentCount)' : ''}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ShadcnColors.foreground,
            ),
          ),
        ),

        // 评论列表
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 3, // 模拟3条评论
          separatorBuilder: (context, index) =>
              const Divider(color: ShadcnColors.border, height: 1),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ShadcnSpacing.lg,
                vertical: ShadcnSpacing.lg,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: ShadcnColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'U${index + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: ShadcnColors.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(width: ShadcnSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '用户 ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: ShadcnColors.foreground,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '2h',
                              style: TextStyle(
                                color: ShadcnColors.mutedForeground,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '这是一个评论占位符。真正的评论功能将在稍后实现。',
                          style: TextStyle(color: ShadcnColors.foreground),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // 底部间距
        const SizedBox(height: 40),
      ],
    );
  }
}

