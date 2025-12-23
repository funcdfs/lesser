import 'package:flutter/material.dart';
import '../config/shadcn_theme.dart';

class PostCardSkeleton extends StatefulWidget {
  const PostCardSkeleton({super.key});

  @override
  State<PostCardSkeleton> createState() => _PostCardSkeletonState();
}

class _PostCardSkeletonState extends State<PostCardSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
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
        // Simple opacity pulse or sliding gradient could work.
        // Let's use opacity pulse for simplicity and performance.
        return Opacity(
          opacity: 0.5 + 0.5 * _controller.value, // Pulse between 0.5 and 1.0
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
            // Avatar Skeleton
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: ShadcnColors.secondary, // Light gray
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: ShadcnSpacing.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header (Name + Handle)
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
                  // Content Lines
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
                  // Action Row
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
