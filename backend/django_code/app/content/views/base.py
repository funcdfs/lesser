from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import action
from content.models.base import ContentImage

class BaseContentViewSet(viewsets.ModelViewSet):
    """基础内容视图集"""
    permission_classes = [IsAuthenticated]
    
    def perform_create(self, serializer):
        # 创建内容
        content = serializer.save(user=self.request.user)
        
        # 处理图片上传
        if 'images' in self.request.FILES:
            images = self.request.FILES.getlist('images')
            for image in images:
                content_image = ContentImage.objects.create(image=image)
                content.images.add(content_image)
        
        return content
    
    @action(detail=True, methods=['post'], url_path='upload-images')
    def upload_images(self, request, pk=None):
        """上传图片到现有内容"""
        content = self.get_object()
        
        # 检查用户权限
        if content.user != request.user:
            return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
        
        if 'images' not in request.FILES:
            return Response({'error': 'No images provided'}, status=status.HTTP_400_BAD_REQUEST)
        
        images = request.FILES.getlist('images')
        uploaded_images = []
        
        for image in images:
            content_image = ContentImage.objects.create(image=image)
            content.images.add(content_image)
            uploaded_images.append(content_image)
        
        from content.serializers.base import ContentImageSerializer
        serializer = ContentImageSerializer(uploaded_images, many=True)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
    @action(detail=True, methods=['post'], url_path='publish')
    def publish(self, request, pk=None):
        """发布内容"""
        content = self.get_object()
        
        # 检查用户权限
        if content.user != request.user:
            return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
        
        content.is_published = True
        content.save()
        
        serializer = self.get_serializer(content)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'], url_path='unpublish')
    def unpublish(self, request, pk=None):
        """取消发布内容"""
        content = self.get_object()
        
        # 检查用户权限
        if content.user != request.user:
            return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
        
        content.is_published = False
        content.save()
        
        serializer = self.get_serializer(content)
        return Response(serializer.data)