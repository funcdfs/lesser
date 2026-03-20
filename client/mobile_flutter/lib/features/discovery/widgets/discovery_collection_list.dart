import 'package:flutter/material.dart';
import '../../../../pkg/ui/theme/theme.dart';

/// Curated Playlists 组件 - 匹配 HTML 设计的渐变卡片
class DiscoveryCollectionList extends StatelessWidget {
  const DiscoveryCollectionList({super.key});

  static const List<Map<String, dynamic>> _playlists = [
    {
      'title': '十年最佳\n科幻片',
      'gradient': [Color(0xFF1E3A8A), Colors.transparent],
      'image': 'https://picsum.photos/seed/scifi/480/256',
    },
    {
      'title': '夏日\n大片',
      'gradient': [Color(0xFF7C2D12), Colors.transparent],
      'image': 'https://picsum.photos/seed/summer/480/256',
    },
    {
      'title': '邪典经典',
      'gradient': [Color(0xFF581C87), Colors.transparent],
      'image': 'https://picsum.photos/seed/cult/480/256',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 128,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _playlists.length,
          itemBuilder: (context, index) {
            final playlist = _playlists[index];
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () {
                  // TODO: 跳转到片单详情
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 240,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 背景图片
                        Image.network(
                          playlist['image'] as String,
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
                                size: 48,
                              ),
                            );
                          },
                        ),
                        // 渐变遮罩
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: playlist['gradient'] as List<Color>,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                        // 文字内容
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 160,
                              child: Text(
                                playlist['title'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
}
