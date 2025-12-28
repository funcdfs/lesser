"""
Post serializers.
"""
from rest_framework import serializers

from apps.users.serializers import UserMinimalSerializer

from .models import Post, PostMedia, PostType


class PostMediaSerializer(serializers.ModelSerializer):
    """Post media serializer."""

    class Meta:
        model = PostMedia
        fields = ['id', 'url', 'media_type', 'order']
        read_only_fields = ['id']


class PostSerializer(serializers.ModelSerializer):
    """Post serializer for list/detail views."""

    author = UserMinimalSerializer(read_only=True)
    media = PostMediaSerializer(many=True, read_only=True)
    is_expired = serializers.BooleanField(read_only=True)

    class Meta:
        model = Post
        fields = [
            'id', 'author', 'post_type', 'title', 'content', 'media_urls', 'media',
            'expires_at', 'is_expired', 'is_deleted',
            'like_count', 'comment_count', 'repost_count', 'bookmark_count',
            'created_at', 'updated_at'
        ]
        read_only_fields = [
            'id', 'author', 'expires_at', 'is_deleted',
            'like_count', 'comment_count', 'repost_count', 'bookmark_count',
            'created_at', 'updated_at'
        ]


class PostCreateSerializer(serializers.ModelSerializer):
    """Post creation serializer."""

    class Meta:
        model = Post
        fields = ['post_type', 'title', 'content', 'media_urls']

    def validate(self, attrs):
        post_type = attrs.get('post_type')
        content = attrs.get('content', '')
        title = attrs.get('title', '')

        # Validation rules based on post type
        if post_type == PostType.STORY:
            if len(content) > 500:
                raise serializers.ValidationError({
                    'content': 'Story content must be 500 characters or less.'
                })
        elif post_type == PostType.SHORT:
            if len(content) > 280:
                raise serializers.ValidationError({
                    'content': 'Short post must be 280 characters or less.'
                })
        elif post_type == PostType.COLUMN:
            if not title:
                raise serializers.ValidationError({
                    'title': 'Column posts require a title.'
                })
            if len(content) < 100:
                raise serializers.ValidationError({
                    'content': 'Column content must be at least 100 characters.'
                })

        return attrs

    def create(self, validated_data):
        validated_data['author'] = self.context['request'].user
        return super().create(validated_data)


class PostUpdateSerializer(serializers.ModelSerializer):
    """Post update serializer."""

    class Meta:
        model = Post
        fields = ['title', 'content', 'media_urls']

    def validate(self, attrs):
        instance = self.instance
        content = attrs.get('content', instance.content)
        title = attrs.get('title', instance.title)

        # Apply same validation rules
        if instance.post_type == PostType.STORY:
            if len(content) > 500:
                raise serializers.ValidationError({
                    'content': 'Story content must be 500 characters or less.'
                })
        elif instance.post_type == PostType.SHORT:
            if len(content) > 280:
                raise serializers.ValidationError({
                    'content': 'Short post must be 280 characters or less.'
                })
        elif instance.post_type == PostType.COLUMN:
            if not title:
                raise serializers.ValidationError({
                    'title': 'Column posts require a title.'
                })

        return attrs
