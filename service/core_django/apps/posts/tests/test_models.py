"""
Tests for Post models.
"""
from datetime import timedelta

import pytest
from django.utils import timezone

from apps.posts.models import Post, PostType

from .factories import ColumnPostFactory, PostFactory, StoryPostFactory


@pytest.mark.django_db
class TestPostModel:
    """Tests for Post model."""

    def test_create_short_post(self):
        """Test creating a short post."""
        post = PostFactory(post_type=PostType.SHORT)
        assert post.pk is not None
        assert post.post_type == PostType.SHORT
        assert post.expires_at is None

    def test_create_story_post_sets_expiry(self):
        """Test that story posts automatically get expiry time."""
        post = StoryPostFactory()
        assert post.expires_at is not None
        expected_expiry = timezone.now() + timedelta(hours=24)
        assert abs((post.expires_at - expected_expiry).total_seconds()) < 5

    def test_create_column_post(self):
        """Test creating a column post."""
        post = ColumnPostFactory()
        assert post.post_type == PostType.COLUMN
        assert post.title != ''

    def test_post_str_representation(self):
        """Test post string representation."""
        post = PostFactory(content='This is a test post content')
        assert post.author.username in str(post)
        assert 'This is a test post' in str(post)

    def test_is_expired_for_story(self):
        """Test is_expired property for story posts."""
        post = StoryPostFactory()
        assert post.is_expired is False

        # Manually set expired time
        post.expires_at = timezone.now() - timedelta(hours=1)
        post.save()
        assert post.is_expired is True

    def test_is_expired_for_non_story(self):
        """Test is_expired returns False for non-story posts."""
        post = PostFactory(post_type=PostType.SHORT)
        assert post.is_expired is False

    def test_get_active_posts_excludes_deleted(self):
        """Test get_active_posts excludes deleted posts."""
        active_post = PostFactory(is_deleted=False)
        deleted_post = PostFactory(is_deleted=True)

        active_posts = Post.get_active_posts()
        assert active_post in active_posts
        assert deleted_post not in active_posts

    def test_get_active_posts_excludes_expired_stories(self):
        """Test get_active_posts excludes expired stories."""
        active_story = StoryPostFactory()
        expired_story = StoryPostFactory()
        expired_story.expires_at = timezone.now() - timedelta(hours=1)
        expired_story.save()

        active_posts = Post.get_active_posts()
        assert active_story in active_posts
        assert expired_story not in active_posts

    def test_default_counts_are_zero(self):
        """Test that default interaction counts are zero."""
        post = PostFactory()
        assert post.like_count == 0
        assert post.comment_count == 0
        assert post.repost_count == 0
        assert post.bookmark_count == 0
