// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// WebSocket 服务提供者

@ProviderFor(webSocketService)
const webSocketServiceProvider = WebSocketServiceProvider._();

/// WebSocket 服务提供者

final class WebSocketServiceProvider
    extends
        $FunctionalProvider<
          WebSocketService,
          WebSocketService,
          WebSocketService
        >
    with $Provider<WebSocketService> {
  /// WebSocket 服务提供者
  const WebSocketServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webSocketServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webSocketServiceHash();

  @$internal
  @override
  $ProviderElement<WebSocketService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WebSocketService create(Ref ref) {
    return webSocketService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WebSocketService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WebSocketService>(value),
    );
  }
}

String _$webSocketServiceHash() => r'a282222dbf477ca26fff917ebfd52d9b6d42b764';

/// 连接状态提供者

@ProviderFor(ConnectionState)
const connectionStateProvider = ConnectionStateProvider._();

/// 连接状态提供者
final class ConnectionStateProvider
    extends $NotifierProvider<ConnectionState, ChatConnectionState> {
  /// 连接状态提供者
  const ConnectionStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionStateHash();

  @$internal
  @override
  ConnectionState create() => ConnectionState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatConnectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatConnectionState>(value),
    );
  }
}

String _$connectionStateHash() => r'e2b0a36c0905f1cf0c38a24f8c790ccf5e2beae6';

/// 连接状态提供者

abstract class _$ConnectionState extends $Notifier<ChatConnectionState> {
  ChatConnectionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ChatConnectionState, ChatConnectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatConnectionState, ChatConnectionState>,
              ChatConnectionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
