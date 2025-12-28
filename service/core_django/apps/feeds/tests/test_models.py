"""
Tests for Feed interaction models.
"""
import pytest
from django.db import IntegrityError

from .factories import BookmarkFactory, CommentFactory, LikeFactory, RepostFactory


@pytest.mark.django_db
class TestLikeModel:
    """Tests for Like model."""

    def test_create_like(self):
        """Test creating a like."""
        like = LikeFactory()
        assert like.pk is not None

    def test_like_str_representation(self):
        """Test like string representation."""
        like = LikeFactory()
        assert like.user.username in str(like)
        assert 'liked' in str(like)

    def test_unique_like_constraint(self):
        """Test that a user can only like a post once."""
        like = LikeFactory()
        with pytest.raises(IntegrityError):
            LikeFactory(user=like.user, post=like.post)


@pytest.mark.django_db
class TestRepostModel:
    """Tests for Repost model."""

    def test_create_repost(self):
        """Test creating a repost."""
        repost = RepostFactory()
        assert repost.pk is not None

    def test_repost_with_quote(self):
        """Test creating a repost with quote."""
        repost = RepostFactory(quote='Great post!')
        assert repost.quote == 'Great post!'

    def test_repost_str_representation(self):
        """Test repost string representation."""
        repost = RepostFactory()
        assert repost.user.username in str(repost)
        assert 'reposted' in str(repost)


@pytest.mark.django_db
class TestCommentModel:
    """Tests for Comment model."""

    def test_create_comment(self):
        """Test creating a comment."""
        comment = CommentFactory()
        assert comment.pk is not None

    def test_comment_str_representation(self):
        """Test comment string representation."""
        comment = CommentFactory(content='This is a test comment')
        assert comment.author.username in str(comment)

    def test_reply_to_comment(self):
        """Test creating a reply to a comment."""
        parent = CommentFactory()
        reply = CommentFactory(post=parent.post, parent=parent)
        assert reply.parent == parent
        assert parent.reply_count == 1

    def test_reply_count_excludes_deleted(self):
        """Test that reply_count excludes deleted replies."""
        parent = CommentFactory()
        CommentFactory(post=parent.post, parent=parent, is_deleted=False)
        CommentFactory(post=parent.post, parent=parent, is_deleted=True)
        assert parent.reply_count == 1


@pytest.mark.django_db
class TestBookmarkModel:
    """Tests for Bookmark model."""

    def test_create_bookmark(self):
        """Test creating a bookmark."""
        bookmark = BookmarkFactory()
        assert bookmark.pk is not None

    def test_bookmark_str_representation(self):
        """Test bookmark string representation."""
        bookmark = BookmarkFactory()
        assert bookmark.user.username in str(bookmark)
        assert 'bookmarked' in str(bookmark)

    def test_unique_bookmark_constraint(self):
        """Test that a user can only bookmark a post once."""
        bookmark = BookmarkFactory()
        with pytest.raises(IntegrityError):
            BookmarkFactory(user=bookmark.user, post=bookmark.post)
