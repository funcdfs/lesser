import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lesser/features/create/data/draft_repository.dart';
import 'package:lesser/features/create/domain/models/draft.dart';
import 'package:lesser/features/search/presentation/providers/search_history_provider.dart';

part 'draft_provider.g.dart';

/// Provider for DraftRepository
@riverpod
Future<DraftRepository> draftRepository(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return DraftRepository(prefs);
}

/// Provider for managing drafts
@riverpod
class Drafts extends _$Drafts {
  @override
  Future<List<Draft>> build() async {
    final repository = await ref.watch(draftRepositoryProvider.future);
    return repository.getDrafts();
  }

  /// Save a new draft or update existing one
  Future<void> saveDraft({
    String? id,
    required String content,
    String? location,
  }) async {
    final repository = await ref.read(draftRepositoryProvider.future);
    final now = DateTime.now();
    
    final draft = Draft(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      location: location,
      createdAt: id != null ? (await repository.getDraft(id))?.createdAt ?? now : now,
      updatedAt: now,
    );
    
    await repository.saveDraft(draft);
    ref.invalidateSelf();
  }

  /// Delete a draft by ID
  Future<void> deleteDraft(String id) async {
    final repository = await ref.read(draftRepositoryProvider.future);
    await repository.deleteDraft(id);
    ref.invalidateSelf();
  }

  /// Clear all drafts
  Future<void> clearDrafts() async {
    final repository = await ref.read(draftRepositoryProvider.future);
    await repository.clearDrafts();
    ref.invalidateSelf();
  }
}

/// Provider for getting a single draft by ID
@riverpod
Future<Draft?> draftById(Ref ref, String id) async {
  final repository = await ref.watch(draftRepositoryProvider.future);
  return repository.getDraft(id);
}
