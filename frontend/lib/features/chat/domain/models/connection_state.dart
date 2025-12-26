/// WebSocket 连接状态
enum ChatConnectionState {
  /// 已断开连接
  disconnected,

  /// 正在连接
  connecting,

  /// 已连接
  connected,

  /// 正在重新连接
  reconnecting,
}
