import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../theme/colors.dart';

/// 头像尺寸枚举
enum AppAvatarSize {
  /// 小尺寸 - 32px
  small,

  /// 中等尺寸 - 48px（默认）
  medium,

  /// 大尺寸 - 64px
  large,

  /// 超大尺寸 - 80px
  extraLarge,
}

/// 头像形状枚举
enum AppAvatarShape {
  /// 圆形
  circle,

  /// 圆角矩形
  square,
}

/// 统一头像组件 - 基于 TDesign 风格
///
/// 支持图片头像、文字头像、SVG 头像，以及加载失败时的回退显示。
/// 应用深色主题样式。
///
/// 示例用法:
/// ```dart
/// AppAvatar(
///   imageUrl: 'https://example.com/avatar.jpg',
///   fallbackText: 'JD',
///   size: AppAvatarSize.medium,
/// )
/// ```
class AppAvatar extends StatelessWidget {
  /// 头像图片 URL
  final String? imageUrl;

  /// 回退显示的文字（通常是用户姓名的首字母）
  final String? fallbackText;

  /// 头像尺寸
  final AppAvatarSize size;

  /// 头像形状
  final AppAvatarShape shape;

  /// 自定义尺寸（优先于 size 枚举）
  final double? customSize;

  /// 边框宽度
  final double borderWidth;

  /// 边框颜色
  final Color? borderColor;

  /// 背景颜色（用于文字头像）
  final Color? backgroundColor;

  /// 文字颜色
  final Color? textColor;

  /// 点击回调
  final VoidCallback? onTap;

  /// 自定义子组件（优先级最高）
  final Widget? child;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.fallbackText,
    this.size = AppAvatarSize.medium,
    this.shape = AppAvatarShape.circle,
    this.customSize,
    this.borderWidth = 0,
    this.borderColor,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.child,
  });

  /// 工厂方法：创建小尺寸头像
  factory AppAvatar.small({
    Key? key,
    String? imageUrl,
    String? fallbackText,
    AppAvatarShape shape = AppAvatarShape.circle,
    VoidCallback? onTap,
  }) {
    return AppAvatar(
      key: key,
      imageUrl: imageUrl,
      fallbackText: fallbackText,
      size: AppAvatarSize.small,
      shape: shape,
      onTap: onTap,
    );
  }

  /// 工厂方法：创建中等尺寸头像
  factory AppAvatar.medium({
    Key? key,
    String? imageUrl,
    String? fallbackText,
    AppAvatarShape shape = AppAvatarShape.circle,
    VoidCallback? onTap,
  }) {
    return AppAvatar(
      key: key,
      imageUrl: imageUrl,
      fallbackText: fallbackText,
      size: AppAvatarSize.medium,
      shape: shape,
      onTap: onTap,
    );
  }

  /// 工厂方法：创建大尺寸头像
  factory AppAvatar.large({
    Key? key,
    String? imageUrl,
    String? fallbackText,
    AppAvatarShape shape = AppAvatarShape.circle,
    VoidCallback? onTap,
  }) {
    return AppAvatar(
      key: key,
      imageUrl: imageUrl,
      fallbackText: fallbackText,
      size: AppAvatarSize.large,
      shape: shape,
      onTap: onTap,
    );
  }

  /// 工厂方法：创建带边框的头像
  factory AppAvatar.bordered({
    Key? key,
    String? imageUrl,
    String? fallbackText,
    AppAvatarSize size = AppAvatarSize.medium,
    AppAvatarShape shape = AppAvatarShape.circle,
    double borderWidth = 2,
    Color? borderColor,
    VoidCallback? onTap,
  }) {
    return AppAvatar(
      key: key,
      imageUrl: imageUrl,
      fallbackText: fallbackText,
      size: size,
      shape: shape,
      borderWidth: borderWidth,
      borderColor: borderColor ?? AppColors.border,
      onTap: onTap,
    );
  }

  /// 获取头像尺寸（像素值）
  double get _avatarSize {
    if (customSize != null) return customSize!;
    switch (size) {
      case AppAvatarSize.small:
        return 32;
      case AppAvatarSize.medium:
        return 48;
      case AppAvatarSize.large:
        return 64;
      case AppAvatarSize.extraLarge:
        return 80;
    }
  }

  /// 获取圆角半径
  double get _borderRadius {
    if (shape == AppAvatarShape.circle) {
      return _avatarSize / 2;
    }
    // 方形头像使用较小的圆角
    return _avatarSize * 0.15;
  }

  /// 映射到 TDesign 头像类型
  TDAvatarType get _tdAvatarType {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return TDAvatarType.normal;
    }
    if (fallbackText != null && fallbackText!.isNotEmpty) {
      return TDAvatarType.customText;
    }
    return TDAvatarType.icon;
  }

  /// 映射到 TDesign 头像尺寸
  TDAvatarSize get _tdAvatarSize {
    switch (size) {
      case AppAvatarSize.small:
        return TDAvatarSize.small;
      case AppAvatarSize.medium:
        return TDAvatarSize.medium;
      case AppAvatarSize.large:
        return TDAvatarSize.large;
      case AppAvatarSize.extraLarge:
        return TDAvatarSize.large;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget avatarWidget;

    // 如果有自定义子组件，直接使用
    if (child != null) {
      avatarWidget = _buildContainer(child: child!);
    } else {
      avatarWidget = _buildAvatarContent();
    }

    // 添加点击效果
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }

  /// 构建头像内容
  Widget _buildAvatarContent() {
    // 使用 TDAvatar 组件
    return TDAvatar(
      size: _tdAvatarSize,
      type: _tdAvatarType,
      shape: shape == AppAvatarShape.circle
          ? TDAvatarShape.circle
          : TDAvatarShape.square,
      text: _getDisplayText(),
      avatarUrl: imageUrl,
      defaultUrl: '',
      avatarSize: customSize ?? _avatarSize,
      onTap: onTap,
    );
  }

  /// 构建容器（用于自定义子组件）
  Widget _buildContainer({required Widget child}) {
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.secondary,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? AppColors.border,
                width: borderWidth,
              )
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  /// 获取显示文字
  String _getDisplayText() {
    if (fallbackText == null || fallbackText!.isEmpty) {
      return '?';
    }
    // 取首字母并大写
    return fallbackText!.trim().substring(0, 1).toUpperCase();
  }
}

/// 头像组 - 用于显示多个头像的堆叠效果
class AppAvatarGroup extends StatelessWidget {
  /// 头像列表
  final List<AppAvatar> avatars;

  /// 最大显示数量
  final int maxCount;

  /// 头像尺寸
  final AppAvatarSize size;

  /// 重叠偏移量
  final double overlap;

  /// 超出数量时的显示样式
  final bool showOverflowCount;

  const AppAvatarGroup({
    super.key,
    required this.avatars,
    this.maxCount = 5,
    this.size = AppAvatarSize.small,
    this.overlap = 8,
    this.showOverflowCount = true,
  });

  double get _avatarSize {
    switch (size) {
      case AppAvatarSize.small:
        return 32;
      case AppAvatarSize.medium:
        return 48;
      case AppAvatarSize.large:
        return 64;
      case AppAvatarSize.extraLarge:
        return 80;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayCount = avatars.length > maxCount ? maxCount : avatars.length;
    final overflowCount = avatars.length - maxCount;

    return SizedBox(
      height: _avatarSize,
      child: Stack(
        children: [
          for (int i = 0; i < displayCount; i++)
            Positioned(
              left: i * (_avatarSize - overlap),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.background,
                    width: 2,
                  ),
                ),
                child: AppAvatar(
                  imageUrl: avatars[i].imageUrl,
                  fallbackText: avatars[i].fallbackText,
                  size: size,
                  customSize: _avatarSize,
                ),
              ),
            ),
          if (showOverflowCount && overflowCount > 0)
            Positioned(
              left: displayCount * (_avatarSize - overlap),
              child: Container(
                width: _avatarSize,
                height: _avatarSize,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.background,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$overflowCount',
                    style: TextStyle(
                      color: AppColors.secondaryForeground,
                      fontSize: _avatarSize * 0.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
