"""
用户视图模块。
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
    """用户注册端点。"""

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
    """用户登录端点。"""

    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']
        response_data = AuthResponseSerializer.get_tokens_for_user(user)
        return Response(response_data, status=status.HTTP_200_OK)


class LogoutView(APIView):
    """用户登出端点。"""

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
    """Token 刷新端点，包含更好的错误处理。"""

    def post(self, request, *args, **kwargs):
        try:
            return super().post(request, *args, **kwargs)
        except Exception:
            return Response(
                {'detail': 'Token is invalid or expired.'},
                status=status.HTTP_401_UNAUTHORIZED
            )


class UserProfileView(generics.RetrieveUpdateAPIView):
    """当前用户个人资料端点。"""

    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user

    def retrieve(self, request, *args, **kwargs):
        """返回包含用户信息和统计数据的个人资料格式。"""
        user = self.get_object()
        user_data = self.get_serializer(user).data
        
        # 获取粉丝/关注数量
        followers_count = Follow.objects.filter(following=user).count()
        following_count = Follow.objects.filter(follower=user).count()
        
        return Response({
            'user': user_data,
            'followers_count': followers_count,
            'following_count': following_count,
            'posts_count': 0,  # TODO: 帖子功能完成后实现
            'is_following': False,
            'is_followed_by': False,
        })


class UserDetailView(generics.RetrieveAPIView):
    """根据用户名获取用户详情。"""

    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = 'username'


class UserDetailByIdView(generics.RetrieveAPIView):
    """根据 ID 获取用户详情（用于内部服务通信）。"""

    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [AllowAny]  # 内部服务调用不需要认证
    lookup_field = 'id'


class ChangePasswordView(APIView):
    """修改密码端点。"""

    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = ChangePasswordSerializer(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        request.user.set_password(serializer.validated_data['new_password'])
        request.user.save()
        return Response({'detail': 'Password changed successfully.'}, status=status.HTTP_200_OK)


class FollowView(APIView):
    """关注/取消关注用户端点。"""

    permission_classes = [IsAuthenticated]

    def post(self, request, username):
        """关注用户。"""
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
        """取消关注用户。"""
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
    """获取用户的粉丝列表。"""

    serializer_class = FollowSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        username = self.kwargs.get('username')
        user = get_object_or_404(User, username=username)
        return Follow.objects.filter(following=user)


class FollowingListView(generics.ListAPIView):
    """获取用户的关注列表。"""

    serializer_class = FollowSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        username = self.kwargs.get('username')
        user = get_object_or_404(User, username=username)
        return Follow.objects.filter(follower=user)


class FriendsListView(generics.ListAPIView):
    """获取当前用户的互相关注好友列表。
    
    好友定义为互相关注的用户：
    - 当前用户关注了对方，且对方也关注了当前用户。
    """

    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        # 获取当前用户关注的用户
        following_ids = Follow.objects.filter(
            follower=user
        ).values_list('following_id', flat=True)
        
        # 获取关注当前用户的用户
        followers_ids = Follow.objects.filter(
            following=user
        ).values_list('follower_id', flat=True)
        
        # 交集 = 互相关注 = 好友
        friend_ids = set(following_ids) & set(followers_ids)
        return User.objects.filter(id__in=friend_ids).order_by('username')
