// =============================================================================
// 频道数据模型
// =============================================================================
//
// 定义频道的核心数据结构，采用数据与 UI 状态分离的设计模式。
//
// ## 设计原则
//
// 1. **数据与状态分离**：`ChannelModel` 只包含服务端返回的业务数据，
//    `ChannelUIState` 管理客户端特有的 UI 状态（如未读数、静音、置顶）
//
// 2. **不可变性**：所有模型都是不可变的，通过 `copyWith` 创建新实例
//
// 3. **便捷 getter**：提供格式化和计算属性，避免 UI 层重复逻辑
//
// 4. **Proto 对齐**：字段命名和结构与 protos/channel/channel.proto 保持一致
//
// ## 类结构
//
// - `ChannelModel` - 频道核心数据（来自服务端）
// - `ChannelUIState` - 频道 UI 状态（客户端管理）
// - `SubscriberModel` - 订阅者信息
// - `AdminModel` - 管理员信息

import '../../../pkg/utils/copy_with_utils.dart';
import '../../../pkg/utils/format_utils.dart';
import 'channel_message_model.dart';

// =============================================================================
// 频道核心模型
// =============================================================================

/// 频道核心数据模型
///
/// 表示一个广播频道的完整信息，类似 Telegram Channel。
/// 只包含服务端返回的业务数据，不包含客户端 UI 状态。
///
/// ## 字段分组
///
/// - **基础信息**：id, name, description, avatarUrl, username
/// - **权限信息**：ownerId, adminIds, isSubscribed, isAdmin, isOwner, isPublic
/// - **统计信息**：subscriberCount, messageCount
/// - **时间信息**：createdAt, updatedAt, lastMessageTime
/// - **内容预览**：pinnedMessage, lastMessagePreview
class ChannelModel {
  const ChannelModel({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
    this.avatarUrl,
    this.link,
    required this.ownerId,
    this.adminIds = const [],
    required this.subscriberCount,
    this.messageCount = 0,
    this.createdAt,
    this.updatedAt,
    this.isSubscribed = false,
    this.isAdmin = false,
    this.isOwner = false,
    this.isPublic = true,
    this.pinnedMessage,
    this.lastMessagePreview,
    this.lastMessageTime,
  });

  // ---------------------------------------------------------------------------
  // 基础信息
  // ---------------------------------------------------------------------------

  /// 频道唯一标识
  final String id;

  /// 频道唯一标识符（如 tech_daily，用于 URL）
  final String name;

  /// 频道显示名称（如 "科技日报"）
  final String displayName;

  /// 频道描述（可选）
  final String? description;

  /// 频道头像 URL（可选）
  final String? avatarUrl;

  /// 分享链接（如 https://lesser.app/c/tech_daily）
  final String? link;

  // ---------------------------------------------------------------------------
  // 权限信息
  // ---------------------------------------------------------------------------

  /// 频道所有者 ID
  final String ownerId;

  /// 管理员 ID 列表
  final List<String> adminIds;

  /// 当前用户是否已订阅
  final bool isSubscribed;

  /// 当前用户是否是管理员
  final bool isAdmin;

  /// 当前用户是否是所有者
  final bool isOwner;

  /// 是否为公开频道
  final bool isPublic;

  // ---------------------------------------------------------------------------
  // 统计信息
  // ---------------------------------------------------------------------------

  /// 订阅者数量
  final int subscriberCount;

  /// 消息总数
  final int messageCount;

  // ---------------------------------------------------------------------------
  // 时间信息
  // ---------------------------------------------------------------------------

  /// 创建时间
  final DateTime? createdAt;

  /// 最后更新时间
  final DateTime? updatedAt;

  /// 最后消息时间（用于列表排序）
  final DateTime? lastMessageTime;

  // ---------------------------------------------------------------------------
  // 内容预览
  // ---------------------------------------------------------------------------

  /// 置顶消息（可选）
  final ChannelMessageModel? pinnedMessage;

  /// 最后消息预览文本（用于列表显示）
  final String? lastMessagePreview;

  // ---------------------------------------------------------------------------
  // 便捷 getter
  // ---------------------------------------------------------------------------

  /// 格式化的订阅者数量（如 "1.2K"、"3.5M"）
  String get formattedSubscriberCount => formatSubscriberCount(subscriberCount);

  /// 头像占位符文字
  ///
  /// 当没有头像时显示频道名首字符，如果频道名为空则显示 '#'
  String get avatarPlaceholder => displayName.isNotEmpty ? displayName[0] : '#';

  /// 是否有最后消息
  bool get hasLastMessage {
    final preview = lastMessagePreview;
    return preview != null && preview.isNotEmpty;
  }

  /// 是否有置顶消息
  bool get hasPinnedMessage => pinnedMessage != null;

  /// 兼容旧代码的 lastMessage getter
  @Deprecated('使用 lastMessagePreview 代替')
  String? get lastMessage => lastMessagePreview;

  // ---------------------------------------------------------------------------
  // copyWith & 相等性
  // ---------------------------------------------------------------------------

  /// 复制并修改指定字段
  ChannelModel copyWith({
    String? id,
    String? name,
    String? displayName,
    Object? description = sentinel,
    Object? avatarUrl = sentinel,
    Object? link = sentinel,
    String? ownerId,
    List<String>? adminIds,
    int? subscriberCount,
    int? messageCount,
    Object? createdAt = sentinel,
    Object? updatedAt = sentinel,
    bool? isSubscribed,
    bool? isAdmin,
    bool? isOwner,
    bool? isPublic,
    Object? pinnedMessage = sentinel,
    Object? lastMessagePreview = sentinel,
    Object? lastMessageTime = sentinel,
  }) {
    return ChannelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description == sentinel
          ? this.description
          : castOrNull<String>(description),
      avatarUrl: avatarUrl == sentinel
          ? this.avatarUrl
          : castOrNull<String>(avatarUrl),
      link: link == sentinel ? this.link : castOrNull<String>(link),
      ownerId: ownerId ?? this.ownerId,
      adminIds: adminIds ?? this.adminIds,
      subscriberCount: subscriberCount ?? this.subscriberCount,
      messageCount: messageCount ?? this.messageCount,
      createdAt: createdAt == sentinel
          ? this.createdAt
          : castOrNull<DateTime>(createdAt),
      updatedAt: updatedAt == sentinel
          ? this.updatedAt
          : castOrNull<DateTime>(updatedAt),
      isSubscribed: isSubscribed ?? this.isSubscribed,
      isAdmin: isAdmin ?? this.isAdmin,
      isOwner: isOwner ?? this.isOwner,
      isPublic: isPublic ?? this.isPublic,
      pinnedMessage: pinnedMessage == sentinel
          ? this.pinnedMessage
          : castOrNull<ChannelMessageModel>(pinnedMessage),
      lastMessagePreview: lastMessagePreview == sentinel
          ? this.lastMessagePreview
          : castOrNull<String>(lastMessagePreview),
      lastMessageTime: lastMessageTime == sentinel
          ? this.lastMessageTime
          : castOrNull<DateTime>(lastMessageTime),
    );
  }

  /// 基于 ID 判断相等性
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ChannelModel && id == other.id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ChannelModel(id: $id, name: $name, displayName: $displayName, subscribers: $subscriberCount)';
}

// =============================================================================
// 频道 UI 状态
// =============================================================================

/// 频道 UI 状态
///
/// 管理频道列表项的客户端 UI 状态，与核心数据 [ChannelModel] 分离。
class ChannelUIState {
  const ChannelUIState({
    required this.channelId,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isPinned = false,
  });

  /// 创建空状态（所有值为默认值）
  factory ChannelUIState.empty(String channelId) =>
      ChannelUIState(channelId: channelId);

  /// 关联的频道 ID
  final String channelId;

  /// 未读消息数量
  final int unreadCount;

  /// 是否静音（静音后不显示通知，但仍计数）
  final bool isMuted;

  /// 是否置顶（置顶频道在列表顶部显示）
  final bool isPinned;

  /// 是否有未读消息
  bool get hasUnread => unreadCount > 0;

  /// 复制并修改指定字段
  ChannelUIState copyWith({int? unreadCount, bool? isMuted, bool? isPinned}) {
    return ChannelUIState(
      channelId: channelId,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChannelUIState &&
          channelId == other.channelId &&
          unreadCount == other.unreadCount &&
          isMuted == other.isMuted &&
          isPinned == other.isPinned);

  @override
  int get hashCode => Object.hash(channelId, unreadCount, isMuted, isPinned);

  @override
  String toString() =>
      'ChannelUIState(id: $channelId, unread: $unreadCount, muted: $isMuted, pinned: $isPinned)';
}

// =============================================================================
// 订阅者模型
// =============================================================================

/// 频道订阅者信息
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

  SubscriberModel copyWith({
    String? userId,
    String? username,
    Object? avatarUrl = sentinel,
    DateTime? subscribedAt,
  }) {
    return SubscriberModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl == sentinel
          ? this.avatarUrl
          : castOrNull<String>(avatarUrl),
      subscribedAt: subscribedAt ?? this.subscribedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscriberModel && userId == other.userId);

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() => 'SubscriberModel(userId: $userId, username: $username)';
}

// =============================================================================
// 管理员模型
// =============================================================================

/// 频道管理员信息
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

  AdminModel copyWith({
    String? userId,
    String? username,
    Object? avatarUrl = sentinel,
    bool? isOwner,
    DateTime? addedAt,
  }) {
    return AdminModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl == sentinel
          ? this.avatarUrl
          : castOrNull<String>(avatarUrl),
      isOwner: isOwner ?? this.isOwner,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AdminModel && userId == other.userId);

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() =>
      'AdminModel(userId: $userId, username: $username, isOwner: $isOwner)';
}
