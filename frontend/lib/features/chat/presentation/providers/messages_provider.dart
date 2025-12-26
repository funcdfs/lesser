import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/message_repository.dart';
import '../../domain/models/message.dart';
import 'connection_provider.dart';

part 'messages_provider.g.dart';

/// 消息仓库提供者
@riverpod
Future<MessageRepository> messageRepository(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  return MessageRepository(prefs);
}

/// 消息列表提供者
/// 
/// 根据会话 ID 获取消息列表
@riverpod
class Messages extends _$Messages {
  StreamSubscription<Message>? _messageSubscription;
  
  @override
  Future<List<Message>> build(String conversationId) async {
    final repository = await ref.watch(messageRepositoryProvider.future);
    
    // 监听新消息
    final wsService = ref.watch(webSocketServiceProvider);
    _messageSubscription?.cancel();
    _messageSubscription = wsService.onMessage.listen((message) {
      if (message.conversationId == conversationId) {
        _addMessage(message);
      }
    });
    
    ref.onDispose(() {
      _messageSubscription?.cancel();
    });
    
    // 从本地存储加载消息
    return repository.getLocalMessages(conversationId);
  }
  
  /// 添加新消息到列表
  void _addMessage(Message message) {
    final currentState = state;
    if (currentState is AsyncData<List<Message>>) {
      final messages = [...currentState.value];
      // 检查消息是否已存在
      final existingIndex = messages.indexWhere((m) => m.id == message.id);
      if (existingIndex >= 0) {
        messages[existingIndex] = message;
      } else {
        messages.add(message);
      }
      // 按时间排序
      messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
      state = AsyncData(messages);
    }
  }
  
  /// 发送消息
  /// 
  /// [content] 消息内容
  /// [sender] 发送者信息
  Future<bool> sendMessage(String content, MessageSender sender) async {
    final repository = await ref.read(messageRepositoryProvider.future);
    final wsService = ref.read(webSocketServiceProvider);
    
    // 创建消息
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      sender: sender,
      content: content,
      type: MessageType.text,
      status: MessageStatus.sending,
      sentAt: DateTime.now(),
      isFromCurrentUser: true,
    );
    
    // 先添加到本地列表（乐观更新）
    _addMessage(message);
    
    // 保存到本地存储
    await repository.saveMessageLocally(message);
    
    // 发送到服务器
    final sent = wsService.send(message);
    
    if (sent) {
      // 更新消息状态为已发送
      final sentMessage = message.copyWith(status: MessageStatus.sent);
      await repository.saveMessageLocally(sentMessage);
      _addMessage(sentMessage);
      return true;
    } else {
      // 更新消息状态为发送失败
      final failedMessage = message.copyWith(status: MessageStatus.failed);
      await repository.saveMessageLocally(failedMessage);
      _addMessage(failedMessage);
      return false;
    }
  }
  
  /// 标记消息为已读
  Future<void> markAsRead(String messageId) async {
    final repository = await ref.read(messageRepositoryProvider.future);
    await repository.markAsRead(messageId, conversationId);
    
    // 更新本地状态
    final currentState = state;
    if (currentState is AsyncData<List<Message>>) {
      final messages = currentState.value.map((m) {
        if (m.id == messageId) {
          return m.copyWith(isRead: true, status: MessageStatus.read);
        }
        return m;
      }).toList();
      state = AsyncData(messages);
    }
  }
  
  /// 删除消息
  Future<void> deleteMessage(String messageId) async {
    final repository = await ref.read(messageRepositoryProvider.future);
    await repository.deleteLocalMessage(messageId, conversationId);
    
    // 更新本地状态
    final currentState = state;
    if (currentState is AsyncData<List<Message>>) {
      final messages = currentState.value.where((m) => m.id != messageId).toList();
      state = AsyncData(messages);
    }
  }
  
  /// 重新发送失败的消息
  Future<bool> resendMessage(String messageId) async {
    final currentState = state;
    if (currentState is! AsyncData<List<Message>>) return false;
    
    final message = currentState.value.firstWhere(
      (m) => m.id == messageId,
      orElse: () => throw Exception('Message not found'),
    );
    
    if (message.status != MessageStatus.failed) return false;
    
    final repository = await ref.read(messageRepositoryProvider.future);
    final wsService = ref.read(webSocketServiceProvider);
    
    // 更新状态为发送中
    final sendingMessage = message.copyWith(status: MessageStatus.sending);
    await repository.saveMessageLocally(sendingMessage);
    _addMessage(sendingMessage);
    
    // 重新发送
    final sent = wsService.send(sendingMessage);
    
    if (sent) {
      final sentMessage = sendingMessage.copyWith(status: MessageStatus.sent);
      await repository.saveMessageLocally(sentMessage);
      _addMessage(sentMessage);
      return true;
    } else {
      final failedMessage = sendingMessage.copyWith(status: MessageStatus.failed);
      await repository.saveMessageLocally(failedMessage);
      _addMessage(failedMessage);
      return false;
    }
  }
  
  /// 刷新消息列表
  Future<void> refresh() async {
    final repository = await ref.read(messageRepositoryProvider.future);
    state = const AsyncLoading();
    state = AsyncData(await repository.getLocalMessages(conversationId));
  }
}
