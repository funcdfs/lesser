// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 会话列表提供者

@ProviderFor(Conversations)
const conversationsProvider = ConversationsProvider._();

/// 会话列表提供者
final class ConversationsProvider
    extends $AsyncNotifierProvider<Conversations, List<Conversation>> {
  /// 会话列表提供者
  const ConversationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationsHash();

  @$internal
  @override
  Conversations create() => Conversations();
}

String _$conversationsHash() => r'2a1be555286e86b0c67fc38d03aba4040ac5ce07';

/// 会话列表提供者

abstract class _$Conversations extends $AsyncNotifier<List<Conversation>> {
  FutureOr<List<Conversation>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<Conversation>>, List<Conversation>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Conversation>>, List<Conversation>>,
              AsyncValue<List<Conversation>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// 当前会话提供者

@ProviderFor(CurrentConversation)
const currentConversationProvider = CurrentConversationProvider._();

/// 当前会话提供者
final class CurrentConversationProvider
    extends $NotifierProvider<CurrentConversation, Conversation?> {
  /// 当前会话提供者
  const CurrentConversationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentConversationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentConversationHash();

  @$internal
  @override
  CurrentConversation create() => CurrentConversation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Conversation? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Conversation?>(value),
    );
  }
}

String _$currentConversationHash() =>
    r'bf0d0bbe6016d9f20697aa99fc1f8d1f9e21a226';

/// 当前会话提供者

abstract class _$CurrentConversation extends $Notifier<Conversation?> {
  Conversation? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Conversation?, Conversation?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Conversation?, Conversation?>,
              Conversation?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// 总未读消息数提供者

@ProviderFor(totalUnreadCount)
const totalUnreadCountProvider = TotalUnreadCountProvider._();

/// 总未读消息数提供者

final class TotalUnreadCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// 总未读消息数提供者
  const TotalUnreadCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalUnreadCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalUnreadCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return totalUnreadCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$totalUnreadCountHash() => r'4ed9c9d7e684fbe7299200797c374adc55cb5e3b';
