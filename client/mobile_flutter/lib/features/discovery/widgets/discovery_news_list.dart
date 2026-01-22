import 'package:flutter/material.dart';
import '../../../../pkg/ui/theme/theme.dart';

/// Latest News 组件 - 匹配 HTML 设计的新闻卡片
class DiscoveryNewsList extends StatelessWidget {
  const DiscoveryNewsList({super.key});

  static const List<Map<String, String>> _news = [
    {
      'title': 'New Trailers Released',
      'description':
          'The latest release for Dune: Part Two has fans speculating about the ending...',
      'image': 'https://picsum.photos/seed/news1/560/256',
    },
    {
      'title': 'Casting News',
      'description':
          'Major casting announcements for the upcoming Marvel phase revealed today.',
      'image': 'https://picsum.photos/seed/news2/560/256',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final surfaceElevated = AppColors.of(context).surfaceElevated;
    final textPrimary = AppColors.of(context).textPrimary;
    final textSecondary = AppColors.of(context).textSecondary;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _news.length,
          itemBuilder: (context, index) {
            final newsItem = _news[index];
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () {
                  // TODO: 跳转到新闻详情
                },
                child: Container(
                  width: 280,
                  decoration: BoxDecoration(
                    color: surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade200.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 图片区域
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: SizedBox(
                          height: 128,
                          width: double.infinity,
                          child: Image.network(
                            newsItem['image']!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // 文字内容
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              newsItem['title']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              newsItem['description']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
