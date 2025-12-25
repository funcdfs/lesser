from rest_framework import serializers
from content.models.base import ContentImage

class ContentImageSerializer(serializers.ModelSerializer):
    """内容图片序列化器"""
    class Meta:
        model = ContentImage
        fields = ['id', 'image', 'uploaded_at']
        read_only_fields = ['id', 'uploaded_at']

class BaseContentSerializer(serializers.ModelSerializer):
    """基础内容序列化器"""
    user = serializers.PrimaryKeyRelatedField(read_only=True)
    images = ContentImageSerializer(many=True, required=False, read_only=True)
    likes_count = serializers.IntegerField(read_only=True)
    comments_count = serializers.IntegerField(read_only=True)
    reposts_count = serializers.IntegerField(read_only=True)
    bookmarks_count = serializers.IntegerField(read_only=True)
    
    class Meta:
        abstract = True
        fields = [
            'id', 'user', 'images', 'likes_count', 'comments_count',
            'reposts_count', 'bookmarks_count', 'created_at', 'updated_at'
        ]
        read_only_fields = [
            'id', 'user', 'likes_count', 'comments_count', 'reposts_count',
            'bookmarks_count', 'created_at', 'updated_at'
        ]