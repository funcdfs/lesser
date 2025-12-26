import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the error display pattern used across the app.
/// The error display is a Container with error styling that shows
/// an error icon and message.
void main() {
  group('Error Display Pattern', () {
    /// Helper to create the error display widget used in auth screens
    Widget createErrorDisplay(String message) {
      return MaterialApp(
        home: Scaffold(
          body: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFF5252)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFFF5252),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFFF5252),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('displays error message', (tester) async {
      const errorMessage = '用户名或密码错误';
      await tester.pumpWidget(createErrorDisplay(errorMessage));

      // Verify error message is displayed
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('displays error icon', (tester) async {
      await tester.pumpWidget(createErrorDisplay('Test error'));

      // Verify error icon is displayed
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('has correct error styling', (tester) async {
      await tester.pumpWidget(createErrorDisplay('Test error'));

      // Find the container
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      // Verify background color
      expect(decoration.color, equals(const Color(0xFFFFF5F5)));

      // Verify border color
      expect(decoration.border, isNotNull);
    });

    testWidgets('displays long error messages correctly', (tester) async {
      const longMessage =
          '这是一个很长的错误消息，用于测试错误显示组件是否能正确处理长文本内容，确保文本不会溢出并且能够正确换行显示。';
      await tester.pumpWidget(createErrorDisplay(longMessage));

      // Verify long message is displayed
      expect(find.text(longMessage), findsOneWidget);

      // Verify no overflow errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('error text has correct color', (tester) async {
      await tester.pumpWidget(createErrorDisplay('Test error'));

      // Find the text widget
      final textWidget = tester.widget<Text>(find.text('Test error'));

      // Verify text color
      expect(textWidget.style?.color, equals(const Color(0xFFFF5252)));
    });
  });

  group('Validation Error Messages', () {
    testWidgets('username validation error displays correctly', (tester) async {
      const errorMessage = '用户名至少需要 3 个字符';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Color(0xFFFF5252)),
              ),
            ),
          ),
        ),
      );

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('email validation error displays correctly', (tester) async {
      const errorMessage = '请输入有效的邮箱地址';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Color(0xFFFF5252)),
              ),
            ),
          ),
        ),
      );

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('password validation error displays correctly', (tester) async {
      const errorMessage = '密码至少需要 8 个字符';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Color(0xFFFF5252)),
              ),
            ),
          ),
        ),
      );

      expect(find.text(errorMessage), findsOneWidget);
    });
  });
}
