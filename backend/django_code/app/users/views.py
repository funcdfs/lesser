from django.contrib.auth import login, logout, authenticate
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
        username = request.data.get('username', '').strip()
        email = request.data.get('email', '').strip()
        
        # Support both 'password' field (frontend) and 'password1/password2' fields (compatibility)
        password = request.data.get('password', '').strip()
        confirm_password = request.data.get('confirm_password', '').strip()
        
        # Fallback to password1/password2 if password/confirm_password not provided
        if not password:
            password = request.data.get('password1', '').strip()
        if not confirm_password:
            confirm_password = request.data.get('password2', '').strip()

        # Validate required fields - check for empty or whitespace-only values
        if not username:
            return Response({'error': '用户名不能为空'}, status=status.HTTP_400_BAD_REQUEST)
        
        if not password:
            return Response({'error': '密码不能为空'}, status=status.HTTP_400_BAD_REQUEST)
        
        if not confirm_password:
            return Response({'error': '确认密码不能为空'}, status=status.HTTP_400_BAD_REQUEST)

        # Validate password match
        if password != confirm_password:
            return Response({'error': '两次输入的密码不一致'}, status=status.HTTP_400_BAD_REQUEST)

        # Check if username already exists
        if CustomUser.objects.filter(username=username).exists():
            return Response({'error': '用户名已存在'}, status=status.HTTP_400_BAD_REQUEST)

        # Create user
        try:
            user = CustomUser.objects.create_user(
                username=username,
                password=password,
                email=email
            )
            token = Token.objects.create(user=user)
            return Response({
                'token': token.key,
                'username': user.username,
                'userId': user.id
            }, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

# 用户登录API
class LoginAPI(APIView):
    permission_classes = [AllowAny]
    
    def post(self, request):
        username = request.data.get('username', '').strip()
        password = request.data.get('password', '').strip()
        
        # Validate required fields
        if not username:
            return Response({'error': '用户名不能为空'}, status=status.HTTP_400_BAD_REQUEST)
        
        if not password:
            return Response({'error': '密码不能为空'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Authenticate user
        user = authenticate(username=username, password=password)
        
        if user is not None:
            login(request, user)
            token, _ = Token.objects.get_or_create(user=user)
            return Response({
                'token': token.key,
                'username': user.username,
                'userId': user.id
            }, status=status.HTTP_200_OK)
        
        return Response({'error': '用户名或密码错误'}, status=status.HTTP_400_BAD_REQUEST)

# 用户登出API
class LogoutAPI(APIView):
    def post(self, request):
        # Check if user has an auth token
        if hasattr(request.user, 'auth_token'):
            try:
                request.user.auth_token.delete()
            except Exception:
                # Token might already be deleted or not exist
                pass
        
        logout(request)
        return Response({'message': '退出登录成功'}, status=status.HTTP_200_OK)

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