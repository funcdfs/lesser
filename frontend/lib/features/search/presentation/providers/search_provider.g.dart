// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchRepository)
const searchRepositoryProvider = SearchRepositoryProvider._();

final class SearchRepositoryProvider
    extends
        $FunctionalProvider<
          SearchRepository,
          SearchRepository,
          SearchRepository
        >
    with $Provider<SearchRepository> {
  const SearchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchRepositoryHash();

  @$internal
  @override
  $ProviderElement<SearchRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SearchRepository create(Ref ref) {
    return searchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchRepository>(value),
    );
  }
}

String _$searchRepositoryHash() => r'9f9f1c2c08640de5a5b4cc06f1a2ae91cfb64c47';

/// Provider for the current search query

@ProviderFor(SearchQuery)
const searchQueryProvider = SearchQueryProvider._();

/// Provider for the current search query
final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  /// Provider for the current search query
  const SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'a2de29f344488b8b351fbfcf9c230f993798b9ea';

/// Provider for the current search query

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for the current search filter

@ProviderFor(CurrentSearchFilter)
const currentSearchFilterProvider = CurrentSearchFilterProvider._();

/// Provider for the current search filter
final class CurrentSearchFilterProvider
    extends $NotifierProvider<CurrentSearchFilter, SearchFilter> {
  /// Provider for the current search filter
  const CurrentSearchFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentSearchFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentSearchFilterHash();

  @$internal
  @override
  CurrentSearchFilter create() => CurrentSearchFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchFilter>(value),
    );
  }
}

String _$currentSearchFilterHash() =>
    r'86dbb250d1b406649f0d5f50cdcfbb5e0ee24864';

/// Provider for the current search filter

abstract class _$CurrentSearchFilter extends $Notifier<SearchFilter> {
  SearchFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SearchFilter, SearchFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchFilter, SearchFilter>,
              SearchFilter,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for search results with pagination

@ProviderFor(SearchResults)
const searchResultsProvider = SearchResultsProvider._();

/// Provider for search results with pagination
final class SearchResultsProvider
    extends $AsyncNotifierProvider<SearchResults, SearchResult> {
  /// Provider for search results with pagination
  const SearchResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchResultsHash();

  @$internal
  @override
  SearchResults create() => SearchResults();
}

String _$searchResultsHash() => r'71a0801848cebdf1ff1bd7f6991942dcf4e16f97';

/// Provider for search results with pagination

abstract class _$SearchResults extends $AsyncNotifier<SearchResult> {
  FutureOr<SearchResult> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<SearchResult>, SearchResult>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SearchResult>, SearchResult>,
              AsyncValue<SearchResult>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
