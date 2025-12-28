"""
Tests for Feed API views.
"""
import pytest
from rest_framework import status

from apps.feeds.models import Bookmark, Comment, Like
from apps.posts.tests.factories import PostFactory
from apps.users.tests.factories import FollowFactory, UserFactory

from .factories import BookmarkFactory, CommentFactory, LikeFactory


@pytest.mark.django_db
class TestLikeView:
    """Tests for like/unlike endpoint."""

    def test_like_post(self, api_client):
        """Test liking a post."""
        user = UserFactory()
        post = PostFactory()
        api_client.force_authenticate(user=user)
        response = api_client.post(f'/api/v1/feeds/posts/{post.id}/like/')
        assert response.status_code == status.HTTP_201_CREATED
        assert Like.objects.filter(user=user, post=post).exists()

    def test_unlike_post(self, api_client):
        """Test unliking a post."""
        user = UserFactory()
        post = PostFactory()
        LikeFactory(user=user, post=post)
        api_client.force_authenticate(user=user)
        response = api_client.delete(f'/api/v1/feeds/posts/{post.id}/like/')
        assert response.status_code == status.HTTP_200_OK
        assert not Like.objects.filter(user=user, post=post).exists()

    def test_like_already_liked(self, api_client):
        """Test liking an already liked post."""
        user = UserFactory()
        post = PostFactory()
        LikeFactory(user=user, post=post)
        api_client.force_authenticate(user=user)
        response = api_client.post(f'/api/v1/feeds/posts/{post.id}/like/')
        assert response.status_code == status.HTTP_200_OK


@pytest.mark.django_db
class TestBookmarkView:
    """Tests for bookmark endpoint."""

    def test_bookmark_post(self, api_client):
        """Test bookmarking a post."""
        user = UserFactory()
        post = PostFactory()
        api_client.force_authenticate(user=user)
        response = api_client.post(f'/api/v1/feeds/posts/{post.id}/bookmark/')
        assert response.status_code == status.HTTP_201_CREATED
        assert Bookmark.objects.filter(user=user, post=post).exists()

    def test_remove_bookmark(self, api_client):
        """Test removing a bookmark."""
        user = UserFactory()
        post = PostFactory()
        BookmarkFactory(user=user, post=post)
        api_client.force_authenticate(user=user)
        response = api_client.delete(f'/api/v1/feeds/posts/{post.id}/bookmark/')
        assert response.status_code == status.HTTP_200_OK
        assert not Bookmark.objects.filter(user=user, post=post).exists()

    def test_list_bookmarks(self, api_client):
        """Test listing user's bookmarks."""
        user = UserFactory()
        BookmarkFactory.create_batch(3, user=user)
        api_client.force_authenticate(user=user)
        response = api_client.get('/api/v1/feeds/bookmarks/')
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data['results']) == 3


@pytest.mark.django_db
class TestCommentView:
    """Tests for comment endpoint."""

    def test_create_comment(self, api_client):
        """Test creating a comment."""
        user = UserFactory()
        post = PostFactory()
        api_client.force_authenticate(user=user)
        response = api_client.post(f'/api/v1/feeds/posts/{post.id}/comments/', {
            'content': 'Great post!',
        })
        assert response.status_code == status.HTTP_201_CREATED
        assert Comment.objects.filter(author=user, post=post).exists()

    def test_list_comments(self, api_client):
        """Test listing comments for a post."""
        user = UserFactory()
        post = PostFactory()
        CommentFactory.create_batch(3, post=post)
        api_client.force_authenticate(user=user)
        response = api_client.get(f'/api/v1/feeds/posts/{post.id}/comments/')
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data['results']) == 3

    def test_delete_own_comment(self, api_client):
        """Test deleting own comment."""
        user = UserFactory()
        comment = CommentFactory(author=user)
        api_client.force_authenticate(user=user)
        response = api_client.delete(f'/api/v1/feeds/comments/{comment.id}/')
        assert response.status_code == status.HTTP_204_NO_CONTENT
        comment.refresh_from_db()
        assert comment.is_deleted is True


@pytest.mark.django_db
class TestFeedListView:
    """Tests for feed list endpoint."""

    def test_get_feed(self, api_client):
        """Test getting user's feed."""
        user = UserFactory()
        followed_user = UserFactory()
        FollowFactory(follower=user, following=followed_user)
        PostFactory.create_batch(2, author=followed_user)
        PostFactory()  # Post by non-followed user
        api_client.force_authenticate(user=user)
        response = api_client.get('/api/v1/feeds/')
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data['results']) == 2

    def test_empty_feed(self, api_client):
        """Test empty feed when not following anyone."""
        user = UserFactory()
        PostFactory.create_batch(3)
        api_client.force_authenticate(user=user)
        response = api_client.get('/api/v1/feeds/')
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data['results']) == 0
