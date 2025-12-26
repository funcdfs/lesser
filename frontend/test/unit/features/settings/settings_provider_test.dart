import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lesser/features/settings/data/settings_repository.dart';
import 'package:lesser/features/settings/domain/models/user_settings.dart';
import 'package:lesser/features/settings/presentation/providers/settings_provider.dart';
import 'package:lesser/features/settings/presentation/providers/theme_provider.dart';
import 'package:lesser/features/search/presentation/providers/search_history_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWith((_) async => prefs),
        settingsRepositoryProvider.overrideWith((_) async => SettingsRepository(prefs)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ThemeNotifier Provider', () {
    test('starts with system theme mode', () {
      // Act
      final themeMode = container.read(themeProvider);

      // Assert
      expect(themeMode, equals(ThemeMode.system));
    });

    test('can override with specific value', () {
      // Arrange - create container with overridden value
      final testContainer = ProviderContainer(
        overrides: [
          themeProvider.overrideWithValue(ThemeMode.dark),
        ],
      );

      // Act
      final themeMode = testContainer.read(themeProvider);

      // Assert
      expect(themeMode, equals(ThemeMode.dark));

      testContainer.dispose();
    });

    test('toggleTheme changes state', () {
      // Act
      container.read(themeProvider.notifier).toggleTheme();

      // Assert - from system, should go to light
      final themeMode = container.read(themeProvider);
      expect(themeMode, equals(ThemeMode.light));
    });

    test('toggleTheme from light goes to dark', () {
      // Arrange - toggle once to get to light
      container.read(themeProvider.notifier).toggleTheme();
      expect(container.read(themeProvider), equals(ThemeMode.light));

      // Act - toggle again
      container.read(themeProvider.notifier).toggleTheme();

      // Assert
      final themeMode = container.read(themeProvider);
      expect(themeMode, equals(ThemeMode.dark));
    });

    test('toggleTheme from dark goes to light', () {
      // Arrange - toggle twice to get to dark
      container.read(themeProvider.notifier).toggleTheme(); // system -> light
      container.read(themeProvider.notifier).toggleTheme(); // light -> dark
      expect(container.read(themeProvider), equals(ThemeMode.dark));

      // Act - toggle again
      container.read(themeProvider.notifier).toggleTheme();

      // Assert
      final themeMode = container.read(themeProvider);
      expect(themeMode, equals(ThemeMode.light));
    });
  });

  group('SettingsRepository', () {
    test('returns default settings when empty', () {
      // Arrange
      final repository = SettingsRepository(prefs);

      // Act
      final settings = repository.getSettings();

      // Assert
      expect(settings.themeMode, equals(ThemeMode.system));
      expect(settings.notificationsEnabled, isTrue);
      expect(settings.language, equals('zh'));
    });

    test('saves and retrieves settings', () async {
      // Arrange
      final repository = SettingsRepository(prefs);
      const newSettings = UserSettings(
        themeMode: ThemeMode.dark,
        notificationsEnabled: false,
        language: 'en',
      );

      // Act
      await repository.saveSettings(newSettings);
      final retrieved = repository.getSettings();

      // Assert
      expect(retrieved.themeMode, equals(ThemeMode.dark));
      expect(retrieved.notificationsEnabled, isFalse);
      expect(retrieved.language, equals('en'));
    });

    test('getThemeMode returns system by default', () {
      // Arrange
      final repository = SettingsRepository(prefs);

      // Act
      final mode = repository.getThemeMode();

      // Assert
      expect(mode, equals(ThemeMode.system));
    });

    test('setThemeMode persists theme', () async {
      // Arrange
      final repository = SettingsRepository(prefs);

      // Act
      await repository.setThemeMode(ThemeMode.dark);
      final mode = repository.getThemeMode();

      // Assert
      expect(mode, equals(ThemeMode.dark));
    });
  });

  group('UserSettingsNotifier Provider', () {
    test('loads default settings initially', () async {
      // Act
      final settings = await container.read(userSettingsProvider.future);

      // Assert
      expect(settings.themeMode, equals(ThemeMode.system));
      expect(settings.notificationsEnabled, isTrue);
      expect(settings.language, equals('zh'));
    });

    test('updateSettings persists new settings', () async {
      // Arrange
      const newSettings = UserSettings(
        themeMode: ThemeMode.dark,
        notificationsEnabled: false,
        language: 'en',
      );

      // Act
      await container.read(userSettingsProvider.notifier).updateSettings(newSettings);

      // Wait for invalidation to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - read from repository directly
      final repository = await container.read(settingsRepositoryProvider.future);
      final savedSettings = repository.getSettings();
      expect(savedSettings.themeMode, equals(ThemeMode.dark));
      expect(savedSettings.notificationsEnabled, isFalse);
      expect(savedSettings.language, equals('en'));
    });

    test('setNotificationsEnabled updates only notifications setting', () async {
      // Act
      await container.read(userSettingsProvider.notifier).setNotificationsEnabled(false);

      // Wait for invalidation
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      final repository = await container.read(settingsRepositoryProvider.future);
      final savedSettings = repository.getSettings();
      expect(savedSettings.notificationsEnabled, isFalse);
      // Other settings should remain default
      expect(savedSettings.language, equals('zh'));
    });

    test('setLanguage updates only language setting', () async {
      // Act
      await container.read(userSettingsProvider.notifier).setLanguage('en');

      // Wait for invalidation
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      final repository = await container.read(settingsRepositoryProvider.future);
      final savedSettings = repository.getSettings();
      expect(savedSettings.language, equals('en'));
      // Other settings should remain default
      expect(savedSettings.notificationsEnabled, isTrue);
    });
  });
}
