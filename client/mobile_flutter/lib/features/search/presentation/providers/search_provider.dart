import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../feeds/domain/entities/feed_item.dart';
import '../../domain/repositories/search_repository.dart';

/// Search tab type
enum SearchTab { posts, users }

/// Search state
enum SearchStatus { initial, loading, loaded, error }

class SearchState {
  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.activeTab = SearchTab.posts,
    this.posts = const [],
    this.users = const [],
    this.errorMessage,
  });

  final SearchStatus status;
  final String query;
  final SearchTab activeTab;
  final List<FeedItem> posts;
  final List<User> users;
  final String? errorMessage;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    SearchTab? activeTab,
    List<FeedItem>? posts,
    List<User>? users,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      activeTab: activeTab ?? this.activeTab,
      posts: posts ?? this.posts,
      users: users ?? this.users,
      errorMessage: errorMessage,
    );
  }
}

/// Search notifier
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier({
    required SearchRepository repository,
  })  : _repository = repository,
        super(const SearchState());

  final SearchRepository _repository;

  /// Update search query
  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }

  /// Change active tab
  void changeTab(SearchTab tab) {
    state = state.copyWith(activeTab: tab);
    if (state.query.isNotEmpty) {
      search();
    }
  }

  /// Perform search
  Future<void> search() async {
    if (state.query.isEmpty) return;

    state = state.copyWith(status: SearchStatus.loading);

    if (state.activeTab == SearchTab.posts) {
      final result = await _repository.searchPosts(query: state.query);
      result.fold(
        (failure) => state = state.copyWith(
          status: SearchStatus.error,
          errorMessage: failure.message,
        ),
        (posts) => state = state.copyWith(
          status: SearchStatus.loaded,
          posts: posts,
        ),
      );
    } else {
      final result = await _repository.searchUsers(query: state.query);
      result.fold(
        (failure) => state = state.copyWith(
          status: SearchStatus.error,
          errorMessage: failure.message,
        ),
        (users) => state = state.copyWith(
          status: SearchStatus.loaded,
          users: users,
        ),
      );
    }
  }

  /// Search users only (for new conversation)
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) return;

    state = state.copyWith(status: SearchStatus.loading, query: query);

    final result = await _repository.searchUsers(query: query);
    result.fold(
      (failure) => state = state.copyWith(
        status: SearchStatus.error,
        errorMessage: failure.message,
      ),
      (users) => state = state.copyWith(
        status: SearchStatus.loaded,
        users: users,
      ),
    );
  }

  /// Clear search
  void clear() {
    state = const SearchState();
  }

  /// Check if loading
  bool get isLoading => state.status == SearchStatus.loading;
}

/// Search provider
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final repository = getIt<SearchRepository>();
  return SearchNotifier(repository: repository);
});
