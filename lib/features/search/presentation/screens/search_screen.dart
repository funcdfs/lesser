import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';

/// 搜索页面
///
/// 负责：
/// - 搜索输入框
/// - 显示热门榜单和热门标签
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<Map<String, String>> hotListItems = [
    {
      'title': '简单又健康的早餐食谱合集',
      'author': 'Sarah Chen',
      'heat': '1256 热度',
      'image':
          'https://tiebapic.baidu.com/forum/pic/item/8326cffc1e178a82d6199320f303738da977e8ea.jpg',
    },
    {
      'title': '家居收纳技巧大公开',
      'author': 'Alex Rivera',
      'heat': '2341 热度',
      'image':
          'https://tiebapic.baidu.com/forum/pic/item/bba1cd11728b47103e6834b9cfcec3fdfd0323ea.jpg',
    },
    {
      'title': '亲子旅行目的地推荐',
      'author': 'Maya Patel',
      'heat': '3456 热度',
      'image':
          'https://tiebapic.baidu.com/forum/pic/item/7aec54e736d12f2ea06efb0849c2d562853568ea.jpg',
    },
    {
      'title': '护肤步骤详解：从清洁到保养',
      'author': 'Emma Wilson',
      'heat': '1890 热度',
      'image':
          'https://tiebapic.baidu.com/forum/pic/item/d62a6059252dd42ad1f4f5a3063b5bb5c8eab8ea.jpg',
    },
    {
      'title': 'DIY手工：制作个性化笔记本',
      'author': 'David Kim',
      'heat': '987 热度',
      'image':
          'https://tiebapic.baidu.com/forum/pic/item/a8014c086e061d9539d09c3e7ef40ad162d9caea.jpg',
    },
  ];

  final List<String> hotTags = [
    '旅行',
    '美食',
    '摄影',
    '艺术',
    '音乐',
    '电影',
    '读书',
    '健身',
    '科技',
    '设计',
  ];
  final List<String> categoryFilters = ['全局热门', '旅游', '美食', '科技'];
  String _selectedCategory = '全局热门';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.zinc100,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const TextField(
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: '搜索文章、话题、用户...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.mutedForeground,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(bottom: 10, top: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Icon(Icons.tune_outlined, color: AppColors.foreground),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          _buildHotListSection(textTheme),
          const SizedBox(height: AppSpacing.xl3),
          _buildHotTagsSection(textTheme),
        ],
      ),
    );
  }

  Widget _buildHotListSection(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart, color: AppColors.foreground),
              const SizedBox(width: AppSpacing.sm),
              Text('热门榜单', style: textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categoryFilters.map((category) {
                final isSelected = category == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm - 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.secondary,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryForeground
                            : AppColors.secondaryForeground,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Column(
            children: hotListItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == hotListItems.length - 1 ? 0 : AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    Text(
                      '${index + 1}',
                      style: textTheme.titleLarge?.copyWith(
                        color: index < 3
                            ? const Color(0xFFFFD700)
                            : AppColors.mutedForeground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${item['author']!} · ${item['heat']!}',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: CachedNetworkImage(
                        imageUrl: item['image']!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: AppColors.muted),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHotTagsSection(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '# 热门标签',
            style: textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.md,
            children: hotTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: AppColors.secondaryForeground,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
