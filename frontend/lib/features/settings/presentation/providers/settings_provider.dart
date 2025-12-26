import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lesser/features/settings/domain/models/user_settings.dart';
import 'package:lesser/features/settings/presentation/providers/theme_provider.dart';

part 'settings_provider.g.dart';

/// Provider for managing user settings
@Riverpod(keepAlive: true)
class UserSettingsNotifier extends _$UserSettingsNotifier {
  @override
  Future<UserSettings> build() async {
    final repository = await ref.watch(settingsRepositoryProvider.future);
    return repository.getSettings();
  }

  /// Update all settings at once
  Future<void> updateSettings(UserSettings settings) async {
    final repository = await ref.read(settingsRepositoryProvider.future);
    await repository.saveSettings(settings);
    
    // Also update theme provider if theme changed
    final currentState = state;
    if (currentState.hasValue && currentState.value!.themeMode != settings.themeMode) {
      ref.read(themeProvider.notifier).setThemeMode(settings.themeMode);
    }
    
    ref.invalidateSelf();
  }

  /// Update notifications enabled setting
  Future<void> setNotificationsEnabled(bool enabled) async {
    final currentState = state;
    final currentSettings = currentState.hasValue ? currentState.value! : const UserSettings();
    await updateSettings(currentSettings.copyWith(notificationsEnabled: enabled));
  }

  /// Update language setting
  Future<void> setLanguage(String language) async {
    final currentState = state;
    final currentSettings = currentState.hasValue ? currentState.value! : const UserSettings();
    await updateSettings(currentSettings.copyWith(language: language));
  }
}
