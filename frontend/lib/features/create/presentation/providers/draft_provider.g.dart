// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for DraftRepository

@ProviderFor(draftRepository)
const draftRepositoryProvider = DraftRepositoryProvider._();

/// Provider for DraftRepository

final class DraftRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<DraftRepository>,
          DraftRepository,
          FutureOr<DraftRepository>
        >
    with $FutureModifier<DraftRepository>, $FutureProvider<DraftRepository> {
  /// Provider for DraftRepository
  const DraftRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'draftRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$draftRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<DraftRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DraftRepository> create(Ref ref) {
    return draftRepository(ref);
  }
}

String _$draftRepositoryHash() => r'8fc53cd29512264561a6207e1f704749da3f39cb';

/// Provider for managing drafts

@ProviderFor(Drafts)
const draftsProvider = DraftsProvider._();

/// Provider for managing drafts
final class DraftsProvider extends $AsyncNotifierProvider<Drafts, List<Draft>> {
  /// Provider for managing drafts
  const DraftsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'draftsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$draftsHash();

  @$internal
  @override
  Drafts create() => Drafts();
}

String _$draftsHash() => r'386a6b7b88c0a7ff16c81dfc1eff7216d0f49f49';

/// Provider for managing drafts

abstract class _$Drafts extends $AsyncNotifier<List<Draft>> {
  FutureOr<List<Draft>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Draft>>, List<Draft>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Draft>>, List<Draft>>,
              AsyncValue<List<Draft>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for getting a single draft by ID

@ProviderFor(draftById)
const draftByIdProvider = DraftByIdFamily._();

/// Provider for getting a single draft by ID

final class DraftByIdProvider
    extends $FunctionalProvider<AsyncValue<Draft?>, Draft?, FutureOr<Draft?>>
    with $FutureModifier<Draft?>, $FutureProvider<Draft?> {
  /// Provider for getting a single draft by ID
  const DraftByIdProvider._({
    required DraftByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'draftByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$draftByIdHash();

  @override
  String toString() {
    return r'draftByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Draft?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Draft?> create(Ref ref) {
    final argument = this.argument as String;
    return draftById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DraftByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$draftByIdHash() => r'aa432afd281d7c31e22f52be16c140b8cc019b03';

/// Provider for getting a single draft by ID

final class DraftByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Draft?>, String> {
  const DraftByIdFamily._()
    : super(
        retry: null,
        name: r'draftByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for getting a single draft by ID

  DraftByIdProvider call(String id) =>
      DraftByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'draftByIdProvider';
}
