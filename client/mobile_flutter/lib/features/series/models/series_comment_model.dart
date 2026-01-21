// =============================================================================
// 剧集评论模型
// =============================================================================
//
// 定义剧集评论相关的数据结构，包括评论、作者、媒体附件和输入状态。
//
// ## 设计说明
//
// 1. **与公共评论组件集成**：通过 `SeriesCommentModelExt` 扩展提供转换方法，
//    将剧集评论转换为公共评论组件可用的格式
//
// 2. **数据与状态分离**：`SeriesCommentModel` 存储业务数据，
//    `CommentUIState` 管理临时 UI 状态
//
// 3. **哨兵值模式**：`copyWith` 方法使用公共 `sentinel` 哨兵值，
//    支持传入 null 清除可选字段
//
// ## 类结构
//
// - `CommentMediaType` - 媒体类型枚举
// - `CommentMedia` - 媒体附件模型
// - `CommentAuthor` - 评论作者模型
// - `SeriesCommentModel` - 评论核心模型
// - `CommentUIState` - 评论 UI 状态
// - `SeriesMessageContext` - 动态上下文（评论页头部用）
// - `SeriesCommentInputState` - 评论输入状态

import '../../../pkg/comment/comment.dart' as pkg_comment;
import '../../../pkg/utils/copy_with_utils.dart';

// 重新导出公共类型，方便外部使用
export '../../../pkg/comment/comment.dart' show CommentIconState, ReplyTarget;

// =============================================================================
// 媒体类型
// =============================================================================

/// 评论媒体类型
enum CommentMediaType {
  /// 静态图片
  image,

  /// 视频
  video,

  /// 动图
  gif;

  /// 是否为动态媒体（视频或动图）
  bool get isAnimated => this == video || this == gif;
}

// =============================================================================
// 媒体附件
// =============================================================================

/// 评论媒体附件
///
/// 表示评论中包含的图片、视频或动图。
class CommentMedia {
  const CommentMedia({
    required this.url,
    required this.type,
    this.width,
    this.height,
    this.thumbnailUrl,
    this.durationMs,
    this.blurhash,
  });

  /// 媒体资源 URL
  final String url;

  /// 媒体类型
  final CommentMediaType type;

  /// 原始宽度（像素）
  final int? width;

  /// 原始高度（像素）
  final int? height;

  /// 缩略图 URL（用于视频预览）
  final String? thumbnailUrl;

  /// 视频时长（毫秒）
  final int? durationMs;

  /// BlurHash 占位符（用于加载时显示模糊预览）
  final String? blurhash;

  /// 宽高比（用于布局计算）
  double? get aspectRatio {
    final w = width;
    final h = height;
    if (w == null || h == null || h == 0) return null;
    return w / h;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CommentMedia && url == other.url);

  @override
  int get hashCode => url.hashCode;
}

// =============================================================================
// 评论作者
// =============================================================================

/// 评论作者
///
/// 包含作者的基本信息和在剧集中的角色。
class CommentAuthor {
  const CommentAuthor({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    this.isVerified = false,
    this.isSeriesOwner = false,
    this.isSeriesAdmin = false,
  });

  /// 用户 ID
  final String id;

  /// 用户名（唯一标识，如 @username）
  final String username;

  /// 显示名称
  final String displayName;

  /// 头像 URL
  final String avatarUrl;

  /// 是否已认证
  final bool isVerified;

  /// 是否是剧集所有者
  final bool isSeriesOwner;

  /// 是否是剧集管理员
  final bool isSeriesAdmin;

  /// 已注销用户的占位符
  static const deleted = CommentAuthor(
    id: '',
    username: 'deleted',
    displayName: '已注销用户',
    avatarUrl: '',
  );

  /// 是否为已注销用户
  bool get isDeleted => id.isEmpty;

  /// 是否有特殊权限（所有者或管理员）
  bool get hasPrivilege => isSeriesOwner || isSeriesAdmin;

  /// 角色标签（用于 UI 显示）
  String? get roleLabel {
    if (isSeriesOwner) return '剧集主';
    if (isSeriesAdmin) return '管理员';
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CommentAuthor && id == other.id);

  @override
  int get hashCode => id.hashCode;
}

// =============================================================================
// 剧集评论模型
// =============================================================================

/// 剧集评论
///
/// 表示剧集动态下的一条评论，支持嵌套回复。
class SeriesCommentModel {
  const SeriesCommentModel({
    required this.id,
    required this.postId,
    required this.seriesId,
    required this.author,
    required this.content,
    this.media = const [],
    this.replyTo,
    this.replyCount = 0,
    this.likeCount = 0,
    this.isLiked = false,
    required this.createdAtMs,
    this.isDeleted = false,
    this.isPinned = false,
    this.isOwn = false,
    this.interactionState = pkg_comment.CommentIconState.normal,
    this.isViewed = false,
    this.hasMyReply = false,
  });

  /// 评论唯一标识
  final String id;

  /// 所属动态 ID
  final String postId;

  /// 所属剧集 ID
  final String seriesId;

  /// 评论作者
  final CommentAuthor author;

  /// 评论文本内容
  final String content;

  /// 创建时间（毫秒时间戳）
  final int createdAtMs;

  /// 回复目标（如果是回复其他评论）
  final pkg_comment.ReplyTarget? replyTo;

  /// 回复数量
  final int replyCount;

  /// 点赞数量
  final int likeCount;

  /// 当前用户是否已点赞
  final bool isLiked;

  /// 评论交互状态（用于 UI 图标显示）
  final pkg_comment.CommentIconState interactionState;

  /// 是否已删除
  final bool isDeleted;

  /// 是否置顶
  final bool isPinned;

  /// 是否是当前用户发布的
  final bool isOwn;

  /// 是否已查看
  final bool isViewed;

  /// 当前用户是否有回复
  final bool hasMyReply;

  /// 媒体附件列表
  final List<CommentMedia> media;

  // ---------------------------------------------------------------------------
  // 便捷 getter
  // ---------------------------------------------------------------------------

  /// 是否有回复
  bool get hasReplies => replyCount > 0;

  /// 是否是回复（而非根评论）
  bool get isReply => replyTo != null;

  /// 是否有媒体附件
  bool get hasMedia => media.isNotEmpty;

  /// 创建时间（DateTime 格式）
  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(createdAtMs);

  // ---------------------------------------------------------------------------
  // copyWith & 乐观更新
  // ---------------------------------------------------------------------------

  /// 复制并修改指定字段
  ///
  /// 对于可选字段（如 `replyTo`），使用哨兵值模式：
  /// - 不传参：保留原值
  /// - 传入 `null`：清除该字段
  /// - 传入具体值：更新为新值
  SeriesCommentModel copyWith({
    String? id,
    String? postId,
    String? seriesId,
    CommentAuthor? author,
    String? content,
    List<CommentMedia>? media,
    Object? replyTo = sentinel,
    int? replyCount,
    int? likeCount,
    bool? isLiked,
    int? createdAtMs,
    bool? isDeleted,
    bool? isPinned,
    bool? isOwn,
    pkg_comment.CommentIconState? interactionState,
    bool? isViewed,
    bool? hasMyReply,
  }) {
    return SeriesCommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      seriesId: seriesId ?? this.seriesId,
      author: author ?? this.author,
      content: content ?? this.content,
      media: media ?? this.media,
      replyTo: replyTo == sentinel
          ? this.replyTo
          : castOrNull<pkg_comment.ReplyTarget>(replyTo),
      replyCount: replyCount ?? this.replyCount,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      isDeleted: isDeleted ?? this.isDeleted,
      isPinned: isPinned ?? this.isPinned,
      isOwn: isOwn ?? this.isOwn,
      interactionState: interactionState ?? this.interactionState,
      isViewed: isViewed ?? this.isViewed,
      hasMyReply: hasMyReply ?? this.hasMyReply,
    );
  }

  /// 切换点赞状态（乐观更新）
  SeriesCommentModel withLikeToggled() => copyWith(
    likeCount: isLiked ? likeCount - 1 : likeCount + 1,
    isLiked: !isLiked,
  );

  /// 回复数 +1（乐观更新）
  SeriesCommentModel withReplyAdded() => copyWith(replyCount: replyCount + 1);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesCommentModel && id == other.id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    final preview = content.length > 20
        ? '${content.substring(0, 20)}...'
        : content;
    return 'SeriesCommentModel(id: $id, author: ${author.displayName}, content: $preview)';
  }
}

// =============================================================================
// 评论 UI 状态
// =============================================================================

/// 评论 UI 状态
///
/// 管理评论的临时 UI 状态，与核心数据分离。
class CommentUIState {
  const CommentUIState({
    required this.commentId,
    this.isHighlighted = false,
    this.isExpanded = false,
    this.isSubmitting = false,
  });

  /// 关联的评论 ID
  final String commentId;

  /// 是否高亮显示
  final bool isHighlighted;

  /// 回复列表是否展开
  final bool isExpanded;

  /// 是否正在提交操作
  final bool isSubmitting;

  /// 复制并修改指定字段
  CommentUIState copyWith({
    bool? isHighlighted,
    bool? isExpanded,
    bool? isSubmitting,
  }) {
    return CommentUIState(
      commentId: commentId,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isExpanded: isExpanded ?? this.isExpanded,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  /// 设置高亮状态
  CommentUIState withHighlight(bool value) => copyWith(isHighlighted: value);

  /// 设置提交状态
  CommentUIState withSubmitting(bool value) => copyWith(isSubmitting: value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommentUIState &&
          commentId == other.commentId &&
          isHighlighted == other.isHighlighted &&
          isExpanded == other.isExpanded &&
          isSubmitting == other.isSubmitting);

  @override
  int get hashCode =>
      Object.hash(commentId, isHighlighted, isExpanded, isSubmitting);

  @override
  String toString() =>
      'CommentUIState(id: $commentId, highlighted: $isHighlighted, '
      'expanded: $isExpanded, submitting: $isSubmitting)';
}

// =============================================================================
// 消息上下文
// =============================================================================

/// 剧集动态上下文
///
/// 用于评论页头部展示原始动态的摘要信息。
class SeriesMessageContext {
  const SeriesMessageContext({
    required this.postId,
    required this.seriesId,
    required this.seriesName,
    required this.seriesAvatarUrl,
    required this.contentPreview,
    required this.createdAtMs,
  });

  /// 动态 ID
  final String postId;

  /// 剧集 ID
  final String seriesId;

  /// 剧集名称
  final String seriesName;

  /// 剧集头像 URL
  final String seriesAvatarUrl;

  /// 动态内容预览
  final String contentPreview;

  /// 创建时间（毫秒时间戳）
  final int createdAtMs;

  /// 创建时间（DateTime 格式）
  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(createdAtMs);
}

// =============================================================================
// 评论输入状态
// =============================================================================

/// 评论输入状态
///
/// 管理评论输入框的状态，包括文本、附件、回复目标等。
/// `replyTo` 字段使用哨兵值模式，支持传入 null 清除回复目标。
class SeriesCommentInputState {
  const SeriesCommentInputState({
    this.text = '',
    this.attachments = const [],
    this.replyTo,
    this.isSubmitting = false,
    this.error,
  });

  /// 输入的文本内容
  final String text;

  /// 待上传的附件列表
  final List<CommentMedia> attachments;

  /// 回复目标（如果是回复其他评论）
  final pkg_comment.ReplyTarget? replyTo;

  /// 是否正在提交
  final bool isSubmitting;

  /// 错误信息
  final String? error;

  /// 是否可以提交（有内容且未在提交中）
  bool get canSubmit => text.trim().isNotEmpty && !isSubmitting;

  /// 是否有附件
  bool get hasAttachments => attachments.isNotEmpty;

  /// 是否正在回复其他评论
  bool get isReplying => replyTo != null;

  /// 复制并修改指定字段
  ///
  /// 对于可选字段（如 `replyTo`、`error`），使用哨兵值模式：
  /// - 不传参：保留原值
  /// - 传入 `null`：清除该字段
  /// - 传入具体值：更新为新值
  SeriesCommentInputState copyWith({
    String? text,
    List<CommentMedia>? attachments,
    Object? replyTo = sentinel,
    bool? isSubmitting,
    Object? error = sentinel,
  }) {
    return SeriesCommentInputState(
      text: text ?? this.text,
      attachments: attachments ?? this.attachments,
      replyTo: replyTo == sentinel
          ? this.replyTo
          : castOrNull<pkg_comment.ReplyTarget>(replyTo),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error == sentinel ? this.error : castOrNull<String>(error),
    );
  }

  /// 清空所有输入状态
  SeriesCommentInputState clear() => const SeriesCommentInputState();

  /// 设置回复目标
  SeriesCommentInputState withReplyTo(pkg_comment.ReplyTarget? target) =>
      copyWith(replyTo: target);
}

// =============================================================================
// 模型转换扩展
// =============================================================================

/// 剧集评论模型转换扩展
///
/// 提供将剧集评论转换为公共评论组件格式的方法。
extension SeriesCommentModelExt on SeriesCommentModel {
  /// 转换为公共评论模型
  pkg_comment.CommentModel toCommentModel() {
    // 使用局部变量避免 ! 强制解包
    final replyTarget = replyTo;

    return pkg_comment.CommentModel(
      id: id,
      targetId: postId,
      targetType: 'series_post',
      author: pkg_comment.CommentAuthor(
        id: author.id,
        username: author.username,
        displayName: author.displayName,
        avatarUrl: author.avatarUrl,
        isVerified: author.isVerified,
        roleLabel: author.roleLabel,
      ),
      content: content,
      replyTo: replyTarget != null
          ? pkg_comment.ReplyTarget(
              commentId: replyTarget.commentId,
              authorName: replyTarget.authorName,
              contentPreview: replyTarget.contentPreview,
              isDeleted: replyTarget.isDeleted,
            )
          : null,
      replyCount: replyCount,
      likeCount: likeCount,
      isLiked: isLiked,
      createdAtMs: createdAtMs,
      isDeleted: isDeleted,
      isPinned: isPinned,
      isOwn: isOwn,
      interactionState: interactionState,
    );
  }
}
