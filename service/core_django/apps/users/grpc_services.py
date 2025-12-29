"""
gRPC service implementations for users.
"""
import grpc
from google.protobuf.timestamp_pb2 import Timestamp

from .models import User
from .services import UserService

# Proto 生成的代码导入
try:
    from generated.protos.auth import auth_pb2, auth_pb2_grpc
    from generated.protos.common import common_pb2
    PROTO_AVAILABLE = True
except ImportError:
    PROTO_AVAILABLE = False


class AuthServicer(auth_pb2_grpc.AuthServiceServicer if PROTO_AVAILABLE else object):
    """gRPC Auth service implementation."""

    def __init__(self):
        self.user_service = UserService()

    def _user_to_proto(self, user: User):
        """Convert User model to proto message."""
        if not PROTO_AVAILABLE:
            return None
            
        created_at = Timestamp()
        created_at.FromDatetime(user.created_at)
        
        return auth_pb2.User(
            id=str(user.id),
            username=user.username,
            email=user.email,
            display_name=user.display_name or '',
            avatar_url=user.avatar_url or '',
            bio=user.bio or '',
            created_at=created_at,
        )

    def ValidateToken(self, request, context):
        """Validate JWT token and return user info."""
        if not PROTO_AVAILABLE:
            context.set_code(grpc.StatusCode.UNIMPLEMENTED)
            context.set_details('Proto not available')
            return None
            
        try:
            from rest_framework_simplejwt.tokens import AccessToken
            token = AccessToken(request.access_token)
            user_id = token.get('user_id')
            return auth_pb2.ValidateResponse(
                valid=True,
                user_id=str(user_id)
            )
        except Exception as e:
            return auth_pb2.ValidateResponse(
                valid=False,
                user_id=''
            )

    def GetUser(self, request, context):
        """Get user by ID."""
        if not PROTO_AVAILABLE:
            context.set_code(grpc.StatusCode.UNIMPLEMENTED)
            context.set_details('Proto not available')
            return None
            
        user = self.user_service.get_user_by_id(request.user_id)
        if not user:
            context.set_code(grpc.StatusCode.NOT_FOUND)
            context.set_details('User not found')
            return auth_pb2.User()
        return self._user_to_proto(user)

    def Register(self, request, context):
        """Register a new user."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented')
        return auth_pb2.AuthResponse() if PROTO_AVAILABLE else None

    def Login(self, request, context):
        """Login with email and password."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented')
        return auth_pb2.AuthResponse() if PROTO_AVAILABLE else None

    def Logout(self, request, context):
        """Logout and invalidate token."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented')
        return common_pb2.Empty() if PROTO_AVAILABLE else None

    def RefreshToken(self, request, context):
        """Refresh access token."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented')
        return auth_pb2.AuthResponse() if PROTO_AVAILABLE else None


def get_auth_servicer():
    """Factory function to get AuthServicer instance."""
    return AuthServicer()
