from rest_framework import serializers
from content.models.drafts import Draft
from content.serializers.base import BaseContentSerializer

class DraftSerializer(BaseContentSerializer):
    """草稿序列化器"""
    content_type = serializers.ChoiceField(choices=Draft.CONTENT_TYPE_CHOICES)
    
    class Meta(BaseContentSerializer.Meta):
        model = Draft
        fields = BaseContentSerializer.Meta.fields + ['title', 'content', 'content_type', 'column_title', 'is_auto_saved']