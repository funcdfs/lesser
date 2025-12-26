import 'package:glados/glados.dart';
import 'package:lesser/features/auth/domain/models/user.dart';

/// Property-based tests for User Model Serialization
/// Feature: frontend-code-improvement, Property 1: Model Serialization Round-Trip
/// Validates: Requirements 2.3

void main() {
  group('User Model - Property-Based Serialization Tests', () {
    // Property 1: Model Serialization Round-Trip
    // For any valid User object, serializing to JSON and deserializing back
    // SHALL produce an equivalent object.
    Glados2(any.positiveIntOrZero, any.lowercaseLetters).test(
      'Property 1: User serialization round-trip - toJson then fromJson returns equivalent object',
      (id, username) {
        // Create a user with generated values
        final user = User(
          id: id,
          username: username.isEmpty ? 'user' : username,
          email: '${username.isEmpty ? 'user' : username}@example.com',
          firstName: username.isEmpty ? null : 'First$username',
          lastName: username.isEmpty ? null : 'Last$username',
        );

        // Act: Serialize to JSON and deserialize back
        final json = user.toJson();
        final reconstructedUser = User.fromJson(json);

        // Assert: The reconstructed user should equal the original
        expect(reconstructedUser, equals(user));
        expect(reconstructedUser.id, equals(user.id));
        expect(reconstructedUser.username, equals(user.username));
        expect(reconstructedUser.email, equals(user.email));
        expect(reconstructedUser.firstName, equals(user.firstName));
        expect(reconstructedUser.lastName, equals(user.lastName));
      },
    );

    // Additional example-based tests for specific edge cases
    test('User with null optional fields should round-trip correctly', () {
      const originalUser = User(
        id: 2,
        username: 'user2',
        email: 'user2@test.com',
        firstName: null,
        lastName: null,
      );

      final json = originalUser.toJson();
      final reconstructedUser = User.fromJson(json);

      expect(reconstructedUser, equals(originalUser));
      expect(reconstructedUser.firstName, isNull);
      expect(reconstructedUser.lastName, isNull);
    });

    test('toJson should produce valid JSON structure with snake_case keys', () {
      const user = User(
        id: 10,
        username: 'johnsmith',
        email: 'john@example.com',
        firstName: 'John',
        lastName: 'Smith',
      );

      final json = user.toJson();

      expect(json['id'], equals(10));
      expect(json['username'], equals('johnsmith'));
      expect(json['email'], equals('john@example.com'));
      expect(json['first_name'], equals('John'));
      expect(json['last_name'], equals('Smith'));
    });

    test('fromJson should handle snake_case keys correctly', () {
      final json = {
        'id': 42,
        'username': 'johndoe',
        'email': 'john@example.com',
        'first_name': 'John',
        'last_name': 'Doe',
      };

      final user = User.fromJson(json);

      expect(user.id, equals(42));
      expect(user.username, equals('johndoe'));
      expect(user.email, equals('john@example.com'));
      expect(user.firstName, equals('John'));
      expect(user.lastName, equals('Doe'));
    });
  });
}
