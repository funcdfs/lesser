import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lesser/features/settings/data/settings_repository.dart';
import 'package:lesser/features/search/presentation/providers/search_history_provider.dart';

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
    return ThemeMode.dark;
  }

  /// Set the theme mode
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}
