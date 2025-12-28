import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';
import 'message.dart';

/// Conversation type enum
enum ConversationType { private, group, channel }

/// Conversation entity
class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.type,
    required this.members,
    required this.createdAt,
    this.name,
    this.creatorId,
    this.lastMessage,
    this.unreadCount = 0,
  });

  final String id;
  final ConversationType type;
  final List<User> members;
  final DateTime createdAt;
  final String? name;
  final String? creatorId;
  final Message? lastMessage;
  final int unreadCount;

  @override
  List<Object?> get props => [
        id,
        type,
        members,
        createdAt,
        name,
        creatorId,
        lastMessage,
        unreadCount,
      ];
}
