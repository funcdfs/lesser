"""
Search business logic services.
"""
from django.db.models import Q, QuerySet

from apps.posts.models import Post
from apps.users.models import User


class SearchService:
    """Search-related business logic."""

    @staticmethod
    def search_posts(
        query: str,
        post_type: str = None,
        author_username: str = None,
        date_from: str = None,
        date_to: str = None,
        limit: int = 20
    ) -> QuerySet[Post]:
        """Search posts with filters."""
        queryset = Post.get_active_posts().select_related('author')

        if query:
            queryset = queryset.filter(
                Q(content__icontains=query) |
                Q(title__icontains=query)
            )

        if post_type:
            queryset = queryset.filter(post_type=post_type)

        if author_username:
            queryset = queryset.filter(author__username=author_username)

        if date_from:
            queryset = queryset.filter(created_at__gte=date_from)

        if date_to:
            queryset = queryset.filter(created_at__lte=date_to)

        return queryset[:limit]

    @staticmethod
    def search_users(query: str, limit: int = 20) -> QuerySet[User]:
        """Search users by username or display name."""
        queryset = User.objects.filter(is_active=True)

        if query:
            queryset = queryset.filter(
                Q(username__icontains=query) |
                Q(display_name__icontains=query) |
                Q(bio__icontains=query)
            )

        return queryset[:limit]

    @staticmethod
    def get_trending_posts(limit: int = 10) -> QuerySet[Post]:
        """Get trending posts based on engagement."""
        return Post.get_active_posts().order_by(
            '-like_count', '-comment_count', '-created_at'
        ).select_related('author')[:limit]
