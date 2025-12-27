import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/theme.dart';
import '../../domain/models/hot_item.dart';
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

  void _onHistoryTap(String query) {
    _searchController.text = query;
    _onSearch(query);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _isSearching = false);
    ref.read(searchResultsProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final selectedCategory = ref.watch(selectedCategoryProvider);

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
                child: TextField(
                  controller: _searchController,
                  autofocus: false,
                  onSubmitted: _onSearch,
                  onChanged: (value) {
                    if (value.isEmpty && _isSearching) {
                      setState(() => _isSearching = false);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: '搜索文章、话题、用户...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.mutedForeground,
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.mutedForeground,
                              size: 18,
                            ),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.only(bottom: 10, top: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Icon(Icons.tune_outlined, color: AppColors.foreground),
          ],
        ),
      ),
      body: _isSearching
          ? _buildSearchResults(textTheme)
          : _buildDefaultContent(textTheme, selectedCategory),
    );
  }

  Widget _buildDefaultContent(TextTheme textTheme, String selectedCategory) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      children: [
        _buildSearchHistorySection(textTheme),
        _buildHotListSection(textTheme, selectedCategory),
        const SizedBox(height: AppSpacing.xl3),
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
                      const Icon(Icons.history, color: AppColors.foreground),
                      const SizedBox(width: AppSpacing.sm),
                      Text('搜索历史', style: textTheme.headlineSmall),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(searchHistoryProvider.notifier).clearHistory();
                    },
                    child: const Text(
                      '清空',
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: history.take(10).map((query) {
                  return GestureDetector(
                    onTap: () => _onHistoryTap(query),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm - 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            query,
                            style: const TextStyle(
                              color: AppColors.secondaryForeground,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(searchHistoryProvider.notifier)
                                  .removeFromHistory(query);
                            },
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildHotListSection(TextTheme textTheme, String selectedCategory) {
    final hotListAsync = ref.watch(hotListProvider);

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
                final isSelected = category == selectedCategory;
                return GestureDetector(
                  onTap: () => ref
                      .read(selectedCategoryProvider.notifier)
                      .setCategory(category),
                  child: Container(
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm - 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : AppColors.secondary,
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
          hotListAsync.when(
            data: (hotListItems) => _buildHotListItems(textTheme, hotListItems),
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
      ),
    );
  }

  Widget _buildHotListItems(TextTheme textTheme, List<HotItem> hotListItems) {
    return Column(
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
                      ? AppColors.rankingGold
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
                      item.title,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${item.author} · ${item.heat}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              if (item.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl!,
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
    );
  }

  Widget _buildHotTagsSection(TextTheme textTheme) {
    final hotTagsAsync = ref.watch(hotTagsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '# 热门标签',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.tagGreen,
            ),
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
                      style: const TextStyle(
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
      ),
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
                const Icon(
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
              ...result.users.map((user) => ListTile(
                    leading: CircleAvatar(
                      child: Text(user.username[0].toUpperCase()),
                    ),
                    title: Text(user.username),
                    subtitle: Text(user.email),
                    onTap: () {
                      // Navigate to user profile
                    },
                  )),
              const SizedBox(height: AppSpacing.xl),
            ],
            if (result.posts.isNotEmpty) ...[
              Text('帖子', style: textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              ...result.posts.map((post) => Card(
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
                  )),
              const SizedBox(height: AppSpacing.xl),
            ],
            if (result.tags.isNotEmpty) ...[
              Text('标签', style: textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: result.tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          onDeleted: null,
                        ))
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
            const Icon(
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
