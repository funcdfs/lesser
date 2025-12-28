import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/shared/widgets/custom_button.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('should display label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              onPressed: () {},
              label: 'Click Me',
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              onPressed: () {
                pressed = true;
              },
              label: 'Click Me',
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, true);
    });

    testWidgets('should show loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              onPressed: () {},
              label: 'Click Me',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Click Me'), findsNothing);
    });

    testWidgets('should be disabled when isEnabled is false', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              onPressed: () {
                pressed = true;
              },
              label: 'Click Me',
              isEnabled: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, false);
    });

    testWidgets('should display icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              onPressed: () {},
              label: 'Click Me',
              icon: Icons.add,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('SecondaryButton', () {
    testWidgets('should display label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryButton(
              onPressed: () {},
              label: 'Secondary',
            ),
          ),
        ),
      );

      expect(find.text('Secondary'), findsOneWidget);
    });

    testWidgets('should use OutlinedButton', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryButton(
              onPressed: () {},
              label: 'Secondary',
            ),
          ),
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('should show loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryButton(
              onPressed: () {},
              label: 'Secondary',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('AppTextButton', () {
    testWidgets('should display label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextButton(
              onPressed: () {},
              label: 'Text Button',
            ),
          ),
        ),
      );

      expect(find.text('Text Button'), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextButton(
              onPressed: () {
                pressed = true;
              },
              label: 'Text Button',
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextButton));
      expect(pressed, true);
    });

    testWidgets('should display icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextButton(
              onPressed: () {},
              label: 'Text Button',
              icon: Icons.info,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.info), findsOneWidget);
    });
  });

  group('BadgeIconButton', () {
    testWidgets('should display icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BadgeIconButton(
              icon: Icons.notifications,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('should display badge when badge > 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BadgeIconButton(
              icon: Icons.notifications,
              onPressed: () {},
              badge: 5,
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('should not display badge when badge is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BadgeIconButton(
              icon: Icons.notifications,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Only the icon should be present, no badge text
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('should display 99+ when badge > 99', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BadgeIconButton(
              icon: Icons.notifications,
              onPressed: () {},
              badge: 150,
            ),
          ),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BadgeIconButton(
              icon: Icons.notifications,
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      expect(pressed, true);
    });
  });
}
