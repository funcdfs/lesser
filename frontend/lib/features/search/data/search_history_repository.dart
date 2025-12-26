import 'package:shared_preferences/shared_preferences.dart';

/// Repository for managing search history using SharedPreferences
class SearchHistoryRepository {
  static const String _historyKey = 'search_history';
  static const int _maxHistoryItems = 20;

  final SharedPreferences _prefs;

  SearchHistoryRepository(this._prefs);

  /// Get all search history items
  List<String> getHistory() {
    return _prefs.getStringList(_historyKey) ?? [];
  }

  /// Add a query to search history
  /// If the query already exists, it will be moved to the top
  Future<void> addHistory(String query) async {
    if (query.trim().isEmpty) return;

    final history = getHistory();
    
    // Remove if already exists (to move to top)
    history.remove(query);
    
    // Add to the beginning
    history.insert(0, query);
    
    // Limit the history size
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }
    
    await _prefs.setStringList(_historyKey, history);
  }

  /// Remove a specific query from history
  Future<void> removeHistory(String query) async {
    final history = getHistory();
    history.remove(query);
    await _prefs.setStringList(_historyKey, history);
  }

  /// Clear all search history
  Future<void> clearHistory() async {
    await _prefs.remove(_historyKey);
  }
}
