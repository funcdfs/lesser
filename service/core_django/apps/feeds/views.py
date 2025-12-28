"""
Feed views for interactions.
"""
from django.db.models import Exists, OuterRef
from django.shortcuts import get_object_or_404
from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.posts.models import Post
from apps.posts.services import PostService

from .models import Bookmark, Comment, Like, Repost
from .serializers import (
    BookmarkSerializer,
    CommentCreateSerializer,
    CommentSerializer,
    FeedItemSerializer,
    RepostCreateSerializer,
    RepostSerializer,
)


class FeedListView(generics.ListAPIView):
    """Get user's feed (posts from followed users)."""

    serializer_class = FeedItemSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        following_ids = user.following.values_list('following_id', flat=True)

        posts = Post.get_active_posts().filter(
            author_id__in=following_ids
        ).select_related('author').annotate(
            is_liked=Exists(Like.objects.filter(user=user, post=OuterRef('pk'))),
            is_bookmarked=Exists(Bookmark.objects.filter(user=user, post=OuterRef('pk'))),
            is_reposted=Exists(Repost.objects.filter(user=user, post=OuterRef('pk'))),
        )

        return posts

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        page = self.paginate_queryset(queryset)

        if page is not None:
            data = [
                {
                    'post': post,
                    'is_liked': post.is_liked,
                    'is_bookmarked': post.is_bookmarked,
                    'is_reposted': post.is_reposted,
                }
                for post in page
            ]
            serializer = self.get_serializer(data, many=True)
            return self.get_paginated_response(serializer.data)

        data = [
            {
                'post': post,
                'is_liked': post.is_liked,
                'is_bookmarked': post.is_bookmarked,
                'is_reposted': post.is_reposted,
            }
            for post in queryset
        ]
        serializer = self.get_serializer(data, many=True)
        return Response(serializer.data)


class LikeView(APIView):
    """Like/unlike a post."""

    permission_classes = [IsAuthenticated]

    def post(self, request, post_id):
        """Like a post."""
        post = get_object_or_404(Post, id=post_id, is_deleted=False)
        like, created = Like.objects.get_or_create(user=request.user, post=post)

        if created:
            PostService.increment_count(post, 'like_count')
            return Response({'detail': 'Post liked.'}, status=status.HTTP_201_CREATED)
        return Response({'detail': 'Already liked.'}, status=status.HTTP_200_OK)

    def delete(self, request, post_id):
        """Unlike a post."""
        post = get_object_or_404(Post, id=post_id, is_deleted=False)
        deleted, _ = Like.objects.filter(user=request.user, post=post).delete()

        if deleted:
            PostService.decrement_count(post, 'like_count')
            return Response({'detail': 'Post unliked.'}, status=status.HTTP_200_OK)
        return Response({'detail': 'Not liked.'}, status=status.HTTP_400_BAD_REQUEST)


class BookmarkView(APIView):
    """Bookmark/unbookmark a post."""

    permission_classes = [IsAuthenticated]

    def post(self, request, post_id):
        """Bookmark a post."""
        post = get_object_or_404(Post, id=post_id, is_deleted=False)
        bookmark, created = Bookmark.objects.get_or_create(user=request.user, post=post)

        if created:
            PostService.increment_count(post, 'bookmark_count')
            return Response({'detail': 'Post bookmarked.'}, status=status.HTTP_201_CREATED)
        return Response({'detail': 'Already bookmarked.'}, status=status.HTTP_200_OK)

    def delete(self, request, post_id):
        """Remove bookmark."""
        post = get_object_or_404(Post, id=post_id, is_deleted=False)
        deleted, _ = Bookmark.objects.filter(user=request.user, post=post).delete()

        if deleted:
            PostService.decrement_count(post, 'bookmark_count')
            return Response({'detail': 'Bookmark removed.'}, status=status.HTTP_200_OK)
        return Response({'detail': 'Not bookmarked.'}, status=status.HTTP_400_BAD_REQUEST)


class BookmarkListView(generics.ListAPIView):
    """List user's bookmarks."""

    serializer_class = BookmarkSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Bookmark.objects.filter(
            user=self.request.user
        ).select_related('post', 'post__author')


class RepostView(APIView):
    """Repost a post."""

    permission_classes = [IsAuthenticated]

    def post(self, request, post_id):
        """Create a repost."""
        post = get_object_or_404(Post, id=post_id, is_deleted=False)
        serializer = RepostCreateSerializer(data={'post': post.id, **request.data})
        serializer.is_valid(raise_exception=True)

        repost = Repost.objects.create(
            user=request.user,
            post=post,
            quote=serializer.validated_data.get('quote', '')
        )
        PostService.increment_count(post, 'repost_count')

        return Response(
            RepostSerializer(repost).data,
            status=status.HTTP_201_CREATED
        )

    def delete(self, request, post_id):
        """Remove repost."""
        post = get_object_or_404(Post, id=post_id, is_deleted=False)
        deleted, _ = Repost.objects.filter(user=request.user, post=post).delete()

        if deleted:
            PostService.decrement_count(post, 'repost_count')
            return Response({'detail': 'Repost removed.'}, status=status.HTTP_200_OK)
        return Response({'detail': 'Not reposted.'}, status=status.HTTP_400_BAD_REQUEST)


class CommentListCreateView(generics.ListCreateAPIView):
    """List or create comments for a post."""

    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        post_id = self.kwargs.get('post_id')
        return Comment.objects.filter(
            post_id=post_id,
            parent__isnull=True,
            is_deleted=False
        ).select_related('author')

    def get_serializer_class(self):
        if self.request.method == 'POST':
            return CommentCreateSerializer
        return CommentSerializer

    def perform_create(self, serializer):
        post_id = self.kwargs.get('post_id')
        post = get_object_or_404(Post, id=post_id, is_deleted=False)
        comment = serializer.save(author=self.request.user, post=post)
        PostService.increment_count(post, 'comment_count')
        return comment


class CommentDetailView(generics.RetrieveDestroyAPIView):
    """Retrieve or delete a comment."""

    serializer_class = CommentSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = 'id'

    def get_queryset(self):
        return Comment.objects.filter(is_deleted=False).select_related('author')

    def destroy(self, request, *args, **kwargs):
        """Soft delete the comment."""
        instance = self.get_object()
        if instance.author != request.user:
            return Response(
                {'detail': 'You can only delete your own comments.'},
                status=status.HTTP_403_FORBIDDEN
            )
        instance.is_deleted = True
        instance.save()
        PostService.decrement_count(instance.post, 'comment_count')
        return Response(status=status.HTTP_204_NO_CONTENT)


class CommentRepliesView(generics.ListAPIView):
    """List replies to a comment."""

    serializer_class = CommentSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        comment_id = self.kwargs.get('comment_id')
        return Comment.objects.filter(
            parent_id=comment_id,
            is_deleted=False
        ).select_related('author')
