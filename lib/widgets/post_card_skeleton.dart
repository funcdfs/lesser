import 'package:flutter/material.dart';
import '../config/shadcn_theme.dart';

/// 帖子卡片的骨架屏组件
/// 用于在内容加载时展示占位符，减少视觉抖动。
class PostCardSkeleton extends StatefulWidget {
  const PostCardSkeleton({super.key});

  @override
  State<PostCardSkeleton> createState() => _PostCardSkeletonState();
}

class _PostCardSkeletonState extends State<PostCardSkeleton>
    with SingleTickerProviderStateMixin {
  /// 动画控制器，用于实现透明度呼吸效果
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // 使用透明度脉冲动画展示加载感
        return Opacity(
          opacity: 0.5 + 0.5 * _controller.value, // 透明度在 0.5 到 1.0 之间循环
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ShadcnSpacing.lg,
          vertical: ShadcnSpacing.md,
        ),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: ShadcnColors.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像骨架
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: ShadcnColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: ShadcnSpacing.md),
            // 内容骨架
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 头部骨架 (用户名 + ID 句柄)
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 14,
                        decoration: BoxDecoration(
                          color: ShadcnColors.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 60,
                        height: 12,
                        decoration: BoxDecoration(
                          color: ShadcnColors.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 正文内容行骨架
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: ShadcnColors.secondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: ShadcnColors.secondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 200,
                    height: 14,
                    decoration: BoxDecoration(
                      color: ShadcnColors.secondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 操作栏骨架
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionSkeleton(),
                      _buildActionSkeleton(),
                      _buildActionSkeleton(),
                      _buildActionSkeleton(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建单个操作按钮的骨架
  Widget _buildActionSkeleton() {
    return Container(
      width: 40,
      height: 20,
      decoration: BoxDecoration(
        color: ShadcnColors.secondary,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
