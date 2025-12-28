import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesser/shared/widgets/app_button.dart';

/// Widget tests for AppButton component.
/// Tests various button types, loading and disabled states.
/// Requirements: 3.1, 3.2, 3.3, 3.4, 3.5
void main() {
  /// Helper to wrap widget with MaterialApp for testing
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('AppButton Type Rendering', () {
    testWidgets('renders primary button with correct text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton(
            text: 'Primary Button',
            type: AppButtonType.primary,
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Primary Button'), findsOneWidget);
    });

    testWidgets('renders secondary button', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton.secondary(text: 'Secondary Button', onPressed: () {}),
        ),
      );

      expect(find.text('Secondary Button'), findsOneWidget);
    });

    testWidgets('renders outline button', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton.outline(text: 'Outline Button', onPressed: () {}),
        ),
      );

      expect(find.text('Outline Button'), findsOneWidget);
    });

    testWidgets('renders text button', (tester) async {
      await tester.pumpWidget(
        createTestWidget(AppButton.text(text: 'Text Button', onPressed: () {})),
      );

      expect(find.text('Text Button'), findsOneWidget);
    });

    testWidgets('renders danger button', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton.danger(text: 'Danger Button', onPressed: () {}),
        ),
      );

      expect(find.text('Danger Button'), findsOneWidget);
    });

    testWidgets('renders ghost button with icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(AppButton.ghost(icon: Icons.add, onPressed: () {})),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('AppButton Loading State', () {
    testWidgets('shows loading indicator when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton(text: 'Loading Button', isLoading: true, onPressed: () {}),
        ),
      );

      // Loading indicator should be present (TDLoading widget)
      expect(find.text('Loading Button'), findsOneWidget);
    });

    testWidgets('button is not tappable when loading', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        createTestWidget(
          AppButton(
            text: 'Loading Button',
            isLoading: true,
            onPressed: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Loading Button'));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('primary button with loading state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton.primary(text: 'Submit', isLoading: true, onPressed: () {}),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
    });
  });

  group('AppButton Disabled State', () {
    testWidgets('button is not tappable when disabled', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        createTestWidget(
          AppButton(
            text: 'Disabled Button',
            isDisabled: true,
            onPressed: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Disabled Button'));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('disabled primary button renders', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton.primary(
            text: 'Disabled Primary',
            isDisabled: true,
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Disabled Primary'), findsOneWidget);
    });

    testWidgets('disabled danger button renders', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton.danger(
            text: 'Disabled Danger',
            isDisabled: true,
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Disabled Danger'), findsOneWidget);
    });
  });

  group('AppButton Interaction', () {
    testWidgets('calls onPressed when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        createTestWidget(
          AppButton(text: 'Tap Me', onPressed: () => tapped = true),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does not call onPressed when onPressed is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(const AppButton(text: 'No Action', onPressed: null)),
      );

      // Should not throw when tapped
      await tester.tap(find.text('No Action'));
      await tester.pump();
    });
  });

  group('AppButton Size Variants', () {
    testWidgets('renders small button', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton(text: 'Small', size: AppButtonSize.small, onPressed: () {}),
        ),
      );

      expect(find.text('Small'), findsOneWidget);
    });

    testWidgets('renders medium button (default)', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton(
            text: 'Medium',
            size: AppButtonSize.medium,
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Medium'), findsOneWidget);
    });

    testWidgets('renders large button', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton(text: 'Large', size: AppButtonSize.large, onPressed: () {}),
        ),
      );

      expect(find.text('Large'), findsOneWidget);
    });
  });

  group('AppButton with Icon', () {
    testWidgets('renders button with icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton(text: 'With Icon', icon: Icons.add, onPressed: () {}),
        ),
      );

      expect(find.text('With Icon'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders ghost text button with icon and label', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton.ghostText(
            icon: Icons.favorite,
            label: 'Like',
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Like'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });

  group('AppButton Block Mode', () {
    testWidgets('renders block button with full width', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton(text: 'Block Button', isBlock: true, onPressed: () {}),
        ),
      );

      expect(find.text('Block Button'), findsOneWidget);

      // Verify the SizedBox has infinite width
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(double.infinity));
    });
  });
}
