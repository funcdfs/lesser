from rest_framework import serializers
from .models import Post

class PostSerializer(serializers.ModelSerializer):
    username = serializers.ReadOnlyField(source='user.username')
    id = serializers.ReadOnlyField()
    is_liked = serializers.BooleanField(default=False)
    
    class Meta:
        model = Post
        fields = [
            'id', 'username', 'content', 'location', 'likes',
            'comments_count', 'reposts_count', 'bookmarks_count', 
            'shares_count', 'created_at', 'is_liked'
        ]
        read_only_fields = ['user']