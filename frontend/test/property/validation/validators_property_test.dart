import 'package:glados/glados.dart';
import 'package:lesser/core/validation/validation_rules.dart';
import 'package:lesser/core/validation/validators.dart';

/// Property-based tests for Input Validation Correctness
/// Feature: frontend-code-improvement, Property 2: Input Validation Correctness
/// Validates: Requirements 4.1, 4.2, 4.3, 4.5

void main() {
  group('Email Validation - Property Tests', () {
    // Property 2a: Valid emails pass validation
    // For any valid email format, validateEmail SHALL return null
    test('Valid email formats pass validation', () {
      final validEmails = [
        'test@example.com',
        'user.name@domain.org',
        'user+tag@example.co.uk',
        'a@b.co',
        'test123@test-domain.com',
      ];

      for (final email in validEmails) {
        expect(
          Validators.validateEmail(email),
          isNull,
          reason: 'Email "$email" should be valid',
        );
      }
    });

    // Property 2b: Invalid emails are rejected
    // For any invalid email format, validateEmail SHALL return non-null error
    test('Invalid email formats are rejected', () {
      final invalidEmails = [
        '',
        'notanemail',
        '@nodomain.com',
        'no@',
        'spaces in@email.com',
        'missing.domain@',
      ];

      for (final email in invalidEmails) {
        expect(
          Validators.validateEmail(email),
          isNotNull,
          reason: 'Email "$email" should be invalid',
        );
      }
    });

    // Property: Empty/null emails are rejected
    test('Empty and null emails are rejected', () {
      expect(Validators.validateEmail(null), isNotNull);
      expect(Validators.validateEmail(''), isNotNull);
    });
  });

  group('Username Validation - Property Tests', () {
    // Property 2c: Valid usernames pass validation
    Glados(any.lowercaseLetters).test(
      'Property 2c: Valid alphanumeric usernames pass validation',
      (letters) {
        // Ensure username meets minimum length
        final username = letters.length < ValidationRules.minUsernameLength
            ? 'usr${letters}'
            : letters.length > ValidationRules.maxUsernameLength
                ? letters.substring(0, ValidationRules.maxUsernameLength)
                : letters;

        // Only test if username is valid format (letters only)
        if (username.isNotEmpty && 
            username.length >= ValidationRules.minUsernameLength &&
            username.length <= ValidationRules.maxUsernameLength) {
          expect(
            Validators.validateUsername(username),
            isNull,
            reason: 'Username "$username" should be valid',
          );
        }
      },
    );

    // Property 2d: Usernames with valid characters pass
    test('Usernames with underscores and numbers pass validation', () {
      final validUsernames = [
        'user_name',
        'user123',
        'User_Name_123',
        'abc',
        '_underscore_',
      ];

      for (final username in validUsernames) {
        expect(
          Validators.validateUsername(username),
          isNull,
          reason: 'Username "$username" should be valid',
        );
      }
    });

    // Property 2e: Usernames too short are rejected
    test('Usernames shorter than minimum length are rejected', () {
      final shortUsernames = ['a', 'ab'];

      for (final username in shortUsernames) {
        expect(
          Validators.validateUsername(username),
          isNotNull,
          reason: 'Username "$username" should be too short',
        );
      }
    });

    // Property 2f: Usernames too long are rejected
    test('Usernames longer than maximum length are rejected', () {
      final longUsername = 'a' * (ValidationRules.maxUsernameLength + 1);
      expect(
        Validators.validateUsername(longUsername),
        isNotNull,
        reason: 'Username should be too long',
      );
    });

    // Property 2g: Usernames with invalid characters are rejected
    test('Usernames with special characters are rejected', () {
      final invalidUsernames = [
        'user@name',
        'user name',
        'user-name',
        'user.name',
        'user!name',
      ];

      for (final username in invalidUsernames) {
        expect(
          Validators.validateUsername(username),
          isNotNull,
          reason: 'Username "$username" should be invalid',
        );
      }
    });

    // Property: Empty/null usernames are rejected
    test('Empty and null usernames are rejected', () {
      expect(Validators.validateUsername(null), isNotNull);
      expect(Validators.validateUsername(''), isNotNull);
    });
  });

  group('Password Validation - Property Tests', () {
    // Property 2h: Valid passwords pass validation
    test('Valid passwords with letters and numbers pass validation', () {
      final validPasswords = [
        'password1',
        'Password123',
        'abc12345',
        'Test1234',
        'a1b2c3d4',
      ];

      for (final password in validPasswords) {
        expect(
          Validators.validatePassword(password),
          isNull,
          reason: 'Password "$password" should be valid',
        );
      }
    });

    // Property 2i: Passwords too short are rejected
    Glados(any.lowercaseLetters).test(
      'Property 2i: Passwords shorter than minimum length are rejected',
      (letters) {
        // Create a password that's too short (less than 8 chars)
        final shortPassword = letters.length < ValidationRules.minPasswordLength
            ? letters
            : letters.substring(0, ValidationRules.minPasswordLength - 1);

        if (shortPassword.isNotEmpty && 
            shortPassword.length < ValidationRules.minPasswordLength) {
          expect(
            Validators.validatePassword(shortPassword),
            isNotNull,
            reason: 'Password "$shortPassword" should be too short',
          );
        }
      },
    );

    // Property 2j: Passwords without letters are rejected
    test('Passwords without letters are rejected', () {
      final noLetterPasswords = [
        '12345678',
        '123456789',
        '!@#\$%^&*',
      ];

      for (final password in noLetterPasswords) {
        expect(
          Validators.validatePassword(password),
          isNotNull,
          reason: 'Password "$password" should require letters',
        );
      }
    });

    // Property 2k: Passwords without numbers are rejected
    test('Passwords without numbers are rejected', () {
      final noNumberPasswords = [
        'abcdefgh',
        'Password',
        'NoNumbers',
      ];

      for (final password in noNumberPasswords) {
        expect(
          Validators.validatePassword(password),
          isNotNull,
          reason: 'Password "$password" should require numbers',
        );
      }
    });

    // Property: Empty/null passwords are rejected
    test('Empty and null passwords are rejected', () {
      expect(Validators.validatePassword(null), isNotNull);
      expect(Validators.validatePassword(''), isNotNull);
    });
  });

  group('Post Content Validation - Property Tests', () {
    // Property 2l: Valid content passes validation
    Glados(any.lowercaseLetters).test(
      'Property 2l: Non-empty content passes validation',
      (content) {
        // Ensure content is not empty and within limits
        final validContent = content.isEmpty ? 'test content' : content;
        final truncatedContent = validContent.length > ValidationRules.maxPostContentLength
            ? validContent.substring(0, ValidationRules.maxPostContentLength)
            : validContent;

        expect(
          Validators.validatePostContent(truncatedContent),
          isNull,
          reason: 'Content "$truncatedContent" should be valid',
        );
      },
    );

    // Property 2m: Whitespace-only content is rejected
    test('Whitespace-only content is rejected', () {
      final whitespaceContent = [
        ' ',
        '  ',
        '\t',
        '\n',
        '   \t\n   ',
      ];

      for (final content in whitespaceContent) {
        expect(
          Validators.validatePostContent(content),
          isNotNull,
          reason: 'Whitespace-only content should be rejected',
        );
      }
    });

    // Property 2n: Empty/null content is rejected
    test('Empty and null content is rejected', () {
      expect(Validators.validatePostContent(null), isNotNull);
      expect(Validators.validatePostContent(''), isNotNull);
    });

    // Property 2o: Content exceeding max length is rejected
    test('Content exceeding maximum length is rejected', () {
      final longContent = 'a' * (ValidationRules.maxPostContentLength + 1);
      expect(
        Validators.validatePostContent(longContent),
        isNotNull,
        reason: 'Content exceeding max length should be rejected',
      );
    });
  });

  group('Password Confirmation Validation', () {
    test('Matching passwords pass validation', () {
      expect(
        Validators.validatePasswordConfirm('password123', 'password123'),
        isNull,
      );
    });

    test('Non-matching passwords are rejected', () {
      expect(
        Validators.validatePasswordConfirm('password123', 'different123'),
        isNotNull,
      );
    });

    test('Empty confirmation is rejected', () {
      expect(
        Validators.validatePasswordConfirm('password123', ''),
        isNotNull,
      );
      expect(
        Validators.validatePasswordConfirm('password123', null),
        isNotNull,
      );
    });
  });
}
