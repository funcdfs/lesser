import 'package:flutter/material.dart';
import '../../../../pkg/ui/theme/theme.dart';

/// 影视卡片组件 - 匹配 HTML 设计
class DiscoveryMediaCard extends StatelessWidget {
  const DiscoveryMediaCard({
    super.key,
    required this.title,
    required this.rating,
    this.posterUrl = 'https://picsum.photos/300/450',
    this.isBookmarked = false,
    this.onTapBookmark,
    this.onTapPlay,
    this.onTapAdd,
  });

  final String title;
  final double rating;
  final String posterUrl;
  final bool isBookmarked;
  final VoidCallback? onTapBookmark;
  final VoidCallback? onTapPlay;
  final VoidCallback? onTapAdd;

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.of(context).accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 封面区域
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // 封面图片
                Positioned.fill(
                  child: Image.network(
                    posterUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColors.of(context).surfaceElevated,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.of(context).accent,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.of(context).surfaceElevated,
                        child: Icon(
                          Icons.broken_image_rounded,
                          color: AppColors.of(context).textDisabled,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),

                // 左上角 - 书签图标
                Positioned(
                  top: 0,
                  left: 8,
                  child: GestureDetector(
                    onTap: onTapBookmark,
                    child: Icon(
                      Icons.bookmark_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 20,
                      shadows: const [
                        Shadow(color: Colors.black45, blurRadius: 4),
                      ],
                    ),
                  ),
                ),

                // 右上角 - 评分
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 左下角 - 播放按钮
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: onTapPlay,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),

                // 右下角 - 添加按钮
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onTapAdd,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 标题
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.of(context).textPrimary,
          ),
        ),
      ],
    );
  }
}
