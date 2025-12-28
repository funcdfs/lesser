"""
Feed serializers.
"""
from rest_framework import serializers

from apps.posts.serializers import PostSerializer
from apps.users.serializers import UserMinimalSerializer

from .models import Bookmark, Comment, Like, Repost


class LikeSerializer(serializers.ModelSerializer):
    """Like serializer."""

    user = UserMinimalSerializer(read_only=True)

    class Meta:
        model = Like
        fields = ['id', 'user', 'post', 'created_at']
        read_only_fields = ['id', 'user', 'created_at']


class RepostSerializer(serializers.ModelSerializer):
    """Repost serializer."""

    user = UserMinimalSerializer(read_only=True)
    post = PostSerializer(read_only=True)

    class Meta:
        model = Repost
        fields = ['id', 'user', 'post', 'quote', 'created_at']
        read_only_fields = ['id', 'user', 'created_at']


class RepostCreateSerializer(serializers.ModelSerializer):
    """Repost creation serializer."""

    class Meta:
        model = Repost
        fields = ['post', 'quote']


class CommentSerializer(serializers.ModelSerializer):
    """Comment serializer."""

    author = UserMinimalSerializer(read_only=True)
    reply_count = serializers.IntegerField(read_only=True)

    class Meta:
        model = Comment
        fields = [
            'id', 'author', 'post', 'parent', 'content',
            'reply_count', 'is_deleted', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'author', 'is_deleted', 'created_at', 'updated_at']


class CommentCreateSerializer(serializers.ModelSerializer):
    """Comment creation serializer."""

    class Meta:
        model = Comment
        fields = ['post', 'parent', 'content']

    def validate_content(self, value):
        if len(value.strip()) == 0:
            raise serializers.ValidationError('Comment cannot be empty.')
        return value

    def validate(self, attrs):
        parent = attrs.get('parent')
        post = attrs.get('post')

        # Ensure parent comment belongs to the same post
        if parent and parent.post != post:
            raise serializers.ValidationError({
                'parent': 'Parent comment must belong to the same post.'
            })

        return attrs


class BookmarkSerializer(serializers.ModelSerializer):
    """Bookmark serializer."""

    user = UserMinimalSerializer(read_only=True)
    post = PostSerializer(read_only=True)

    class Meta:
        model = Bookmark
        fields = ['id', 'user', 'post', 'created_at']
        read_only_fields = ['id', 'user', 'created_at']


class FeedItemSerializer(serializers.Serializer):
    """Feed item serializer combining post with user interaction status."""

    post = PostSerializer()
    is_liked = serializers.BooleanField()
    is_bookmarked = serializers.BooleanField()
    is_reposted = serializers.BooleanField()
