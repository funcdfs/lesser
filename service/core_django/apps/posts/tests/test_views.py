"""
Tests for Post API views.
"""
import pytest
from rest_framework import status

from apps.posts.models import Post, PostType
from apps.users.tests.factories import UserFactory

from .factories import PostFactory


@pytest.mark.django_db
class TestPostListCreateView:
    """Tests for post list and create endpoint."""

    def test_list_posts(self, api_client):
        """Test listing posts."""
        user = UserFactory()
        PostFactory.create_batch(3)
        api_client.force_authenticate(user=user)
        response = api_client.get('/api/v1/posts/')
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data['results']) == 3

    def test_create_short_post(self, api_client):
        """Test creating a short post."""
        user = UserFactory()
        api_client.force_authenticate(user=user)
        response = api_client.post('/api/v1/posts/', {
            'post_type': 'short',
            'content': 'This is a test post',
        })
        assert response.status_code == status.HTTP_201_CREATED
        assert response.data['post_type'] == 'short'
        assert response.data['author']['id'] == str(user.id)

    def test_create_post_unauthenticated(self, api_client):
        """Test creating post fails when not authenticated."""
        response = api_client.post('/api/v1/posts/', {
            'post_type': 'short',
            'content': 'Test',
        })
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


@pytest.mark.django_db
class TestPostDetailView:
    """Tests for post detail endpoint."""

    def test_get_post(self, api_client):
        """Test getting a single post."""
        user = UserFactory()
        post = PostFactory()
        api_client.force_authenticate(user=user)
        response = api_client.get(f'/api/v1/posts/{post.id}/')
        assert response.status_code == status.HTTP_200_OK
        assert response.data['id'] == str(post.id)

    def test_update_own_post(self, api_client):
        """Test updating own post."""
        user = UserFactory()
        post = PostFactory(author=user)
        api_client.force_authenticate(user=user)
        response = api_client.patch(f'/api/v1/posts/{post.id}/', {
            'content': 'Updated content',
        })
        assert response.status_code == status.HTTP_200_OK
        assert response.data['content'] == 'Updated content'

    def test_cannot_update_others_post(self, api_client):
        """Test that user cannot update another user's post."""
        user = UserFactory()
        other_user = UserFactory()
        post = PostFactory(author=other_user)
        api_client.force_authenticate(user=user)
        response = api_client.patch(f'/api/v1/posts/{post.id}/', {
            'content': 'Hacked content',
        })
        assert response.status_code == status.HTTP_403_FORBIDDEN

    def test_delete_post_soft_deletes(self, api_client):
        """Test that deleting a post soft deletes it."""
        user = UserFactory()
        post = PostFactory(author=user)
        api_client.force_authenticate(user=user)
        response = api_client.delete(f'/api/v1/posts/{post.id}/')
        assert response.status_code == status.HTTP_204_NO_CONTENT
        post.refresh_from_db()
        assert post.is_deleted is True


@pytest.mark.django_db
class TestUserPostsView:
    """Tests for user posts endpoint."""

    def test_list_user_posts(self, api_client):
        """Test listing posts by a specific user."""
        user = UserFactory()
        author = UserFactory()
        PostFactory.create_batch(2, author=author)
        PostFactory()  # Post by another user
        api_client.force_authenticate(user=user)
        response = api_client.get(f'/api/v1/posts/user/{author.username}/')
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data['results']) == 2


@pytest.mark.django_db
class TestPostsByTypeView:
    """Tests for posts by type endpoint."""

    def test_list_posts_by_type(self, api_client):
        """Test listing posts filtered by type."""
        user = UserFactory()
        PostFactory.create_batch(2, post_type=PostType.SHORT)
        PostFactory(post_type=PostType.COLUMN)
        api_client.force_authenticate(user=user)
        response = api_client.get('/api/v1/posts/type/short/')
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data['results']) == 2
