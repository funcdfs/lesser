"""
User business logic services.
"""
from typing import Optional

from django.db.models import QuerySet

from .models import Follow, User


class UserService:
    """User-related business logic."""

    @staticmethod
    def get_user_by_id(user_id: str) -> Optional[User]:
        """Get user by ID."""
        try:
            return User.objects.get(id=user_id)
        except User.DoesNotExist:
            return None

    @staticmethod
    def get_user_by_username(username: str) -> Optional[User]:
        """Get user by username."""
        try:
            return User.objects.get(username=username)
        except User.DoesNotExist:
            return None

    @staticmethod
    def get_user_by_email(email: str) -> Optional[User]:
        """Get user by email."""
        try:
            return User.objects.get(email=email)
        except User.DoesNotExist:
            return None

    @staticmethod
    def is_following(follower: User, following: User) -> bool:
        """Check if follower is following the user."""
        return Follow.objects.filter(follower=follower, following=following).exists()

    @staticmethod
    def get_followers(user: User) -> QuerySet[Follow]:
        """Get user's followers."""
        return Follow.objects.filter(following=user).select_related('follower')

    @staticmethod
    def get_following(user: User) -> QuerySet[Follow]:
        """Get users that user is following."""
        return Follow.objects.filter(follower=user).select_related('following')

    @staticmethod
    def follow_user(follower: User, following: User) -> tuple[Follow, bool]:
        """Follow a user. Returns (follow_obj, created)."""
        return Follow.objects.get_or_create(follower=follower, following=following)

    @staticmethod
    def unfollow_user(follower: User, following: User) -> bool:
        """Unfollow a user. Returns True if unfollowed."""
        deleted, _ = Follow.objects.filter(follower=follower, following=following).delete()
        return deleted > 0
