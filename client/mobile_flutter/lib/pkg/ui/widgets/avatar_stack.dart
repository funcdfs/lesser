// 头像堆叠组件
//
// 多个头像重叠显示，常用于评论入口、群组成员展示等场景

import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'avatar_button.dart';

/// 头像堆叠组件
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.avatarUrls,
    this.size = 28,
    this.overlapRatio = 0.4,
    this.borderWidth = 2,
    this.borderColor,
  });

  /// 头像 URL 列表
  final List<String> avatarUrls;

  /// 单个头像尺寸
  final double size;

  /// 重叠比例（0.0 - 1.0），默认 40%
  final double overlapRatio;

  /// 边框宽度
  final double borderWidth;

  /// 边框颜色，默认使用 surfaceElevated
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    if (avatarUrls.isEmpty) return const SizedBox.shrink();

    final colors = AppColors.of(context);
    final effectiveBorderColor = borderColor ?? colors.surfaceElevated;
    final overlap = size * overlapRatio;
    final width = size + (avatarUrls.length - 1) * (size - overlap);

    return SizedBox(
      height: size,
      width: width,
      child: Stack(
        children: [
          // 从后往前绘制，确保第一个头像在最上层
          for (int i = avatarUrls.length - 1; i >= 0; i--)
            Positioned(
              left: i * (size - overlap),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: effectiveBorderColor,
                    width: borderWidth,
                  ),
                ),
                child: AvatarButton(
                  imageUrl: avatarUrls[i],
                  size: size - borderWidth * 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
