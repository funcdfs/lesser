"""
Pytest configuration and fixtures for Django tests.
"""
import pytest
from rest_framework.test import APIClient

from apps.users.models import User


@pytest.fixture
def api_client():
    """Return an API client for testing."""
    return APIClient()


@pytest.fixture
def user_data():
    """Return sample user data for testing."""
    return {
        'username': 'testuser',
        'email': 'test@example.com',
        'password': 'TestPass123!',
        'display_name': 'Test User',
    }


@pytest.fixture
def user(db, user_data):
    """Create and return a test user."""
    return User.objects.create_user(
        username=user_data['username'],
        email=user_data['email'],
        password=user_data['password'],
        display_name=user_data['display_name'],
    )


@pytest.fixture
def second_user(db):
    """Create and return a second test user."""
    return User.objects.create_user(
        username='seconduser',
        email='second@example.com',
        password='TestPass123!',
        display_name='Second User',
    )


@pytest.fixture
def authenticated_client(api_client, user):
    """Return an authenticated API client."""
    api_client.force_authenticate(user=user)
    return api_client


@pytest.fixture
def auth_tokens(api_client, user, user_data):
    """Get authentication tokens for a user."""
    response = api_client.post('/api/v1/auth/login/', {
        'email': user_data['email'],
        'password': user_data['password'],
    })
    return response.data
