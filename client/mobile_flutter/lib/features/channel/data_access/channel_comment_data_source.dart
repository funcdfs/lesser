// 频道评论数据源

import '../../../pkg/comment/comment.dart';
import '../handler/channel_mock_data.dart';
import '../models/channel_comment_model.dart' as channel;

/// 频道评论数据源
///
/// 实现 [CommentDataSource] 接口，为频道提供评论数据。
class ChannelCommentDataSource implements CommentDataSource {
  ChannelCommentDataSource({
    required this.channelId,
    required this.currentUserId,
  });

  final String channelId;
  final String currentUserId;

  // 缓存子孙评论数量
  final Map<String, int> _descendantCounts = {};

  /// 通过评论 ID 获取根评论模型
  ///
  /// 用于深层链接导航，找到评论树的根节点
  Future<CommentModel?> getRootCommentById(String commentId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    // 在所有帖子的评论中查找
    for (final entry in mockComments.entries) {
      for (final comment in entry.value) {
        if (comment.id == commentId) {
          // 找到了，这是根评论
          return comment.toCommentModel();
        }
      }
    }

    // 在子评论中查找
    for (final entry in mockReplies.entries) {
      for (final comment in entry.value) {
        if (comment.id == commentId) {
          // 找到了，需要向上查找根评论
          return _findRootComment(entry.key);
        }
      }
    }

    return null;
  }

  /// 递归查找根评论
  CommentModel? _findRootComment(String parentId) {
    // 检查是否是根评论
    for (final entry in mockComments.entries) {
      for (final comment in entry.value) {
        if (comment.id == parentId) {
          return comment.toCommentModel();
        }
      }
    }

    // 继续向上查找
    for (final entry in mockReplies.entries) {
      for (final comment in entry.value) {
        if (comment.id == parentId) {
          return _findRootComment(entry.key);
        }
      }
    }

    return null;
  }

  @override
  Future<CommentListState> loadComments(
    String targetId,
    String targetType,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final rootComments =
        mockComments[targetId] ?? <channel.ChannelCommentModel>[];

    // 收集所有评论（根评论 + 所有子孙评论）- 扁平化展示
    final allComments = <channel.ChannelCommentModel>[];

    for (final rootComment in rootComments) {
      allComments.add(rootComment);
      // 递归收集该根评论的所有子孙
      _collectDescendants(rootComment.id, allComments);
    }

    // 按时间排序（最早的在前）
    allComments.sort((a, b) => a.createdAtMs.compareTo(b.createdAtMs));

    // 计算子孙数量（用于显示"查看 X 条回复"）
    _calculateDescendantCounts(targetId);

    // 转换并标记
    final comments = allComments.map((c) {
      final model = c.toCommentModel();
      return model.copyWith(isOwn: c.author.id == currentUserId);
    }).toList();

    // 找出置顶评论
    final pinnedIndex = comments.indexWhere((c) => c.isPinned);
    CommentModel? pinnedComment;
    if (pinnedIndex != -1) {
      pinnedComment = comments.removeAt(pinnedIndex);
    }

    return CommentListState(
      comments: comments,
      pinnedComment: pinnedComment,
      totalCount: allComments.length,
      hasMore: false,
    );
  }

  @override
  Future<CommentListState> loadThread(CommentModel rootComment) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // 递归收集所有子孙评论
    final allDescendants = <channel.ChannelCommentModel>[];
    _collectDescendants(rootComment.id, allDescendants);

    // 按时间排序
    allDescendants.sort((a, b) => a.createdAtMs.compareTo(b.createdAtMs));

    // 转换并标记
    final comments = allDescendants.map((c) {
      final model = c.toCommentModel();
      return model.copyWith(isOwn: c.author.id == currentUserId);
    }).toList();

    return CommentListState(
      comments: comments,
      rootComment: rootComment,
      totalCount: comments.length,
      hasMore: false,
    );
  }

  @override
  int getDescendantCount(String commentId) {
    return _descendantCounts[commentId] ?? 0;
  }

  @override
  Future<void> toggleLike(String commentId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Mock: 直接成功
  }

  @override
  Future<CommentModel> submitComment({
    required String targetId,
    required String targetType,
    required String content,
    ReplyTarget? replyTo,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return CommentModel(
      id: 'new_${DateTime.now().millisecondsSinceEpoch}',
      targetId: targetId,
      targetType: targetType,
      author: CommentAuthor(
        id: currentUserId,
        username: 'me',
        displayName: '我',
        avatarUrl: 'https://i.pravatar.cc/100?img=20',
      ),
      content: content,
      replyTo: replyTo,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
      isOwn: true,
    );
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Mock: 直接成功
  }

  @override
  Future<CommentListState> loadMoreComments(
    String targetId,
    String targetType,
    String? cursor,
  ) async {
    // Mock: 暂无分页，直接返回空
    await Future.delayed(const Duration(milliseconds: 100));
    return const CommentListState(hasMore: false);
  }

  // ---- 私有方法 ----

  /// 递归收集所有子孙评论
  void _collectDescendants(
    String parentId,
    List<channel.ChannelCommentModel> result,
  ) {
    final children = mockReplies[parentId];
    if (children == null || children.isEmpty) return;

    for (final child in children) {
      result.add(child);
      _collectDescendants(child.id, result);
    }
  }

  /// 计算所有评论的子孙数量
  void _calculateDescendantCounts(String messageId) {
    _descendantCounts.clear();

    final comments = mockComments[messageId] ?? [];
    for (final comment in comments) {
      _calculateDescendantCountRecursive(comment.id);
    }
  }

  /// 递归计算子孙数量
  int _calculateDescendantCountRecursive(String commentId) {
    final children = mockReplies[commentId];
    if (children == null || children.isEmpty) {
      _descendantCounts[commentId] = 0;
      return 0;
    }

    int count = children.length;
    for (final child in children) {
      count += _calculateDescendantCountRecursive(child.id);
    }

    _descendantCounts[commentId] = count;
    return count;
  }
}
