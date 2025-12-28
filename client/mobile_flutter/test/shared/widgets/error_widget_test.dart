import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/shared/widgets/error_widget.dart';

void main() {
  group('AppErrorWidget', () {
    testWidgets('should display default error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(),
          ),
        ),
      );

      expect(find.text('An error occurred'), findsOneWidget);
    });

    testWidgets('should display custom error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(message: 'Custom error'),
          ),
        ),
      );

      expect(find.text('Custom error'), findsOneWidget);
    });

    testWidgets('should display error icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display custom icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(icon: Icons.warning),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('should show retry button when onRetry is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(onRetry: () {}),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should not show retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(),
          ),
        ),
      );

      expect(find.text('Retry'), findsNothing);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('should call onRetry when retry button is tapped', (tester) async {
      bool retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(
              onRetry: () {
                retryCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      expect(retryCalled, true);
    });
  });

  group('EmptyStateWidget', () {
    testWidgets('should display message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(message: 'No items found'),
          ),
        ),
      );

      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('should display default icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(message: 'Empty'),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('should display custom icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              message: 'Empty',
              icon: Icons.search_off,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('should show action button when action and label provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              message: 'Empty',
              action: () {},
              actionLabel: 'Add Item',
            ),
          ),
        ),
      );

      expect(find.text('Add Item'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should call action when button is tapped', (tester) async {
      bool actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              message: 'Empty',
              action: () {
                actionCalled = true;
              },
              actionLabel: 'Add Item',
            ),
          ),
        ),
      );

      await tester.tap(find.text('Add Item'));
      expect(actionCalled, true);
    });
  });
}
