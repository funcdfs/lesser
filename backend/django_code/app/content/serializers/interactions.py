from rest_framework import serializers
from content.models.base import ContentComment, ContentLike, ContentBookmark, ContentRepost

class ContentCommentSerializer(serializers.ModelSerializer):
    """内容评论序列化器"""
    user = serializers.PrimaryKeyRelatedField(read_only=True)
    likes_count = serializers.IntegerField(read_only=True)
    
    class Meta:
        model = ContentComment
        fields = ['id', 'user', 'content_id', 'content_type', 'content_text', 'likes_count', 'created_at', 'updated_at']
        read_only_fields = ['id', 'user', 'likes_count', 'created_at', 'updated_at']

class ContentLikeSerializer(serializers.ModelSerializer):
    """内容点赞序列化器"""
    user = serializers.PrimaryKeyRelatedField(read_only=True)
    
    class Meta:
        model = ContentLike
        fields = ['id', 'user', 'content_id', 'content_type', 'created_at']
        read_only_fields = ['id', 'user', 'created_at']

class ContentBookmarkSerializer(serializers.ModelSerializer):
    """内容收藏序列化器"""
    user = serializers.PrimaryKeyRelatedField(read_only=True)
    
    class Meta:
        model = ContentBookmark
        fields = ['id', 'user', 'content_id', 'content_type', 'created_at']
        read_only_fields = ['id', 'user', 'created_at']

class ContentRepostSerializer(serializers.ModelSerializer):
    """内容转发序列化器"""
    user = serializers.PrimaryKeyRelatedField(read_only=True)
    
    class Meta:
        model = ContentRepost
        fields = ['id', 'user', 'content_id', 'content_type', 'added_content', 'created_at']
        read_only_fields = ['id', 'user', 'created_at']