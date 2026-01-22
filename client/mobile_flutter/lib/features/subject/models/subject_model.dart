// =============================================================================
// 剧集数据模型
// =============================================================================
//
// 定义剧集的核心数据结构，采用数据与 UI 状态分离的设计模式。
//
// ## 设计原则
//
// 1. **数据与状态分离**：`SubjectModel` 只包含服务端返回的业务数据，
//    `SubjectUIState` 管理客户端特有的 UI 状态（如未读数、静音、置顶）
//
// 2. **不可变性**：所有模型都是不可变的，通过 `copyWith` 创建新实例
//
// 3. **便捷 getter**：提供格式化和计算属性，避免 UI 层重复逻辑
//
// 4. **Proto 对齐**：字段命名和结构与 protos/series/series.proto 保持一致
//
// ## 类结构
//
// - `SubjectModel` - 剧集核心数据（来自服务端）
// - `SubjectUIState` - 剧集 UI 状态（客户端管理）
// - `SubscriberModel` - 订阅者信息
// - `AdminModel` - 管理员信息

import '../../../pkg/utils/copy_with_utils.dart';
import '../../../pkg/utils/format_utils.dart';
import 'subject_post_model.dart';

// =============================================================================
// 剧集核心模型
// =============================================================================

/// 剧集核心数据模型
///
/// 表示一个广播剧集的完整信息，类似 Telegram Channel。
/// 只包含服务端返回的业务数据，不包含客户端 UI 状态。
///
/// ## 字段分组
///
/// - **基础信息**：id, name, title, description, coverUrl, link
/// - **权限信息**：ownerId, adminIds, isSubscribed, isAdmin, isOwner, isPublic
/// - **统计信息**：subscriberCount, postCount
/// - **时间信息**：createdAt, updatedAt, lastPostTime
/// - **内容预览**：pinnedPost, lastPostPreview
class SubjectModel {
  const SubjectModel({
    required this.id,
    required this.name,
    required this.title,
    this.description,
    this.coverUrl,
    this.link,
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
    this.isOfficial = false,
    this.isVerified = false,
    this.tags = const [],
    this.pinnedPost,
    this.lastPostPreview,
    this.lastPostTime,
  });

  // ---------------------------------------------------------------------------
  // 基础信息
  // ---------------------------------------------------------------------------

  /// 剧集唯一标识
  final String id;

  /// 剧集唯一标识符（如 tech_daily，用于 URL）
  final String name;

  /// 剧集显示名称（如 "科技日报"）
  final String title;

  /// 剧集描述（可选）
  final String? description;

  /// 剧集封面 URL（可选）
  final String? coverUrl;

  /// 分享链接（如 https://lesser.app/s/tech_daily）
  final String? link;

  // ---------------------------------------------------------------------------
  // 权限信息
  // ---------------------------------------------------------------------------

  /// 剧集所有者 ID
  final String ownerId;

  /// 管理员 ID 列表
  final List<String> adminIds;

  /// 当前用户是否已订阅
  final bool isSubscribed;

  /// 当前用户是否是管理员
  final bool isAdmin;

  /// 当前用户是否是所有者
  final bool isOwner;

  /// 是否为公开剧集
  final bool isPublic;

  /// 是否为官方剧集
  final bool isOfficial;

  /// 是否为认证用户/明星剧集
  final bool isVerified;

  /// 剧集标签 ID 列表
  final List<String> tags;

  // ---------------------------------------------------------------------------
  // 统计信息
  // ---------------------------------------------------------------------------

  /// 订阅者数量
  final int subscriberCount;

  /// 动态总数
  final int postCount;

  // ---------------------------------------------------------------------------
  // 时间信息
  // ---------------------------------------------------------------------------

  /// 创建时间
  final DateTime? createdAt;

  /// 最后更新时间
  final DateTime? updatedAt;

  /// 最后动态时间（用于列表排序）
  final DateTime? lastPostTime;

  // ---------------------------------------------------------------------------
  // 内容预览
  // ---------------------------------------------------------------------------

  /// 置顶动态（可选）
  final SubjectPostModel? pinnedPost;

  /// 最后动态预览文本（用于列表显示）
  final String? lastPostPreview;

  // ---------------------------------------------------------------------------
  // 便捷 getter
  // ---------------------------------------------------------------------------

  /// 格式化的订阅者数量（如 "1.2K"、"3.5M"）
  String get formattedSubscriberCount => formatSubscriberCount(subscriberCount);

  /// 封面占位符文字
  ///
  /// 当没有封面时显示剧集名首字符，如果剧集名为空则显示 '#'
  String get coverPlaceholder => title.isNotEmpty ? title[0] : '#';

  /// 是否有通过最后动态
  bool get hasLastPost {
    final preview = lastPostPreview;
    return preview != null && preview.isNotEmpty;
  }

  /// 是否有置顶动态
  bool get hasPinnedPost => pinnedPost != null;

  // ---------------------------------------------------------------------------
  // copyWith & 相等性
  // ---------------------------------------------------------------------------

  /// 复制并修改指定字段
  SubjectModel copyWith({
    String? id,
    String? name,
    String? title,
    Object? description = sentinel,
    Object? coverUrl = sentinel,
    Object? link = sentinel,
    String? ownerId,
    List<String>? adminIds,
    int? subscriberCount,
    int? postCount,
    Object? createdAt = sentinel,
    Object? updatedAt = sentinel,
    bool? isSubscribed,
    bool? isAdmin,
    bool? isOwner,
    bool? isPublic,
    bool? isOfficial,
    bool? isVerified,
    List<String>? tags,
    Object? pinnedPost = sentinel,
    Object? lastPostPreview = sentinel,
    Object? lastPostTime = sentinel,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      description: description == sentinel
          ? this.description
          : castOrNull<String>(description),
      coverUrl: coverUrl == sentinel
          ? this.coverUrl
          : castOrNull<String>(coverUrl),
      link: link == sentinel ? this.link : castOrNull<String>(link),
      ownerId: ownerId ?? this.ownerId,
      adminIds: adminIds ?? this.adminIds,
      subscriberCount: subscriberCount ?? this.subscriberCount,
      postCount: postCount ?? this.postCount,
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
      isOfficial: isOfficial ?? this.isOfficial,
      isVerified: isVerified ?? this.isVerified,
      tags: tags ?? this.tags,
      pinnedPost: pinnedPost == sentinel
          ? this.pinnedPost
          : castOrNull<SubjectPostModel>(pinnedPost),
      lastPostPreview: lastPostPreview == sentinel
          ? this.lastPostPreview
          : castOrNull<String>(lastPostPreview),
      lastPostTime: lastPostTime == sentinel
          ? this.lastPostTime
          : castOrNull<DateTime>(lastPostTime),
    );
  }

  /// 基于 ID 判断相等性
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SubjectModel && id == other.id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SubjectModel(id: $id, name: $name, title: $title, subscribers: $subscriberCount)';
}

// =============================================================================
// 剧集 UI 状态
// =============================================================================

/// 剧集 UI 状态
///
/// 管理剧集列表项的客户端 UI 状态，与核心数据 [SubjectModel] 分离。
class SubjectUIState {
  const SubjectUIState({
    required this.subjectId,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isPinned = false,
  });



  /// 关联的剧集 ID
  final String subjectId;

  /// 未读动态数量
  final int unreadCount;

  /// 是否静音（静音后不显示通知，但仍计数）
  final bool isMuted;

  /// 是否置顶（置顶剧集在列表顶部显示）
  final bool isPinned;

  /// 是否有未读动态
  bool get hasUnread => unreadCount > 0;

  /// 复制并修改指定字段
  SubjectUIState copyWith({int? unreadCount, bool? isMuted, bool? isPinned}) {
    return SubjectUIState(
      subjectId: subjectId,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubjectUIState &&
          subjectId == other.subjectId &&
          unreadCount == other.unreadCount &&
          isMuted == other.isMuted &&
          isPinned == other.isPinned);

  @override
  int get hashCode => Object.hash(subjectId, unreadCount, isMuted, isPinned);

  @override
  String toString() =>
      'SubjectUIState(id: $subjectId, unread: $unreadCount, muted: $isMuted, pinned: $isPinned)';
}

// =============================================================================
// 订阅者模型
// =============================================================================

/// 剧集订阅者信息
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

/// 剧集管理员信息
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
