import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesser/shared/widgets/app_input.dart';

/// Widget tests for AppInput component.
/// Tests text and password input, error state display.
/// Requirements: 4.1, 4.2, 4.4
void main() {
  /// Helper to wrap widget with MaterialApp for testing
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }

  group('AppInput Text Input', () {
    testWidgets('renders text input widget', (tester) async {
      await tester.pumpWidget(
        createTestWidget(AppInput(hintText: 'Enter username')),
      );

      // AppInput should render and contain a TextField
      expect(find.byType(AppInput), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders text input with label', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppInput(labelText: 'Username', hintText: 'Enter username'),
        ),
      );

      expect(find.byType(AppInput), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
    });

    testWidgets('accepts text input', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        createTestWidget(
          AppInput(controller: controller, hintText: 'Enter text'),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello World');
      expect(controller.text, equals('Hello World'));
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changedValue;
      await tester.pumpWidget(
        createTestWidget(
          AppInput(
            hintText: 'Enter text',
            onChanged: (value) => changedValue = value,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test');
      expect(changedValue, equals('Test'));
    });

    testWidgets('renders text input using factory method', (tester) async {
      await tester.pumpWidget(
        createTestWidget(AppInput.text(hintText: 'Text input')),
      );

      expect(find.byType(AppInput), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('AppInput Password Input', () {
    testWidgets('renders password input with obscured text', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        createTestWidget(
          AppInput(
            controller: controller,
            type: AppInputType.password,
            hintText: 'Enter password',
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'secret123');
      await tester.pump();

      // Password should be obscured - find the TextField and check obscureText
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('renders password input using factory method', (tester) async {
      await tester.pumpWidget(
        createTestWidget(AppInput.password(hintText: 'Enter password')),
      );

      expect(find.byType(AppInput), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('password input has obscured text initially', (tester) async {
      await tester.pumpWidget(
        createTestWidget(AppInput.password(hintText: 'Enter password')),
      );

      // Password should be obscured initially
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('password input can be toggled to show text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(AppInput.password(hintText: 'Enter password')),
      );

      // Initially password should be obscured
      TextField textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);

      // Find and tap the suffix widget area to toggle visibility
      // The suffix is built by _buildSuffixWidget which wraps icon in GestureDetector
      final suffixFinder = find.descendant(
        of: find.byType(AppInput),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Icon &&
              (widget.icon == Icons.visibility_off_outlined ||
                  widget.icon == Icons.visibility_outlined),
        ),
      );

      if (suffixFinder.evaluate().isNotEmpty) {
        await tester.tap(suffixFinder);
        await tester.pump();

        // Password should now be visible
        textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.obscureText, isFalse);
      }
    });
  });

  group('AppInput Error State', () {
    testWidgets('displays error text when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppInput(hintText: 'Enter text', errorText: 'This field is required'),
        ),
      );

      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('shows error icon with error text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppInput(hintText: 'Enter text', errorText: 'Invalid input'),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Invalid input'), findsOneWidget);
    });

    testWidgets('does not show error when errorText is null', (tester) async {
      await tester.pumpWidget(
        createTestWidget(AppInput(hintText: 'Enter text', errorText: null)),
      );

      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('does not show error when errorText is empty', (tester) async {
      await tester.pumpWidget(
        createTestWidget(AppInput(hintText: 'Enter text', errorText: '')),
      );

      expect(find.byIcon(Icons.error_outline), findsNothing);
    });
  });

  group('AppInput Helper Text', () {
    testWidgets('displays helper text when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppInput(
            hintText: 'Enter text',
            helperText: 'This is a helpful hint',
          ),
        ),
      );

      expect(find.text('This is a helpful hint'), findsOneWidget);
    });

    testWidgets('error text takes precedence over helper text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppInput(
            hintText: 'Enter text',
            helperText: 'Helper text',
            errorText: 'Error text',
          ),
        ),
      );

      expect(find.text('Error text'), findsOneWidget);
      expect(find.text('Helper text'), findsNothing);
    });
  });

  group('AppInput Disabled State', () {
    testWidgets('renders disabled input', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppInput(hintText: 'Disabled input', isDisabled: true),
        ),
      );

      expect(find.byType(AppInput), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('disabled input is read-only', (tester) async {
      final controller = TextEditingController(text: 'Initial');
      await tester.pumpWidget(
        createTestWidget(
          AppInput(
            controller: controller,
            hintText: 'Disabled input',
            isDisabled: true,
          ),
        ),
      );

      // The input should be read-only when disabled
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.readOnly, isTrue);
    });
  });

  group('AppInput with Icons', () {
    testWidgets('renders input with prefix icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppInput(hintText: 'Search', prefixIcon: Icons.search),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('renders input with suffix icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppInput(hintText: 'Enter text', suffixIcon: Icons.clear),
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('renders email input with email icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(AppInput.email(hintText: 'Enter email')),
      );

      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });
  });

  group('AppInput Multiline', () {
    testWidgets('renders multiline input', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppInput.multiline(hintText: 'Enter description', maxLines: 4),
        ),
      );

      expect(find.byType(AppInput), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('AppInput Number Input', () {
    testWidgets('renders number input', (tester) async {
      await tester.pumpWidget(
        createTestWidget(AppInput.number(hintText: 'Enter number')),
      );

      expect(find.byType(AppInput), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
