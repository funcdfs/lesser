"""
Post views.
"""
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import filters, generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from core.permissions import IsAuthorOrReadOnly

from .models import Post
from .serializers import PostCreateSerializer, PostSerializer, PostUpdateSerializer


class PostListCreateView(generics.ListCreateAPIView):
    """List posts or create a new post."""

    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['post_type', 'author__username']
    search_fields = ['content', 'title']
    ordering_fields = ['created_at', 'like_count']
    ordering = ['-created_at']

    def get_queryset(self):
        return Post.get_active_posts().select_related('author')

    def get_serializer_class(self):
        if self.request.method == 'POST':
            return PostCreateSerializer
        return PostSerializer


class PostDetailView(generics.RetrieveUpdateDestroyAPIView):
    """Retrieve, update, or delete a post."""

    permission_classes = [IsAuthenticated, IsAuthorOrReadOnly]
    lookup_field = 'id'

    def get_queryset(self):
        return Post.objects.filter(is_deleted=False).select_related('author')

    def get_serializer_class(self):
        if self.request.method in ['PUT', 'PATCH']:
            return PostUpdateSerializer
        return PostSerializer

    def destroy(self, request, *args, **kwargs):
        """Soft delete the post."""
        instance = self.get_object()
        instance.is_deleted = True
        instance.save()
        return Response(status=status.HTTP_204_NO_CONTENT)


class UserPostsView(generics.ListAPIView):
    """List posts by a specific user."""

    serializer_class = PostSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        username = self.kwargs.get('username')
        return Post.get_active_posts().filter(
            author__username=username
        ).select_related('author')


class MyPostsView(generics.ListAPIView):
    """List current user's posts."""

    serializer_class = PostSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Post.objects.filter(
            author=self.request.user,
            is_deleted=False
        ).select_related('author')


class PostsByTypeView(generics.ListAPIView):
    """List posts by type (story, short, column)."""

    serializer_class = PostSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        post_type = self.kwargs.get('post_type')
        return Post.get_active_posts().filter(
            post_type=post_type
        ).select_related('author')
