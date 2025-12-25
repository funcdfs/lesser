from rest_framework import viewsets
from content.models.articles import Article
from content.serializers.articles import ArticleSerializer
from content.views.base import BaseContentViewSet

class ArticleViewSet(BaseContentViewSet):
    """文章视图集"""
    queryset = Article.objects.all().order_by('-created_at')
    serializer_class = ArticleSerializer