// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'chat_user.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

/// 会话模型
/// 
/// 表示两个或多个用户之间的聊天会话
@freezed
sealed class Conversation with _$Conversation {
  const factory Conversation({
    /// 会话 ID
    required String id,
    
    /// 会话参与者列表
    required List<ChatUser> participants,
    
    /// 最后一条消息内容
    @JsonKey(name: 'last_message') String? lastMessage,
    
    /// 最后一条消息时间
    @JsonKey(name: 'last_message_time') DateTime? lastMessageTime,
    
    /// 未读消息数量
    @JsonKey(name: 'unread_count') @Default(0) int unreadCount,
    
    /// 会话创建时间
    @JsonKey(name: 'created_at') required DateTime createdAt,
    
    /// 会话更新时间
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}
