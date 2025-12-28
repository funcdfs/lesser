import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/features/auth/data/models/token_model.dart';

void main() {
  group('TokenModel', () {
    const testJson = {
      'access': 'access_token_123',
      'refresh': 'refresh_token_456',
    };

    const testTokenModel = TokenModel(
      accessToken: 'access_token_123',
      refreshToken: 'refresh_token_456',
    );

    group('fromJson', () {
      test('should return a valid model from JSON', () {
        // Act
        final result = TokenModel.fromJson(testJson);

        // Assert
        expect(result.accessToken, 'access_token_123');
        expect(result.refreshToken, 'refresh_token_456');
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // Act
        final result = testTokenModel.toJson();

        // Assert
        expect(result['access'], 'access_token_123');
        expect(result['refresh'], 'refresh_token_456');
      });
    });

    test('should have correct properties', () {
      expect(testTokenModel.accessToken, 'access_token_123');
      expect(testTokenModel.refreshToken, 'refresh_token_456');
    });
  });
}
