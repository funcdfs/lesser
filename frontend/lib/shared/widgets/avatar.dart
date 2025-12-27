import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lesser/shared/theme/theme.dart';

/// 头像组件 - 基于 TDesign TDAvatar
/// 支持网络图片、SVG 格式头像以及在加载失败或无 URL 时显示首字母占位符。
///
/// 注意：推荐使用 [AppAvatar] 组件，该组件提供更完整的 TDesign 集成。
/// 此组件保留用于向后兼容。
class Avatar extends StatelessWidget {
  /// 头像图片的 URL
  final String? avatarUrl;

  /// 回退显示的占位字符（通常是用户姓名的首字母）
  final String fallbackInitials;

  /// 头像尺寸大小
  final double size;

  const Avatar({
    super.key,
    this.avatarUrl,
    required this.fallbackInitials,
    this.size = 40,
  });

  /// 映射尺寸到 TDAvatar 尺寸
  TDAvatarSize get _tdSize {
    if (size <= 32) return TDAvatarSize.small;
    if (size <= 48) return TDAvatarSize.medium;
    return TDAvatarSize.large;
  }

  /// 获取显示文字
  String get _displayText {
    final initials = fallbackInitials.trim();
    return initials.isNotEmpty ? initials.substring(0, 1).toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    // 处理 SVG 格式头像 - TDAvatar 不直接支持 SVG，需要特殊处理
    if (avatarUrl != null &&
        avatarUrl!.isNotEmpty &&
        (avatarUrl!.endsWith('.svg') || avatarUrl!.contains('avataaars/svg'))) {
      return _buildSvgAvatar();
    }

    // 使用 TDAvatar 组件
    return TDAvatar(
      size: _tdSize,
      type: _getAvatarType(),
      shape: TDAvatarShape.circle,
      text: _displayText,
      avatarUrl: avatarUrl,
      defaultUrl: '',
      avatarSize: size,
    );
  }

  /// 获取头像类型
  TDAvatarType _getAvatarType() {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return TDAvatarType.normal;
    }
    return TDAvatarType.customText;
  }

  /// 构建 SVG 头像（TDAvatar 不直接支持 SVG）
  Widget _buildSvgAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.secondary,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: SvgPicture.network(
        avatarUrl!,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => _buildFallback(),
      ),
    );
  }

  /// 构建占位符内容
  Widget _buildFallback() {
    return Center(
      child: Text(
        _displayText,
        style: TextStyle(
          color: AppColors.secondaryForeground,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}
