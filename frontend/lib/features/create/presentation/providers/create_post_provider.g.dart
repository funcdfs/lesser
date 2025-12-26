// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_post_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Repository provider for creating posts

@ProviderFor(createPostRepository)
const createPostRepositoryProvider = CreatePostRepositoryProvider._();

/// Repository provider for creating posts

final class CreatePostRepositoryProvider
    extends
        $FunctionalProvider<
          CreatePostRepository,
          CreatePostRepository,
          CreatePostRepository
        >
    with $Provider<CreatePostRepository> {
  /// Repository provider for creating posts
  const CreatePostRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createPostRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createPostRepositoryHash();

  @$internal
  @override
  $ProviderElement<CreatePostRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreatePostRepository create(Ref ref) {
    return createPostRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreatePostRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreatePostRepository>(value),
    );
  }
}

String _$createPostRepositoryHash() =>
    r'd3b99e1ea3b7fa61823905a7d9b7be67c3d8a896';

/// Notifier provider for creating posts

@ProviderFor(CreatePost)
const createPostProvider = CreatePostProvider._();

/// Notifier provider for creating posts
final class CreatePostProvider
    extends $NotifierProvider<CreatePost, AsyncValue<void>> {
  /// Notifier provider for creating posts
  const CreatePostProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createPostProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createPostHash();

  @$internal
  @override
  CreatePost create() => CreatePost();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$createPostHash() => r'f58bbea49cc46ffb217852998f91f9c88fca6bc7';

/// Notifier provider for creating posts

abstract class _$CreatePost extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
