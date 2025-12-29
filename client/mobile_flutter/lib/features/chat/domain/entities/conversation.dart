import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';
import 'message.dart';

/// copyWith 中用于区分 null 和未提供的哨兵值
const _sentinel = Object();

/// 会话类型枚举
enum ConversationType { private, group, channel }

/// 会话实体
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

  Conversation copyWith({
    String? id,
    ConversationType? type,
    List<User>? members,
    DateTime? createdAt,
    Object? name = _sentinel,
    Object? creatorId = _sentinel,
    Object? lastMessage = _sentinel,
    int? unreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      type: type ?? this.type,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      name: name == _sentinel ? this.name : name as String?,
      creatorId: creatorId == _sentinel ? this.creatorId : creatorId as String?,
      lastMessage: lastMessage == _sentinel ? this.lastMessage : lastMessage as Message?,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

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
