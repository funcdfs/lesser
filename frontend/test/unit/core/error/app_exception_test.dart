import 'package:glados/glados.dart';
import 'package:lesser/core/error/app_exception.dart';
import 'package:lesser/core/error/error_handler.dart';

/// Property-based tests for Error Handling Consistency
/// Feature: frontend-code-improvement, Property 3: Error Handling Consistency
/// Validates: Requirements 3.2, 3.3

void main() {
  group('Error Handling - Property-Based Tests', () {
    // Property 3: Error Handling Consistency
    // For any HTTP status code, handleHttpError SHALL return an appropriate exception
    // with a non-empty userMessage.
    
    Glados(any.intInRange(100, 599)).test(
      'Property 3: All HTTP status codes map to exceptions with non-empty userMessage',
      (statusCode) {
        // Act: Convert status code to exception
        final exception = ErrorHandler.handleHttpError(statusCode);

        // Assert: Exception should have non-empty userMessage
        expect(exception, isA<AppException>());
        expect(exception.userMessage, isNotEmpty);
        expect(exception.message, isNotEmpty);
      },
    );

    Glados(any.intInRange(400, 499)).test(
      'Property 3a: Client error status codes (4xx) map to appropriate exceptions',
      (statusCode) {
        final exception = ErrorHandler.handleHttpError(statusCode);

        // All 4xx errors should be either NetworkException, AuthException, or ValidationException
        expect(
          exception,
          anyOf(
            isA<NetworkException>(),
            isA<AuthException>(),
            isA<ValidationException>(),
          ),
        );
        expect(exception.userMessage, isNotEmpty);
      },
    );

    Glados(any.intInRange(500, 599)).test(
      'Property 3b: Server error status codes (5xx) map to NetworkException',
      (statusCode) {
        final exception = ErrorHandler.handleHttpError(statusCode);

        // All 5xx errors should be NetworkException
        expect(exception, isA<NetworkException>());
        expect(exception.userMessage, isNotEmpty);
      },
    );
  });

  group('NetworkException - Property Tests', () {
    Glados(any.intInRange(100, 599)).test(
      'NetworkException.fromStatusCode always produces non-empty userMessage',
      (statusCode) {
        final exception = NetworkException.fromStatusCode(statusCode);

        expect(exception.userMessage, isNotEmpty);
        expect(exception.statusCode, equals(statusCode));
      },
    );

    test('NetworkException.connectionError has non-empty userMessage', () {
      final exception = NetworkException.connectionError();
      expect(exception.userMessage, isNotEmpty);
    });

    test('NetworkException.timeout has non-empty userMessage', () {
      final exception = NetworkException.timeout();
      expect(exception.userMessage, isNotEmpty);
    });
  });

  group('AuthException - Property Tests', () {
    test('All AuthErrorType values produce non-empty userMessage', () {
      for (final type in AuthErrorType.values) {
        final exception = AuthException(type: type);
        expect(exception.userMessage, isNotEmpty,
            reason: 'AuthErrorType.$type should have non-empty userMessage');
      }
    });

    test('AuthException with custom message uses custom message', () {
      const customMessage = 'Custom error message';
      final exception = AuthException(
        type: AuthErrorType.unknown,
        customMessage: customMessage,
      );
      expect(exception.userMessage, equals(customMessage));
    });
  });

  group('ValidationException - Property Tests', () {
    Glados2(any.lowercaseLetters, any.lowercaseLetters).test(
      'ValidationException with field errors has non-empty userMessage',
      (field, errorMsg) {
        // Ensure non-empty strings
        final fieldName = field.isEmpty ? 'field' : field;
        final errorMessage = errorMsg.isEmpty ? 'error' : errorMsg;
        
        final exception = ValidationException(
          fieldErrors: {fieldName: errorMessage},
        );

        expect(exception.userMessage, isNotEmpty);
        expect(exception.userMessage, equals(errorMessage));
      },
    );

    test('ValidationException with empty fieldErrors uses default message', () {
      final exception = ValidationException(fieldErrors: {});
      expect(exception.userMessage, isNotEmpty);
      expect(exception.userMessage, equals('数据验证失败'));
    });

    test('ValidationException with custom message uses custom message when fieldErrors empty', () {
      const customMessage = 'Custom validation error';
      final exception = ValidationException(
        fieldErrors: {},
        message: customMessage,
      );
      expect(exception.userMessage, equals(customMessage));
    });
  });

  group('Specific HTTP Status Code Mappings', () {
    test('401 maps to AuthException with tokenExpired', () {
      final exception = ErrorHandler.handleHttpError(401);
      expect(exception, isA<AuthException>());
      expect((exception as AuthException).type, equals(AuthErrorType.tokenExpired));
    });

    test('403 maps to AuthException with forbidden', () {
      final exception = ErrorHandler.handleHttpError(403);
      expect(exception, isA<AuthException>());
      expect((exception as AuthException).type, equals(AuthErrorType.forbidden));
    });

    test('404 maps to NetworkException', () {
      final exception = ErrorHandler.handleHttpError(404);
      expect(exception, isA<NetworkException>());
    });

    test('422 maps to ValidationException', () {
      final exception = ErrorHandler.handleHttpError(422);
      expect(exception, isA<ValidationException>());
    });

    test('500 maps to NetworkException', () {
      final exception = ErrorHandler.handleHttpError(500);
      expect(exception, isA<NetworkException>());
    });
  });

  group('ErrorHandler Utility Methods', () {
    test('getUserMessage returns userMessage for AppException', () {
      final exception = NetworkException(message: 'Test error');
      final message = ErrorHandler.getUserMessage(exception);
      expect(message, equals('Test error'));
    });

    test('getUserMessage returns default message for non-AppException', () {
      final exception = Exception('Generic error');
      final message = ErrorHandler.getUserMessage(exception);
      expect(message, equals('发生错误，请稍后重试'));
    });

    test('handleNetworkError returns same exception if already NetworkException', () {
      final original = NetworkException(message: 'Original');
      final result = ErrorHandler.handleNetworkError(original);
      expect(result, same(original));
    });

    test('handleNetworkError returns connectionError for other exceptions', () {
      final exception = Exception('Generic');
      final result = ErrorHandler.handleNetworkError(exception);
      expect(result.message, contains('网络连接'));
    });

    test('handleAuthError returns same exception if already AuthException', () {
      final original = AuthException(type: AuthErrorType.tokenExpired);
      final result = ErrorHandler.handleAuthError(original);
      expect(result, same(original));
    });

    test('handleAuthError returns unknown type for other exceptions', () {
      final exception = Exception('Generic');
      final result = ErrorHandler.handleAuthError(exception);
      expect(result.type, equals(AuthErrorType.unknown));
    });
  });
}
