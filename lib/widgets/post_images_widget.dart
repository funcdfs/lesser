import 'package:flutter/material.dart';

/// 帖子图片展示组件
/// 支持单张图片全屏显示和多张图片的横向滚动浏览（瀑布流/轮播）。
class PostImagesWidget extends StatelessWidget {
  /// 图片 URL 列表
  final List<String> imageUrls;

  /// 展示高度
  final double height;

  const PostImagesWidget({
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
      return Container(
        constraints: BoxConstraints(maxHeight: height, maxWidth: maxWidth),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(displayUrls.first),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // 情况 2: 多张图片时，以横向滚动轮播形式显示
    return SizedBox(
      height: height,
      width: maxWidth,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: displayUrls.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Container(
            width: 250, // 轮播中每张图片的固定宽度
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(displayUrls[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
