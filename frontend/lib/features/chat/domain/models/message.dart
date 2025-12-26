// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

/// 消息类型
enum MessageType {
  /// 文字消息
  @JsonValue('text')
  text,

  /// 图片消息
  @JsonValue('image')
  image,

  /// 视频消息
  @JsonValue('video')
  video,

  /// 音频消息
  @JsonValue('audio')
  audio,

  /// 系统消息
  @JsonValue('system')
  system,
}

/// 消息状态
enum MessageStatus {
  /// 发送中
  @JsonValue('sending')
  sending,

  /// 已发送
  @JsonValue('sent')
  sent,

  /// 已送达
  @JsonValue('delivered')
  delivered,

  /// 已读
  @JsonValue('read')
  read,

  /// 发送失败
  @JsonValue('failed')
  failed,
}

/// 消息发送者信息
@freezed
sealed class MessageSender with _$MessageSender {
  const factory MessageSender({
    /// 用户 ID
    @JsonKey(name: 'user_id') required String userId,

    /// 用户名
    required String username,

    /// 用户头像 URL
    @JsonKey(name: 'avatar_url') required String avatarUrl,
  }) = _MessageSender;

  factory MessageSender.fromJson(Map<String, dynamic> json) =>
      _$MessageSenderFromJson(json);
}

/// Helper function to convert MessageSender to JSON
Map<String, dynamic> _senderToJson(MessageSender sender) => sender.toJson();

/// Helper function to convert JSON to MessageSender
MessageSender _senderFromJson(Map<String, dynamic> json) => MessageSender.fromJson(json);

/// 消息业务模型
///
/// 定义：聊天消息的业务结构和字段
@freezed
sealed class Message with _$Message {
  const factory Message({
    /// 消息 ID
    required String id,

    /// 会话 ID
    @JsonKey(name: 'conversation_id') required String conversationId,

    /// 发送者信息
    @JsonKey(toJson: _senderToJson, fromJson: _senderFromJson) required MessageSender sender,

    /// 消息内容
    required String content,

    /// 消息类型
    @Default(MessageType.text) MessageType type,

    /// 消息状态
    @Default(MessageStatus.sent) MessageStatus status,

    /// 发送时间
    @JsonKey(name: 'sent_at') required DateTime sentAt,

    /// 是否已读
    @JsonKey(name: 'is_read') @Default(false) bool isRead,

    /// 是否是当前用户发送的
    @JsonKey(name: 'is_from_current_user') @Default(false) bool isFromCurrentUser,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
