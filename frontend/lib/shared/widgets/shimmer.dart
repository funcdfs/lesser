import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// 骨架屏闪烁动画装饰器 - 基于 TDesign 风格
///
/// 职责：为背景块添加平滑的扫光效果。
/// 保持与原有 API 兼容，同时使用 TDesign 的动画风格。
///
/// 示例用法:
/// ```dart
/// ShimmerLoading(
///   child: Container(
///     width: 100,
///     height: 100,
///     color: AppColors.secondary,
///   ),
/// )
/// ```
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({super.key, required this.child, this.isLoading = true});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              colors: [
                AppColors.gray800,
                AppColors.gray700,
                AppColors.gray800,
              ],
              stops: const [0.1, 0.3, 0.4],
              transform: _SlidingGradientTransform(
                offset: _shimmerController.value,
              ),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.offset});

  final double offset;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * offset, 0.0, 0.0);
  }
}

/// 骨架屏类型枚举
enum AppSkeletonType {
  /// 文本行
  text,

  /// 头像（圆形）
  avatar,

  /// 矩形区域
  rect,

  /// 图片
  image,
}

/// 统一骨架屏组件 - 基于 TDesign TDSkeleton
///
/// 提供一致的骨架屏加载效果，支持多种类型。
/// 应用深色主题样式。
///
/// 示例用法:
/// ```dart
/// // 文本骨架
/// AppSkeleton.text(width: 200)
///
/// // 头像骨架
/// AppSkeleton.avatar(size: 48)
///
/// // 矩形骨架
/// AppSkeleton.rect(width: 100, height: 100)
/// ```
class AppSkeleton extends StatelessWidget {
  /// 骨架屏类型
  final AppSkeletonType type;

  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  /// 圆角
  final double? borderRadius;

  /// 是否显示动画
  final bool animation;

  const AppSkeleton({
    super.key,
    this.type = AppSkeletonType.rect,
    this.width,
    this.height,
    this.borderRadius,
    this.animation = true,
  });

  /// 工厂方法：创建文本骨架
  factory AppSkeleton.text({
    Key? key,
    double? width,
    double height = 14,
    bool animation = true,
  }) {
    return AppSkeleton(
      key: key,
      type: AppSkeletonType.text,
      width: width,
      height: height,
      borderRadius: AppRadius.sm,
      animation: animation,
    );
  }

  /// 工厂方法：创建头像骨架
  factory AppSkeleton.avatar({
    Key? key,
    double size = 40,
    bool animation = true,
  }) {
    return AppSkeleton(
      key: key,
      type: AppSkeletonType.avatar,
      width: size,
      height: size,
      animation: animation,
    );
  }

  /// 工厂方法：创建矩形骨架
  factory AppSkeleton.rect({
    Key? key,
    double? width,
    double? height,
    double? borderRadius,
    bool animation = true,
  }) {
    return AppSkeleton(
      key: key,
      type: AppSkeletonType.rect,
      width: width,
      height: height,
      borderRadius: borderRadius ?? AppRadius.md,
      animation: animation,
    );
  }

  /// 工厂方法：创建图片骨架
  factory AppSkeleton.image({
    Key? key,
    double? width,
    double height = 200,
    double? borderRadius,
    bool animation = true,
  }) {
    return AppSkeleton(
      key: key,
      type: AppSkeletonType.image,
      width: width,
      height: height,
      borderRadius: borderRadius ?? AppRadius.lg,
      animation: animation,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? double.infinity;
    final effectiveHeight = height ?? 14;

    Widget skeleton;

    switch (type) {
      case AppSkeletonType.avatar:
        skeleton = Container(
          width: effectiveWidth,
          height: effectiveHeight,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.secondary,
          ),
        );
        break;
      case AppSkeletonType.text:
      case AppSkeletonType.rect:
      case AppSkeletonType.image:
        skeleton = Container(
          width: effectiveWidth,
          height: effectiveHeight,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.sm),
          ),
        );
        break;
    }

    if (animation) {
      return ShimmerLoading(child: skeleton);
    }

    return skeleton;
  }
}

/// 骨架屏列表组件
///
/// 快速创建多行骨架屏
///
/// 示例用法:
/// ```dart
/// AppSkeletonList(
///   itemCount: 3,
///   itemBuilder: (context, index) => AppSkeleton.text(),
/// )
/// ```
class AppSkeletonList extends StatelessWidget {
  /// 骨架项数量
  final int itemCount;

  /// 骨架项构建器
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// 项之间的间距
  final double spacing;

  const AppSkeletonList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.spacing = AppSpacing.sm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index < itemCount - 1 ? spacing : 0),
          child: itemBuilder(context, index),
        ),
      ),
    );
  }
}
