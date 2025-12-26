// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for SharedPreferences instance

@ProviderFor(sharedPreferences)
const sharedPreferencesProvider = SharedPreferencesProvider._();

/// Provider for SharedPreferences instance

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedPreferences>,
          SharedPreferences,
          FutureOr<SharedPreferences>
        >
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  /// Provider for SharedPreferences instance
  const SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return sharedPreferences(ref);
  }
}

String _$sharedPreferencesHash() => r'6c03b929f567eb6f97608f6208b95744ffee3bfd';

/// Provider for SearchHistoryRepository

@ProviderFor(searchHistoryRepository)
const searchHistoryRepositoryProvider = SearchHistoryRepositoryProvider._();

/// Provider for SearchHistoryRepository

final class SearchHistoryRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<SearchHistoryRepository>,
          SearchHistoryRepository,
          FutureOr<SearchHistoryRepository>
        >
    with
        $FutureModifier<SearchHistoryRepository>,
        $FutureProvider<SearchHistoryRepository> {
  /// Provider for SearchHistoryRepository
  const SearchHistoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchHistoryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchHistoryRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<SearchHistoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SearchHistoryRepository> create(Ref ref) {
    return searchHistoryRepository(ref);
  }
}

String _$searchHistoryRepositoryHash() =>
    r'd204eff596e63cd474b440546ea0f2c41d3dae2e';

/// Provider for managing search history

@ProviderFor(SearchHistory)
const searchHistoryProvider = SearchHistoryProvider._();

/// Provider for managing search history
final class SearchHistoryProvider
    extends $AsyncNotifierProvider<SearchHistory, List<String>> {
  /// Provider for managing search history
  const SearchHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchHistoryHash();

  @$internal
  @override
  SearchHistory create() => SearchHistory();
}

String _$searchHistoryHash() => r'0123e29026b3630e4eb9c4020637c551fb628d3c';

/// Provider for managing search history

abstract class _$SearchHistory extends $AsyncNotifier<List<String>> {
  FutureOr<List<String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<String>>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<String>>, List<String>>,
              AsyncValue<List<String>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
