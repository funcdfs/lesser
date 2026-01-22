import 'package:flutter/material.dart';
import 'discovery_media_card.dart';

class DiscoveryHorizontalList extends StatelessWidget {
  const DiscoveryHorizontalList({
    super.key,
    required this.count,
    required this.labelPrefix,
    required this.baseColor,
  });

  final int count;
  final String labelPrefix;
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 260,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: count,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            return DiscoveryMediaCard(
              title: '$labelPrefix $index',
              rating: 8.0 + (index % 10) / 10,
              placeholderColor: baseColor.withValues(alpha: 0.2),
              onTapWatchlist: () {
                // TODO: 添加到片单
              },
              onTapWantToWatch: () {
                // TODO: 添加到想看
              },
              onTapTrailer: () {
                // TODO: 播放预告片
              },
              onTapInfo: () {
                // TODO: 查看详情
              },
            );
          },
        ),
      ),
    );
  }
}
