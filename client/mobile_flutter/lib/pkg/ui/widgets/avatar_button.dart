// 头像按钮

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../effects/effects.dart';
import '../theme/theme.dart';

// 条件导入 - Web 平台不使用 cached_network_image
import 'package:cached_network_image/cached_network_image.dart';

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
    final bgColor = colors.surfaceElevated;
    final textColor = colors.textTertiary;

    return TapScale(
      onTap: onTap,
      scale: 0.92,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
        clipBehavior: Clip.antiAlias,
        child: imageUrl != null
            ? _buildNetworkImage(textColor)
            : _buildPlaceholder(textColor, size),
      ),
    );
  }

  /// 构建网络图片
  Widget _buildNetworkImage(Color textColor) {
    // Web 平台使用 Image.network（CachedNetworkImage 在 Web 上有问题）
    if (kIsWeb) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(textColor, size);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(textColor, size);
        },
      );
    }
    // 非 Web 平台使用 CachedNetworkImage
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      width: size,
      height: size,
      memCacheWidth: (size * 2).toInt(),
      memCacheHeight: (size * 2).toInt(),
      placeholder: (context, url) => _buildPlaceholder(textColor, size),
      errorWidget: (context, url, error) => _buildPlaceholder(textColor, size),
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
    return Center(
      child: Icon(Icons.person_rounded, size: size * 0.5, color: textColor),
    );
  }
}
