import 'package:glados/glados.dart';
import 'package:lesser/features/chat/domain/models/message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lesser/features/chat/data/message_repository.dart';

/// Property-based tests for Message Persistence
/// Feature: frontend-code-improvement, Property 4: Message Persistence Round-Trip
/// Validates: Requirements 6.5

void main() {
  group('Message Model - Property-Based Serialization Tests', () {
    // Property 4: Message Persistence Round-Trip
    // For any valid Message object, serializing to JSON and deserializing back
    // SHALL produce an equivalent object.
    Glados2(any.lowercaseLetters, any.bool).test(
      'Property 4: Message serialization round-trip - toJson then fromJson returns equivalent object',
      (content, isRead) {
        // Create a message with generated values
        final sender = MessageSender(
          userId: 'user-${content.hashCode}',
          username: 'testuser',
          avatarUrl: 'https://example.com/avatar.jpg',
        );

        final message = Message(
          id: 'msg-${content.hashCode}',
          conversationId: 'conv-123',
          sender: sender,
          content: content.isEmpty ? 'default message' : content,
          type: MessageType.text,
          status: MessageStatus.sent,
          sentAt: DateTime(2024, 1, 15, 10, 30, 0),
          isRead: isRead,
          isFromCurrentUser: !isRead,
        );

        // Act: Serialize to JSON and deserialize back
        final json = message.toJson();
        final reconstructedMessage = Message.fromJson(json);

        // Assert: The reconstructed message should equal the original
        expect(reconstructedMessage, equals(message));
        expect(reconstructedMessage.id, equals(message.id));
        expect(reconstructedMessage.conversationId, equals(message.conversationId));
        expect(reconstructedMessage.content, equals(message.content));
        expect(reconstructedMessage.type, equals(message.type));
        expect(reconstructedMessage.status, equals(message.status));
        expect(reconstructedMessage.isRead, equals(message.isRead));
        expect(reconstructedMessage.isFromCurrentUser, equals(message.isFromCurrentUser));
        expect(reconstructedMessage.sender.userId, equals(message.sender.userId));
        expect(reconstructedMessage.sender.username, equals(message.sender.username));
      },
    );
  });

  group('MessageSender Model - Property-Based Serialization Tests', () {
    Glados(any.lowercaseLetters).test(
      'MessageSender serialization round-trip',
      (username) {
        final sender = MessageSender(
          userId: 'user-${username.hashCode}',
          username: username.isEmpty ? 'default' : username,
          avatarUrl: 'https://example.com/avatar.jpg',
        );

        final json = sender.toJson();
        final reconstructedSender = MessageSender.fromJson(json);

        expect(reconstructedSender, equals(sender));
        expect(reconstructedSender.userId, equals(sender.userId));
        expect(reconstructedSender.username, equals(sender.username));
        expect(reconstructedSender.avatarUrl, equals(sender.avatarUrl));
      },
    );
  });

  group('Message Repository - Property-Based Persistence Tests', () {
    late MessageRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = MessageRepository(prefs);
    });

    Glados2(any.lowercaseLetters, any.bool).test(
      'Property 4: Message persistence round-trip - saveMessageLocally then getLocalMessages returns equivalent object',
      (content, isRead) async {
        final conversationId = 'conv-${content.hashCode}';
        final sender = MessageSender(
          userId: 'user-123',
          username: 'testuser',
          avatarUrl: 'https://example.com/avatar.jpg',
        );

        final message = Message(
          id: 'msg-${content.hashCode}',
          conversationId: conversationId,
          sender: sender,
          content: content.isEmpty ? 'default message' : content,
          type: MessageType.text,
          status: MessageStatus.sent,
          sentAt: DateTime(2024, 1, 15, 10, 30, 0),
          isRead: isRead,
          isFromCurrentUser: !isRead,
        );

        // Act: Save message locally and retrieve it
        await repository.saveMessageLocally(message);
        final retrievedMessages = await repository.getLocalMessages(conversationId);

        // Assert: The retrieved message should equal the original
        expect(retrievedMessages.length, equals(1));
        final retrievedMessage = retrievedMessages.first;
        expect(retrievedMessage, equals(message));
        expect(retrievedMessage.id, equals(message.id));
        expect(retrievedMessage.content, equals(message.content));
        expect(retrievedMessage.isRead, equals(message.isRead));
      },
    );
  });

  group('Message Model - Example-Based Tests', () {
    test('Message with all message types should round-trip correctly', () {
      for (final type in MessageType.values) {
        final sender = MessageSender(
          userId: 'user-1',
          username: 'testuser',
          avatarUrl: 'https://example.com/avatar.jpg',
        );

        final message = Message(
          id: 'msg-$type',
          conversationId: 'conv-1',
          sender: sender,
          content: 'Test content for $type',
          type: type,
          status: MessageStatus.sent,
          sentAt: DateTime(2024, 1, 15, 10, 30, 0),
          isRead: false,
          isFromCurrentUser: true,
        );

        final json = message.toJson();
        final reconstructedMessage = Message.fromJson(json);

        expect(reconstructedMessage, equals(message));
        expect(reconstructedMessage.type, equals(type));
      }
    });

    test('Message with all status types should round-trip correctly', () {
      for (final status in MessageStatus.values) {
        final sender = MessageSender(
          userId: 'user-1',
          username: 'testuser',
          avatarUrl: 'https://example.com/avatar.jpg',
        );

        final message = Message(
          id: 'msg-$status',
          conversationId: 'conv-1',
          sender: sender,
          content: 'Test content for $status',
          type: MessageType.text,
          status: status,
          sentAt: DateTime(2024, 1, 15, 10, 30, 0),
          isRead: false,
          isFromCurrentUser: true,
        );

        final json = message.toJson();
        final reconstructedMessage = Message.fromJson(json);

        expect(reconstructedMessage, equals(message));
        expect(reconstructedMessage.status, equals(status));
      }
    });

    test('toJson should produce valid JSON structure with snake_case keys', () {
      final sender = MessageSender(
        userId: 'user-123',
        username: 'testuser',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      final message = Message(
        id: 'msg-1',
        conversationId: 'conv-1',
        sender: sender,
        content: 'Hello world',
        type: MessageType.text,
        status: MessageStatus.sent,
        sentAt: DateTime(2024, 1, 15, 10, 30, 0),
        isRead: true,
        isFromCurrentUser: false,
      );

      final json = message.toJson();

      expect(json['id'], equals('msg-1'));
      expect(json['conversation_id'], equals('conv-1'));
      expect(json['content'], equals('Hello world'));
      expect(json['type'], equals('text'));
      expect(json['status'], equals('sent'));
      expect(json['is_read'], equals(true));
      expect(json['is_from_current_user'], equals(false));
      expect(json['sender'], isA<Map<String, dynamic>>());
      expect(json['sender']['user_id'], equals('user-123'));
    });
  });

  group('Message Repository - Example-Based Tests', () {
    late MessageRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = MessageRepository(prefs);
    });

    test('saveMessagesLocally should save multiple messages', () async {
      final sender = MessageSender(
        userId: 'user-1',
        username: 'testuser',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      final messages = [
        Message(
          id: 'msg-1',
          conversationId: 'conv-1',
          sender: sender,
          content: 'First message',
          sentAt: DateTime(2024, 1, 15, 10, 30, 0),
        ),
        Message(
          id: 'msg-2',
          conversationId: 'conv-1',
          sender: sender,
          content: 'Second message',
          sentAt: DateTime(2024, 1, 15, 10, 31, 0),
        ),
      ];

      await repository.saveMessagesLocally(messages);
      final retrieved = await repository.getLocalMessages('conv-1');

      expect(retrieved.length, equals(2));
      expect(retrieved[0].id, equals('msg-1'));
      expect(retrieved[1].id, equals('msg-2'));
    });

    test('deleteLocalMessage should remove specific message', () async {
      final sender = MessageSender(
        userId: 'user-1',
        username: 'testuser',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      final message = Message(
        id: 'msg-to-delete',
        conversationId: 'conv-1',
        sender: sender,
        content: 'Message to delete',
        sentAt: DateTime(2024, 1, 15, 10, 30, 0),
      );

      await repository.saveMessageLocally(message);
      var retrieved = await repository.getLocalMessages('conv-1');
      expect(retrieved.length, equals(1));

      await repository.deleteLocalMessage('msg-to-delete', 'conv-1');
      retrieved = await repository.getLocalMessages('conv-1');
      expect(retrieved.length, equals(0));
    });

    test('clearLocalMessages should remove all messages for conversation', () async {
      final sender = MessageSender(
        userId: 'user-1',
        username: 'testuser',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      final messages = [
        Message(
          id: 'msg-1',
          conversationId: 'conv-1',
          sender: sender,
          content: 'First message',
          sentAt: DateTime(2024, 1, 15, 10, 30, 0),
        ),
        Message(
          id: 'msg-2',
          conversationId: 'conv-1',
          sender: sender,
          content: 'Second message',
          sentAt: DateTime(2024, 1, 15, 10, 31, 0),
        ),
      ];

      await repository.saveMessagesLocally(messages);
      await repository.clearLocalMessages('conv-1');
      final retrieved = await repository.getLocalMessages('conv-1');

      expect(retrieved.length, equals(0));
    });

    test('markAsRead should update message read status', () async {
      final sender = MessageSender(
        userId: 'user-1',
        username: 'testuser',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      final message = Message(
        id: 'msg-1',
        conversationId: 'conv-1',
        sender: sender,
        content: 'Unread message',
        sentAt: DateTime(2024, 1, 15, 10, 30, 0),
        isRead: false,
        status: MessageStatus.delivered,
      );

      await repository.saveMessageLocally(message);
      await repository.markAsRead('msg-1', 'conv-1');
      final retrieved = await repository.getLocalMessages('conv-1');

      expect(retrieved.first.isRead, isTrue);
      expect(retrieved.first.status, equals(MessageStatus.read));
    });
  });
}
