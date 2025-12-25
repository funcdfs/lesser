from rest_framework import serializers
from content.models.column import Column

class ColumnSerializer(serializers.ModelSerializer):
    """专栏序列化器"""
    creator = serializers.PrimaryKeyRelatedField(read_only=True)
    articles_count = serializers.IntegerField(read_only=True)
    
    class Meta:
        model = Column
        fields = ['id', 'title', 'description', 'creator', 'articles_count', 'created_at', 'updated_at']
        read_only_fields = ['id', 'creator', 'articles_count', 'created_at', 'updated_at']