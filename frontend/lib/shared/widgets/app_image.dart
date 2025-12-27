import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// 图片适应模式枚举
enum AppImageFit {
  /// 包含 - 保持比例，完整显示
  contain,

  /// 覆盖 - 保持比例，填满容器
  cover,

  /// 填充 - 拉伸填满
  fill,

  /// 缩小 - 仅在图片大于容器时缩小
  scaleDown,

  /// 无 - 原始尺寸
  none,
}

/// 图片形状枚举
enum AppImageShape {
  /// 矩形
  rectangle,

  /// 圆角矩形
  rounded,

  /// 圆形
  circle,
}

/// 统一图片组件 - 基于 TDesign 风格
///
/// 支持网络图片加载、placeholder、error 状态显示。
/// 应用深色主题样式。
///
/// 示例用法:
/// ```dart
/// AppImage(
///   src: 'https://example.com/image.jpg',
///   width: 200,
///   height: 150,
///   fit: AppImageFit.cover,
/// )
/// ```
class AppImage extends StatelessWidget {
  /// 图片 URL
  final String src;

  /// 图片宽度
  final double? width;

  /// 图片高度
  final double? height;

  /// 图片适应模式
  final AppImageFit fit;

  /// 图片形状
  final AppImageShape shape;

  /// 圆角半径（仅当 shape 为 rounded 时有效）
  final double borderRadius;

  /// 占位符组件
  final Widget? placeholder;

  /// 错误状态组件
  final Widget? errorWidget;

  /// 是否显示加载指示器
  final bool showLoading;

  /// 背景颜色
  final Color? backgroundColor;

  /// 点击回调
  final VoidCallback? onTap;

  /// 图片加载完成回调
  final VoidCallback? onLoad;

  /// 图片加载失败回调
  final void Function(Object error)? onError;

  const AppImage({
    super.key,
    required this.src,
    this.width,
    this.height,
    this.fit = AppImageFit.cover,
    this.shape = AppImageShape.rectangle,
    this.borderRadius = AppRadius.md,
    this.placeholder,
    this.errorWidget,
    this.showLoading = true,
    this.backgroundColor,
    this.onTap,
    this.onLoad,
    this.onError,
  });

  /// 工厂方法：创建圆形图片
  factory AppImage.circle({
    Key? key,
    required String src,
    required double size,
    Widget? placeholder,
    Widget? errorWidget,
    VoidCallback? onTap,
  }) {
    return AppImage(
      key: key,
      src: src,
      width: size,
      height: size,
      shape: AppImageShape.circle,
      placeholder: placeholder,
      errorWidget: errorWidget,
      onTap: onTap,
    );
  }

  /// 工厂方法：创建圆角图片
  factory AppImage.rounded({
    Key? key,
    required String src,
    double? width,
    double? height,
    double borderRadius = AppRadius.md,
    AppImageFit fit = AppImageFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    VoidCallback? onTap,
  }) {
    return AppImage(
      key: key,
      src: src,
      width: width,
      height: height,
      shape: AppImageShape.rounded,
      borderRadius: borderRadius,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
      onTap: onTap,
    );
  }

  /// 工厂方法：创建缩略图
  factory AppImage.thumbnail({
    Key? key,
    required String src,
    double size = 80,
    VoidCallback? onTap,
  }) {
    return AppImage(
      key: key,
      src: src,
      width: size,
      height: size,
      shape: AppImageShape.rounded,
      borderRadius: AppRadius.sm,
      fit: AppImageFit.cover,
      onTap: onTap,
    );
  }

  /// 映射适应模式到 BoxFit
  BoxFit get _boxFit {
    switch (fit) {
      case AppImageFit.contain:
        return BoxFit.contain;
      case AppImageFit.cover:
        return BoxFit.cover;
      case AppImageFit.fill:
        return BoxFit.fill;
      case AppImageFit.scaleDown:
        return BoxFit.scaleDown;
      case AppImageFit.none:
        return BoxFit.none;
    }
  }

  /// 获取边框形状
  BorderRadius? get _borderRadius {
    switch (shape) {
      case AppImageShape.rectangle:
        return null;
      case AppImageShape.rounded:
        return BorderRadius.circular(borderRadius);
      case AppImageShape.circle:
        return BorderRadius.circular(
          (width ?? height ?? 100) / 2,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = _buildImage();

    // 应用形状裁剪
    if (_borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: _borderRadius!,
        child: imageWidget,
      );
    }

    // 添加点击效果
    if (onTap != null) {
      imageWidget = GestureDetector(
        onTap: onTap,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  /// 构建图片组件
  Widget _buildImage() {
    // 使用 TDImage 组件
    return TDImage(
      imgUrl: src,
      width: width,
      height: height,
      fit: _boxFit,
      loadingWidget: showLoading ? _buildPlaceholder() : null,
      errorWidget: _buildErrorWidget(),
    );
  }

  /// 构建占位符
  Widget _buildPlaceholder() {
    if (placeholder != null) return placeholder!;

    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? AppColors.surface,
      child: Center(
        child: TDLoading(
          size: TDLoadingSize.small,
          icon: TDLoadingIcon.circle,
          iconColor: AppColors.mutedForeground,
        ),
      ),
    );
  }

  /// 构建错误状态组件
  Widget _buildErrorWidget() {
    if (errorWidget != null) return errorWidget!;

    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? AppColors.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              TDIcons.image_error,
              size: 24,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '加载失败',
              style: TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 图片画廊组件 - 用于显示多张图片
class AppImageGallery extends StatelessWidget {
  /// 图片 URL 列表
  final List<String> images;

  /// 每行显示数量
  final int crossAxisCount;

  /// 图片间距
  final double spacing;

  /// 图片圆角
  final double borderRadius;

  /// 图片点击回调
  final void Function(int index)? onImageTap;

  /// 最大显示数量
  final int? maxCount;

  /// 是否显示更多数量
  final bool showOverflowCount;

  const AppImageGallery({
    super.key,
    required this.images,
    this.crossAxisCount = 3,
    this.spacing = AppSpacing.xs,
    this.borderRadius = AppRadius.sm,
    this.onImageTap,
    this.maxCount,
    this.showOverflowCount = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayImages = maxCount != null && images.length > maxCount!
        ? images.take(maxCount!).toList()
        : images;
    final overflowCount =
        maxCount != null ? images.length - maxCount! : 0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: displayImages.length,
      itemBuilder: (context, index) {
        final isLastItem = index == displayImages.length - 1;
        final showOverflow =
            isLastItem && showOverflowCount && overflowCount > 0;

        return Stack(
          fit: StackFit.expand,
          children: [
            AppImage.rounded(
              src: displayImages[index],
              borderRadius: borderRadius,
              onTap: onImageTap != null ? () => onImageTap!(index) : null,
            ),
            if (showOverflow)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.overlay,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: Center(
                    child: Text(
                      '+$overflowCount',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
