import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/features/auth/data/models/user_model.dart';
import 'package:mobile_flutter/features/auth/domain/entities/user.dart';

void main() {
  group('UserModel', () {
    const testJson = {
      'id': '1',
      'username': 'testuser',
      'email': 'test@example.com',
      'display_name': 'Test User',
      'avatar_url': 'https://example.com/avatar.png',
      'bio': 'Test bio',
      'created_at': '2024-01-01T00:00:00.000Z',
    };

    const testUserModel = UserModel(
      id: '1',
      username: 'testuser',
      email: 'test@example.com',
      displayName: 'Test User',
      avatarUrl: 'https://example.com/avatar.png',
      bio: 'Test bio',
      createdAt: null,
    );

    test('should be a subclass of User entity', () {
      expect(testUserModel, isA<User>());
    });

    group('fromJson', () {
      test('should return a valid model from JSON', () {
        // Act
        final result = UserModel.fromJson(testJson);

        // Assert
        expect(result.id, '1');
        expect(result.username, 'testuser');
        expect(result.email, 'test@example.com');
        expect(result.displayName, 'Test User');
        expect(result.avatarUrl, 'https://example.com/avatar.png');
        expect(result.bio, 'Test bio');
        expect(result.createdAt, isNotNull);
      });

      test('should handle null optional fields', () {
        // Arrange
        const minimalJson = {
          'id': '1',
          'username': 'testuser',
          'email': 'test@example.com',
        };

        // Act
        final result = UserModel.fromJson(minimalJson);

        // Assert
        expect(result.id, '1');
        expect(result.displayName, isNull);
        expect(result.avatarUrl, isNull);
        expect(result.bio, isNull);
        expect(result.createdAt, isNull);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // Arrange
        const userModel = UserModel(
          id: '1',
          username: 'testuser',
          email: 'test@example.com',
          displayName: 'Test User',
          avatarUrl: 'https://example.com/avatar.png',
          bio: 'Test bio',
        );

        // Act
        final result = userModel.toJson();

        // Assert
        expect(result['id'], '1');
        expect(result['username'], 'testuser');
        expect(result['email'], 'test@example.com');
        expect(result['display_name'], 'Test User');
        expect(result['avatar_url'], 'https://example.com/avatar.png');
        expect(result['bio'], 'Test bio');
      });

      test('should handle null values in JSON output', () {
        // Arrange
        const userModel = UserModel(
          id: '1',
          username: 'testuser',
          email: 'test@example.com',
        );

        // Act
        final result = userModel.toJson();

        // Assert
        expect(result['display_name'], isNull);
        expect(result['avatar_url'], isNull);
        expect(result['bio'], isNull);
      });
    });

    group('fromEntity', () {
      test('should create UserModel from User entity', () {
        // Arrange
        const user = User(
          id: '1',
          username: 'testuser',
          email: 'test@example.com',
          displayName: 'Test User',
        );

        // Act
        final result = UserModel.fromEntity(user);

        // Assert
        expect(result.id, user.id);
        expect(result.username, user.username);
        expect(result.email, user.email);
        expect(result.displayName, user.displayName);
      });
    });
  });
}
