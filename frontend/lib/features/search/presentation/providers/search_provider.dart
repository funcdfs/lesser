import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lesser/core/network/api_provider.dart';
import 'package:lesser/core/config/debug_config.dart';
import 'package:lesser/features/search/data/search_repository.dart';
import 'package:lesser/features/search/domain/models/search_filter.dart';
import 'package:lesser/features/search/domain/models/search_result.dart';
import 'package:lesser/features/auth/domain/models/user.dart';
import 'package:lesser/features/feeds/domain/models/post.dart';

part 'search_provider.g.dart';

@riverpod
SearchRepository searchRepository(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SearchRepository(apiClient);
}

/// Provider for the current search query
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

/// Provider for the current search filter
@riverpod
class CurrentSearchFilter extends _$CurrentSearchFilter {
  @override
  SearchFilter build() => const SearchFilter();

  void setType(SearchType type) {
    state = state.copyWith(type: type);
  }

  void setSortBy(SortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void reset() {
    state = const SearchFilter();
  }
}

/// Provider for search results with pagination
@riverpod
class SearchResults extends _$SearchResults {
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  Future<SearchResult> build() async {
    // Return empty result initially
    return const SearchResult();
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncData(SearchResult());
      return;
    }

    _currentPage = 1;
    _hasMore = true;
    state = const AsyncLoading();

    try {
      final result = await _performSearch(query, _currentPage);
      _hasMore = result.hasMore;
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> loadMore(String query) async {
    if (!_hasMore || state is AsyncLoading) return;

    final currentResult = state.value;
    if (currentResult == null) return;

    _currentPage++;

    try {
      final newResult = await _performSearch(query, _currentPage);
      _hasMore = newResult.hasMore;

      // Merge results
      state = AsyncData(SearchResult(
        users: [...currentResult.users, ...newResult.users],
        posts: [...currentResult.posts, ...newResult.posts],
        tags: [...currentResult.tags, ...newResult.tags],
        hasMore: newResult.hasMore,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<SearchResult> _performSearch(String query, int page) async {
    if (DebugConfig.debugLocal) {
      // Debug mode: return mock data
      await Future.delayed(const Duration(milliseconds: 500));
      return SearchResult(
        users: List.generate(
          5,
          (i) => User(
            id: i + (page - 1) * 5,
            username: 'user_${query}_$i',
            email: 'user$i@example.com',
          ),
        ),
        posts: List.generate(
          5,
          (i) => Post(
            id: '${(page - 1) * 5 + i}',
            username: 'author_$i',
            content: 'Post about $query - item $i',
            createdAt: '2024-01-15T10:30:00Z',
          ),
        ),
        tags: ['#$query', '#${query}trending', '#${query}hot'],
        hasMore: page < 3,
      );
    } else {
      final repository = ref.read(searchRepositoryProvider);
      final filter = ref.read(currentSearchFilterProvider);
      return repository.search(
        query: query,
        type: filter.type,
        page: page,
      );
    }
  }

  void clear() {
    _currentPage = 1;
    _hasMore = true;
    state = const AsyncData(SearchResult());
  }
}
