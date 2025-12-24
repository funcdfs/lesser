/// 消息业务模型
///
/// 定义：聊天消息的业务结构和字段
/// ❌ 不包含 UI / JSON / API 字段
class Message {
  /// 消息 ID
  final String id;

  /// 发送者信息
  final MessageSender sender;

  /// 消息内容
  final String content;

  /// 消息类型
  final MessageType type;

  /// 发送时间
  final DateTime sentAt;

  /// 是否已读
  final bool isRead;

  /// 是否是当前用户发送的
  final bool isFromCurrentUser;

  Message({
    required this.id,
    required this.sender,
    required this.content,
    required this.type,
    required this.sentAt,
    required this.isRead,
    required this.isFromCurrentUser,
  });

  /// 创建副本
  Message copyWith({
    String? id,
    MessageSender? sender,
    String? content,
    MessageType? type,
    DateTime? sentAt,
    bool? isRead,
    bool? isFromCurrentUser,
  }) {
    return Message(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      type: type ?? this.type,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
      isFromCurrentUser: isFromCurrentUser ?? this.isFromCurrentUser,
    );
  }
}

/// 消息类型
enum MessageType {
  /// 文字消息
  text,

  /// 图片消息
  image,

  /// 视频消息
  video,

  /// 音频消息
  audio,

  /// 系统消息
  system,
}

/// 消息发送者信息
class MessageSender {
  /// 用户 ID
  final String userId;

  /// 用户名
  final String username;

  /// 用户头像 URL
  final String avatarUrl;

  MessageSender({
    required this.userId,
    required this.username,
    required this.avatarUrl,
  });
}
