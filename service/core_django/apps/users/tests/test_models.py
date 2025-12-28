"""
Tests for User models.
"""
import pytest
from django.db import IntegrityError

from apps.users.models import Follow, User

from .factories import FollowFactory, UserFactory


@pytest.mark.django_db
class TestUserModel:
    """Tests for User model."""

    def test_create_user(self):
        """Test creating a user with valid data."""
        user = UserFactory()
        assert user.pk is not None
        assert user.is_active is True
        assert user.is_staff is False

    def test_create_user_without_email_raises_error(self):
        """Test that creating user without email raises ValueError."""
        with pytest.raises(ValueError, match='Users must have an email address'):
            User.objects.create_user(email='', username='test', password='pass')

    def test_create_user_without_username_raises_error(self):
        """Test that creating user without username raises ValueError."""
        with pytest.raises(ValueError, match='Users must have a username'):
            User.objects.create_user(email='test@example.com', username='', password='pass')

    def test_create_superuser(self):
        """Test creating a superuser."""
        user = User.objects.create_superuser(
            email='admin@example.com',
            username='admin',
            password='AdminPass123!'
        )
        assert user.is_staff is True
        assert user.is_superuser is True
        assert user.is_verified is True

    def test_user_str_representation(self):
        """Test user string representation."""
        user = UserFactory(username='testuser')
        assert str(user) == 'testuser'

    def test_email_normalized(self):
        """Test that email is normalized."""
        user = UserFactory(email='Test@EXAMPLE.com')
        assert user.email == 'Test@example.com'

    def test_unique_username_constraint(self):
        """Test that username must be unique."""
        UserFactory(username='unique')
        with pytest.raises(IntegrityError):
            UserFactory(username='unique')

    def test_unique_email_constraint(self):
        """Test that email must be unique."""
        UserFactory(email='unique@example.com')
        with pytest.raises(IntegrityError):
            UserFactory(email='unique@example.com')

    def test_followers_count(self):
        """Test followers count property."""
        user = UserFactory()
        follower1 = UserFactory()
        follower2 = UserFactory()
        FollowFactory(follower=follower1, following=user)
        FollowFactory(follower=follower2, following=user)
        assert user.followers_count == 2

    def test_following_count(self):
        """Test following count property."""
        user = UserFactory()
        following1 = UserFactory()
        following2 = UserFactory()
        FollowFactory(follower=user, following=following1)
        FollowFactory(follower=user, following=following2)
        assert user.following_count == 2


@pytest.mark.django_db
class TestFollowModel:
    """Tests for Follow model."""

    def test_create_follow(self):
        """Test creating a follow relationship."""
        follow = FollowFactory()
        assert follow.pk is not None
        assert follow.follower != follow.following

    def test_follow_str_representation(self):
        """Test follow string representation."""
        follower = UserFactory(username='follower')
        following = UserFactory(username='following')
        follow = FollowFactory(follower=follower, following=following)
        assert str(follow) == 'follower -> following'

    def test_unique_follow_constraint(self):
        """Test that a user can only follow another user once."""
        follower = UserFactory()
        following = UserFactory()
        FollowFactory(follower=follower, following=following)
        with pytest.raises(IntegrityError):
            FollowFactory(follower=follower, following=following)
