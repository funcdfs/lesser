from rest_framework import serializers
from content.models.posts import Post
from content.serializers.base import BaseContentSerializer

class PostSerializer(BaseContentSerializer):
    """帖子序列化器"""
    class Meta(BaseContentSerializer.Meta):
        model = Post
        fields = BaseContentSerializer.Meta.fields + ['content', 'is_published']