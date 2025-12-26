// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feeds_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(feedsRepository)
const feedsRepositoryProvider = FeedsRepositoryProvider._();

final class FeedsRepositoryProvider
    extends
        $FunctionalProvider<FeedsRepository, FeedsRepository, FeedsRepository>
    with $Provider<FeedsRepository> {
  const FeedsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedsRepositoryHash();

  @$internal
  @override
  $ProviderElement<FeedsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeedsRepository create(Ref ref) {
    return feedsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedsRepository>(value),
    );
  }
}

String _$feedsRepositoryHash() => r'8d6bea753bd624e36ca29a4c9d41dfb81e7b69eb';

@ProviderFor(PagedFeeds)
const pagedFeedsProvider = PagedFeedsProvider._();

final class PagedFeedsProvider
    extends $AsyncNotifierProvider<PagedFeeds, List<Post>> {
  const PagedFeedsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pagedFeedsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pagedFeedsHash();

  @$internal
  @override
  PagedFeeds create() => PagedFeeds();
}

String _$pagedFeedsHash() => r'284cf7a76d720d3edd4f2c7e4fe8c1eae6f3d26d';

abstract class _$PagedFeeds extends $AsyncNotifier<List<Post>> {
  FutureOr<List<Post>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Post>>, List<Post>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Post>>, List<Post>>,
              AsyncValue<List<Post>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
