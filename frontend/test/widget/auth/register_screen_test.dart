import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesser/core/validation/validators.dart';

/// Tests for register screen validation logic and UI patterns.
/// Note: Full widget tests for RegisterScreen are pending forui API migration.
void main() {
  group('Register Validation Logic', () {
    test('validates empty username', () {
      final result = Validators.validateUsername('');
      expect(result, isNotNull);
    });

    test('validates username with invalid characters', () {
      final result = Validators.validateUsername('user@name');
      expect(result, isNotNull);
      expect(result, contains('字母'));
    });

    test('validates username too long', () {
      final result = Validators.validateUsername('a' * 25);
      expect(result, isNotNull);
      expect(result, contains('20'));
    });

    test('validates valid username with underscore', () {
      final result = Validators.validateUsername('valid_user_123');
      expect(result, isNull);
    });

    test('validates empty email', () {
      final result = Validators.validateEmail('');
      expect(result, isNotNull);
    });

    test('validates email without domain', () {
      final result = Validators.validateEmail('test@');
      expect(result, isNotNull);
    });

    test('validates email without @', () {
      final result = Validators.validateEmail('testexample.com');
      expect(result, isNotNull);
    });

    test('validates valid email', () {
      final result = Validators.validateEmail('user@example.com');
      expect(result, isNull);
    });

    test('validates password confirmation mismatch', () {
      final result = Validators.validatePasswordConfirm(
        'password123',
        'differentpassword',
      );
      expect(result, isNotNull);
      expect(result, contains('不一致'));
    });

    test('validates password confirmation match', () {
      final result = Validators.validatePasswordConfirm(
        'password123',
        'password123',
      );
      expect(result, isNull);
    });

    test('validates empty password confirmation', () {
      final result = Validators.validatePasswordConfirm(
        'password123',
        '',
      );
      expect(result, isNotNull);
    });
  });

  group('Register Error Display Pattern', () {
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

    testWidgets('displays username validation error', (tester) async {
      const errorMessage = '用户名至少需要 3 个字符';
      await tester.pumpWidget(createErrorDisplay(errorMessage));

      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays email validation error', (tester) async {
      const errorMessage = '请输入有效的邮箱地址';
      await tester.pumpWidget(createErrorDisplay(errorMessage));

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('displays password mismatch error', (tester) async {
      const errorMessage = '两次输入的密码不一致';
      await tester.pumpWidget(createErrorDisplay(errorMessage));

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('displays server error message', (tester) async {
      const errorMessage = '邮箱已被注册';
      await tester.pumpWidget(createErrorDisplay(errorMessage));

      expect(find.text(errorMessage), findsOneWidget);
    });
  });

  group('Register Form UI Elements', () {
    testWidgets('renders register button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text('注册'),
            ),
          ),
        ),
      );

      expect(find.text('注册'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('renders login link', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                const Text('已有账号？'),
                TextButton(
                  onPressed: () {},
                  child: const Text('立即登录'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('已有账号？'), findsOneWidget);
      expect(find.text('立即登录'), findsOneWidget);
    });

    testWidgets('renders password visibility toggle', (tester) async {
      bool obscure = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => obscure = !obscure),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('renders app branding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text(
                  'Lesser',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '记录生活的每一个瞬间',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Lesser'), findsOneWidget);
      expect(find.text('记录生活的每一个瞬间'), findsOneWidget);
    });
  });
}
