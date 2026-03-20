import 'package:flutter/material.dart';
import '../../../../pkg/ui/effects/effects.dart';
import '../../../../pkg/ui/theme/theme.dart';

class TrackerPlaylists extends StatelessWidget {
  const TrackerPlaylists({super.key});

  static const _playlists = [
    (title: 'Sci-Fi Masterpieces', count: 12, seed: 'scifi1'),
    (title: 'Weekend Binge', count: 5, seed: 'binge2'),
    (title: 'Top Anime', count: 24, seed: 'anime3'),
    (title: 'Favorites 2024', count: 8, seed: 'fav4'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 区域标题
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'Playlists',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colors.accent,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: colors.accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio:
                  0.78, // Adjusted height to tighten bottom empty space
            ),
            itemCount: _playlists.length,
            itemBuilder: (context, index) {
              final p = _playlists[index];
              return _PlaylistCard(
                title: p.title,
                count: p.count,
                seed: p.seed,
                index: index,
              );
            },
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({
    required this.title,
    required this.count,
    required this.seed,
    required this.index,
  });

  final String title;
  final int count;
  final String seed;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    // 计算实际展示的图片数量，以及溢出的数量
    final overflowCount = count > 4 ? count - 4 : 0;

    return TapScale(
      onTap: () {},
      scale: TapScales.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: colors.surfaceElevated,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 4.0;
                    // 计算每个小格子的尺寸
                    final itemSize = (constraints.maxWidth - spacing) / 2;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: List.generate(4, (i) {
                        final borderRadius = BorderRadius.only(
                          topLeft: Radius.circular(i == 0 ? 16 : 4),
                          topRight: Radius.circular(i == 1 ? 16 : 4),
                          bottomLeft: Radius.circular(i == 2 ? 16 : 4),
                          bottomRight: Radius.circular(i == 3 ? 16 : 4),
                        );

                        // 如果数量不足对应的格子数，显示占位色块
                        if (i >= count) {
                          return Container(
                            width: itemSize,
                            height: itemSize,
                            decoration: BoxDecoration(
                              color: colors.accent.withValues(alpha: 0.05),
                              borderRadius: borderRadius,
                            ),
                          );
                        }

                        final imageWidget = Image.network(
                          'https://picsum.photos/seed/${seed}_$i/200/200',
                          width: itemSize,
                          height: itemSize,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              width: itemSize,
                              height: itemSize,
                              color: colors.accentSoft,
                            );
                          },
                          errorBuilder: (_, _, _) => Container(
                            width: itemSize,
                            height: itemSize,
                            color: colors.accentSoft,
                          ),
                        );

                        // 如果有溢出并且是第四个格子，显示底层图片外加模糊遮罩层
                        if (i == 3 && overflowCount > 0) {
                          return ClipRRect(
                            borderRadius: borderRadius,
                            child: SizedBox(
                              width: itemSize,
                              height: itemSize,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  imageWidget,
                                  FrostedGlass(
                                    blur: 8.0,
                                    opacity: 0.3,
                                    color: colors.accent,
                                    borderRadius: borderRadius,
                                    child: Center(
                                      child: Text(
                                        '+$overflowCount',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // 普通显示图片
                        return ClipRRect(
                          borderRadius: borderRadius,
                          child: imageWidget,
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 标题
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$count titles',
            style: TextStyle(
              fontSize: 13,
              color: colors.textTertiary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
