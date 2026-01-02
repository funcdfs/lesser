# gRPC 双向流使用指南

> 本文档说明如何在 Flutter 端使用 gRPC 双向流实现实时消息通信。

---

## 概述

项目使用 gRPC 双向流 (`StreamEvents` RPC) 替代 WebSocket 实现实时消息推送。双向流的优势：

- **强类型**: Protocol Buffers 提供类型安全
- **统一协议**: 与其他 gRPC API 使用相同协议
- **自动重连**: 内置重连机制
- **心跳保活**: Ping/Pong 机制保持连接

---

## 架构概览

```
┌─────────────────────────────────────────────────────────────┐
│  Flutter Client                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  UnifiedGrpcClient                                   │    │
│  │  ├── ChatStreamClient (双向流)                       │    │
│  │  ├── 自动重连 (指数退避)                             │    │
│  │  └── 心跳 Ping/Pong                                  │    │
│  └─────────────────────────────────────────────────────┘    │
│                          │                                   │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  StreamEventHandler                                  │    │
│  │  ├── ServerEvent 分发                                │    │
│  │  ├── ConversationSubscriptionManager                 │    │
│  │  └── MessageSendTracker                              │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼ gRPC 双向流
┌─────────────────────────────────────────────────────────────┐
│  Chat Service (:50052)                                       │
│  ├── StreamManager (管理活跃连接)                            │
│  └── StreamClient (单个流连接)                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Flutter 端使用

### 1. 建立连接

```dart
import 'package:mobile_flutter/core/network/unified_grpc_client.dart';

// 获取 UnifiedGrpcClient 实例 (通过 DI)
final grpcClient = getIt<UnifiedGrpcClient>();

// 连接双向流
await grpcClient.connect();
```

### 2. 订阅会话

进入聊天室时订阅会话，接收该会话的实时消息：

```dart
import 'package:mobile_flutter/core/network/stream_event_handler.dart';

final eventHandler = getIt<StreamEventHandler>();

// 订阅会话
eventHandler.subscribeConversation('conversation-uuid');

// 取消订阅 (离开聊天室时)
eventHandler.unsubscribeConversation('conversation-uuid');
```

### 3. 监听服务端事件

```dart
// 监听新消息
eventHandler.onNewMessage.listen((message) {
  print('收到新消息: ${message.content}');
});

// 监听已读回执
eventHandler.onMessageRead.listen((readEvent) {
  print('消息已读: ${readEvent.messageId}');
});

// 监听正在输入
eventHandler.onTyping.listen((typing) {
  print('${typing.userId} 正在输入...');
});
```

### 4. 发送消息

```dart
// 通过双向流发送消息
final messageId = await eventHandler.sendMessage(
  conversationId: 'conversation-uuid',
  content: 'Hello!',
  messageType: MessageType.text,
);
```

### 5. 发送正在输入指示

```dart
eventHandler.sendTyping(conversationId: 'conversation-uuid');
```

---

## 事件类型

### 客户端事件 (ClientEvent)

| 事件 | 说明 |
|------|------|
| `SubscribeConversation` | 订阅会话，接收该会话的实时消息 |
| `UnsubscribeConversation` | 取消订阅会话 |
| `SendMessage` | 通过流发送消息 |
| `Typing` | 发送正在输入指示 |
| `Ping` | 心跳请求 |

### 服务端事件 (ServerEvent)

| 事件 | 说明 |
|------|------|
| `NewMessage` | 新消息推送 |
| `MessageRead` | 已读回执推送 |
| `TypingIndicator` | 正在输入指示推送 |
| `Pong` | 心跳响应 |
| `Error` | 错误通知 |

---

## 自动重连机制

`UnifiedGrpcClient` 内置自动重连机制：

```dart
// 重连配置
const reconnectConfig = ReconnectConfig(
  initialDelay: Duration(seconds: 1),
  maxDelay: Duration(seconds: 30),
  multiplier: 2.0,  // 指数退避
  maxAttempts: 10,
);
```

重连流程：
1. 连接断开时自动触发重连
2. 使用指数退避算法计算延迟
3. 重连成功后自动重新订阅之前的会话
4. 达到最大重试次数后触发认证失败回调

---

## 心跳机制

心跳用于保持连接活跃，检测连接状态：

```dart
// 心跳配置
const heartbeatConfig = HeartbeatConfig(
  interval: Duration(seconds: 30),
  timeout: Duration(seconds: 10),
);
```

心跳流程：
1. 客户端定时发送 `Ping`
2. 服务端响应 `Pong`
3. 超时未收到 `Pong` 则触发重连

---

## 错误处理

### 连接错误

```dart
grpcClient.onConnectionError.listen((error) {
  if (error is AuthenticationError) {
    // Token 过期，需要重新登录
    navigateToLogin();
  } else if (error is NetworkError) {
    // 网络错误，等待自动重连
    showNetworkErrorToast();
  }
});
```

### 消息发送失败

```dart
try {
  await eventHandler.sendMessage(...);
} on MessageSendError catch (e) {
  // 消息发送失败，可以重试
  showRetryDialog(e.message);
}
```

---

## 最佳实践

### 1. 连接时机

- 用户登录成功后立即建立连接
- App 从后台恢复时检查连接状态
- 用户登出时断开连接

### 2. 订阅管理

- 进入聊天室时订阅
- 离开聊天室时取消订阅
- 不要订阅过多会话（建议 < 10）

### 3. 消息去重

- 客户端通过消息 ID 去重
- 发送者不会收到自己发送的消息广播

### 4. 乐观更新

- 发送消息时先显示临时消息
- 收到服务端确认后替换为正式消息
- 发送失败时显示重试按钮

---

## 示例代码

### 完整聊天页面示例

```dart
class ChatPage extends ConsumerStatefulWidget {
  final String conversationId;
  
  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  late StreamEventHandler _eventHandler;
  
  @override
  void initState() {
    super.initState();
    _eventHandler = ref.read(streamEventHandlerProvider);
    
    // 订阅会话
    _eventHandler.subscribeConversation(widget.conversationId);
    
    // 监听新消息
    _eventHandler.onNewMessage.listen(_handleNewMessage);
  }
  
  @override
  void dispose() {
    // 取消订阅
    _eventHandler.unsubscribeConversation(widget.conversationId);
    super.dispose();
  }
  
  void _handleNewMessage(Message message) {
    if (message.conversationId == widget.conversationId) {
      // 更新消息列表
      ref.read(messagesProvider.notifier).addMessage(message);
    }
  }
  
  Future<void> _sendMessage(String content) async {
    try {
      await _eventHandler.sendMessage(
        conversationId: widget.conversationId,
        content: content,
      );
    } catch (e) {
      // 显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发送失败，请重试')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // ... UI 实现
  }
}
```

---

## 调试技巧

### 1. 查看连接状态

```dart
print('连接状态: ${grpcClient.connectionState}');
// ConnectionState.connected / disconnected / connecting
```

### 2. 查看订阅的会话

```dart
print('已订阅会话: ${eventHandler.subscribedConversations}');
```

### 3. 启用调试日志

```dart
// 在 main.dart 中启用
Logger.level = Level.debug;
```
