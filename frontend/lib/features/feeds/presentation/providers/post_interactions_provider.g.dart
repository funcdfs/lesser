// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_interactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for PostRepository

@ProviderFor(postRepository)
const postRepositoryProvider = PostRepositoryProvider._();

/// Provider for PostRepository

final class PostRepositoryProvider
    extends $FunctionalProvider<PostRepository, PostRepository, PostRepository>
    with $Provider<PostRepository> {
  /// Provider for PostRepository
  const PostRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postRepositoryHash();

  @$internal
  @override
  $ProviderElement<PostRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PostRepository create(Ref ref) {
    return postRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostRepository>(value),
    );
  }
}

String _$postRepositoryHash() => r'3c5f01de1116882b177b0b1a7036f34a55e45cc2';

/// Provider for managing post interactions (like/bookmark)

@ProviderFor(PostInteractions)
const postInteractionsProvider = PostInteractionsFamily._();

/// Provider for managing post interactions (like/bookmark)
final class PostInteractionsProvider
    extends $NotifierProvider<PostInteractions, PostInteractionState> {
  /// Provider for managing post interactions (like/bookmark)
  const PostInteractionsProvider._({
    required PostInteractionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'postInteractionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postInteractionsHash();

  @override
  String toString() {
    return r'postInteractionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PostInteractions create() => PostInteractions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostInteractionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostInteractionState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PostInteractionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postInteractionsHash() => r'8bcbee2258ab64f6e811f5dfb1afbd1076ed3c2c';

/// Provider for managing post interactions (like/bookmark)

final class PostInteractionsFamily extends $Family
    with
        $ClassFamilyOverride<
          PostInteractions,
          PostInteractionState,
          PostInteractionState,
          PostInteractionState,
          String
        > {
  const PostInteractionsFamily._()
    : super(
        retry: null,
        name: r'postInteractionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for managing post interactions (like/bookmark)

  PostInteractionsProvider call(String postId) =>
      PostInteractionsProvider._(argument: postId, from: this);

  @override
  String toString() => r'postInteractionsProvider';
}

/// Provider for managing post interactions (like/bookmark)

abstract class _$PostInteractions extends $Notifier<PostInteractionState> {
  late final _$args = ref.$arg as String;
  String get postId => _$args;

  PostInteractionState build(String postId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<PostInteractionState, PostInteractionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PostInteractionState, PostInteractionState>,
              PostInteractionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
