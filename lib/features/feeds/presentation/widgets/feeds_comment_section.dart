import 'package:flutter/material.dart';
import 'package:lesser/shared/shared.dart';
import '../../domain/models/comment.dart';

/// Feed 评论区域
///
/// 负责：
/// - 显示评论列表 (TikTok 风格)
/// - 提供评论输入框 (吸底)
/// - 支持回复和点赞
class FeedsCommentSection extends StatefulWidget {
  const FeedsCommentSection({super.key});

  @override
  State<FeedsCommentSection> createState() => _FeedsCommentSectionState();
}

class _FeedsCommentSectionState extends State<FeedsCommentSection> {
  final TextEditingController _commentController = TextEditingController();

  // 模拟数据
  final List<Comment> _mockComments = [
    Comment(
      id: '1',
      author: CommentAuthor(
        userId: 'u1',
        username: 'DesignLover',
        avatarUrl:
            'https://tiebapic.baidu.com/forum/pic/item/962bd40735fae6cd7d3d75004ab30f2442a7d97e.jpg',
        isVerified: true,
      ),
      content:
          'This UI is absolutely stunning! Love the TikTok style implementation. 😍',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likeCount: 1250,
      replyCount: 3,
      replies: [
        Comment(
          id: '1_1',
          author: CommentAuthor(
            userId: 'u2',
            username: 'FlutterDev',
            avatarUrl:
                'https://tiebapic.baidu.com/forum/pic/item/7ea6a61ea8d3fd1f26f28689714e251f95ca5f33.jpg',
            isVerified: false,
          ),
          content: 'Agreed! The transitions are so smooth.',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          likeCount: 45,
        ),
      ],
    ),
    Comment(
      id: '2',
      author: CommentAuthor(
        userId: 'u3',
        username: 'TechEnthusiast',
        avatarUrl:
            'https://tiebapic.baidu.com/forum/pic/item/2cf5e0fe9925bc3146d2cb7c1edf8db1cb137021.jpg',
        isVerified: false,
      ),
      content:
          'Can you share the source code for this specific feature? It looks like it uses DraggableScrollableSheet.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      likeCount: 89,
      replyCount: 0,
    ),
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl2),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context),

          const Divider(height: 1),

          // Comment List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              itemCount: _mockComments.length,
              itemBuilder: (context, index) {
                return _CommentItem(comment: _mockComments[index]);
              },
            ),
          ),

          // Sticky Input Field
          _buildInputField(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '${_mockComments.length + 1} comments',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Positioned(
            right: 0,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Avatar(
            avatarUrl:
                'https://tiebapic.baidu.com/forum/pic/item/2cf5e0fe9925bc3146d2cb7c1edf8db1cb137021.jpg',
            fallbackInitials: 'Me',
            size: 34,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedForeground,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 8,
                  ),
                ),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            onPressed: () {
              // Handle send
              _commentController.clear();
            },
            icon: const Icon(Icons.send_rounded, size: 20),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatefulWidget {
  final Comment comment;
  final bool isReply;

  const _CommentItem({required this.comment, this.isReply = false});

  @override
  State<_CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<_CommentItem> {
  bool _showReplies = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: widget.isReply ? AppSpacing.md : AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Avatar(
                avatarUrl: widget.comment.author.avatarUrl,
                fallbackInitials: widget.comment.author.username,
                size: widget.isReply ? 24 : 32,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.comment.author.username,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.mutedForeground,
                              ),
                        ),
                        if (widget.comment.author.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 10,
                            color: Colors.blue,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.comment.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          TimeFormatter.formatRelativeTime(
                            widget.comment.createdAt,
                          ),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontSize: 11,
                                color: AppColors.zinc400,
                              ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        GestureDetector(
                          onTap: () {
                            // Handle reply action
                          },
                          child: Text(
                            'Reply',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: AppColors.zinc500,
                                ),
                          ),
                        ),
                      ],
                    ),

                    // Replies Section
                    if (widget.comment.replyCount > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _showReplies = !_showReplies),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 1,
                              color: AppColors.zinc200,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _showReplies
                                  ? 'Hide replies'
                                  : 'View ${widget.comment.replyCount} replies',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.zinc500,
                                  ),
                            ),
                            Icon(
                              _showReplies
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 14,
                              color: AppColors.zinc500,
                            ),
                          ],
                        ),
                      ),
                      if (_showReplies && widget.comment.replies != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: Column(
                            children: widget.comment.replies!
                                .map(
                                  (reply) => _CommentItem(
                                    comment: reply,
                                    isReply: true,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                children: [
                  Icon(
                    widget.comment.isLikedByCurrentUser
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 16,
                    color: widget.comment.isLikedByCurrentUser
                        ? AppColors.destructive
                        : AppColors.mutedForeground,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatCount(widget.comment.likeCount),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: AppColors.zinc400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
