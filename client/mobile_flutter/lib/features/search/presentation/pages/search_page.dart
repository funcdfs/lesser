import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../feeds/presentation/widgets/feed_item_card.dart';
import '../providers/search_provider.dart';
import '../widgets/user_search_item.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    ref.read(searchProvider.notifier).updateQuery(query);
    if (query.isNotEmpty) {
      ref.read(searchProvider.notifier).search();
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchState.query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchProvider.notifier).clear();
                    },
                  )
                : null,
          ),
          onSubmitted: _onSearch,
          onChanged: (value) {
            ref.read(searchProvider.notifier).updateQuery(value);
          },
        ),
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'Posts',
                    isActive: searchState.activeTab == SearchTab.posts,
                    onTap: () => ref
                        .read(searchProvider.notifier)
                        .changeTab(SearchTab.posts),
                  ),
                ),
                Expanded(
                  child: _TabButton(
                    label: 'Users',
                    isActive: searchState.activeTab == SearchTab.users,
                    onTap: () => ref
                        .read(searchProvider.notifier)
                        .changeTab(SearchTab.users),
                  ),
                ),
              ],
            ),
          ),
          // Results
          Expanded(child: _buildResults(searchState)),
        ],
      ),
    );
  }

  Widget _buildResults(SearchState searchState) {
    if (searchState.query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Search for posts or users',
              style: TextStyle(color: AppColors.textSecondaryLight),
            ),
          ],
        ),
      );
    }

    switch (searchState.status) {
      case SearchStatus.initial:
        return const SizedBox.shrink();
      case SearchStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case SearchStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(searchState.errorMessage ?? 'An error occurred'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(searchProvider.notifier).search(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      case SearchStatus.loaded:
        if (searchState.activeTab == SearchTab.posts) {
          if (searchState.posts.isEmpty) {
            return _buildEmptyState('No posts found');
          }
          return ListView.separated(
            itemCount: searchState.posts.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final post = searchState.posts[index];
              return FeedItemCard(feedItem: post);
            },
          );
        } else {
          if (searchState.users.isEmpty) {
            return _buildEmptyState('No users found');
          }
          return ListView.separated(
            itemCount: searchState.users.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = searchState.users[index];
              return UserSearchItem(user: user);
            },
          );
        }
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.textSecondaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: AppColors.textSecondaryLight),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.primary : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}
