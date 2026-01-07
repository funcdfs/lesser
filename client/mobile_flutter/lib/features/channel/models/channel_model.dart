// 频道数据模型

import 'channel_post_model.dart';

/// 频道
class ChannelModel {
  const ChannelModel({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
    this.username,
    required this.ownerId,
    this.adminIds = const [],
    required this.subscriberCount,
    this.postCount = 0,
    this.createdAt,
    this.updatedAt,
    this.isSubscribed = false,
    this.isAdmin = false,
    this.isOwner = false,
    this.isPublic = true,
    this.pinnedPost,
    // UI 扩展字段
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isPinned = false,
  });

  final String id;
  final String name;
  final String? description;
  final String? avatarUrl;
  final String? username;
  final String ownerId;
  final List<String> adminIds;
  final int subscriberCount;
  final int postCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSubscribed;
  final bool isAdmin;
  final bool isOwner;
  final bool isPublic;
  final ChannelPostModel? pinnedPost;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isMuted;
  final bool isPinned;

  ChannelModel copyWith({
    String? id,
    String? name,
    String? description,
    String? avatarUrl,
    String? username,
    String? ownerId,
    List<String>? adminIds,
    int? subscriberCount,
    int? postCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSubscribed,
    bool? isAdmin,
    bool? isOwner,
    bool? isPublic,
    ChannelPostModel? pinnedPost,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isMuted,
    bool? isPinned,
  }) {
    return ChannelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      username: username ?? this.username,
      ownerId: ownerId ?? this.ownerId,
      adminIds: adminIds ?? this.adminIds,
      subscriberCount: subscriberCount ?? this.subscriberCount,
      postCount: postCount ?? this.postCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      isAdmin: isAdmin ?? this.isAdmin,
      isOwner: isOwner ?? this.isOwner,
      isPublic: isPublic ?? this.isPublic,
      pinnedPost: pinnedPost ?? this.pinnedPost,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  String get formattedSubscriberCount {
    if (subscriberCount >= 10000) {
      return '${(subscriberCount / 10000).toStringAsFixed(1)} 万';
    }
    return subscriberCount.toString();
  }
}

/// 订阅者
class SubscriberModel {
  const SubscriberModel({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.subscribedAt,
  });

  final String userId;
  final String username;
  final String? avatarUrl;
  final DateTime subscribedAt;
}

/// 管理员
class AdminModel {
  const AdminModel({
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.isOwner = false,
    required this.addedAt,
  });

  final String userId;
  final String username;
  final String? avatarUrl;
  final bool isOwner;
  final DateTime addedAt;
}
