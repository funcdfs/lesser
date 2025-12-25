from rest_framework import viewsets
from content.models.drafts import Draft
from content.serializers.drafts import DraftSerializer
from content.views.base import BaseContentViewSet

class DraftViewSet(BaseContentViewSet):
    """草稿视图集"""
    queryset = Draft.objects.all().order_by('-updated_at')
    serializer_class = DraftSerializer