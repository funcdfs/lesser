// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) =>
    _UserSettings(
      themeMode: json['theme_mode'] == null
          ? ThemeMode.system
          : const ThemeModeConverter().fromJson(json['theme_mode'] as String),
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      language: json['language'] as String? ?? 'zh',
    );

Map<String, dynamic> _$UserSettingsToJson(_UserSettings instance) =>
    <String, dynamic>{
      'theme_mode': const ThemeModeConverter().toJson(instance.themeMode),
      'notifications_enabled': instance.notificationsEnabled,
      'language': instance.language,
    };
