from rest_framework import serializers
from content.models.reels import Reel
from content.serializers.base import BaseContentSerializer

class ReelSerializer(BaseContentSerializer):
    """短视频序列化器"""
    class Meta(BaseContentSerializer.Meta):
        model = Reel
        fields = BaseContentSerializer.Meta.fields + ['title', 'description', 'video_url', 'duration', 'is_published']