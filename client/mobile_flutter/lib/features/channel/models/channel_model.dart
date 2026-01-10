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
// ## 类结构
//
// - `ChannelModel` - 频道核心数据（来自服务端）
// - `ChannelUIState` - 频道 UI 状态（客户端管理）
// - `SubscriberModel` - 订阅者信息
// - `AdminModel` - 管理员信息

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
/// - **内容预览**：pinnedMessage, lastMessage
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
    this.messageCount = 0,
    this.createdAt,
    this.updatedAt,
    this.isSubscribed = false,
    this.isAdmin = false,
    this.isOwner = false,
    this.isPublic = true,
    this.pinnedMessage,
    this.lastMessage,
    this.lastMessageTime,
  });

  // ---------------------------------------------------------------------------
  // 基础信息
  // ---------------------------------------------------------------------------

  /// 频道唯一标识
  final String id;

  /// 频道显示名称
  final String name;

  /// 频道描述（可选）
  final String? description;

  /// 频道头像 URL（可选）
  final String? avatarUrl;

  /// 频道用户名（用于分享链接，如 @channel_name）
  final String? username;

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
  final String? lastMessage;

  // ---------------------------------------------------------------------------
  // 便捷 getter
  // ---------------------------------------------------------------------------

  /// 格式化的订阅者数量（如 "1.2K"、"3.5M"）
  String get formattedSubscriberCount => formatSubscriberCount(subscriberCount);

  /// 头像占位符文字
  ///
  /// 当没有头像时显示频道名首字符，如果频道名为空则显示 '#'
  String get avatarPlaceholder => name.isNotEmpty ? name[0] : '#';

  /// 是否有最后消息
  bool get hasLastMessage => lastMessage != null && lastMessage!.isNotEmpty;

  /// 是否有置顶消息
  bool get hasPinnedMessage => pinnedMessage != null;

  // ---------------------------------------------------------------------------
  // copyWith & 相等性
  // ---------------------------------------------------------------------------

  /// 复制并修改指定字段
  ChannelModel copyWith({
    String? id,
    String? name,
    String? description,
    String? avatarUrl,
    String? username,
    String? ownerId,
    List<String>? adminIds,
    int? subscriberCount,
    int? messageCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSubscribed,
    bool? isAdmin,
    bool? isOwner,
    bool? isPublic,
    ChannelMessageModel? pinnedMessage,
    String? lastMessage,
    DateTime? lastMessageTime,
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
      messageCount: messageCount ?? this.messageCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      isAdmin: isAdmin ?? this.isAdmin,
      isOwner: isOwner ?? this.isOwner,
      isPublic: isPublic ?? this.isPublic,
      pinnedMessage: pinnedMessage ?? this.pinnedMessage,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
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
      'ChannelModel(id: $id, name: $name, subscribers: $subscriberCount)';
}

// =============================================================================
// 频道 UI 状态
// =============================================================================

/// 频道 UI 状态
///
/// 管理频道列表项的客户端 UI 状态，与核心数据 [ChannelModel] 分离。
/// 这种设计允许 UI 状态独立更新，而不影响业务数据。
///
/// ## 使用场景
///
/// - 未读消息计数
/// - 静音状态（不显示通知）
/// - 置顶状态（列表顶部显示）
///
/// ## 状态管理
///
/// UI 状态由 [ChannelHandler] 管理，存储在 `Map<String, ChannelUIState>` 中，
/// 通过 `channelId` 关联到对应的频道。
class ChannelUIState {
  const ChannelUIState({
    required this.channelId,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isPinned = false,
  });

  /// 关联的频道 ID
  final String channelId;

  /// 未读消息数量
  final int unreadCount;

  /// 是否静音（静音后不显示通知，但仍计数）
  final bool isMuted;

  /// 是否置顶（置顶频道在列表顶部显示）
  final bool isPinned;

  // ---------------------------------------------------------------------------
  // 便捷 getter
  // ---------------------------------------------------------------------------

  /// 是否有未读消息
  bool get hasUnread => unreadCount > 0;

  // ---------------------------------------------------------------------------
  // copyWith & 相等性
  // ---------------------------------------------------------------------------

  /// 复制并修改指定字段
  ChannelUIState copyWith({int? unreadCount, bool? isMuted, bool? isPinned}) {
    return ChannelUIState(
      channelId: channelId,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  /// 比较所有字段，确保状态变化能触发 UI 重建
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
///
/// 用于显示订阅者列表或订阅者详情。
class SubscriberModel {
  const SubscriberModel({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.subscribedAt,
  });

  /// 用户 ID
  final String userId;

  /// 用户名
  final String username;

  /// 头像 URL
  final String? avatarUrl;

  /// 订阅时间
  final DateTime subscribedAt;
}

// =============================================================================
// 管理员模型
// =============================================================================

/// 频道管理员信息
///
/// 用于显示管理员列表或管理员详情。
class AdminModel {
  const AdminModel({
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.isOwner = false,
    required this.addedAt,
  });

  /// 用户 ID
  final String userId;

  /// 用户名
  final String username;

  /// 头像 URL
  final String? avatarUrl;

  /// 是否是频道所有者
  final bool isOwner;

  /// 被添加为管理员的时间
  final DateTime addedAt;
}
