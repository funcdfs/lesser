import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/feed_item.dart';

class FeedItemCard extends StatelessWidget {
  const FeedItemCard({
    super.key,
    required this.feedItem,
    this.onLike,
    this.onRepost,
    this.onBookmark,
    this.onComment,
    this.onShare,
    this.onTap,
  });

  final FeedItem feedItem;
  final VoidCallback? onLike;
  final VoidCallback? onRepost;
  final VoidCallback? onBookmark;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            _buildContent(context),
            if (feedItem.mediaUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildMedia(),
            ],
            const SizedBox(height: 12),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: feedItem.author.avatarUrl != null
              ? NetworkImage(feedItem.author.avatarUrl!)
              : null,
          child: feedItem.author.avatarUrl == null
              ? Text(
                  feedItem.author.username[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    feedItem.author.displayName ?? feedItem.author.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '@${feedItem.author.username}',
                    style: TextStyle(color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
              Text(
                feedItem.createdAt.timeAgo,
                style: TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (feedItem.postType == PostType.story)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Story',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () {
            // Show more options
          },
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (feedItem.title != null) ...[
          Text(
            feedItem.title!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          feedItem.content,
          style: const TextStyle(fontSize: 15, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildMedia() {
    if (feedItem.mediaUrls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          feedItem.mediaUrls.first,
          fit: BoxFit.cover,
          height: 200,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: AppColors.surfaceLight,
              child: const Center(
                child: Icon(Icons.broken_image_outlined),
              ),
            );
          },
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: feedItem.mediaUrls.length > 4 ? 4 : feedItem.mediaUrls.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            feedItem.mediaUrls[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.surfaceLight,
                child: const Center(
                  child: Icon(Icons.broken_image_outlined),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          activeIcon: Icons.chat_bubble,
          count: feedItem.commentsCount,
          onTap: onComment,
        ),
        _ActionButton(
          icon: Icons.repeat,
          activeIcon: Icons.repeat,
          count: feedItem.repostsCount,
          isActive: feedItem.isReposted,
          activeColor: AppColors.repost,
          onTap: onRepost,
        ),
        _ActionButton(
          icon: Icons.favorite_border,
          activeIcon: Icons.favorite,
          count: feedItem.likesCount,
          isActive: feedItem.isLiked,
          activeColor: AppColors.like,
          onTap: onLike,
        ),
        _ActionButton(
          icon: Icons.bookmark_border,
          activeIcon: Icons.bookmark,
          isActive: feedItem.isBookmarked,
          activeColor: AppColors.bookmark,
          onTap: onBookmark,
        ),
        _ActionButton(
          icon: Icons.share_outlined,
          onTap: onShare,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    this.activeIcon,
    this.count,
    this.isActive = false,
    this.activeColor,
    this.onTap,
  });

  final IconData icon;
  final IconData? activeIcon;
  final int? count;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(
              isActive ? (activeIcon ?? icon) : icon,
              size: 20,
              color: color,
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 4),
              Text(
                count!.compact,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
