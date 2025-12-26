// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 消息仓库提供者

@ProviderFor(messageRepository)
const messageRepositoryProvider = MessageRepositoryProvider._();

/// 消息仓库提供者

final class MessageRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<MessageRepository>,
          MessageRepository,
          FutureOr<MessageRepository>
        >
    with
        $FutureModifier<MessageRepository>,
        $FutureProvider<MessageRepository> {
  /// 消息仓库提供者
  const MessageRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'messageRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$messageRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<MessageRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MessageRepository> create(Ref ref) {
    return messageRepository(ref);
  }
}

String _$messageRepositoryHash() => r'03da70b4805691514d7985cf693000bc68e1fc96';

/// 消息列表提供者
///
/// 根据会话 ID 获取消息列表

@ProviderFor(Messages)
const messagesProvider = MessagesFamily._();

/// 消息列表提供者
///
/// 根据会话 ID 获取消息列表
final class MessagesProvider
    extends $AsyncNotifierProvider<Messages, List<Message>> {
  /// 消息列表提供者
  ///
  /// 根据会话 ID 获取消息列表
  const MessagesProvider._({
    required MessagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'messagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$messagesHash();

  @override
  String toString() {
    return r'messagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Messages create() => Messages();

  @override
  bool operator ==(Object other) {
    return other is MessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messagesHash() => r'ba08dadc011d7a716de13e9795f552616db6848f';

/// 消息列表提供者
///
/// 根据会话 ID 获取消息列表

final class MessagesFamily extends $Family
    with
        $ClassFamilyOverride<
          Messages,
          AsyncValue<List<Message>>,
          List<Message>,
          FutureOr<List<Message>>,
          String
        > {
  const MessagesFamily._()
    : super(
        retry: null,
        name: r'messagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 消息列表提供者
  ///
  /// 根据会话 ID 获取消息列表

  MessagesProvider call(String conversationId) =>
      MessagesProvider._(argument: conversationId, from: this);

  @override
  String toString() => r'messagesProvider';
}

/// 消息列表提供者
///
/// 根据会话 ID 获取消息列表

abstract class _$Messages extends $AsyncNotifier<List<Message>> {
  late final _$args = ref.$arg as String;
  String get conversationId => _$args;

  FutureOr<List<Message>> build(String conversationId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<List<Message>>, List<Message>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Message>>, List<Message>>,
              AsyncValue<List<Message>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
