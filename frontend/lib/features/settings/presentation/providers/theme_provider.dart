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
/// Uses keepAlive to persist across the app lifecycle
@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    // Initialize with system theme, will be updated when repository loads
    _loadThemeMode();
    return ThemeMode.system;
  }

  Future<void> _loadThemeMode() async {
    try {
      final repository = await ref.read(settingsRepositoryProvider.future);
      final mode = repository.getThemeMode();
      state = mode;
    } catch (_) {
      // Keep default on error
    }
  }

  /// Set the theme mode and persist it
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final repository = await ref.read(settingsRepositoryProvider.future);
      await repository.setThemeMode(mode);
    } catch (_) {
      // State is already updated, persistence failure is non-critical
    }
  }

  /// Toggle between light and dark mode
  /// If currently system, switches to light
  void toggleTheme() {
    final newMode = switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system => ThemeMode.light,
    };
    setThemeMode(newMode);
  }
}
