from rest_framework import viewsets
from content.models.story import Story
from content.serializers.story import StorySerializer
from content.views.base import BaseContentViewSet

class StoryViewSet(BaseContentViewSet):
    """故事视图集"""
    queryset = Story.objects.all()
    serializer_class = StorySerializer