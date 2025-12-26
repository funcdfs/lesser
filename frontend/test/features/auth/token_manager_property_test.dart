import 'package:flutter_test/flutter_test.dart' hide group, setUp, test, expect;
import 'package:glados/glados.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lesser/core/network/token_manager.dart';

/// Property-based tests for TokenManager
/// Feature: user-authentication, Property 8: Token Round-Trip
/// Validates: Requirements 6.3
void main() {
  // Set up SharedPreferences mock before each test
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TokenManager Property Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    // Property 8: Token Round-Trip
    // For any valid token string T, calling saveToken(T) followed by getToken()
    // SHALL return a value equal to T.
    Glados<String>(any.lowercaseLetters).test(
      'Property 8: Token Round-Trip - saveToken then getToken returns same token',
      (token) async {
        // Skip empty tokens
        if (token.isEmpty) return;

        // Reset SharedPreferences for each iteration
        SharedPreferences.setMockInitialValues({});

        // Save the token
        await TokenManager.saveToken(token);

        // Retrieve the token
        final retrieved = await TokenManager.getToken();

        // Verify round-trip
        expect(retrieved, equals(token));
      },
    );

    // Additional property test for token deletion
    Glados<String>(any.lowercaseLetters).test(
      'deleteToken clears the saved token',
      (token) async {
        // Skip empty tokens
        if (token.isEmpty) return;

        // Reset SharedPreferences for each iteration
        SharedPreferences.setMockInitialValues({});

        // Save a token
        await TokenManager.saveToken(token);

        // Delete the token
        await TokenManager.deleteToken();

        // Verify token is cleared
        final retrieved = await TokenManager.getToken();
        expect(retrieved, isNull);
      },
    );
  });
}
