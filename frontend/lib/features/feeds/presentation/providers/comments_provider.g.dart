// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for CommentsRepository

@ProviderFor(commentsRepository)
const commentsRepositoryProvider = CommentsRepositoryProvider._();

/// Provider for CommentsRepository

final class CommentsRepositoryProvider
    extends
        $FunctionalProvider<
          CommentsRepository,
          CommentsRepository,
          CommentsRepository
        >
    with $Provider<CommentsRepository> {
  /// Provider for CommentsRepository
  const CommentsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commentsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commentsRepositoryHash();

  @$internal
  @override
  $ProviderElement<CommentsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CommentsRepository create(Ref ref) {
    return commentsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommentsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommentsRepository>(value),
    );
  }
}

String _$commentsRepositoryHash() =>
    r'36b83141aef7d6edd3e59c22da0636b8180359a0';

/// Provider for managing comments for a specific post

@ProviderFor(PostComments)
const postCommentsProvider = PostCommentsFamily._();

/// Provider for managing comments for a specific post
final class PostCommentsProvider
    extends $NotifierProvider<PostComments, CommentsState> {
  /// Provider for managing comments for a specific post
  const PostCommentsProvider._({
    required PostCommentsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'postCommentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postCommentsHash();

  @override
  String toString() {
    return r'postCommentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PostComments create() => PostComments();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommentsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommentsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PostCommentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postCommentsHash() => r'bbb100550a4efe508921a62e5c3c6ffe02a634fe';

/// Provider for managing comments for a specific post

final class PostCommentsFamily extends $Family
    with
        $ClassFamilyOverride<
          PostComments,
          CommentsState,
          CommentsState,
          CommentsState,
          String
        > {
  const PostCommentsFamily._()
    : super(
        retry: null,
        name: r'postCommentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for managing comments for a specific post

  PostCommentsProvider call(String postId) =>
      PostCommentsProvider._(argument: postId, from: this);

  @override
  String toString() => r'postCommentsProvider';
}

/// Provider for managing comments for a specific post

abstract class _$PostComments extends $Notifier<CommentsState> {
  late final _$args = ref.$arg as String;
  String get postId => _$args;

  CommentsState build(String postId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<CommentsState, CommentsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CommentsState, CommentsState>,
              CommentsState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for the total comment count of a post
/// This can be used to display comment count without loading all comments

@ProviderFor(CommentCount)
const commentCountProvider = CommentCountFamily._();

/// Provider for the total comment count of a post
/// This can be used to display comment count without loading all comments
final class CommentCountProvider extends $NotifierProvider<CommentCount, int> {
  /// Provider for the total comment count of a post
  /// This can be used to display comment count without loading all comments
  const CommentCountProvider._({
    required CommentCountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'commentCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$commentCountHash();

  @override
  String toString() {
    return r'commentCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CommentCount create() => CommentCount();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CommentCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$commentCountHash() => r'8d0a31338df2c31b4f134a8e2d62f8ed55370ee5';

/// Provider for the total comment count of a post
/// This can be used to display comment count without loading all comments

final class CommentCountFamily extends $Family
    with $ClassFamilyOverride<CommentCount, int, int, int, String> {
  const CommentCountFamily._()
    : super(
        retry: null,
        name: r'commentCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for the total comment count of a post
  /// This can be used to display comment count without loading all comments

  CommentCountProvider call(String postId) =>
      CommentCountProvider._(argument: postId, from: this);

  @override
  String toString() => r'commentCountProvider';
}

/// Provider for the total comment count of a post
/// This can be used to display comment count without loading all comments

abstract class _$CommentCount extends $Notifier<int> {
  late final _$args = ref.$arg as String;
  String get postId => _$args;

  int build(String postId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
