"""
Notification models.
"""
import uuid

from django.db import models

from apps.users.models import User


class NotificationType(models.TextChoices):
    LIKE = 'like', 'Like'
    COMMENT = 'comment', 'Comment'
    REPLY = 'reply', 'Reply'
    BOOKMARK = 'bookmark', 'Bookmark'
    MENTION = 'mention', 'Mention'
    FOLLOW = 'follow', 'Follow'
    REPOST = 'repost', 'Repost'


class Notification(models.Model):
    """Notification model for user activities."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        User, on_delete=models.CASCADE, related_name='notifications'
    )
    type = models.CharField(max_length=20, choices=NotificationType.choices, db_index=True)
    actor = models.ForeignKey(
        User, on_delete=models.CASCADE, related_name='actions'
    )
    target_type = models.CharField(max_length=50)  # 'post', 'comment', 'user'
    target_id = models.UUIDField()
    message = models.CharField(max_length=255, blank=True)
    is_read = models.BooleanField(default=False, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)

    class Meta:
        db_table = 'notifications'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['user', 'is_read', '-created_at']),
        ]

    def __str__(self):
        return f'{self.actor.username} {self.type} -> {self.user.username}'

    @classmethod
    def create_notification(
        cls,
        user: User,
        notification_type: str,
        actor: User,
        target_type: str,
        target_id: str,
        message: str = ''
    ) -> 'Notification':
        """Create a notification."""
        # Don't notify user of their own actions
        if user == actor:
            return None

        return cls.objects.create(
            user=user,
            type=notification_type,
            actor=actor,
            target_type=target_type,
            target_id=target_id,
            message=message
        )
