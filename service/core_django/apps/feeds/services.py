"""
Feed business logic services.
"""
from typing import Optional

from django.db.models import QuerySet

from apps.posts.models import Post
from apps.users.models import User

from .models import Bookmark, Comment, Like, Repost


class FeedService:
    """Feed-related business logic."""

    @staticmethod
    def is_liked(user: User, post: Post) -> bool:
        """Check if user liked the post."""
        return Like.objects.filter(user=user, post=post).exists()

    @staticmethod
    def is_bookmarked(user: User, post: Post) -> bool:
        """Check if user bookmarked the post."""
        return Bookmark.objects.filter(user=user, post=post).exists()

    @staticmethod
    def is_reposted(user: User, post: Post) -> bool:
        """Check if user reposted the post."""
        return Repost.objects.filter(user=user, post=post).exists()

    @staticmethod
    def like_post(user: User, post: Post) -> tuple[Like, bool]:
        """Like a post. Returns (like_obj, created)."""
        return Like.objects.get_or_create(user=user, post=post)

    @staticmethod
    def unlike_post(user: User, post: Post) -> bool:
        """Unlike a post. Returns True if unliked."""
        deleted, _ = Like.objects.filter(user=user, post=post).delete()
        return deleted > 0

    @staticmethod
    def bookmark_post(user: User, post: Post) -> tuple[Bookmark, bool]:
        """Bookmark a post. Returns (bookmark_obj, created)."""
        return Bookmark.objects.get_or_create(user=user, post=post)

    @staticmethod
    def unbookmark_post(user: User, post: Post) -> bool:
        """Remove bookmark. Returns True if removed."""
        deleted, _ = Bookmark.objects.filter(user=user, post=post).delete()
        return deleted > 0

    @staticmethod
    def repost(user: User, post: Post, quote: str = '') -> Repost:
        """Create a repost."""
        return Repost.objects.create(user=user, post=post, quote=quote)

    @staticmethod
    def get_post_comments(post: Post, parent: Optional[Comment] = None) -> QuerySet[Comment]:
        """Get comments for a post."""
        return Comment.objects.filter(
            post=post,
            parent=parent,
            is_deleted=False
        ).select_related('author')

    @staticmethod
    def create_comment(
        author: User,
        post: Post,
        content: str,
        parent: Optional[Comment] = None
    ) -> Comment:
        """Create a comment."""
        return Comment.objects.create(
            author=author,
            post=post,
            content=content,
            parent=parent
        )

    @staticmethod
    def get_user_bookmarks(user: User) -> QuerySet[Bookmark]:
        """Get user's bookmarks."""
        return Bookmark.objects.filter(user=user).select_related('post', 'post__author')
