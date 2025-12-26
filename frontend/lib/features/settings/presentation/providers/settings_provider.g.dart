// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for managing user settings

@ProviderFor(UserSettingsNotifier)
const userSettingsProvider = UserSettingsNotifierProvider._();

/// Provider for managing user settings
final class UserSettingsNotifierProvider
    extends $AsyncNotifierProvider<UserSettingsNotifier, UserSettings> {
  /// Provider for managing user settings
  const UserSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userSettingsNotifierHash();

  @$internal
  @override
  UserSettingsNotifier create() => UserSettingsNotifier();
}

String _$userSettingsNotifierHash() =>
    r'f96ced1d95c707b5436d62bfc2a340dd5a0b6faf';

/// Provider for managing user settings

abstract class _$UserSettingsNotifier extends $AsyncNotifier<UserSettings> {
  FutureOr<UserSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<UserSettings>, UserSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserSettings>, UserSettings>,
              AsyncValue<UserSettings>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
