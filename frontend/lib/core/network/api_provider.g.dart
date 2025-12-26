// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(apiClient)
const apiClientProvider = ApiClientProvider._();

final class ApiClientProvider
    extends $FunctionalProvider<ApiClient, ApiClient, ApiClient>
    with $Provider<ApiClient> {
  const ApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiClientHash();

  @$internal
  @override
  $ProviderElement<ApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ApiClient create(Ref ref) {
    return apiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiClient>(value),
    );
  }
}

String _$apiClientHash() => r'05eacc6dc3fa586c44e47dd0c1e5cf2b1ed1f36a';

@ProviderFor(chopperApiService)
const chopperApiServiceProvider = ChopperApiServiceProvider._();

final class ChopperApiServiceProvider
    extends
        $FunctionalProvider<
          ChopperApiService,
          ChopperApiService,
          ChopperApiService
        >
    with $Provider<ChopperApiService> {
  const ChopperApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chopperApiServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chopperApiServiceHash();

  @$internal
  @override
  $ProviderElement<ChopperApiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChopperApiService create(Ref ref) {
    return chopperApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChopperApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChopperApiService>(value),
    );
  }
}

String _$chopperApiServiceHash() => r'83bbaeb0968f57f18a7cee144e3812552d9af026';
