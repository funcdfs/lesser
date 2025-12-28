"""
User views.
"""
from django.shortcuts import get_object_or_404
from rest_framework import generics, status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenRefreshView

from .models import Follow, User
from .serializers import (
    AuthResponseSerializer,
    ChangePasswordSerializer,
    FollowSerializer,
    LoginSerializer,
    RegisterSerializer,
    UserSerializer,
)


class RegisterView(generics.CreateAPIView):
    """User registration endpoint."""

    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [AllowAny]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        response_data = AuthResponseSerializer.get_tokens_for_user(user)
        return Response(response_data, status=status.HTTP_201_CREATED)


class LoginView(APIView):
    """User login endpoint."""

    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']
        response_data = AuthResponseSerializer.get_tokens_for_user(user)
        return Response(response_data, status=status.HTTP_200_OK)


class LogoutView(APIView):
    """User logout endpoint."""

    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            refresh_token = request.data.get('refresh_token')
            if refresh_token:
                token = RefreshToken(refresh_token)
                token.blacklist()
            return Response({'detail': 'Successfully logged out.'}, status=status.HTTP_200_OK)
        except Exception:
            return Response({'detail': 'Invalid token.'}, status=status.HTTP_400_BAD_REQUEST)


class TokenRefreshAPIView(TokenRefreshView):
    """Token refresh endpoint."""

    pass


class UserProfileView(generics.RetrieveUpdateAPIView):
    """Current user profile endpoint."""

    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user


class UserDetailView(generics.RetrieveAPIView):
    """User detail by username."""

    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = 'username'


class ChangePasswordView(APIView):
    """Change password endpoint."""

    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = ChangePasswordSerializer(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        request.user.set_password(serializer.validated_data['new_password'])
        request.user.save()
        return Response({'detail': 'Password changed successfully.'}, status=status.HTTP_200_OK)


class FollowView(APIView):
    """Follow/unfollow user endpoint."""

    permission_classes = [IsAuthenticated]

    def post(self, request, username):
        """Follow a user."""
        user_to_follow = get_object_or_404(User, username=username)
        if user_to_follow == request.user:
            return Response(
                {'detail': 'You cannot follow yourself.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        follow, created = Follow.objects.get_or_create(
            follower=request.user,
            following=user_to_follow
        )
        if not created:
            return Response(
                {'detail': 'Already following this user.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        return Response({'detail': 'Successfully followed.'}, status=status.HTTP_201_CREATED)

    def delete(self, request, username):
        """Unfollow a user."""
        user_to_unfollow = get_object_or_404(User, username=username)
        deleted, _ = Follow.objects.filter(
            follower=request.user,
            following=user_to_unfollow
        ).delete()
        if not deleted:
            return Response(
                {'detail': 'Not following this user.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        return Response({'detail': 'Successfully unfollowed.'}, status=status.HTTP_200_OK)


class FollowersListView(generics.ListAPIView):
    """List user's followers."""

    serializer_class = FollowSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        username = self.kwargs.get('username')
        user = get_object_or_404(User, username=username)
        return Follow.objects.filter(following=user)


class FollowingListView(generics.ListAPIView):
    """List users that user is following."""

    serializer_class = FollowSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        username = self.kwargs.get('username')
        user = get_object_or_404(User, username=username)
        return Follow.objects.filter(follower=user)
