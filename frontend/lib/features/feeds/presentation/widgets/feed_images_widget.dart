import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/inner_drag_lock.dart';
import 'image_preview_screen.dart';

/// Feed 图片展示组件
/// 支持单张图片全屏显示和多张图片的横向滚动浏览（瀑布流/轮播）。
class FeedImagesWidget extends StatelessWidget {
  /// 图片 URL 列表
  final List<String> imageUrls;

  /// 展示高度
  final double height;

  const FeedImagesWidget({
    super.key,
    required this.imageUrls,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    // 限制单次展示的最大图片数量（50张）
    final displayUrls = imageUrls.take(50).toList();

    // 获取屏幕宽度以在宽屏（如平板、桌面）上应用最大宽度限制
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 640 ? 600.0 : double.infinity;

    // 情况 1: 只有一张图片时，占满宽度显示
    if (displayUrls.length == 1) {
      return GestureDetector(
        onTap: () => _openImagePreview(context, displayUrls, 0),
        child: Container(
          constraints: BoxConstraints(maxHeight: height, maxWidth: maxWidth),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Hero(
              tag: displayUrls.first,
              child: CachedNetworkImage(
                imageUrl: displayUrls.first,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.muted.withValues(alpha: 0.1),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
        ),
      );
    }

    // 情况 2: 多张图片时，以横向滚动轮播形式显示
    return SizedBox(
      height: height,
      width: maxWidth,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            // 开始横向滚动，通知外层禁止翻页
            InnerDragLock.start();
          } else if (notification is ScrollEndNotification ||
              notification is ScrollUpdateNotification &&
                  notification.metrics.outOfRange) {
            // 滚动结束或超出后尝试释放锁
            InnerDragLock.end();
          }
          return false;
        },
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: displayUrls.length,
          separatorBuilder: (context, index) =>
              const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _openImagePreview(context, displayUrls, index),
              child: Container(
                width: 250, // 轮播中每张图片的固定宽度
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Hero(
                    tag: displayUrls[index],
                    child: CachedNetworkImage(
                      imageUrl: displayUrls[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.muted.withValues(alpha: 0.1),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openImagePreview(BuildContext context, List<String> urls, int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ImagePreviewScreen(imageUrls: urls, initialIndex: index),
          );
        },
      ),
    );
  }
}
