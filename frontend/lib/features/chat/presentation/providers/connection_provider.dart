import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/websocket_service.dart';
import '../../domain/models/connection_state.dart';
import 'package:lesser/core/config/environment_config.dart';

part 'connection_provider.g.dart';

/// WebSocket 服务提供者
@riverpod
WebSocketService webSocketService(Ref ref) {
  final wsUrl = EnvironmentConfig.wsUrl;
  final service = WebSocketService(serverUrl: wsUrl);
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
}

/// 连接状态提供者
@riverpod
class ConnectionState extends _$ConnectionState {
  StreamSubscription<ChatConnectionState>? _subscription;
  
  @override
  ChatConnectionState build() {
    final service = ref.watch(webSocketServiceProvider);
    
    // 监听连接状态变化
    _subscription?.cancel();
    _subscription = service.onConnectionState.listen((state) {
      this.state = state;
    });
    
    ref.onDispose(() {
      _subscription?.cancel();
    });
    
    return service.currentState;
  }
  
  /// 连接到 WebSocket 服务器
  Future<void> connect({String? authToken}) async {
    final service = ref.read(webSocketServiceProvider);
    await service.connect(authToken: authToken);
  }
  
  /// 断开连接
  Future<void> disconnect() async {
    final service = ref.read(webSocketServiceProvider);
    await service.disconnect();
  }
  
  /// 重新连接
  Future<void> reconnect() async {
    final service = ref.read(webSocketServiceProvider);
    await service.reconnect();
  }
}
