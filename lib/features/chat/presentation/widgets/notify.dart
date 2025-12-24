import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';

class NotifyWidget extends StatelessWidget {
  const NotifyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg, horizontal: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNotifyItem(context, Icons.favorite_border, '收到的喜欢'),
          _buildNotifyItem(context, Icons.chat_bubble_outline, '评论和回复'),
          _buildNotifyItem(context, Icons.bookmark_border, '收藏和@'),
          _buildNotifyItem(context, Icons.person_add_alt_1_outlined, '新增粉丝'),
        ],
      ),
    );
  }

  Widget _buildNotifyItem(BuildContext context, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.foreground, size: 28),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: AppColors.mutedForeground, fontSize: 13),
        ),
      ],
    );
  }
}
