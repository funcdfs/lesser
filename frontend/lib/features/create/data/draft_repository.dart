import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/draft.dart';

/// Repository for managing draft storage using SharedPreferences
class DraftRepository {
  static const String _draftsKey = 'drafts';

  final SharedPreferences _prefs;

  DraftRepository(this._prefs);

  /// Get all saved drafts
  Future<List<Draft>> getDrafts() async {
    final draftsJson = _prefs.getStringList(_draftsKey) ?? [];
    return draftsJson
        .map((json) => Draft.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // Sort by most recent
  }

  /// Get a single draft by ID
  Future<Draft?> getDraft(String id) async {
    final drafts = await getDrafts();
    try {
      return drafts.firstWhere((draft) => draft.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Save a draft (creates new or updates existing)
  Future<void> saveDraft(Draft draft) async {
    final drafts = await getDrafts();
    final existingIndex = drafts.indexWhere((d) => d.id == draft.id);
    
    if (existingIndex >= 0) {
      drafts[existingIndex] = draft;
    } else {
      drafts.add(draft);
    }
    
    await _saveDrafts(drafts);
  }

  /// Delete a draft by ID
  Future<void> deleteDraft(String id) async {
    final drafts = await getDrafts();
    drafts.removeWhere((draft) => draft.id == id);
    await _saveDrafts(drafts);
  }

  /// Clear all drafts
  Future<void> clearDrafts() async {
    await _prefs.remove(_draftsKey);
  }

  /// Internal method to save drafts list
  Future<void> _saveDrafts(List<Draft> drafts) async {
    final draftsJson = drafts.map((draft) => jsonEncode(draft.toJson())).toList();
    await _prefs.setStringList(_draftsKey, draftsJson);
  }
}
