import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../feeds/domain/entities/feed_item.dart';

class PostTypeSelector extends StatelessWidget {
  const PostTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  final PostType selectedType;
  final void Function(PostType) onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PostTypeOption(
            type: PostType.story,
            label: 'Story',
            icon: Icons.timer_outlined,
            description: '24h',
            isSelected: selectedType == PostType.story,
            onTap: () => onTypeSelected(PostType.story),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PostTypeOption(
            type: PostType.short,
            label: 'Short',
            icon: Icons.short_text,
            description: '280 chars',
            isSelected: selectedType == PostType.short,
            onTap: () => onTypeSelected(PostType.short),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PostTypeOption(
            type: PostType.column,
            label: 'Column',
            icon: Icons.article_outlined,
            description: 'Long-form',
            isSelected: selectedType == PostType.column,
            onTap: () => onTypeSelected(PostType.column),
          ),
        ),
      ],
    );
  }
}

class _PostTypeOption extends StatelessWidget {
  const _PostTypeOption({
    required this.type,
    required this.label,
    required this.icon,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final PostType type;
  final String label;
  final IconData icon;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondaryLight,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
