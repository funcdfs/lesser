"""
User serializers.
"""
from django.contrib.auth import authenticate
from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers
from rest_framework_simplejwt.tokens import RefreshToken

from .models import Follow, User


class UserSerializer(serializers.ModelSerializer):
    """User serializer for public profile."""

    followers_count = serializers.IntegerField(read_only=True)
    following_count = serializers.IntegerField(read_only=True)

    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'display_name', 'avatar_url', 'bio',
            'is_verified', 'followers_count', 'following_count', 'created_at'
        ]
        read_only_fields = ['id', 'is_verified', 'created_at']


class UserMinimalSerializer(serializers.ModelSerializer):
    """Minimal user serializer for nested objects."""

    class Meta:
        model = User
        fields = ['id', 'username', 'display_name', 'avatar_url']


class RegisterSerializer(serializers.ModelSerializer):
    """User registration serializer."""

    password = serializers.CharField(write_only=True, validators=[validate_password])
    password_confirm = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'password_confirm', 'display_name']

    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError({'password_confirm': 'Passwords do not match.'})
        return attrs

    def create(self, validated_data):
        validated_data.pop('password_confirm')
        user = User.objects.create_user(**validated_data)
        return user


class LoginSerializer(serializers.Serializer):
    """User login serializer."""

    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        email = attrs.get('email')
        password = attrs.get('password')

        user = authenticate(username=email, password=password)
        if not user:
            raise serializers.ValidationError('Invalid email or password.')
        if not user.is_active:
            raise serializers.ValidationError('User account is disabled.')

        attrs['user'] = user
        return attrs


class AuthResponseSerializer(serializers.Serializer):
    """Authentication response serializer."""

    user = UserSerializer()
    access_token = serializers.CharField()
    refresh_token = serializers.CharField()

    @classmethod
    def get_tokens_for_user(cls, user):
        refresh = RefreshToken.for_user(user)
        return {
            'user': UserSerializer(user).data,
            'access_token': str(refresh.access_token),
            'refresh_token': str(refresh),
        }


class FollowSerializer(serializers.ModelSerializer):
    """Follow serializer."""

    follower = UserMinimalSerializer(read_only=True)
    following = UserMinimalSerializer(read_only=True)

    class Meta:
        model = Follow
        fields = ['id', 'follower', 'following', 'created_at']
        read_only_fields = ['id', 'created_at']


class ChangePasswordSerializer(serializers.Serializer):
    """Change password serializer."""

    old_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True, validators=[validate_password])

    def validate_old_password(self, value):
        user = self.context['request'].user
        if not user.check_password(value):
            raise serializers.ValidationError('Old password is incorrect.')
        return value
