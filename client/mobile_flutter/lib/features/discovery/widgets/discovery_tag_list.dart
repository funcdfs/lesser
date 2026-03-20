import 'package:flutter/material.dart';
import '../../../../pkg/ui/theme/theme.dart';

/// Popular Tags 组件 - 匹配 HTML 设计的网格布局
class DiscoveryTagList extends StatelessWidget {
  const DiscoveryTagList({super.key});

  static const List<String> _tags = [
    '筛选',
    '赛博朋克',
    '获奖作品',
    '真实故事改编',
    '浪漫喜剧',
    '末日题材',
    '太空歌剧',
    '心理惊悚',
    '动漫',
    '口碑佳作',
    '黑暗奇幻',
  ];

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.of(context).accent;
    final surfaceElevated = AppColors.of(context).surfaceElevated;
    final textSecondary = AppColors.of(context).textSecondary;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 120,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildFilterButton(context, accentColor),
                    const SizedBox(width: 10),
                    ..._buildTagRow(
                      context,
                      [_tags[1], _tags[2]],
                      surfaceElevated,
                      textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: _buildTagRow(
                    context,
                    [_tags[3], _tags[4]],
                    surfaceElevated,
                    textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: _buildTagRow(
                    context,
                    [_tags[5], _tags[6]],
                    surfaceElevated,
                    textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: _buildTagRow(
                    context,
                    [_tags[7]],
                    surfaceElevated,
                    textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: _buildTagRow(
                    context,
                    [_tags[8]],
                    surfaceElevated,
                    textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: _buildTagRow(
                    context,
                    [_tags[9]],
                    surfaceElevated,
                    textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '筛选',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward, color: Colors.white, size: 14),
        ],
      ),
    );
  }

  List<Widget> _buildTagRow(
    BuildContext context,
    List<String> tags,
    Color backgroundColor,
    Color textColor,
  ) {
    return tags.map((tag) {
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(tag, style: TextStyle(color: textColor, fontSize: 14)),
        ),
      );
    }).toList();
  }
}
