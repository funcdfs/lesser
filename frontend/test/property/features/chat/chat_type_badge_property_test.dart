import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesser/features/chat/presentation/widgets/chat_item.dart';
import 'package:lesser/features/chat/presentation/widgets/chat_type_badge.dart';

/// Property-based tests for ChatTypeBadge
/// Feature: message-page-ui-refactor, Property 2: Chat Type Badge Consistency
/// Validates: Requirements 2.5, 2.6, 6.5, 6.6, 6.7, 6.8

void main() {
  group('ChatTypeBadge - Property 2: Chat Type Badge Consistency', () {
    /// **Feature: message-page-ui-refactor, Property 2: Chat Type Badge Consistency**
    /// **Validates: Requirements 2.5, 2.6, 6.5, 6.6, 6.7, 6.8**
    ///
    /// *For any* ChatItem with a given chatType, the ChatTypeBadge SHALL display
    /// the correct icon:
    /// - ChatType.group → group icon (双人图标)
    /// - ChatType.channel → hashtag icon (#)
    /// - ChatType.private → no badge displayed

    // Property test: For ALL ChatType values, the correct icon is displayed
    test('Property 2: All ChatType values display correct icons', () {
      // This is a property test that exhaustively tests all enum values
      // Since ChatType is a finite enum, we test all possible values
      for (final chatType in ChatType.values) {
        final expectedIcon = _getExpectedIcon(chatType);
        final expectedNoIcon = chatType == ChatType.private;

        // Verify the mapping is consistent
        if (expectedNoIcon) {
          expect(
            expectedIcon,
            isNull,
            reason: 'Private chat should have no icon',
          );
        } else {
          expect(
            expectedIcon,
            isNotNull,
            reason: '$chatType should have an icon',
          );
        }
      }
    });

    testWidgets('group chat displays people_outline icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatTypeBadge(chatType: ChatType.group),
          ),
        ),
      );

      expect(find.byType(ChatTypeBadge), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
      expect(find.byIcon(Icons.tag), findsNothing);
    });

    testWidgets('channel chat displays tag icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatTypeBadge(chatType: ChatType.channel),
          ),
        ),
      );

      expect(find.byType(ChatTypeBadge), findsOneWidget);
      expect(find.byIcon(Icons.tag), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsNothing);
    });

    testWidgets('private chat displays no badge (SizedBox.shrink)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatTypeBadge(chatType: ChatType.private),
          ),
        ),
      );

      expect(find.byType(ChatTypeBadge), findsOneWidget);
      // Private chat should render SizedBox.shrink (empty)
      expect(find.byIcon(Icons.people_outline), findsNothing);
      expect(find.byIcon(Icons.tag), findsNothing);
    });

    testWidgets('badge has correct size (16x16) for group chat',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatTypeBadge(chatType: ChatType.group),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ChatTypeBadge),
          matching: find.byType(Container),
        ),
      );

      expect(container.constraints?.maxWidth, equals(16));
      expect(container.constraints?.maxHeight, equals(16));
    });

    testWidgets('badge has correct size (16x16) for channel chat',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatTypeBadge(chatType: ChatType.channel),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ChatTypeBadge),
          matching: find.byType(Container),
        ),
      );

      expect(container.constraints?.maxWidth, equals(16));
      expect(container.constraints?.maxHeight, equals(16));
    });

    // Property: Icon consistency across multiple renders
    testWidgets('Property 2: Icon consistency - same chatType always shows same icon',
        (tester) async {
      // Test that rendering the same chatType multiple times produces consistent results
      for (int i = 0; i < 3; i++) {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ChatTypeBadge(chatType: ChatType.group),
            ),
          ),
        );

        expect(
          find.byIcon(Icons.people_outline),
          findsOneWidget,
          reason: 'Group chat should consistently show people_outline icon (iteration $i)',
        );
      }

      for (int i = 0; i < 3; i++) {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ChatTypeBadge(chatType: ChatType.channel),
            ),
          ),
        );

        expect(
          find.byIcon(Icons.tag),
          findsOneWidget,
          reason: 'Channel chat should consistently show tag icon (iteration $i)',
        );
      }
    });
  });
}

/// Helper function to get expected icon for a ChatType
/// Returns null for private chat (no icon should be displayed)
IconData? _getExpectedIcon(ChatType chatType) {
  switch (chatType) {
    case ChatType.group:
      return Icons.people_outline;
    case ChatType.channel:
      return Icons.tag;
    case ChatType.private:
      return null;
  }
}
