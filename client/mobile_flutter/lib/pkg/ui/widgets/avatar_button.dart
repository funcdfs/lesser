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
        decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
        clipBehavior: Clip.antiAlias,
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                width: size,
                height: size,
                // 加载中显示占位符
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildPlaceholder(textColor, size);
                },
                // 加载失败显示占位符
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder(textColor, size);
                },
              )
            : _buildPlaceholder(textColor, size),
      ),
    );
  }

  /// 构建占位符（首字母或默认图标）
  Widget _buildPlaceholder(Color textColor, double size) {
    if (placeholder != null) {
      return Center(
        child: Text(
          placeholder!,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      );
    }
    // 无占位符时显示默认用户图标
    return Center(
      child: Icon(Icons.person_rounded, size: size * 0.5, color: textColor),
    );
  }
}
