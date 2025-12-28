"""
Post models supporting story, short, and column types.
"""
import uuid
from datetime import timedelta

from django.db import models
from django.utils import timezone

from apps.users.models import User


class PostType(models.TextChoices):
    STORY = 'story', 'Story'      # 24h auto-delete
    SHORT = 'short', 'Short'      # Short text
    COLUMN = 'column', 'Column'   # Long-form article


class Post(models.Model):
    """Post model supporting multiple content types."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name='posts')
    post_type = models.CharField(max_length=10, choices=PostType.choices, db_index=True)
    title = models.CharField(max_length=200, blank=True)  # For column type
    content = models.TextField()
    media_urls = models.JSONField(default=list, blank=True)
    expires_at = models.DateTimeField(null=True, blank=True, db_index=True)  # For story
    is_deleted = models.BooleanField(default=False, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)

    # Denormalized counts for performance
    like_count = models.PositiveIntegerField(default=0)
    comment_count = models.PositiveIntegerField(default=0)
    repost_count = models.PositiveIntegerField(default=0)
    bookmark_count = models.PositiveIntegerField(default=0)

    class Meta:
        db_table = 'posts'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['author', '-created_at']),
            models.Index(fields=['post_type', '-created_at']),
        ]

    def __str__(self):
        return f'{self.author.username}: {self.content[:50]}'

    def save(self, *args, **kwargs):
        # Auto-set expires_at for story posts
        if self.post_type == PostType.STORY and not self.expires_at:
            self.expires_at = timezone.now() + timedelta(hours=24)
        super().save(*args, **kwargs)

    @property
    def is_expired(self):
        """Check if post is expired (for stories)."""
        if self.expires_at:
            return timezone.now() > self.expires_at
        return False

    @classmethod
    def get_active_posts(cls):
        """Get non-deleted, non-expired posts."""
        now = timezone.now()
        return cls.objects.filter(is_deleted=False).exclude(
            post_type=PostType.STORY, expires_at__lt=now
        )


class PostMedia(models.Model):
    """Media attachments for posts."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='media')
    url = models.URLField()
    media_type = models.CharField(max_length=20)  # image, video, etc.
    order = models.PositiveSmallIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'post_media'
        ordering = ['order']
