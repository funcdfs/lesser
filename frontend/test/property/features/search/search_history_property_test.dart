import 'package:glados/glados.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lesser/features/search/data/search_history_repository.dart';

/// Property-based tests for Search History Persistence
/// Feature: frontend-code-improvement, Property 5: Search History Persistence
/// Validates: Requirements 7.4

void main() {
  group('Search History Persistence - Property Tests', () {
    late SearchHistoryRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = SearchHistoryRepository(prefs);
    });

    // Property 5a: Round-trip persistence
    // For any list of search queries, storing then reading SHALL return
    // the same queries in the same order
    Glados(any.nonEmptyList(any.letterOrDigits)).test(
      'Property 5a: Search history round-trip preserves order',
      (queries) async {
        // Filter out empty strings and limit to unique queries
        final uniqueQueries = queries
            .where((q) => q.isNotEmpty)
            .toSet()
            .take(10)
            .toList();

        if (uniqueQueries.isEmpty) return;

        // Clear any existing history
        await repository.clearHistory();

        // Add queries in reverse order (since addHistory prepends)
        for (final query in uniqueQueries.reversed) {
          await repository.addHistory(query);
        }

        // Read back the history
        final retrievedHistory = repository.getHistory();

        // Verify the order is preserved
        expect(
          retrievedHistory.take(uniqueQueries.length).toList(),
          equals(uniqueQueries),
          reason: 'History should preserve insertion order',
        );
      },
    );

    // Property 5b: Adding duplicate moves to top
    test('Property 5b: Adding duplicate query moves it to top', () async {
      await repository.clearHistory();

      await repository.addHistory('first');
      await repository.addHistory('second');
      await repository.addHistory('third');

      // Add 'first' again - should move to top
      await repository.addHistory('first');

      final history = repository.getHistory();
      expect(history.first, equals('first'));
      expect(history.length, equals(3)); // No duplicates
      expect(history, equals(['first', 'third', 'second']));
    });

    // Property 5c: Remove operation removes only specified query
    test('Property 5c: Remove operation removes only specified query', () async {
      await repository.clearHistory();

      await repository.addHistory('query1');
      await repository.addHistory('query2');
      await repository.addHistory('query3');

      await repository.removeHistory('query2');

      final history = repository.getHistory();
      expect(history, equals(['query3', 'query1']));
      expect(history.contains('query2'), isFalse);
    });

    // Property 5d: Clear removes all history
    test('Property 5d: Clear removes all history', () async {
      await repository.addHistory('query1');
      await repository.addHistory('query2');

      await repository.clearHistory();

      final history = repository.getHistory();
      expect(history, isEmpty);
    });

    // Property 5e: Empty queries are not added
    test('Property 5e: Empty and whitespace queries are not added', () async {
      await repository.clearHistory();

      await repository.addHistory('');
      await repository.addHistory('   ');
      await repository.addHistory('\t');

      final history = repository.getHistory();
      expect(history, isEmpty);
    });

    // Property 5f: History respects maximum limit
    test('Property 5f: History respects maximum limit of 20 items', () async {
      await repository.clearHistory();

      // Add more than max items
      for (int i = 0; i < 25; i++) {
        await repository.addHistory('query_$i');
      }

      final history = repository.getHistory();
      expect(history.length, equals(20));
      // Most recent should be first
      expect(history.first, equals('query_24'));
    });
  });
}
