import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/conversation.dart';
import '../../domain/models/chat_user.dart';
import 'package:lesser/core/config/debug_config.dart';

part 'chat_provider.g.dart';

/// 会话列表提供者
@riverpod
class Conversations extends _$Conversations {
  @override
  Future<List<Conversation>> build() async {
    if (DebugConfig.debugLocal) {
      // 纯前端调试模式：返回 mock 数据
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockConversations();
    }
    
    // TODO: 实现从 API 获取会话列表
    return [];
  }
  
  /// 刷新会话列表
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
  
  /// 创建新会话
  Future<Conversation?> createConversation(ChatUser user) async {
    // TODO: 实现创建会话 API 调用
    final conversation = Conversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      participants: [user],
      createdAt: DateTime.now(),
    );
    
    final currentState = state;
    if (currentState is AsyncData<List<Conversation>>) {
      state = AsyncData([conversation, ...currentState.value]);
    }
    
    return conversation;
  }
  
  /// 删除会话
  Future<void> deleteConversation(String conversationId) async {
    // TODO: 实现删除会话 API 调用
    final currentState = state;
    if (currentState is AsyncData<List<Conversation>>) {
      final conversations = currentState.value
          .where((c) => c.id != conversationId)
          .toList();
      state = AsyncData(conversations);
    }
  }
  
  /// 更新会话的最后消息
  void updateLastMessage(String conversationId, String message, DateTime time) {
    final currentState = state;
    if (currentState is AsyncData<List<Conversation>>) {
      final conversations = currentState.value.map((c) {
        if (c.id == conversationId) {
          return c.copyWith(
            lastMessage: message,
            lastMessageTime: time,
            updatedAt: time,
          );
        }
        return c;
      }).toList();
      
      // 按最后消息时间排序
      conversations.sort((a, b) {
        final aTime = a.lastMessageTime ?? a.createdAt;
        final bTime = b.lastMessageTime ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
      
      state = AsyncData(conversations);
    }
  }
  
  /// 增加未读消息数
  void incrementUnreadCount(String conversationId) {
    final currentState = state;
    if (currentState is AsyncData<List<Conversation>>) {
      final conversations = currentState.value.map((c) {
        if (c.id == conversationId) {
          return c.copyWith(unreadCount: c.unreadCount + 1);
        }
        return c;
      }).toList();
      state = AsyncData(conversations);
    }
  }
  
  /// 清除未读消息数
  void clearUnreadCount(String conversationId) {
    final currentState = state;
    if (currentState is AsyncData<List<Conversation>>) {
      final conversations = currentState.value.map((c) {
        if (c.id == conversationId) {
          return c.copyWith(unreadCount: 0);
        }
        return c;
      }).toList();
      state = AsyncData(conversations);
    }
  }
  
  /// 清除所有未读消息
  void clearAllUnreadCount() {
    final currentState = state;
    if (currentState is AsyncData<List<Conversation>>) {
      final conversations = currentState.value.map((c) {
        return c.copyWith(unreadCount: 0);
      }).toList();
      state = AsyncData(conversations);
    }
  }
  
  /// 获取 mock 会话数据
  List<Conversation> _getMockConversations() {
    return [
      Conversation(
        id: '1',
        participants: [
          const ChatUser(
            id: 'user1',
            username: '张三',
            avatarUrl: 'https://i.pravatar.cc/150?img=1',
            isOnline: true,
          ),
        ],
        lastMessage: '你好，最近怎么样？',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Conversation(
        id: '2',
        participants: [
          const ChatUser(
            id: 'user2',
            username: '李四',
            avatarUrl: 'https://i.pravatar.cc/150?img=2',
            isOnline: false,
            lastSeen: null,
          ),
        ],
        lastMessage: '明天见！',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Conversation(
        id: '3',
        participants: [
          const ChatUser(
            id: 'user3',
            username: '王五',
            avatarUrl: 'https://i.pravatar.cc/150?img=3',
            isOnline: true,
          ),
        ],
        lastMessage: '收到，谢谢！',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}

/// 当前会话提供者
@riverpod
class CurrentConversation extends _$CurrentConversation {
  @override
  Conversation? build() {
    return null;
  }
  
  /// 设置当前会话
  void setConversation(Conversation? conversation) {
    state = conversation;
  }
}

/// 总未读消息数提供者
@riverpod
int totalUnreadCount(Ref ref) {
  final conversationsAsync = ref.watch(conversationsProvider);
  
  return conversationsAsync.when(
    data: (conversations) {
      return conversations.fold<int>(0, (sum, c) => sum + c.unreadCount);
    },
    loading: () => 0,
    error: (_, _) => 0,
  );
}

/// 未读会话ID列表提供者（按时间从早到晚排序）
@riverpod
List<String> unreadConversationIds(Ref ref) {
  final conversationsAsync = ref.watch(conversationsProvider);
  
  return conversationsAsync.when(
    data: (conversations) {
      // 筛选有未读消息的会话
      final unreadConversations = conversations
          .where((c) => c.unreadCount > 0)
          .toList();
      
      // 按最后消息时间升序排序（从早到晚）
      unreadConversations.sort((a, b) {
        final aTime = a.lastMessageTime ?? a.createdAt;
        final bTime = b.lastMessageTime ?? b.createdAt;
        return aTime.compareTo(bTime); // 升序排序
      });
      
      return unreadConversations.map((c) => c.id).toList();
    },
    loading: () => [],
    error: (_, _) => [],
  );
}
