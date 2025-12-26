// ignore_for_file: invalid_annotation_target
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_settings.freezed.dart';
part 'user_settings.g.dart';

/// Converter for ThemeMode to/from JSON
class ThemeModeConverter implements JsonConverter<ThemeMode, String> {
  const ThemeModeConverter();

  @override
  ThemeMode fromJson(String json) {
    return switch (json) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  @override
  String toJson(ThemeMode object) {
    return switch (object) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}

/// User settings model for app preferences
@freezed
sealed class UserSettings with _$UserSettings {
  const factory UserSettings({
    @ThemeModeConverter()
    @Default(ThemeMode.system)
    @JsonKey(name: 'theme_mode')
    ThemeMode themeMode,
    @Default(true)
    @JsonKey(name: 'notifications_enabled')
    bool notificationsEnabled,
    @Default('zh')
    String language,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
}
