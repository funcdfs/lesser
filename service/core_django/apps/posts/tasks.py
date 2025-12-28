"""
Celery tasks for posts.
"""
from celery import shared_task
from django.utils import timezone


@shared_task
def delete_expired_stories():
    """
    Delete expired story posts.
    This task should be scheduled to run periodically (e.g., every hour).
    """
    from .models import Post, PostType

    now = timezone.now()
    expired_stories = Post.objects.filter(
        post_type=PostType.STORY,
        expires_at__lt=now,
        is_deleted=False
    )

    count = expired_stories.count()
    expired_stories.update(is_deleted=True)

    return f'Deleted {count} expired stories'


@shared_task
def cleanup_deleted_posts(days_old: int = 30):
    """
    Permanently delete soft-deleted posts older than specified days.
    """
    from datetime import timedelta

    from .models import Post

    cutoff_date = timezone.now() - timedelta(days=days_old)
    old_deleted_posts = Post.objects.filter(
        is_deleted=True,
        updated_at__lt=cutoff_date
    )

    count = old_deleted_posts.count()
    old_deleted_posts.delete()

    return f'Permanently deleted {count} old posts'
