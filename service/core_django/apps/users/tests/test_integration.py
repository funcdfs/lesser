"""
Integration tests for Django services.
"""
import pytest
from django.test import override_settings
from rest_framework import status
from rest_framework.test import APIClient

from apps.users.models import User

from .factories import UserFactory


@pytest.mark.django_db
@pytest.mark.integration
class TestAuthenticationFlow:
    """Integration tests for complete authentication flow."""

    def test_full_auth_flow(self, api_client):
        """Test complete registration -> login -> profile -> logout flow."""
        # 1. Register
        register_data = {
            'username': 'integrationuser',
            'email': 'integration@example.com',
            'password': 'IntegrationPass123!',
            'password_confirm': 'IntegrationPass123!',
            'display_name': 'Integration User',
        }
        response = api_client.post('/api/v1/auth/register/', register_data)
        assert response.status_code == status.HTTP_201_CREATED
        access_token = response.data['access_token']
        refresh_token = response.data['refresh_token']

        # 2. Access protected endpoint with token
        api_client.credentials(HTTP_AUTHORIZATION=f'Bearer {access_token}')
        response = api_client.get('/api/v1/auth/me/')
        assert response.status_code == status.HTTP_200_OK
        assert response.data['username'] == 'integrationuser'

        # 3. Refresh token
        api_client.credentials()  # Clear credentials
        response = api_client.post('/api/v1/auth/token/refresh/', {
            'refresh': refresh_token,
        })
        assert response.status_code == status.HTTP_200_OK
        new_access_token = response.data['access']

        # 4. Use new token
        api_client.credentials(HTTP_AUTHORIZATION=f'Bearer {new_access_token}')
        response = api_client.get('/api/v1/auth/me/')
        assert response.status_code == status.HTTP_200_OK

        # 5. Logout
        response = api_client.post('/api/v1/auth/logout/', {
            'refresh_token': refresh_token,
        })
        assert response.status_code == status.HTTP_200_OK

    def test_follow_unfollow_flow(self, api_client):
        """Test complete follow/unfollow flow."""
        user1 = UserFactory()
        user2 = UserFactory()

        api_client.force_authenticate(user=user1)

        # 1. Follow user2
        response = api_client.post(f'/api/v1/auth/users/{user2.username}/follow/')
        assert response.status_code == status.HTTP_201_CREATED

        # 2. Check followers list
        response = api_client.get(f'/api/v1/auth/users/{user2.username}/followers/')
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data['results']) == 1

        # 3. Check following list
        response = api_client.get(f'/api/v1/auth/users/{user1.username}/following/')
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data['results']) == 1

        # 4. Unfollow
        response = api_client.delete(f'/api/v1/auth/users/{user2.username}/follow/')
        assert response.status_code == status.HTTP_200_OK

        # 5. Verify unfollowed
        response = api_client.get(f'/api/v1/auth/users/{user2.username}/followers/')
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data['results']) == 0


@pytest.mark.django_db
@pytest.mark.integration
class TestPostInteractionFlow:
    """Integration tests for post and interaction flow."""

    def test_post_interaction_flow(self, api_client):
        """Test complete post creation and interaction flow."""
        user1 = UserFactory()
        user2 = UserFactory()

        # 1. User1 creates a post
        api_client.force_authenticate(user=user1)
        response = api_client.post('/api/v1/posts/', {
            'post_type': 'short',
            'content': 'This is a test post for integration testing',
        })
        assert response.status_code == status.HTTP_201_CREATED
        post_id = response.data['id']

        # 2. User2 likes the post
        api_client.force_authenticate(user=user2)
        response = api_client.post(f'/api/v1/feeds/posts/{post_id}/like/')
        assert response.status_code == status.HTTP_201_CREATED

        # 3. User2 comments on the post
        response = api_client.post(f'/api/v1/feeds/posts/{post_id}/comments/', {
            'content': 'Great post!',
        })
        assert response.status_code == status.HTTP_201_CREATED
        comment_id = response.data['id']

        # 4. User2 bookmarks the post
        response = api_client.post(f'/api/v1/feeds/posts/{post_id}/bookmark/')
        assert response.status_code == status.HTTP_201_CREATED

        # 5. Check post counts updated
        response = api_client.get(f'/api/v1/posts/{post_id}/')
        assert response.status_code == status.HTTP_200_OK
        assert response.data['like_count'] == 1
        assert response.data['comment_count'] == 1
        assert response.data['bookmark_count'] == 1

        # 6. User2 removes interactions
        api_client.delete(f'/api/v1/feeds/posts/{post_id}/like/')
        api_client.delete(f'/api/v1/feeds/posts/{post_id}/bookmark/')
        api_client.delete(f'/api/v1/feeds/comments/{comment_id}/')

        # 7. Verify counts updated
        response = api_client.get(f'/api/v1/posts/{post_id}/')
        assert response.status_code == status.HTTP_200_OK
        assert response.data['like_count'] == 0
        assert response.data['bookmark_count'] == 0


@pytest.mark.django_db
@pytest.mark.integration
class TestFeedFlow:
    """Integration tests for feed functionality."""

    def test_feed_shows_followed_users_posts(self, api_client):
        """Test that feed shows posts from followed users."""
        from apps.posts.tests.factories import PostFactory
        from apps.users.tests.factories import FollowFactory

        user = UserFactory()
        followed_user = UserFactory()
        not_followed_user = UserFactory()

        # Create follow relationship
        FollowFactory(follower=user, following=followed_user)

        # Create posts
        PostFactory.create_batch(2, author=followed_user)
        PostFactory.create_batch(3, author=not_followed_user)

        # Check feed
        api_client.force_authenticate(user=user)
        response = api_client.get('/api/v1/feeds/')
        assert response.status_code == status.HTTP_200_OK
        # Should only see posts from followed user
        assert len(response.data['results']) == 2
