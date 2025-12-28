"""
Search views.
"""
from django.db.models import Q
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import filters, generics
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.posts.models import Post
from apps.posts.serializers import PostSerializer
from apps.users.models import User
from apps.users.serializers import UserSerializer


class SearchPostsView(generics.ListAPIView):
    """Search posts by content, title, or author."""

    serializer_class = PostSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['post_type', 'author__username']
    ordering_fields = ['created_at', 'like_count']
    ordering = ['-created_at']

    def get_queryset(self):
        query = self.request.query_params.get('q', '')
        queryset = Post.get_active_posts().select_related('author')

        if query:
            queryset = queryset.filter(
                Q(content__icontains=query) |
                Q(title__icontains=query) |
                Q(author__username__icontains=query) |
                Q(author__display_name__icontains=query)
            )

        # Filter by date range
        date_from = self.request.query_params.get('date_from')
        date_to = self.request.query_params.get('date_to')

        if date_from:
            queryset = queryset.filter(created_at__gte=date_from)
        if date_to:
            queryset = queryset.filter(created_at__lte=date_to)

        return queryset


class SearchUsersView(generics.ListAPIView):
    """Search users by username or display name."""

    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [filters.OrderingFilter]
    ordering_fields = ['created_at', 'username']
    ordering = ['username']

    def get_queryset(self):
        query = self.request.query_params.get('q', '')
        queryset = User.objects.filter(is_active=True)

        if query:
            queryset = queryset.filter(
                Q(username__icontains=query) |
                Q(display_name__icontains=query) |
                Q(bio__icontains=query)
            )

        return queryset


class SearchAllView(APIView):
    """Combined search for posts and users."""

    permission_classes = [IsAuthenticated]

    def get(self, request):
        query = request.query_params.get('q', '')
        limit = int(request.query_params.get('limit', 10))

        results = {
            'posts': [],
            'users': [],
        }

        if query:
            # Search posts
            posts = Post.get_active_posts().filter(
                Q(content__icontains=query) |
                Q(title__icontains=query)
            ).select_related('author')[:limit]
            results['posts'] = PostSerializer(posts, many=True).data

            # Search users
            users = User.objects.filter(
                is_active=True
            ).filter(
                Q(username__icontains=query) |
                Q(display_name__icontains=query)
            )[:limit]
            results['users'] = UserSerializer(users, many=True).data

        return Response(results)


class TrendingView(APIView):
    """Get trending posts and hashtags."""

    permission_classes = [IsAuthenticated]

    def get(self, request):
        limit = int(request.query_params.get('limit', 10))

        # Get trending posts (most liked in recent period)
        trending_posts = Post.get_active_posts().order_by(
            '-like_count', '-created_at'
        ).select_related('author')[:limit]

        return Response({
            'trending_posts': PostSerializer(trending_posts, many=True).data,
        })
