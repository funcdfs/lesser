// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hot_content_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for hot list items

@ProviderFor(hotList)
const hotListProvider = HotListProvider._();

/// Provider for hot list items

final class HotListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HotItem>>,
          List<HotItem>,
          FutureOr<List<HotItem>>
        >
    with $FutureModifier<List<HotItem>>, $FutureProvider<List<HotItem>> {
  /// Provider for hot list items
  const HotListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hotListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hotListHash();

  @$internal
  @override
  $FutureProviderElement<List<HotItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HotItem>> create(Ref ref) {
    return hotList(ref);
  }
}

String _$hotListHash() => r'7521be3bcd334716623cc8c470119fdb628ddf01';

/// Provider for hot tags

@ProviderFor(hotTags)
const hotTagsProvider = HotTagsProvider._();

/// Provider for hot tags

final class HotTagsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Provider for hot tags
  const HotTagsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hotTagsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hotTagsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return hotTags(ref);
  }
}

String _$hotTagsHash() => r'2e53b593eee81eeca0ba55026afec83c1a98dcdc';

/// Provider for category filters

@ProviderFor(SelectedCategory)
const selectedCategoryProvider = SelectedCategoryProvider._();

/// Provider for category filters
final class SelectedCategoryProvider
    extends $NotifierProvider<SelectedCategory, String> {
  /// Provider for category filters
  const SelectedCategoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedCategoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedCategoryHash();

  @$internal
  @override
  SelectedCategory create() => SelectedCategory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$selectedCategoryHash() => r'a76a42c60f425b28efb5757ffb56020361c38859';

/// Provider for category filters

abstract class _$SelectedCategory extends $Notifier<String> {
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
