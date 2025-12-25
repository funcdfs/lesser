from rest_framework import serializers
from content.models.articles import Article
from content.serializers.base import BaseContentSerializer

class ArticleSerializer(BaseContentSerializer):
    """文章序列化器"""
    class Meta(BaseContentSerializer.Meta):
        model = Article
        fields = BaseContentSerializer.Meta.fields + ['title', 'content', 'column_title', 'reading_time', 'is_published']