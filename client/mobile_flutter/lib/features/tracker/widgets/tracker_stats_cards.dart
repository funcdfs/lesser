import 'package:flutter/material.dart';
import '../../../../pkg/ui/effects/effects.dart';
import '../../../../pkg/ui/theme/theme.dart';

/// 线框图结构：
/// ┌─ 想看 ──────────────────┐  ┌─ 看过 ──────────────────┐
/// │  [电视剧] [电影] [动漫] [图书]  │  │  [电视剧] [电影] [动漫] [图书]  │
/// │  堆叠|数  堆叠|数 ...         │  │  堆叠|数  堆叠|数 ...         │
/// └─────────────────────────┘  └─────────────────────────┘
class TrackerStatsCards extends StatelessWidget {
  const TrackerStatsCards({super.key});

  static const _categories = ['电视剧', '电影', '动漫', '图书'];

  // 想看数量 mock
  static const _wantCounts = [18, 11, 8, 5];
  // 看过数量 mock
  static const _seenCounts = [42, 37, 29, 20];

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 「想看」区域
              const _WatchSection(
                label: '想看',
                categories: _categories,
                counts: _wantCounts,
                accentColor: Color(0xFF9B8AC4),
                seedOffset: 0,
              ),
              // 分隔线
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: VerticalDivider(
                  width: 1,
                  thickness: 0.5,
                  color: AppColors.of(context).divider,
                ),
              ),
              // 「看过」区域
              const _WatchSection(
                label: '看过',
                categories: _categories,
                counts: _seenCounts,
                accentColor: Color(0xFF7EB89A),
                seedOffset: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 一个「想看」或「看过」区域，包含标签 + 4列分类卡片
class _WatchSection extends StatelessWidget {
  const _WatchSection({
    required this.label,
    required this.categories,
    required this.counts,
    required this.accentColor,
    required this.seedOffset,
  });

  final String label;
  final List<String> categories;
  final List<int> counts;
  final Color accentColor;
  final int seedOffset;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 药丸标签
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(
              color: colors.textPrimary.withValues(alpha: 0.25),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // 分类列
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(categories.length, (i) {
            return Padding(
              padding: EdgeInsets.only(
                right: i < categories.length - 1 ? 10 : 0,
              ),
              child: _CategoryColumn(
                categoryName: categories[i],
                count: counts[i],
                accentColor: accentColor,
                seed: seedOffset + i * 11,
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// 每一个分类列：分类名 + 卡片（堆叠海报 | 数量）
class _CategoryColumn extends StatelessWidget {
  const _CategoryColumn({
    required this.categoryName,
    required this.count,
    required this.accentColor,
    required this.seed,
  });

  final String categoryName;
  final int count;
  final Color accentColor;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return TapScale(
      onTap: () {},
      scale: TapScales.medium,
      child: SizedBox(
        width: 82,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 分类名
            Text(
              categoryName,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: colors.textTertiary,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 5),
            // 卡片：堆叠状态 + 数量
            Container(
              height: 72,
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.divider, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 左侧：海报堆叠区
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: _MiniPosterStack(
                          seed: seed,
                          accentColor: accentColor,
                        ),
                      ),
                    ),
                  ),
                  // 右侧：数量
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          count.toString(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w300,
                            color: colors.textPrimary,
                            height: 1.0,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '部',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: colors.textTertiary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 小尺寸海报叠放（适配小卡片）
class _MiniPosterStack extends StatelessWidget {
  const _MiniPosterStack({required this.seed, required this.accentColor});

  final int seed;
  final Color accentColor;

  // 3 张海报：后 → 前
  static const _cfg = [
    (angle: -0.22, dx: 10.0, opacity: 0.40),
    (angle: -0.10, dx: 5.0, opacity: 0.68),
    (angle: 0.00, dx: 0.0, opacity: 1.00),
  ];

  static const double _pw = 30.0; // poster width
  static const double _ph = 44.0; // poster height

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SizedBox(
      width: _pw + 14,
      height: _ph + 4,
      child: Stack(
        clipBehavior: Clip.none,
        children: _cfg
            .asMap()
            .entries
            .map((e) {
              final i = e.key;
              final c = e.value;
              return Positioned(
                left: c.dx,
                bottom: 0,
                child: Opacity(
                  opacity: c.opacity,
                  child: Transform.rotate(
                    angle: c.angle,
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: _pw,
                      height: _ph,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.30),
                            blurRadius: 5,
                            offset: const Offset(1, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          'https://picsum.photos/seed/${(seed + i * 7).abs() % 200}/60/90',
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Container(color: colors.accentSoft);
                          },
                          errorBuilder: (_, _, _) => Container(
                            color: colors.accentSoft,
                            child: Icon(
                              Icons.movie_rounded,
                              size: 12,
                              color: accentColor.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList()
            .reversed
            .toList(),
      ),
    );
  }
}
