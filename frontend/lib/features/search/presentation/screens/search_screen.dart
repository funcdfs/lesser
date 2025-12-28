import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/autocomplete.dart';
import '../providers/hot_content_provider.dart';
import '../providers/search_history_provider.dart';
import '../providers/search_provider.dart';

/// 搜索页面
///
/// 负责：
/// - 搜索输入框
/// - 显示热门榜单和热门标签
/// - 显示搜索历史
/// - 执行搜索功能

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isCategoryExpanded = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() => _isSearching = false);
      ref.read(searchResultsProvider.notifier).clear();
      return;
    }

    setState(() => _isSearching = true);
    ref.read(searchHistoryProvider.notifier).addToHistory(query);
    ref.read(searchResultsProvider.notifier).search(query);
  }

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
              child: ref
                  .watch(searchHistoryProvider)
                  .when(
                    data: (history) => AppAutocomplete(
                      controller: _searchController,
                      items: history,
                      hint: '搜索文章、话题、用户...',
                      onChanged: (value) {
                        if (value.isEmpty && _isSearching) {
                          setState(() => _isSearching = false);
                        }
                      },
                      onSelected: _onSearch,
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => AppAutocomplete(
                      controller: _searchController,
                      items: [],
                      hint: '搜索文章、话题、用户...',
                      onChanged: (value) {
                        if (value.isEmpty && _isSearching) {
                          setState(() => _isSearching = false);
                        }
                      },
                      onSelected: _onSearch,
                    ),
                  ),
            ),
            const SizedBox(width: AppSpacing.md),
            Icon(Icons.tune_outlined, color: AppColors.foreground),
          ],
        ),
      ),
      body: Row(
        children: [
          // Left Category Tab Bar
          _buildCategoryTabBar(_isCategoryExpanded),

          // Right Main Content
          Expanded(
            child: _isSearching
                ? _buildSearchResults(textTheme)
                : _buildDefaultContent(textTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabBar(bool isExpanded) {
    final categories = [
      '分类',
      '日常生活',
      '家庭',
      '食物',
      '生活方式',
      '购物',
      '儿童保育',
      '健康',
      '旅行和郊游',
      '宠物',
      '专栏和文章',
      '美容',
      '时尚',
      'DIY',
      '造型',
      '手艺',
      '户外的',
      '学习',
      '教育',
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isExpanded ? 180 : 50,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // Toggle button
          Container(
            height: 50,
            alignment: Alignment.center,
            child: IconButton(
              icon: Icon(isExpanded ? Icons.chevron_left : Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _isCategoryExpanded = !_isCategoryExpanded;
                });
              },
              color: AppColors.foreground,
            ),
          ),

          // Category list
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isTitle = index == 0;

                return ListTile(
                  leading: isTitle ? const Icon(Icons.category) : null,
                  title: isExpanded ? Text(category) : null,
                  dense: true,
                  onTap: () {
                    // Handle category selection
                  },
                  selected:
                      index ==
                      0, // Just for demo, you can add a provider to track selected category
                  selectedColor: AppColors.primary,
                  selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultContent(TextTheme textTheme) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.lg),
        _buildSearchHistorySection(textTheme),
        const SizedBox(height: AppSpacing.xl),
        _buildHotSearchSection(textTheme),
        const SizedBox(height: AppSpacing.xl),
        _buildHotTagsSection(textTheme),
      ],
    );
  }

  Widget _buildSearchHistorySection(TextTheme textTheme) {
    final historyAsync = ref.watch(searchHistoryProvider);

    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        color: AppColors.mutedForeground,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text('搜索历史', style: textTheme.headlineSmall),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.mutedForeground,
                      size: 18,
                    ),
                    onPressed: () {
                      ref.read(searchHistoryProvider.notifier).clearHistory();
                    },
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: history.map((query) {
                  return Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12, right: 6),
                          child: Text(
                            query,
                            style: TextStyle(
                              color: AppColors.secondaryForeground,
                              fontSize: 14,
                              height: 1.2,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: AppColors.mutedForeground,
                            size: 16,
                          ),
                          onPressed: () {
                            ref
                                .read(searchHistoryProvider.notifier)
                                .removeFromHistory(query);
                          },
                          splashRadius: 16,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildHotSearchSection(TextTheme textTheme) {
    final hotListAsync = ref.watch(hotListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_fire_department, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text('Top 10热门文章', style: textTheme.headlineSmall),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        hotListAsync.when(
          data: (hotListItems) => SizedBox(
            height: 180, // Approximately 3 rows height
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hotListItems.length,
              itemBuilder: (context, index) {
                final item = hotListItems[index];

                Color rankingColor;
                if (index == 0) {
                  rankingColor = const Color(0xFFFFD700); // Gold
                } else if (index == 1) {
                  rankingColor = const Color(0xFFC0C0C0); // Silver
                } else if (index == 2) {
                  rankingColor = const Color(0xFFCD7F32); // Bronze
                } else {
                  rankingColor = AppColors.mutedForeground;
                }

                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ranking and title
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index < 3)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: rankingColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${index + 1}',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          else
                            Text(
                              '${index + 1}',
                              style: textTheme.titleMedium?.copyWith(
                                color: rankingColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              item.title,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Author
                      Text(
                        item.author,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Image if available
                      if (item.imageUrl != null)
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              image: DecorationImage(
                                image: NetworkImage(item.imageUrl!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                '加载失败，请重试',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHotTagsSection(TextTheme textTheme) {
    final hotTagsAsync = ref.watch(hotTagsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '# 热门标签',
          style: textTheme.headlineSmall?.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppSpacing.md),
        hotTagsAsync.when(
          data: (hotTags) => Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.md,
            children: hotTags.map((tag) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = tag;
                  _onSearch(tag);
                },
                child: Container(
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
                    style: TextStyle(
                      color: AppColors.secondaryForeground,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, _) => const Text('加载失败'),
        ),
      ],
    );
  }

  Widget _buildSearchResults(TextTheme textTheme) {
    final searchResultsAsync = ref.watch(searchResultsProvider);

    return searchResultsAsync.when(
      data: (result) {
        if (result.users.isEmpty &&
            result.posts.isEmpty &&
            result.tags.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '没有找到相关结果',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '试试其他关键词吧',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (result.users.isNotEmpty) ...[
              Text('用户', style: textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              ...result.users.map(
                (user) => ListTile(
                  leading: CircleAvatar(
                    child: Text(user.username[0].toUpperCase()),
                  ),
                  title: Text(user.username),
                  subtitle: Text(user.email),
                  onTap: () {
                    // Navigate to user profile
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            if (result.posts.isNotEmpty) ...[
              Text('帖子', style: textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              ...result.posts.map(
                (post) => Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: ListTile(
                    title: Text(
                      post.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('by ${post.username}'),
                    onTap: () {
                      // Navigate to post detail
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            if (result.tags.isNotEmpty) ...[
              Text('标签', style: textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: result.tags
                    .map((tag) => Chip(label: Text(tag), onDeleted: null))
                    .toList(),
              ),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '搜索出错了',
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () => _onSearch(_searchController.text),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}
