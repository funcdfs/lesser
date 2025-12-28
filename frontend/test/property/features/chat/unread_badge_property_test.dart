import 'dart:math';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_test/flutter_test.dart';
import 'package:lesser/features/chat/presentation/widgets/chat_item.dart';
import 'package:lesser/shared/widgets/chip.dart';
import 'package:lesser/shared/theme/theme.dart';

/// Property-based tests for UnreadBadge Display Logic
/// Feature: message-page-ui-refactor, Property 3: Unread Badge Display Logic
/// Validates: Requirements 2.8, 2.9

void main() {
  group('UnreadBadge - Property 3: Unread Badge Display Logic', () {
    /// **Feature: message-page-ui-refactor, Property 3: Unread Badge Display Logic**
    /// **Validates: Requirements 2.8, 2.9**
    ///
    /// *For any* ChatItem:
    /// - IF unreadCount > 0, THEN UnreadBadge SHALL be visible
    /// - IF unreadCount > 99, THEN UnreadBadge text SHALL be "99+"
    /// - IF unreadCount <= 0, THEN UnreadBadge SHALL NOT be visible

    // Property test: formatUnreadCount function correctness
    group('formatUnreadCount function', () {
      test('Property 3.1: For all counts <= 0, returns empty string', () {
        // Test boundary and negative values
        final testValues = [0, -1, -10, -100, -999];
        for (final count in testValues) {
          expect(
            formatUnreadCount(count),
            equals(''),
            reason: 'formatUnreadCount($count) should return empty string',
          );
        }
      });

      test('Property 3.2: For all counts 1-99, returns exact count string', () {
        // Test all values from 1 to 99
        for (int count = 1; count <= 99; count++) {
          expect(
            formatUnreadCount(count),
            equals(count.toString()),
            reason: 'formatUnreadCount($count) should return "$count"',
          );
        }
      });

      test('Property 3.3: For all counts > 99, returns "99+"', () {
        // Test boundary and large values
        final testValues = [100, 101, 150, 200, 500, 999, 1000, 9999];
        for (final count in testValues) {
          expect(
            formatUnreadCount(count),
            equals('99+'),
            reason: 'formatUnreadCount($count) should return "99+"',
          );
        }
      });

      test('Property 3.4: Random values follow the same rules', () {
        // Property-based test with random values
        final random = Random(42); // Fixed seed for reproducibility
        
        for (int i = 0; i < 100; i++) {
          // Generate random count from -100 to 500
          final count = random.nextInt(600) - 100;
          final result = formatUnreadCount(count);
          
          if (count <= 0) {
            expect(
              result,
              equals(''),
              reason: 'formatUnreadCount($count) should return empty string',
            );
          } else if (count > 99) {
            expect(
              result,
              equals('99+'),
              reason: 'formatUnreadCount($count) should return "99+"',
            );
          } else {
            expect(
              result,
              equals(count.toString()),
              reason: 'formatUnreadCount($count) should return "$count"',
            );
          }
        }
      });
    });

    // Widget tests for ChatItem unread badge visibility
    group('ChatItem unread badge visibility', () {
      testWidgets('Property 3.5: unreadCount = 0 shows no badge', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChatItem(
                icon: Icons.person,
                iconColor: AppColors.foreground,
                title: 'Test Chat',
                subtitle: 'Last message',
                time: '12:00',
                unreadCount: 0,
                chatType: ChatType.private,
              ),
            ),
          ),
        );

        expect(find.byType(Badge), findsNothing);
      });

      testWidgets('Property 3.6: unreadCount > 0 shows badge', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChatItem(
                icon: Icons.person,
                iconColor: AppColors.foreground,
                title: 'Test Chat',
                subtitle: 'Last message',
                time: '12:00',
                unreadCount: 5,
                chatType: ChatType.private,
              ),
            ),
          ),
        );

        expect(find.byType(Badge), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
      });

      testWidgets('Property 3.7: unreadCount = 99 shows "99"', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChatItem(
                icon: Icons.person,
                iconColor: AppColors.foreground,
                title: 'Test Chat',
                subtitle: 'Last message',
                time: '12:00',
                unreadCount: 99,
                chatType: ChatType.private,
              ),
            ),
          ),
        );

        expect(find.byType(Badge), findsOneWidget);
        expect(find.text('99'), findsOneWidget);
      });

      testWidgets('Property 3.8: unreadCount = 100 shows "99+"', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChatItem(
                icon: Icons.person,
                iconColor: AppColors.foreground,
                title: 'Test Chat',
                subtitle: 'Last message',
                time: '12:00',
                unreadCount: 100,
                chatType: ChatType.private,
              ),
            ),
          ),
        );

        expect(find.byType(Badge), findsOneWidget);
        expect(find.text('99+'), findsOneWidget);
      });

      testWidgets('Property 3.9: unreadCount = 500 shows "99+"', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChatItem(
                icon: Icons.person,
                iconColor: AppColors.foreground,
                title: 'Test Chat',
                subtitle: 'Last message',
                time: '12:00',
                unreadCount: 500,
                chatType: ChatType.private,
              ),
            ),
          ),
        );

        expect(find.byType(Badge), findsOneWidget);
        expect(find.text('99+'), findsOneWidget);
      });

      testWidgets('Property 3.10: badge uses AppColors.info background when not muted',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChatItem(
                icon: Icons.person,
                iconColor: AppColors.foreground,
                title: 'Test Chat',
                subtitle: 'Last message',
                time: '12:00',
                unreadCount: 5,
                isMuted: false,
                chatType: ChatType.private,
              ),
            ),
          ),
        );

        final badge = tester.widget<Badge>(find.byType(Badge));
        expect(badge.backgroundColor, equals(AppColors.info));
      });

      testWidgets('Property 3.11: badge uses AppColors.mutedForeground when muted',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChatItem(
                icon: Icons.person,
                iconColor: AppColors.foreground,
                title: 'Test Chat',
                subtitle: 'Last message',
                time: '12:00',
                unreadCount: 5,
                isMuted: true,
                chatType: ChatType.private,
              ),
            ),
          ),
        );

        final badge = tester.widget<Badge>(find.byType(Badge));
        expect(badge.backgroundColor, equals(AppColors.mutedForeground));
      });
    });

    // Property test: Consistency across multiple random values
    test('Property 3.12: formatUnreadCount is idempotent', () {
      // Calling formatUnreadCount multiple times with the same input
      // should always produce the same output
      final random = Random(123);
      
      for (int i = 0; i < 50; i++) {
        final count = random.nextInt(300) - 50;
        final result1 = formatUnreadCount(count);
        final result2 = formatUnreadCount(count);
        final result3 = formatUnreadCount(count);
        
        expect(result1, equals(result2));
        expect(result2, equals(result3));
      }
    });
  });
}
