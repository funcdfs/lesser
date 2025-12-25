from rest_framework import serializers
from content.models.story import Story
from content.serializers.base import BaseContentSerializer

class StorySerializer(BaseContentSerializer):
    """故事序列化器"""
    class Meta(BaseContentSerializer.Meta):
        model = Story
        fields = BaseContentSerializer.Meta.fields + ['title', 'description', 'video_url', 'duration', 'is_published']