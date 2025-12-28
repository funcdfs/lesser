import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesser/features/chat/presentation/widgets/notify.dart';

/// Widget tests for NotificationBar component.
/// Tests four notification entries rendering and tap callbacks.
/// Requirements: 1.1, 1.2, 1.5
void main() {
  /// Helper to wrap widget with MaterialApp for testing
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('NotificationBar Rendering', () {
    testWidgets('renders four notification entries', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const NotificationBar()),
      );

      // Verify all four labels are displayed
      expect(find.text('喜欢'), findsOneWidget);
      expect(find.text('回复'), findsOneWidget);
      expect(find.text('收藏'), findsOneWidget);
      expect(find.text('关注'), findsOneWidget);
    });

    testWidgets('renders correct icons for each entry', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const NotificationBar()),
      );

      // Verify all four icons are displayed
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
      expect(find.byIcon(Icons.person_add_alt_1_outlined), findsOneWidget);
    });

    testWidgets('renders icon containers with correct size', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const NotificationBar()),
      );

      // Find all Container widgets that are 56x56
      final containers = tester.widgetList<Container>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.constraints?.maxWidth == 56 &&
              widget.constraints?.maxHeight == 56,
        ),
      );

      // Should have 4 icon containers
      expect(containers.length, equals(4));
    });
  });

  group('NotificationBar Tap Callbacks', () {
    testWidgets('calls onTap with likes type when 喜欢 is tapped', (
      tester,
    ) async {
      NotificationType? tappedType;
      await tester.pumpWidget(
        createTestWidget(
          NotificationBar(onTap: (type) => tappedType = type),
        ),
      );

      await tester.tap(find.text('喜欢'));
      await tester.pump();

      expect(tappedType, equals(NotificationType.likes));
    });

    testWidgets('calls onTap with replies type when 回复 is tapped', (
      tester,
    ) async {
      NotificationType? tappedType;
      await tester.pumpWidget(
        createTestWidget(
          NotificationBar(onTap: (type) => tappedType = type),
        ),
      );

      await tester.tap(find.text('回复'));
      await tester.pump();

      expect(tappedType, equals(NotificationType.replies));
    });

    testWidgets('calls onTap with bookmarks type when 收藏 is tapped', (
      tester,
    ) async {
      NotificationType? tappedType;
      await tester.pumpWidget(
        createTestWidget(
          NotificationBar(onTap: (type) => tappedType = type),
        ),
      );

      await tester.tap(find.text('收藏'));
      await tester.pump();

      expect(tappedType, equals(NotificationType.bookmarks));
    });

    testWidgets('calls onTap with follows type when 关注 is tapped', (
      tester,
    ) async {
      NotificationType? tappedType;
      await tester.pumpWidget(
        createTestWidget(
          NotificationBar(onTap: (type) => tappedType = type),
        ),
      );

      await tester.tap(find.text('关注'));
      await tester.pump();

      expect(tappedType, equals(NotificationType.follows));
    });

    testWidgets('does not throw when onTap is null', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const NotificationBar()),
      );

      // Should not throw when tapped without callback
      await tester.tap(find.text('喜欢'));
      await tester.pump();
    });
  });
}
