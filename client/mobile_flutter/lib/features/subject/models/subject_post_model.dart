// =============================================================================
// 剧集动态数据模型
// =============================================================================
//
// 定义剧集动态的数据结构，支持富文本内容、媒体附件、反应和评论。
//
// ## 设计特点
//
// 1. **哨兵值模式**：`copyWith` 方法使用公共 `sentinel` 哨兵值区分
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
// // 创建动态
// final post = SeriesPostModel(
//   id: 'm1',
//   seriesId: 's1',
//   authorId: 'u1',
//   content: '这是一条动态',
//   createdAt: DateTime.now(),
// );
//
// // 乐观更新：添加反应
// final updated = post.withReactionAdded('👍');
//
// // 清除可选字段
// final cleared = post.copyWith(myReaction: null);
// ```

import '../../../pkg/utils/copy_with_utils.dart';
import '../../../pkg/utils/format_utils.dart';
import 'reaction_model.dart';

// =============================================================================
// 剧集动态模型
// =============================================================================

/// 剧集动态
///
/// 表示剧集中的一条动态，包含文本内容、媒体附件、反应统计和评论信息。
///
/// ## 字段分组
///
/// - **核心字段**：id, seriesId, authorId, content, createdAt
/// - **媒体字段**：mediaUrls, linkUrl, linkTitle
/// - **状态字段**：isPinned, isEdited, updatedAt
/// - **反应字段**：reactionStats, myReaction
/// - **评论字段**：commentCount, commentAvatars
/// - **统计字段**：viewCount
class SubjectPostModel {
  const SubjectPostModel({
    required this.id,
    required this.subjectId,
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

  /// 动态唯一标识
  final String id;

  /// 所属剧集 ID
  final String subjectId;

  /// 作者用户 ID
  final String authorId;

  /// 动态文本内容
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

  /// 链接 URL（动态中包含的外部链接）
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
  SubjectPostModel copyWith({
    String? id,
    String? subjectId,
    String? authorId,
    String? content,
    List<String>? mediaUrls,
    int? viewCount,
    DateTime? createdAt,
    Object? updatedAt = sentinel,
    bool? isPinned,
    bool? isEdited,
    Object? authorName = sentinel,
    ReactionStats? reactionStats,
    Object? myReaction = sentinel,
    int? commentCount,
    Object? linkUrl = sentinel,
    Object? linkTitle = sentinel,
    List<String>? commentAvatars,
  }) {
    return SubjectPostModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt == sentinel
          ? this.updatedAt
          : castOrNull<DateTime>(updatedAt),
      isPinned: isPinned ?? this.isPinned,
      isEdited: isEdited ?? this.isEdited,
      authorName: authorName == sentinel
          ? this.authorName
          : castOrNull<String>(authorName),
      reactionStats: reactionStats ?? this.reactionStats,
      myReaction: myReaction == sentinel
          ? this.myReaction
          : castOrNull<String>(myReaction),
      commentCount: commentCount ?? this.commentCount,
      linkUrl: linkUrl == sentinel ? this.linkUrl : castOrNull<String>(linkUrl),
      linkTitle: linkTitle == sentinel
          ? this.linkTitle
          : castOrNull<String>(linkTitle),
      commentAvatars: commentAvatars ?? this.commentAvatars,
    );
  }

  // ---------------------------------------------------------------------------
  // 乐观更新快捷方法
  // ---------------------------------------------------------------------------

  /// 添加反应（乐观更新）
  ///
  /// 立即返回更新后的动态，用于 UI 即时反馈。
  /// 如果服务端请求失败，调用方应回滚到原始状态。
  SubjectPostModel withReactionAdded(String emoji) => copyWith(
    reactionStats: reactionStats.withAdded(emoji),
    myReaction: emoji,
  );

  /// 移除反应（乐观更新）
  ///
  /// 如果当前没有反应，返回 this 避免不必要的对象创建。
  SubjectPostModel withReactionRemoved() {
    final currentReaction = myReaction;
    if (currentReaction == null) return this;

    return copyWith(
      reactionStats: reactionStats.withRemoved(currentReaction),
      myReaction: null,
    );
  }

  /// 切换反应（乐观更新）
  ///
  /// 如果已有相同反应则移除，否则添加新反应（同时移除旧反应）。
  SubjectPostModel withReactionToggled(String emoji) {
    if (myReaction == emoji) {
      return withReactionRemoved();
    }
    return copyWith(
      reactionStats: reactionStats.withToggled(myReaction, emoji),
      myReaction: emoji,
    );
  }

  /// 评论数 +1（乐观更新）
  SubjectPostModel withCommentAdded() =>
      copyWith(commentCount: commentCount + 1);

  // ---------------------------------------------------------------------------
  // 相等性
  // ---------------------------------------------------------------------------

  /// 基于 ID 判断相等性
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubjectPostModel && id == other.id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    final preview = content.length > 20
        ? '${content.substring(0, 20)}...'
        : content;
    return 'SubjectPostModel(id: $id, content: $preview)';
  }
}
