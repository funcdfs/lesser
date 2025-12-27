import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lesser/features/settings/data/settings_repository.dart';
import 'package:lesser/features/search/presentation/providers/search_history_provider.dart';
import 'package:lesser/shared/theme/colors.dart';

part 'theme_provider.g.dart';

/// Provider for SettingsRepository
@riverpod
Future<SettingsRepository> settingsRepository(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return SettingsRepository(prefs);
}

/// Provider for managing theme mode
@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    // 默认使用浅色主题
    AppColors.setDarkMode(false);
    return ThemeMode.light;
  }

  /// Set the theme mode
  void setThemeMode(ThemeMode mode) {
    AppColors.setDarkMode(mode == ThemeMode.dark);
    state = mode;
  }

  /// Toggle between light and dark theme
  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setThemeMode(newMode);
  }

  /// Check if current theme is dark
  bool get isDark => state == ThemeMode.dark;
}
