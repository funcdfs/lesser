// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_user.freezed.dart';
part 'chat_user.g.dart';

/// 聊天用户模型
/// 
/// 表示聊天会话中的参与者信息
@freezed
sealed class ChatUser with _$ChatUser {
  const factory ChatUser({
    /// 用户 ID
    required String id,
    
    /// 用户名
    required String username,
    
    /// 用户头像 URL
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    
    /// 是否在线
    @JsonKey(name: 'is_online') @Default(false) bool isOnline,
    
    /// 最后在线时间
    @JsonKey(name: 'last_seen') DateTime? lastSeen,
  }) = _ChatUser;

  factory ChatUser.fromJson(Map<String, dynamic> json) =>
      _$ChatUserFromJson(json);
}
