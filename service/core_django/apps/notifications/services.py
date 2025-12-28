"""
Notification business logic services.
"""
from typing import Optional

from django.db.models import QuerySet

from apps.users.models import User

from .models import Notification, NotificationType


class NotificationService:
    """Notification-related business logic."""

    @staticmethod
    def get_user_notifications(
        user: User,
        notification_type: Optional[str] = None,
        is_read: Optional[bool] = None
    ) -> QuerySet[Notification]:
        """Get user's notifications with optional filters."""
        queryset = Notification.objects.filter(user=user).select_related('actor')

        if notification_type:
            queryset = queryset.filter(type=notification_type)

        if is_read is not None:
            queryset = queryset.filter(is_read=is_read)

        return queryset

    @staticmethod
    def get_unread_count(user: User) -> int:
        """Get count of unread notifications."""
        return Notification.objects.filter(user=user, is_read=False).count()

    @staticmethod
    def mark_as_read(notification: Notification) -> None:
        """Mark a notification as read."""
        notification.is_read = True
        notification.save(update_fields=['is_read'])

    @staticmethod
    def mark_all_as_read(user: User) -> int:
        """Mark all notifications as read. Returns count."""
        return Notification.objects.filter(
            user=user, is_read=False
        ).update(is_read=True)

    @staticmethod
    def create_like_notification(user: User, actor: User, post_id: str) -> Optional[Notification]:
        """Create a like notification."""
        return Notification.create_notification(
            user=user,
            notification_type=NotificationType.LIKE,
            actor=actor,
            target_type='post',
            target_id=post_id,
            message=f'{actor.username} liked your post'
        )

    @staticmethod
    def create_comment_notification(user: User, actor: User, post_id: str) -> Optional[Notification]:
        """Create a comment notification."""
        return Notification.create_notification(
            user=user,
            notification_type=NotificationType.COMMENT,
            actor=actor,
            target_type='post',
            target_id=post_id,
            message=f'{actor.username} commented on your post'
        )

    @staticmethod
    def create_reply_notification(user: User, actor: User, comment_id: str) -> Optional[Notification]:
        """Create a reply notification."""
        return Notification.create_notification(
            user=user,
            notification_type=NotificationType.REPLY,
            actor=actor,
            target_type='comment',
            target_id=comment_id,
            message=f'{actor.username} replied to your comment'
        )

    @staticmethod
    def create_follow_notification(user: User, actor: User) -> Optional[Notification]:
        """Create a follow notification."""
        return Notification.create_notification(
            user=user,
            notification_type=NotificationType.FOLLOW,
            actor=actor,
            target_type='user',
            target_id=str(actor.id),
            message=f'{actor.username} started following you'
        )

    @staticmethod
    def create_repost_notification(user: User, actor: User, post_id: str) -> Optional[Notification]:
        """Create a repost notification."""
        return Notification.create_notification(
            user=user,
            notification_type=NotificationType.REPOST,
            actor=actor,
            target_type='post',
            target_id=post_id,
            message=f'{actor.username} reposted your post'
        )

    @staticmethod
    def create_mention_notification(user: User, actor: User, post_id: str) -> Optional[Notification]:
        """Create a mention notification."""
        return Notification.create_notification(
            user=user,
            notification_type=NotificationType.MENTION,
            actor=actor,
            target_type='post',
            target_id=post_id,
            message=f'{actor.username} mentioned you in a post'
        )
