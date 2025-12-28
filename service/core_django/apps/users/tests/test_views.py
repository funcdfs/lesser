"""
Tests for User API views.
"""
import pytest
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from apps.users.models import Follow, User

from .factories import FollowFactory, UserFactory


@pytest.mark.django_db
class TestRegisterView:
    """Tests for user registration endpoint."""

    def test_register_success(self, api_client):
        """Test successful user registration."""
        data = {
            'username': 'newuser',
            'email': 'newuser@example.com',
            'password': 'TestPass123!',
            'password_confirm': 'TestPass123!',
            'display_name': 'New User',
        }
        response = api_client.post('/api/v1/auth/register/', data)
        assert response.status_code == status.HTTP_201_CREATED
        assert 'access_token' in response.data
        assert 'refresh_token' in response.data
        assert response.data['user']['username'] == 'newuser'

    def test_register_password_mismatch(self, api_client):
        """Test registration fails with password mismatch."""
        data = {
            'username': 'newuser',
            'email': 'newuser@example.com',
            'password': 'TestPass123!',
            'password_confirm': 'DifferentPass123!',
        }
        response = api_client.post('/api/v1/auth/register/', data)
        assert response.status_code == status.HTTP_400_BAD_REQUEST

    def test_register_duplicate_email(self, api_client):
        """Test registration fails with duplicate email."""
        UserFactory(email='existing@example.com')
        data = {
            'username': 'newuser',
            'email': 'existing@example.com',
            'password': 'TestPass123!',
            'password_confirm': 'TestPass123!',
        }
        response = api_client.post('/api/v1/auth/register/', data)
        assert response.status_code == status.HTTP_400_BAD_REQUEST


@pytest.mark.django_db
class TestLoginView:
    """Tests for user login endpoint."""

    def test_login_success(self, api_client):
        """Test successful login."""
        user = UserFactory()
        response = api_client.post('/api/v1/auth/login/', {
            'email': user.email,
            'password': 'TestPass123!',
        })
        assert response.status_code == status.HTTP_200_OK
        assert 'access_token' in response.data
        assert 'refresh_token' in response.data

    def test_login_invalid_credentials(self, api_client):
        """Test login fails with invalid credentials."""
        user = UserFactory()
        response = api_client.post('/api/v1/auth/login/', {
            'email': user.email,
            'password': 'WrongPassword!',
        })
        assert response.status_code == status.HTTP_400_BAD_REQUEST

    def test_login_nonexistent_user(self, api_client):
        """Test login fails for nonexistent user."""
        response = api_client.post('/api/v1/auth/login/', {
            'email': 'nonexistent@example.com',
            'password': 'TestPass123!',
        })
        assert response.status_code == status.HTTP_400_BAD_REQUEST


@pytest.mark.django_db
class TestLogoutView:
    """Tests for user logout endpoint."""

    def test_logout_success(self, api_client):
        """Test successful logout."""
        user = UserFactory()
        # Login first
        login_response = api_client.post('/api/v1/auth/login/', {
            'email': user.email,
            'password': 'TestPass123!',
        })
        access_token = login_response.data['access_token']
        refresh_token = login_response.data['refresh_token']

        # Logout
        api_client.credentials(HTTP_AUTHORIZATION=f'Bearer {access_token}')
        response = api_client.post('/api/v1/auth/logout/', {
            'refresh_token': refresh_token,
        })
        assert response.status_code == status.HTTP_200_OK

    def test_logout_unauthenticated(self, api_client):
        """Test logout fails when not authenticated."""
        response = api_client.post('/api/v1/auth/logout/')
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


@pytest.mark.django_db
class TestUserProfileView:
    """Tests for user profile endpoint."""

    def test_get_profile(self, api_client):
        """Test getting current user profile."""
        user = UserFactory()
        api_client.force_authenticate(user=user)
        response = api_client.get('/api/v1/auth/me/')
        assert response.status_code == status.HTTP_200_OK
        assert response.data['username'] == user.username

    def test_update_profile(self, api_client):
        """Test updating user profile."""
        user = UserFactory()
        api_client.force_authenticate(user=user)
        response = api_client.patch('/api/v1/auth/me/', {
            'display_name': 'Updated Name',
            'bio': 'Updated bio',
        })
        assert response.status_code == status.HTTP_200_OK
        assert response.data['display_name'] == 'Updated Name'


@pytest.mark.django_db
class TestFollowView:
    """Tests for follow/unfollow endpoint."""

    def test_follow_user(self, api_client):
        """Test following a user."""
        user = UserFactory()
        target = UserFactory()
        api_client.force_authenticate(user=user)
        response = api_client.post(f'/api/v1/auth/users/{target.username}/follow/')
        assert response.status_code == status.HTTP_201_CREATED
        assert Follow.objects.filter(follower=user, following=target).exists()

    def test_unfollow_user(self, api_client):
        """Test unfollowing a user."""
        user = UserFactory()
        target = UserFactory()
        FollowFactory(follower=user, following=target)
        api_client.force_authenticate(user=user)
        response = api_client.delete(f'/api/v1/auth/users/{target.username}/follow/')
        assert response.status_code == status.HTTP_200_OK
        assert not Follow.objects.filter(follower=user, following=target).exists()

    def test_cannot_follow_self(self, api_client):
        """Test that user cannot follow themselves."""
        user = UserFactory()
        api_client.force_authenticate(user=user)
        response = api_client.post(f'/api/v1/auth/users/{user.username}/follow/')
        assert response.status_code == status.HTTP_400_BAD_REQUEST
