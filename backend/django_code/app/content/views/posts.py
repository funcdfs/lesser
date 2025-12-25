from rest_framework import viewsets
from content.models.posts import Post
from content.serializers.posts import PostSerializer
from content.views.base import BaseContentViewSet

class PostViewSet(BaseContentViewSet):
    """帖子视图集"""
    queryset = Post.objects.all().order_by('-created_at')
    serializer_class = PostSerializer