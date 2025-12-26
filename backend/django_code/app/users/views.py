from django.contrib.auth import login, logout
from django.contrib.auth.forms import UserCreationForm, AuthenticationForm
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.authtoken.models import Token
from .models import CustomUser

# 用户注册API
class RegisterAPI(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        username = request.data.get('username')
        password1 = request.data.get('password1')
        password2 = request.data.get('password2')
        email = request.data.get('email', '')

        # 基本验证
        if not username or not password1 or not password2:
            return Response({'error': '请填写完整信息'}, status=status.HTTP_400_BAD_REQUEST)

        if password1 != password2:
            return Response({'error': '两次输入的密码不一致'}, status=status.HTTP_400_BAD_REQUEST)

        # 创建用户
        try:
            user = CustomUser.objects.create_user(
                username=username,
                password=password1,
                email=email
            )
            token = Token.objects.create(user=user)
            return Response({
                'token': token.key,
                'username': user.username,
                'id': user.id
            })
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

# 用户登录API
class LoginAPI(APIView):
    permission_classes = [AllowAny]
    
    def post(self, request):
        form = AuthenticationForm(data=request.data)
        if form.is_valid():
            user = form.get_user()
            login(request, user)
            token, _ = Token.objects.get_or_create(user=user)
            return Response({
                'token': token.key,
                'username': user.username,
                'id': user.id
            }, status=status.HTTP_200_OK)
        return Response(form.errors, status=status.HTTP_400_BAD_REQUEST)

# 用户登出API
class LogoutAPI(APIView):
    def post(self, request):
        request.user.auth_token.delete()
        logout(request)
        return Response({'message': 'Successfully logged out'}, status=status.HTTP_200_OK)

# 用户信息API
class UserAPI(APIView):
    def get(self, request):
        return Response({
            'username': request.user.username,
            'id': request.user.id,
            'email': request.user.email,
            'first_name': request.user.first_name,
            'last_name': request.user.last_name
        }, status=status.HTTP_200_OK)