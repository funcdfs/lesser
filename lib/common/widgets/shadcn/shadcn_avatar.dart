import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/theme.dart';

/// Shadcn 风格的头像组件
/// 支持网络图片、SVG 格式头像以及在加载失败或无 URL 时显示首字母占位符。
class ShadcnAvatar extends StatelessWidget {
  /// 头像图片的 URL
  final String? avatarUrl;

  /// 回退显示的占位字符（通常是用户姓名的首字母）
  final String fallbackInitials;

  /// 头像尺寸大小
  final double size;

  const ShadcnAvatar({
    super.key,
    this.avatarUrl,
    required this.fallbackInitials,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.secondary,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias, // 对于 SVG 内容很重要
      child: _buildContent(),
    );
  }

  /// 根据 avatarUrl 类型构建相应内容
  Widget _buildContent() {
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return _buildFallback();
    }

    // 处理 SVG 格式头像
    if (avatarUrl!.endsWith('.svg') || avatarUrl!.contains('avataaars/svg')) {
      return SvgPicture.network(
        avatarUrl!,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => _buildFallback(),
      );
    }

    // 处理常规图片格式
    return Image.network(
      avatarUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
    );
  }

  /// 构建占位符内容
  Widget _buildFallback() {
    return Center(
      child: Text(
        fallbackInitials.substring(0, 1).toUpperCase(),
        style: TextStyle(
          color: AppColors.secondaryForeground,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}
