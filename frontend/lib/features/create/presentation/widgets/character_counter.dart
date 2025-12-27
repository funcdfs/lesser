import 'package:flutter/material.dart';
import 'package:lesser/shared/theme/theme.dart';

/// A widget that displays character count with a circular progress indicator
class CharacterCounter extends StatelessWidget {
  final int currentLength;
  final int maxLength;
  final double size;

  const CharacterCounter({
    super.key,
    required this.currentLength,
    required this.maxLength,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = currentLength / maxLength;
    final isOverLimit = currentLength > maxLength;
    final isNearLimit = progress > 0.9;

    Color progressColor;
    if (isOverLimit) {
      progressColor = theme.colorScheme.error;
    } else if (isNearLimit) {
      progressColor = AppColors.warning;
    } else {
      progressColor = theme.colorScheme.primary;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress > 1 ? 1 : progress,
            strokeWidth: 2,
            backgroundColor: AppColors.border,
            color: progressColor,
          ),
          Text(
            currentLength.toString(),
            style: TextStyle(
              fontSize: size * 0.4,
              fontWeight: FontWeight.w500,
              color: isOverLimit ? theme.colorScheme.error : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple text-based character counter
class TextCharacterCounter extends StatelessWidget {
  final int currentLength;
  final int maxLength;

  const TextCharacterCounter({
    super.key,
    required this.currentLength,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverLimit = currentLength > maxLength;
    final remaining = maxLength - currentLength;

    return Text(
      '$currentLength / $maxLength',
      style: TextStyle(
        fontSize: 12,
        color: isOverLimit 
            ? theme.colorScheme.error 
            : (remaining < 50 ? AppColors.warning : AppColors.mutedForeground),
      ),
    );
  }
}
