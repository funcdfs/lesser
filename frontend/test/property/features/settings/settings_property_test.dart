import 'package:flutter/material.dart';
import 'package:glados/glados.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lesser/features/settings/data/settings_repository.dart';
import 'package:lesser/features/settings/domain/models/user_settings.dart';

/// Property-based tests for Settings Persistence
/// Feature: frontend-code-improvement, Property 6: Settings Persistence Round-Trip
/// Validates: Requirements 8.3, 8.5

void main() {
  group('Settings Persistence - Property Tests', () {
    late SettingsRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = SettingsRepository(prefs);
    });

    // Property 6a: Settings round-trip persistence
    // For any valid UserSettings object, storing then reading SHALL return
    // an equivalent object
    Glados2(any.intInRange(0, 2), any.bool).test(
      'Property 6a: Settings round-trip preserves all fields',
      (themeModeIndex, notificationsEnabled) async {
        final themeMode = ThemeMode.values[themeModeIndex];
        final languages = ['zh', 'en', 'ja', 'ko'];
        final language = languages[themeModeIndex % languages.length];

        final settings = UserSettings(
          themeMode: themeMode,
          notificationsEnabled: notificationsEnabled,
          language: language,
        );

        // Save settings
        await repository.saveSettings(settings);

        // Read back settings
        final retrievedSettings = repository.getSettings();

        // Verify all fields match
        expect(retrievedSettings.themeMode, equals(settings.themeMode));
        expect(
          retrievedSettings.notificationsEnabled,
          equals(settings.notificationsEnabled),
        );
        expect(retrievedSettings.language, equals(settings.language));
      },
    );

    // Property 6b: ThemeMode round-trip
    // For any ThemeMode, setting then getting SHALL return the same mode
    test('Property 6b: ThemeMode round-trip for all modes', () async {
      for (final mode in ThemeMode.values) {
        await repository.setThemeMode(mode);
        final retrievedMode = repository.getThemeMode();
        expect(
          retrievedMode,
          equals(mode),
          reason: 'ThemeMode $mode should round-trip correctly',
        );
      }
    });

    // Property 6c: Default settings when none saved
    test('Property 6c: Default settings returned when none saved', () {
      final settings = repository.getSettings();

      expect(settings.themeMode, equals(ThemeMode.system));
      expect(settings.notificationsEnabled, isTrue);
      expect(settings.language, equals('zh'));
    });

    // Property 6d: setThemeMode updates settings object
    test('Property 6d: setThemeMode updates settings object', () async {
      // First save some settings
      const initialSettings = UserSettings(
        themeMode: ThemeMode.light,
        notificationsEnabled: true,
        language: 'en',
      );
      await repository.saveSettings(initialSettings);

      // Change theme mode
      await repository.setThemeMode(ThemeMode.dark);

      // Verify settings object is updated
      final settings = repository.getSettings();
      expect(settings.themeMode, equals(ThemeMode.dark));
      // Other fields should remain unchanged
      expect(settings.notificationsEnabled, isTrue);
      expect(settings.language, equals('en'));
    });

    // Property 6e: Settings serialization produces valid JSON
    test('Property 6e: UserSettings toJson produces valid structure', () {
      const settings = UserSettings(
        themeMode: ThemeMode.dark,
        notificationsEnabled: false,
        language: 'en',
      );

      final json = settings.toJson();

      expect(json['theme_mode'], equals('dark'));
      expect(json['notifications_enabled'], equals(false));
      expect(json['language'], equals('en'));
    });

    // Property 6f: Settings deserialization handles all theme modes
    test('Property 6f: UserSettings fromJson handles all theme modes', () {
      final themeModes = ['light', 'dark', 'system'];
      final expectedModes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];

      for (var i = 0; i < themeModes.length; i++) {
        final json = {
          'theme_mode': themeModes[i],
          'notifications_enabled': true,
          'language': 'zh',
        };

        final settings = UserSettings.fromJson(json);
        expect(
          settings.themeMode,
          equals(expectedModes[i]),
          reason: 'Theme mode ${themeModes[i]} should deserialize correctly',
        );
      }
    });
  });
}
