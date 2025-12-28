"""
gRPC service implementations for users.
"""
import grpc
from google.protobuf.timestamp_pb2 import Timestamp

from .models import User
from .services import UserService

# Note: These imports will work after proto code generation
# from generated.protos.auth import auth_pb2, auth_pb2_grpc


class AuthServicer:
    """gRPC Auth service implementation."""

    def __init__(self):
        self.user_service = UserService()

    def _user_to_proto(self, user: User):
        """Convert User model to proto message."""
        # This will be implemented after proto generation
        # For now, return a dict representation
        created_at = Timestamp()
        created_at.FromDatetime(user.created_at)
        return {
            'id': str(user.id),
            'username': user.username,
            'email': user.email,
            'display_name': user.display_name or '',
            'avatar_url': user.avatar_url or '',
            'bio': user.bio or '',
            'created_at': created_at,
        }

    def ValidateToken(self, request, context):
        """Validate JWT token and return user info."""
        # Token validation is handled by JWT middleware
        # This is for inter-service communication
        try:
            from rest_framework_simplejwt.tokens import AccessToken
            token = AccessToken(request.access_token)
            user_id = token.get('user_id')
            return {'valid': True, 'user_id': str(user_id)}
        except Exception:
            return {'valid': False, 'user_id': ''}

    def GetUser(self, request, context):
        """Get user by ID."""
        user = self.user_service.get_user_by_id(request.user_id)
        if not user:
            context.set_code(grpc.StatusCode.NOT_FOUND)
            context.set_details('User not found')
            return None
        return self._user_to_proto(user)


def get_auth_servicer():
    """Factory function to get AuthServicer instance."""
    return AuthServicer()
