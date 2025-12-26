import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/message.dart';

/// 消息仓库
/// 
/// 负责消息的本地存储和远程 API 交互
class MessageRepository {
  final SharedPreferences _prefs;
  
  /// 本地消息存储的键前缀
  static const String _messagesKeyPrefix = 'chat_messages_';
  
  MessageRepository(this._prefs);
  
  /// 获取本地存储的消息键
  String _getMessagesKey(String conversationId) => 
      '$_messagesKeyPrefix$conversationId';
  
  /// 保存消息到本地存储
  /// 
  /// [message] 要保存的消息
  Future<void> saveMessageLocally(Message message) async {
    final messages = await getLocalMessages(message.conversationId);
    
    // 检查消息是否已存在，如果存在则更新
    final existingIndex = messages.indexWhere((m) => m.id == message.id);
    if (existingIndex >= 0) {
      messages[existingIndex] = message;
    } else {
      messages.add(message);
    }
    
    // 按时间排序
    messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    
    // 保存到本地存储
    final jsonList = messages.map((m) => m.toJson()).toList();
    await _prefs.setString(
      _getMessagesKey(message.conversationId),
      jsonEncode(jsonList),
    );
  }
  
  /// 批量保存消息到本地存储
  /// 
  /// [messages] 要保存的消息列表
  Future<void> saveMessagesLocally(List<Message> messages) async {
    if (messages.isEmpty) return;
    
    // 按会话 ID 分组
    final messagesByConversation = <String, List<Message>>{};
    for (final message in messages) {
      messagesByConversation
          .putIfAbsent(message.conversationId, () => [])
          .add(message);
    }
    
    // 分别保存每个会话的消息
    for (final entry in messagesByConversation.entries) {
      final conversationId = entry.key;
      final newMessages = entry.value;
      
      final existingMessages = await getLocalMessages(conversationId);
      
      // 合并消息，避免重复
      final messageMap = <String, Message>{};
      for (final m in existingMessages) {
        messageMap[m.id] = m;
      }
      for (final m in newMessages) {
        messageMap[m.id] = m;
      }
      
      final allMessages = messageMap.values.toList()
        ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
      
      final jsonList = allMessages.map((m) => m.toJson()).toList();
      await _prefs.setString(
        _getMessagesKey(conversationId),
        jsonEncode(jsonList),
      );
    }
  }
  
  /// 获取本地存储的消息
  /// 
  /// [conversationId] 会话 ID
  /// 返回该会话的所有本地消息，按时间排序
  Future<List<Message>> getLocalMessages(String conversationId) async {
    final jsonString = _prefs.getString(_getMessagesKey(conversationId));
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => Message.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    } catch (e) {
      // 如果解析失败，返回空列表
      return [];
    }
  }
  
  /// 删除本地消息
  /// 
  /// [messageId] 消息 ID
  /// [conversationId] 会话 ID
  Future<void> deleteLocalMessage(String messageId, String conversationId) async {
    final messages = await getLocalMessages(conversationId);
    messages.removeWhere((m) => m.id == messageId);
    
    final jsonList = messages.map((m) => m.toJson()).toList();
    await _prefs.setString(
      _getMessagesKey(conversationId),
      jsonEncode(jsonList),
    );
  }
  
  /// 清除会话的所有本地消息
  /// 
  /// [conversationId] 会话 ID
  Future<void> clearLocalMessages(String conversationId) async {
    await _prefs.remove(_getMessagesKey(conversationId));
  }
  
  /// 更新消息状态
  /// 
  /// [messageId] 消息 ID
  /// [conversationId] 会话 ID
  /// [status] 新状态
  Future<void> updateMessageStatus(
    String messageId,
    String conversationId,
    MessageStatus status,
  ) async {
    final messages = await getLocalMessages(conversationId);
    final index = messages.indexWhere((m) => m.id == messageId);
    
    if (index >= 0) {
      messages[index] = messages[index].copyWith(status: status);
      
      final jsonList = messages.map((m) => m.toJson()).toList();
      await _prefs.setString(
        _getMessagesKey(conversationId),
        jsonEncode(jsonList),
      );
    }
  }
  
  /// 标记消息为已读
  /// 
  /// [messageId] 消息 ID
  /// [conversationId] 会话 ID
  Future<void> markAsRead(String messageId, String conversationId) async {
    final messages = await getLocalMessages(conversationId);
    final index = messages.indexWhere((m) => m.id == messageId);
    
    if (index >= 0) {
      messages[index] = messages[index].copyWith(
        isRead: true,
        status: MessageStatus.read,
      );
      
      final jsonList = messages.map((m) => m.toJson()).toList();
      await _prefs.setString(
        _getMessagesKey(conversationId),
        jsonEncode(jsonList),
      );
    }
  }
}
