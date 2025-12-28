"""
Post business logic services.
"""
from typing import Optional

from django.db.models import QuerySet

from apps.users.models import User

from .models import Post, PostType


class PostService:
    """Post-related business logic."""

    @staticmethod
    def get_post_by_id(post_id: str) -> Optional[Post]:
        """Get post by ID."""
        try:
            return Post.objects.get(id=post_id, is_deleted=False)
        except Post.DoesNotExist:
            return None

    @staticmethod
    def get_user_posts(user: User, include_expired: bool = False) -> QuerySet[Post]:
        """Get posts by user."""
        queryset = Post.objects.filter(author=user, is_deleted=False)
        if not include_expired:
            queryset = Post.get_active_posts().filter(author=user)
        return queryset.select_related('author')

    @staticmethod
    def get_feed_posts(user: User, limit: int = 20) -> QuerySet[Post]:
        """Get feed posts for user (from followed users)."""
        following_ids = user.following.values_list('following_id', flat=True)
        return Post.get_active_posts().filter(
            author_id__in=following_ids
        ).select_related('author')[:limit]

    @staticmethod
    def create_post(
        author: User,
        post_type: str,
        content: str,
        title: str = '',
        media_urls: list = None
    ) -> Post:
        """Create a new post."""
        return Post.objects.create(
            author=author,
            post_type=post_type,
            title=title,
            content=content,
            media_urls=media_urls or []
        )

    @staticmethod
    def update_post(post: Post, **kwargs) -> Post:
        """Update a post."""
        for key, value in kwargs.items():
            if hasattr(post, key):
                setattr(post, key, value)
        post.save()
        return post

    @staticmethod
    def delete_post(post: Post) -> None:
        """Soft delete a post."""
        post.is_deleted = True
        post.save()

    @staticmethod
    def increment_count(post: Post, field: str) -> None:
        """Increment a count field."""
        if hasattr(post, field):
            setattr(post, field, getattr(post, field) + 1)
            post.save(update_fields=[field])

    @staticmethod
    def decrement_count(post: Post, field: str) -> None:
        """Decrement a count field."""
        if hasattr(post, field):
            current = getattr(post, field)
            if current > 0:
                setattr(post, field, current - 1)
                post.save(update_fields=[field])
