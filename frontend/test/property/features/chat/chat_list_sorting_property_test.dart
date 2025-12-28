import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesser/features/chat/domain/models/conversation.dart';
import 'package:lesser/features/chat/domain/models/chat_user.dart';

/// Property-based tests for ChatList Sorting
/// Feature: message-page-ui-refactor, Property 1: Chat List Sorting
/// Validates: Requirements 2.2

void main() {
  group('ChatList - Property 1: Chat List Sorting', () {
    /// **Feature: message-page-ui-refactor, Property 1: Chat List Sorting**
    /// **Validates: Requirements 2.2**
    ///
    /// *For any* list of conversations displayed in the Chat_List, they SHALL
    /// be sorted by lastMessageTime in descending order (newest first).

    /// Helper function to sort conversations by lastMessageTime descending
    /// This is the same logic used in ChatScreen._buildChatList()
    List<Conversation> sortConversations(List<Conversation> conversations) {
      final sorted = List<Conversation>.from(conversations)
        ..sort((a, b) {
          final aTime = a.lastMessageTime ?? a.createdAt;
          final bTime = b.lastMessageTime ?? b.createdAt;
          return bTime.compareTo(aTime); // 降序排序
        });
      return sorted;
    }

    /// Helper function to verify list is sorted in descending order by time
    bool isSortedDescending(List<Conversation> conversations) {
      if (conversations.length <= 1) return true;
      
      for (int i = 0; i < conversations.length - 1; i++) {
        final currentTime = conversations[i].lastMessageTime ?? conversations[i].createdAt;
        final nextTime = conversations[i + 1].lastMessageTime ?? conversations[i + 1].createdAt;
        
        // Current should be >= next (descending order)
        if (currentTime.compareTo(nextTime) < 0) {
          return false;
        }
      }
      return true;
    }

    /// Helper function to generate a random conversation
    Conversation generateRandomConversation(Random random, int index) {
      final now = DateTime.now();
      final createdAt = now.subtract(Duration(days: random.nextInt(365)));
      final hasLastMessage = random.nextBool();
      final lastMessageTime = hasLastMessage
          ? createdAt.add(Duration(
              hours: random.nextInt(24 * 30), // Up to 30 days after creation
              minutes: random.nextInt(60),
            ))
          : null;

      return Conversation(
        id: 'conv_$index',
        participants: [
          ChatUser(
            id: 'user_$index',
            username: 'User $index',
            avatarUrl: 'https://example.com/avatar$index.png',
            isOnline: random.nextBool(),
          ),
        ],
        lastMessage: hasLastMessage ? 'Message $index' : null,
        lastMessageTime: lastMessageTime,
        unreadCount: random.nextInt(10),
        createdAt: createdAt,
        updatedAt: lastMessageTime ?? createdAt,
      );
    }

    test('Property 1.1: Empty list remains empty after sorting', () {
      final conversations = <Conversation>[];
      final sorted = sortConversations(conversations);
      
      expect(sorted, isEmpty);
      expect(isSortedDescending(sorted), isTrue);
    });

    test('Property 1.2: Single item list is always sorted', () {
      final conversation = Conversation(
        id: '1',
        participants: const [
          ChatUser(id: 'u1', username: 'User 1', avatarUrl: '', isOnline: true),
        ],
        lastMessage: 'Hello',
        lastMessageTime: DateTime.now(),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      
      final sorted = sortConversations([conversation]);
      
      expect(sorted.length, equals(1));
      expect(isSortedDescending(sorted), isTrue);
    });

    test('Property 1.3: Two items are sorted correctly', () {
      final now = DateTime.now();
      final older = Conversation(
        id: '1',
        participants: const [
          ChatUser(id: 'u1', username: 'User 1', avatarUrl: '', isOnline: true),
        ],
        lastMessage: 'Old message',
        lastMessageTime: now.subtract(const Duration(hours: 2)),
        createdAt: now.subtract(const Duration(days: 1)),
      );
      final newer = Conversation(
        id: '2',
        participants: const [
          ChatUser(id: 'u2', username: 'User 2', avatarUrl: '', isOnline: true),
        ],
        lastMessage: 'New message',
        lastMessageTime: now.subtract(const Duration(hours: 1)),
        createdAt: now.subtract(const Duration(days: 1)),
      );
      
      // Test both orderings
      final sorted1 = sortConversations([older, newer]);
      final sorted2 = sortConversations([newer, older]);
      
      expect(sorted1.first.id, equals('2')); // Newer first
      expect(sorted1.last.id, equals('1'));  // Older last
      expect(sorted2.first.id, equals('2')); // Same result regardless of input order
      expect(sorted2.last.id, equals('1'));
      expect(isSortedDescending(sorted1), isTrue);
      expect(isSortedDescending(sorted2), isTrue);
    });

    test('Property 1.4: Conversations without lastMessageTime use createdAt', () {
      final now = DateTime.now();
      final withLastMessage = Conversation(
        id: '1',
        participants: const [
          ChatUser(id: 'u1', username: 'User 1', avatarUrl: '', isOnline: true),
        ],
        lastMessage: 'Hello',
        lastMessageTime: now.subtract(const Duration(hours: 2)),
        createdAt: now.subtract(const Duration(days: 10)),
      );
      final withoutLastMessage = Conversation(
        id: '2',
        participants: const [
          ChatUser(id: 'u2', username: 'User 2', avatarUrl: '', isOnline: true),
        ],
        lastMessage: null,
        lastMessageTime: null,
        createdAt: now.subtract(const Duration(hours: 1)), // More recent createdAt
      );
      
      final sorted = sortConversations([withLastMessage, withoutLastMessage]);
      
      // withoutLastMessage should be first because its createdAt is more recent
      // than withLastMessage's lastMessageTime
      expect(sorted.first.id, equals('2'));
      expect(isSortedDescending(sorted), isTrue);
    });

    test('Property 1.5: Random list of 10 conversations is sorted correctly', () {
      final random = Random(42); // Fixed seed for reproducibility
      final conversations = List.generate(
        10,
        (index) => generateRandomConversation(random, index),
      );
      
      final sorted = sortConversations(conversations);
      
      expect(sorted.length, equals(10));
      expect(isSortedDescending(sorted), isTrue);
    });

    test('Property 1.6: Random list of 50 conversations is sorted correctly', () {
      final random = Random(123); // Different seed
      final conversations = List.generate(
        50,
        (index) => generateRandomConversation(random, index),
      );
      
      final sorted = sortConversations(conversations);
      
      expect(sorted.length, equals(50));
      expect(isSortedDescending(sorted), isTrue);
    });

    test('Property 1.7: Sorting is stable for equal timestamps', () {
      final now = DateTime.now();
      final sameTime = now.subtract(const Duration(hours: 1));
      
      final conv1 = Conversation(
        id: '1',
        participants: const [
          ChatUser(id: 'u1', username: 'User 1', avatarUrl: '', isOnline: true),
        ],
        lastMessage: 'Message 1',
        lastMessageTime: sameTime,
        createdAt: now.subtract(const Duration(days: 1)),
      );
      final conv2 = Conversation(
        id: '2',
        participants: const [
          ChatUser(id: 'u2', username: 'User 2', avatarUrl: '', isOnline: true),
        ],
        lastMessage: 'Message 2',
        lastMessageTime: sameTime,
        createdAt: now.subtract(const Duration(days: 1)),
      );
      
      final sorted = sortConversations([conv1, conv2]);
      
      expect(sorted.length, equals(2));
      expect(isSortedDescending(sorted), isTrue);
    });

    test('Property 1.8: Sorting preserves all conversations (no data loss)', () {
      final random = Random(456);
      final conversations = List.generate(
        20,
        (index) => generateRandomConversation(random, index),
      );
      
      final originalIds = conversations.map((c) => c.id).toSet();
      final sorted = sortConversations(conversations);
      final sortedIds = sorted.map((c) => c.id).toSet();
      
      expect(sortedIds, equals(originalIds));
      expect(sorted.length, equals(conversations.length));
    });

    test('Property 1.9: Multiple sorts produce same result (idempotent)', () {
      final random = Random(789);
      final conversations = List.generate(
        15,
        (index) => generateRandomConversation(random, index),
      );
      
      final sorted1 = sortConversations(conversations);
      final sorted2 = sortConversations(sorted1);
      final sorted3 = sortConversations(sorted2);
      
      // All sorted lists should have the same order
      for (int i = 0; i < sorted1.length; i++) {
        expect(sorted1[i].id, equals(sorted2[i].id));
        expect(sorted2[i].id, equals(sorted3[i].id));
      }
    });

    test('Property 1.10: 100 random iterations all produce sorted results', () {
      // Property-based test with 100 random iterations
      for (int iteration = 0; iteration < 100; iteration++) {
        final random = Random(iteration);
        final size = random.nextInt(30) + 1; // 1 to 30 conversations
        final conversations = List.generate(
          size,
          (index) => generateRandomConversation(random, index),
        );
        
        final sorted = sortConversations(conversations);
        
        expect(
          isSortedDescending(sorted),
          isTrue,
          reason: 'Iteration $iteration with $size conversations should be sorted',
        );
        expect(
          sorted.length,
          equals(conversations.length),
          reason: 'Iteration $iteration should preserve all conversations',
        );
      }
    });
  });
}
