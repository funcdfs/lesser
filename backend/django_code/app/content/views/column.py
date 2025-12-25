from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from content.models.column import Column
from content.serializers.column import ColumnSerializer

class ColumnViewSet(viewsets.ModelViewSet):
    """专栏视图集"""
    queryset = Column.objects.all()
    serializer_class = ColumnSerializer
    permission_classes = [IsAuthenticated]
    
    def perform_create(self, serializer):
        # 创建专栏时自动设置创建者为当前用户
        serializer.save(creator=self.request.user)
    
    def get_queryset(self):
        # 如果提供了creator参数，过滤特定用户的专栏
        creator_id = self.request.query_params.get('creator_id')
        if creator_id:
            return self.queryset.filter(creator_id=creator_id)
        return self.queryset