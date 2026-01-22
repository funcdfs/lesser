import 'package:flutter/material.dart';
import '../../../../pkg/ui/theme/theme.dart';
import 'discovery_media_card.dart';

/// Trending Now 区域 - 匹配 HTML 设计
class DiscoveryTrendingSection extends StatefulWidget {
  const DiscoveryTrendingSection({super.key});

  @override
  State<DiscoveryTrendingSection> createState() =>
      _DiscoveryTrendingSectionState();
}

class _DiscoveryTrendingSectionState extends State<DiscoveryTrendingSection> {
  int _selectedTimeRange = 0; // 0: Today, 1: Weekly, 2: Month
  int _selectedCategory = 0; // 0: All, 1: Movies, 2: TV Shows, etc.

  final List<String> _timeRanges = ['Today', 'Weekly', 'Month'];
  final List<String> _categories = [
    'All',
    'Movies',
    'TV Shows',
    'Documentaries',
    'Anime',
  ];

  // 假数据 - 电影标题
  final List<String> _movieTitles = [
    'Dune: Part Two',
    'Furiosa',
    'The Fall Guy',
    'Challengers',
    'Immaculate',
    'Civil War',
    'Kingdom Apes',
    'Kung Fu Panda 4',
    'Wonka',
    'Godzilla x Kong',
  ];

  final List<double> _ratings = [
    4.5,
    4.8,
    4.5,
    4.9,
    4.2,
    4.7,
    4.6,
    4.4,
    4.3,
    4.8,
  ];

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // 标题和时间范围选择器
          _buildHeader(context),
          const SizedBox(height: 12),
          // 分类筛选
          _buildCategoryChips(context),
          const SizedBox(height: 12),
          // 两行横向滚动的卡片
          _buildMovieGrid(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textPrimary = AppColors.of(context).textPrimary;
    final surfaceElevated = AppColors.of(context).surfaceElevated;
    final textSecondary = AppColors.of(context).textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Trending Now',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          // 时间范围选择器
          Container(
            decoration: BoxDecoration(
              color: surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_timeRanges.length, (index) {
                final isSelected = _selectedTimeRange == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTimeRange = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      _timeRanges[index],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.of(context).accent
                            : textSecondary,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    final accentColor = AppColors.of(context).accent;
    final surfaceElevated = AppColors.of(context).surfaceElevated;
    final textSecondary = AppColors.of(context).textSecondary;

    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentColor.withValues(alpha: 0.1)
                      : surfaceElevated,
                  border: Border.all(
                    color: isSelected ? accentColor : Colors.transparent,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? accentColor : textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMovieGrid(BuildContext context) {
    return SizedBox(
      height: 520, // 两行的高度
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // 使用 Column 包含两行
          Column(
            children: [
              // 第一行
              SizedBox(
                height: 250,
                child: Row(
                  children: List.generate(10, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: SizedBox(
                        width: 128,
                        child: DiscoveryMediaCard(
                          title: _movieTitles[index % _movieTitles.length],
                          rating: _ratings[index % _ratings.length],
                          posterUrl:
                              'https://picsum.photos/seed/$index/300/450',
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
              // 第二行
              SizedBox(
                height: 250,
                child: Row(
                  children: List.generate(10, (index) {
                    final itemIndex = index + 10;
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: SizedBox(
                        width: 128,
                        child: DiscoveryMediaCard(
                          title: _movieTitles[itemIndex % _movieTitles.length],
                          rating: _ratings[itemIndex % _ratings.length],
                          posterUrl:
                              'https://picsum.photos/seed/$itemIndex/300/450',
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
