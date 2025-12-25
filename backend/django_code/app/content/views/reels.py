from rest_framework import viewsets
from content.models.reels import Reel
from content.serializers.reels import ReelSerializer
from content.views.base import BaseContentViewSet

class ReelViewSet(BaseContentViewSet):
    """短视频视图集"""
    queryset = Reel.objects.all().order_by('-created_at')
    serializer_class = ReelSerializer