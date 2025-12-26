import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lesser/features/settings/data/settings_repository.dart';
import 'package:lesser/features/settings/domain/models/user_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsRepository settingsRepository;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    settingsRepository = SettingsRepository(prefs);
  });

  group('SettingsRepository', () {
    group('getSettings', () {
      test('returns default settings when no settings stored', () {
        // Act
        final result = settingsRepository.getSettings();

        // Assert
        expect(result.themeMode, equals(ThemeMode.system));
        expect(result.notificationsEnabled, isTrue);
        expect(result.language, equals('zh'));
      });

      test('returns stored settings when available', () async {
        // Arrange
        final settings = const UserSettings(
          themeMode: ThemeMode.dark,
          notificationsEnabled: false,
          language: 'en',
        );
        await settingsRepository.saveSettings(settings);

        // Act
        final result = settingsRepository.getSettings();

        // Assert
        expect(result.themeMode, equals(ThemeMode.dark));
        expect(result.notificationsEnabled, isFalse);
        expect(result.language, equals('en'));
      });

      test('returns default settings on invalid JSON', () async {
        // Arrange - store invalid JSON
        await prefs.setString('user_settings', 'invalid json');

        // Act
        final result = settingsRepository.getSettings();

        // Assert - should return defaults
        expect(result.themeMode, equals(ThemeMode.system));
        expect(result.notificationsEnabled, isTrue);
      });
    });

    group('saveSettings', () {
      test('persists settings to SharedPreferences', () async {
        // Arrange
        final settings = const UserSettings(
          themeMode: ThemeMode.light,
          notificationsEnabled: true,
          language: 'fr',
        );

        // Act
        await settingsRepository.saveSettings(settings);

        // Assert
        final stored = settingsRepository.getSettings();
        expect(stored.themeMode, equals(ThemeMode.light));
        expect(stored.notificationsEnabled, isTrue);
        expect(stored.language, equals('fr'));
      });
    });

    group('getThemeMode', () {
      test('returns system theme when no theme stored', () {
        // Act
        final result = settingsRepository.getThemeMode();

        // Assert
        expect(result, equals(ThemeMode.system));
      });

      test('returns light theme when stored', () async {
        // Arrange
        await prefs.setString('theme_mode', 'light');

        // Act
        final result = settingsRepository.getThemeMode();

        // Assert
        expect(result, equals(ThemeMode.light));
      });

      test('returns dark theme when stored', () async {
        // Arrange
        await prefs.setString('theme_mode', 'dark');

        // Act
        final result = settingsRepository.getThemeMode();

        // Assert
        expect(result, equals(ThemeMode.dark));
      });

      test('returns system theme for unknown value', () async {
        // Arrange
        await prefs.setString('theme_mode', 'unknown');

        // Act
        final result = settingsRepository.getThemeMode();

        // Assert
        expect(result, equals(ThemeMode.system));
      });
    });

    group('setThemeMode', () {
      test('persists light theme mode', () async {
        // Act
        await settingsRepository.setThemeMode(ThemeMode.light);

        // Assert
        expect(prefs.getString('theme_mode'), equals('light'));
        expect(settingsRepository.getThemeMode(), equals(ThemeMode.light));
      });

      test('persists dark theme mode', () async {
        // Act
        await settingsRepository.setThemeMode(ThemeMode.dark);

        // Assert
        expect(prefs.getString('theme_mode'), equals('dark'));
        expect(settingsRepository.getThemeMode(), equals(ThemeMode.dark));
      });

      test('persists system theme mode', () async {
        // Act
        await settingsRepository.setThemeMode(ThemeMode.system);

        // Assert
        expect(prefs.getString('theme_mode'), equals('system'));
        expect(settingsRepository.getThemeMode(), equals(ThemeMode.system));
      });

      test('also updates theme in settings object', () async {
        // Arrange - first save some settings
        await settingsRepository.saveSettings(const UserSettings(
          themeMode: ThemeMode.light,
          notificationsEnabled: true,
          language: 'en',
        ));

        // Act
        await settingsRepository.setThemeMode(ThemeMode.dark);

        // Assert - settings should have updated theme
        final settings = settingsRepository.getSettings();
        expect(settings.themeMode, equals(ThemeMode.dark));
        // Other settings should be preserved
        expect(settings.notificationsEnabled, isTrue);
        expect(settings.language, equals('en'));
      });
    });
  });
}
