import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lesser/features/search/data/search_history_repository.dart';

part 'search_history_provider.g.dart';

/// Provider for SharedPreferences instance
@riverpod
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return SharedPreferences.getInstance();
}

/// Provider for SearchHistoryRepository
@riverpod
Future<SearchHistoryRepository> searchHistoryRepository(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return SearchHistoryRepository(prefs);
}

/// Provider for managing search history
@riverpod
class SearchHistory extends _$SearchHistory {
  @override
  Future<List<String>> build() async {
    final repository = await ref.watch(searchHistoryRepositoryProvider.future);
    return repository.getHistory();
  }

  Future<void> addToHistory(String query) async {
    if (query.trim().isEmpty) return;

    final repository = await ref.read(searchHistoryRepositoryProvider.future);
    await repository.addHistory(query);
    ref.invalidateSelf();
  }

  Future<void> removeFromHistory(String query) async {
    final repository = await ref.read(searchHistoryRepositoryProvider.future);
    await repository.removeHistory(query);
    ref.invalidateSelf();
  }

  Future<void> clearHistory() async {
    final repository = await ref.read(searchHistoryRepositoryProvider.future);
    await repository.clearHistory();
    ref.invalidateSelf();
  }
}
