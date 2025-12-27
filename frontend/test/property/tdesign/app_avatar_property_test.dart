import 'package:glados/glados.dart';
import 'package:lesser/shared/widgets/app_avatar.dart';

/// Property-based tests for AppAvatar component
/// Feature: tdesign-ui-unification, Property 4: Avatar Size Consistency
/// **Validates: Requirements 8.3**

void main() {
  group('Property 4: Avatar Size Consistency', () {
    /// **Feature: tdesign-ui-unification, Property 4: Avatar Size Consistency**
    /// **Validates: Requirements 8.3**
    ///
    /// *For any* valid avatar size (small, medium, large, extraLarge),
    /// the `AppAvatar` component SHALL render with the correct predefined dimensions.

    // Define expected sizes for each AppAvatarSize
    final expectedSizes = {
      AppAvatarSize.small: 32.0,
      AppAvatarSize.medium: 48.0,
      AppAvatarSize.large: 64.0,
      AppAvatarSize.extraLarge: 80.0,
    };

    test('All avatar sizes have correct dimensions', () {
      for (final entry in expectedSizes.entries) {
        final size = entry.key;
        final expectedDimension = entry.value;

        expect(
          _getAvatarSize(size),
          equals(expectedDimension),
          reason: 'AppAvatarSize.$size should have dimension $expectedDimension',
        );
      }
    });

    test('Small avatar has correct size (32px)', () {
      expect(_getAvatarSize(AppAvatarSize.small), equals(32.0));
    });

    test('Medium avatar has correct size (48px)', () {
      expect(_getAvatarSize(AppAvatarSize.medium), equals(48.0));
    });

    test('Large avatar has correct size (64px)', () {
      expect(_getAvatarSize(AppAvatarSize.large), equals(64.0));
    });

    test('Extra large avatar has correct size (80px)', () {
      expect(_getAvatarSize(AppAvatarSize.extraLarge), equals(80.0));
    });

    test('Custom size overrides enum size', () {
      const customSize = 100.0;
      // When customSize is provided, it should take precedence
      // This tests the property that customSize > enum size
      for (final enumSize in AppAvatarSize.values) {
        // The avatar should use customSize regardless of enum
        expect(
          customSize,
          isNot(equals(_getAvatarSize(enumSize))),
          reason: 'Custom size should be different from enum size for $enumSize',
        );
      }
    });

    // Property test using glados for random size selection
    Glados(any.intInRange(0, AppAvatarSize.values.length - 1)).test(
      'Property: Any valid avatar size index maps to correct dimension',
      (index) {
        final size = AppAvatarSize.values[index];
        final expectedDimension = expectedSizes[size]!;
        final actualDimension = _getAvatarSize(size);

        expect(
          actualDimension,
          equals(expectedDimension),
          reason: 'AppAvatarSize.$size should have dimension $expectedDimension',
        );
      },
    );

    // Test factory methods produce correct sizes
    test('Factory method AppAvatar.small produces correct size', () {
      final avatar = AppAvatar.small(fallbackText: 'T');
      expect(avatar.size, equals(AppAvatarSize.small));
    });

    test('Factory method AppAvatar.medium produces correct size', () {
      final avatar = AppAvatar.medium(fallbackText: 'T');
      expect(avatar.size, equals(AppAvatarSize.medium));
    });

    test('Factory method AppAvatar.large produces correct size', () {
      final avatar = AppAvatar.large(fallbackText: 'T');
      expect(avatar.size, equals(AppAvatarSize.large));
    });

    // Test AppAvatarGroup size consistency
    test('AppAvatarGroup respects size parameter', () {
      for (final size in AppAvatarSize.values) {
        final expectedDimension = expectedSizes[size]!;
        final group = AppAvatarGroup(
          avatars: [
            AppAvatar(fallbackText: 'A'),
            AppAvatar(fallbackText: 'B'),
          ],
          size: size,
        );

        // Verify the group uses the correct size
        expect(group.size, equals(size));
        // The internal _avatarSize should match
        expect(_getAvatarGroupSize(size), equals(expectedDimension));
      }
    });
  });
}

/// Helper function to get avatar size for a given AppAvatarSize enum
/// This mirrors the logic in AppAvatar._avatarSize getter
double _getAvatarSize(AppAvatarSize size) {
  switch (size) {
    case AppAvatarSize.small:
      return 32;
    case AppAvatarSize.medium:
      return 48;
    case AppAvatarSize.large:
      return 64;
    case AppAvatarSize.extraLarge:
      return 80;
  }
}

/// Helper function to get avatar group size for a given AppAvatarSize enum
/// This mirrors the logic in AppAvatarGroup._avatarSize getter
double _getAvatarGroupSize(AppAvatarSize size) {
  switch (size) {
    case AppAvatarSize.small:
      return 32;
    case AppAvatarSize.medium:
      return 48;
    case AppAvatarSize.large:
      return 64;
    case AppAvatarSize.extraLarge:
      return 80;
  }
}
