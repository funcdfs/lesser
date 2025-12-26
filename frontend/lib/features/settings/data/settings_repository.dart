import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lesser/features/settings/domain/models/user_settings.dart';

/// Repository for managing user settings using SharedPreferences
class SettingsRepository {
  static const String _settingsKey = 'user_settings';
  static const String _themeModeKey = 'theme_mode';

  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  /// Get all user settings
  UserSettings getSettings() {
    final jsonString = _prefs.getString(_settingsKey);
    if (jsonString == null) {
      return const UserSettings();
    }
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserSettings.fromJson(json);
    } catch (_) {
      return const UserSettings();
    }
  }

  /// Save user settings
  Future<void> saveSettings(UserSettings settings) async {
    final jsonString = jsonEncode(settings.toJson());
    await _prefs.setString(_settingsKey, jsonString);
  }

  /// Get the current theme mode
  ThemeMode getThemeMode() {
    final modeString = _prefs.getString(_themeModeKey);
    return switch (modeString) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  /// Set the theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    final modeString = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(_themeModeKey, modeString);
    
    // Also update in settings
    final settings = getSettings();
    await saveSettings(settings.copyWith(themeMode: mode));
  }
}
