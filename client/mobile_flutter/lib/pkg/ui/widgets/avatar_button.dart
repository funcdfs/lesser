// 头像按钮

import 'package:flutter/material.dart';
import '../effects/effects.dart';

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
    return TapScale(
      onTap: onTap,
      scale: 0.92,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFEEEEEE),
          image: imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: imageUrl == null && placeholder != null
            ? Center(
                child: Text(
                  placeholder!,
                  style: TextStyle(
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF666666),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
