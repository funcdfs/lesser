from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from content.models.base import ContentComment, ContentLike, ContentBookmark, ContentRepost
from content.serializers.interactions import (
    ContentCommentSerializer, ContentLikeSerializer, 
    ContentBookmarkSerializer, ContentRepostSerializer
)

class ContentCommentViewSet(viewsets.ModelViewSet):
    """内容评论视图集"""
    permission_classes = [IsAuthenticated]
    queryset = ContentComment.objects.all().order_by('-created_at')
    serializer_class = ContentCommentSerializer
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class ContentLikeViewSet(viewsets.ModelViewSet):
    """内容点赞视图集"""
    permission_classes = [IsAuthenticated]
    queryset = ContentLike.objects.all()
    serializer_class = ContentLikeSerializer
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class ContentBookmarkViewSet(viewsets.ModelViewSet):
    """内容收藏视图集"""
    permission_classes = [IsAuthenticated]
    queryset = ContentBookmark.objects.all()
    serializer_class = ContentBookmarkSerializer
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class ContentRepostViewSet(viewsets.ModelViewSet):
    """内容转发视图集"""
    permission_classes = [IsAuthenticated]
    queryset = ContentRepost.objects.all().order_by('-created_at')
    serializer_class = ContentRepostSerializer
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)