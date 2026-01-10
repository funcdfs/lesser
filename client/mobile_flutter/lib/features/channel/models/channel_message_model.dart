// =============================================================================
// 频道消息数据模型
// =============================================================================
//
// 定义频道消息的数据结构，支持富文本内容、媒体附件、反应和评论。
//
// ## 设计特点
//
// 1. **哨兵值模式**：`copyWith` 方法使用 `_notProvided` 哨兵值区分
//    "传入 null 清除字段" 和 "未传参保留原值" 两种情况
//
// 2. **乐观更新**：提供 `withReactionAdded`、`withReactionRemoved` 等快捷方法，
//    支持 UI 层在等待服务端响应前立即更新显示
//
// 3. **预计算属性**：`displayReactions` 等 getter 在模型层预计算，
//    避免 UI 层每次 build 重复创建列表
//
// ## 使用示例
//
// ```dart
// // 创建消息
// final message = ChannelMessageModel(
//   id: 'm1',
//   channelId: 'c1',
//   authorId: 'u1',
//   content: '这是一条消息',
//   createdAt: DateTime.now(),
// );
//
// // 乐观更新：添加反应
// final updated = message.withReactionAdded('👍');
//
// // 清除可选字段
// final cleared = message.copyWith(myReaction: null);
// ```

import '../../../pkg/utils/format_utils.dart';
import 'reaction_model.dart';

/// 用于 copyWith 方法中区分 null 和未传参的哨兵值
///
/// 这种模式解决了 Dart 中 `copyWith` 方法的常见问题：
/// - 传入 `null` 应该清除字段
/// - 不传参应该保留原值
///
/// 使用 `Object()` 作为哨兵值，因为它是唯一的实例，不会与任何有效值冲突。
const _notProvided = Object();

// =============================================================================
// 频道消息模型
// =============================================================================

/// 频道消息
///
/// 表示频道中的一条消息，包含文本内容、媒体附件、反应统计和评论信息。
///
/// ## 字段分组
///
/// - **核心字段**：id, channelId, authorId, content, createdAt
/// - **媒体字段**：mediaUrls, linkUrl, linkTitle
/// - **状态字段**：isPinned, isEdited, updatedAt
/// - **反应字段**：reactionStats, myReaction
/// - **评论字段**：commentCount, commentAvatars
/// - **统计字段**：viewCount
class ChannelMessageModel {
  const ChannelMessageModel({
    required this.id,
    required this.channelId,
    required this.authorId,
    required this.content,
    this.mediaUrls = const [],
    this.viewCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.isPinned = false,
    this.isEdited = false,
    this.authorName,
    this.reactionStats = ReactionStats.empty,
    this.myReaction,
    this.commentCount = 0,
    this.linkUrl,
    this.linkTitle,
    this.commentAvatars = const [],
  });

  // ---------------------------------------------------------------------------
  // 核心字段
  // ---------------------------------------------------------------------------

  /// 消息唯一标识
  final String id;

  /// 所属频道 ID
  final String channelId;

  /// 作者用户 ID
  final String authorId;

  /// 消息文本内容
  final String content;

  /// 创建时间
  final DateTime createdAt;

  /// 最后更新时间（编辑后更新）
  final DateTime? updatedAt;

  /// 作者显示名称（可选，用于 UI 显示）
  final String? authorName;

  // ---------------------------------------------------------------------------
  // 媒体字段
  // ---------------------------------------------------------------------------

  /// 媒体附件 URL 列表（图片、视频等）
  final List<String> mediaUrls;

  /// 链接 URL（消息中包含的外部链接）
  final String? linkUrl;

  /// 链接标题（用于链接预览卡片）
  final String? linkTitle;

  // ---------------------------------------------------------------------------
  // 状态字段
  // ---------------------------------------------------------------------------

  /// 是否置顶
  final bool isPinned;

  /// 是否已编辑
  final bool isEdited;

  // ---------------------------------------------------------------------------
  // 反应字段
  // ---------------------------------------------------------------------------

  /// 反应统计数据
  ///
  /// 使用 [ReactionStats] 存储 emoji -> 数量的映射，
  /// 支持高效的增删改查操作。
  final ReactionStats reactionStats;

  /// 当前用户的反应 emoji（如果有）
  ///
  /// 用于在 UI 中高亮显示用户已选择的反应。
  final String? myReaction;

  // ---------------------------------------------------------------------------
  // 评论字段
  // ---------------------------------------------------------------------------

  /// 评论数量
  final int commentCount;

  /// 最近评论者头像列表（用于评论入口预览）
  final List<String> commentAvatars;

  // ---------------------------------------------------------------------------
  // 统计字段
  // ---------------------------------------------------------------------------

  /// 浏览次数
  final int viewCount;

  // ---------------------------------------------------------------------------
  // 便捷 getter
  // ---------------------------------------------------------------------------

  /// 是否有反应
  bool get hasReactions => reactionStats.hasReactions;

  /// 当前用户是否已添加反应
  bool get hasReacted => myReaction != null;

  /// 是否有评论
  bool get hasComments => commentCount > 0;

  /// 是否有媒体附件
  bool get hasMedia => mediaUrls.isNotEmpty;

  /// 是否有链接
  bool get hasLink => linkUrl != null;

  /// 获取完整的反应列表（用于反应详情页）
  List<ReactionSummary> get reactions =>
      reactionStats.toSummaryList(myReaction);

  /// 获取用于气泡内展示的反应列表（最多 4 个）
  ///
  /// 限制数量是为了保持气泡布局的整洁，更多反应可在详情页查看。
  List<ReactionSummary> get displayReactions =>
      reactionStats.toSummaryList(myReaction).take(4).toList();

  /// 格式化的浏览数（如 "1.2K"、"3.5M"）
  String get formattedViewCount => formatViewCount(viewCount);

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// 复制并修改指定字段
  ///
  /// 对于可选字段（如 `myReaction`、`linkUrl` 等），使用哨兵值模式：
  /// - 不传参：保留原值
  /// - 传入 `null`：清除该字段
  /// - 传入具体值：更新为新值
  ChannelMessageModel copyWith({
    String? id,
    String? channelId,
    String? authorId,
    String? content,
    List<String>? mediaUrls,
    int? viewCount,
    DateTime? createdAt,
    Object? updatedAt = _notProvided,
    bool? isPinned,
    bool? isEdited,
    Object? authorName = _notProvided,
    ReactionStats? reactionStats,
    Object? myReaction = _notProvided,
    int? commentCount,
    Object? linkUrl = _notProvided,
    Object? linkTitle = _notProvided,
    List<String>? commentAvatars,
  }) {
    return ChannelMessageModel(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt == _notProvided
          ? this.updatedAt
          : _castOrNull<DateTime>(updatedAt),
      isPinned: isPinned ?? this.isPinned,
      isEdited: isEdited ?? this.isEdited,
      authorName: authorName == _notProvided
          ? this.authorName
          : _castOrNull<String>(authorName),
      reactionStats: reactionStats ?? this.reactionStats,
      myReaction: myReaction == _notProvided
          ? this.myReaction
          : _castOrNull<String>(myReaction),
      commentCount: commentCount ?? this.commentCount,
      linkUrl: linkUrl == _notProvided
          ? this.linkUrl
          : _castOrNull<String>(linkUrl),
      linkTitle: linkTitle == _notProvided
          ? this.linkTitle
          : _castOrNull<String>(linkTitle),
      commentAvatars: commentAvatars ?? this.commentAvatars,
    );
  }

  /// 安全类型转换辅助方法
  ///
  /// 将 `Object?` 转换为目标类型 `T?`，类型不匹配时返回 null 并触发断言。
  static T? _castOrNull<T>(Object? value) {
    if (value == null) return null;
    if (value is T) return value as T;
    assert(false, 'copyWith: 期望类型 $T，实际类型 ${value.runtimeType}');
    return null;
  }

  // ---------------------------------------------------------------------------
  // 乐观更新快捷方法
  // ---------------------------------------------------------------------------

  /// 添加反应（乐观更新）
  ///
  /// 立即返回更新后的消息，用于 UI 即时反馈。
  /// 如果服务端请求失败，调用方应回滚到原始状态。
  ChannelMessageModel withReactionAdded(String emoji) => copyWith(
    reactionStats: reactionStats.withAdded(emoji),
    myReaction: emoji,
  );

  /// 移除反应（乐观更新）
  ///
  /// 如果当前没有反应，返回 this 避免不必要的对象创建。
  ChannelMessageModel withReactionRemoved() {
    final currentReaction = myReaction;
    if (currentReaction == null) return this;

    return ChannelMessageModel(
      id: id,
      channelId: channelId,
      authorId: authorId,
      content: content,
      mediaUrls: mediaUrls,
      viewCount: viewCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isPinned: isPinned,
      isEdited: isEdited,
      authorName: authorName,
      reactionStats: reactionStats.withRemoved(currentReaction),
      myReaction: null,
      commentCount: commentCount,
      linkUrl: linkUrl,
      linkTitle: linkTitle,
      commentAvatars: commentAvatars,
    );
  }

  /// 切换反应（乐观更新）
  ///
  /// 如果已有相同反应则移除，否则添加新反应（同时移除旧反应）。
  ChannelMessageModel withReactionToggled(String emoji) {
    if (myReaction == emoji) {
      return withReactionRemoved();
    }
    return copyWith(
      reactionStats: reactionStats.withToggled(myReaction, emoji),
      myReaction: emoji,
    );
  }

  /// 评论数 +1（乐观更新）
  ChannelMessageModel withCommentAdded() =>
      copyWith(commentCount: commentCount + 1);

  // ---------------------------------------------------------------------------
  // 相等性
  // ---------------------------------------------------------------------------

  /// 基于 ID 判断相等性
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChannelMessageModel && id == other.id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    final preview = content.length > 20
        ? '${content.substring(0, 20)}...'
        : content;
    return 'ChannelMessageModel(id: $id, content: $preview)';
  }
}
