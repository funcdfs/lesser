import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesser/core/validation/validators.dart';

/// Tests for login screen validation logic and UI patterns.
/// Note: Full widget tests for LoginScreen are pending forui API migration.
void main() {
  group('Login Validation Logic', () {
    test('validates empty username', () {
      final result = Validators.validateUsername('');
      expect(result, isNotNull);
      expect(result, contains('用户名'));
    });

    test('validates short username', () {
      final result = Validators.validateUsername('ab');
      expect(result, isNotNull);
      expect(result, contains('3'));
    });

    test('validates valid username', () {
      final result = Validators.validateUsername('validuser');
      expect(result, isNull);
    });

    test('validates empty password', () {
      final result = Validators.validatePassword('');
      expect(result, isNotNull);
      expect(result, contains('密码'));
    });

    test('validates short password', () {
      final result = Validators.validatePassword('short');
      expect(result, isNotNull);
      expect(result, contains('8'));
    });

    test('validates valid password', () {
      final result = Validators.validatePassword('password123');
      expect(result, isNull);
    });

    test('validates invalid email format', () {
      final result = Validators.validateEmail('invalid-email');
      expect(result, isNotNull);
      expect(result, contains('邮箱'));
    });

    test('validates valid email format', () {
      final result = Validators.validateEmail('test@example.com');
      expect(result, isNull);
    });
  });

  group('Login Error Display Pattern', () {
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

    testWidgets('displays username error message', (tester) async {
      const errorMessage = '请输入用户名或邮箱';
      await tester.pumpWidget(createErrorDisplay(errorMessage));

      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays password error message', (tester) async {
      const errorMessage = '密码长度至少为8个字符';
      await tester.pumpWidget(createErrorDisplay(errorMessage));

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('displays auth error message', (tester) async {
      const errorMessage = '用户名或密码错误';
      await tester.pumpWidget(createErrorDisplay(errorMessage));

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('error container has correct styling', (tester) async {
      await tester.pumpWidget(createErrorDisplay('Test error'));

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, equals(const Color(0xFFFFF5F5)));
      expect(decoration.borderRadius, equals(BorderRadius.circular(8)));
    });
  });

  group('Login Form UI Elements', () {
    testWidgets('renders login button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text('登录'),
            ),
          ),
        ),
      );

      expect(find.text('登录'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('renders register link', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                const Text('还没有账号？'),
                TextButton(
                  onPressed: () {},
                  child: const Text('立即注册'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('还没有账号？'), findsOneWidget);
      expect(find.text('立即注册'), findsOneWidget);
    });

    testWidgets('renders loading indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
