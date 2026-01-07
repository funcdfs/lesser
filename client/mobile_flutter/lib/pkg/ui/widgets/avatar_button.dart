// 头像按钮

import 'package:flutter/material.dart';
import '../effects/effects.dart';
import '../theme/theme.dart';

class AvatarButton extends StatelessWidget {
  const AvatarButton({
    super.key,
    this.imageUrl,
    this.size = 40,
    this.onTap,
    this.placeholder,
  });

  final String? imageUrl;
  final double size;
  final VoidCallback? onTap;
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    // 头像背景使用 surfaceElevated，文字使用 textTertiary
    final bgColor = colors.surfaceElevated;
    final textColor = colors.textTertiary;

    return TapScale(
      onTap: onTap,
      scale: 0.92,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          image: imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: imageUrl == null && placeholder != null
            ? Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  child: Text(placeholder!),
                ),
              )
            : null,
      ),
    );
  }
}
