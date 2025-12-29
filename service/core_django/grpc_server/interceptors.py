"""
gRPC interceptors for logging, authentication, etc.
"""
import logging
import time
from typing import Callable

import grpc

logger = logging.getLogger(__name__)


class LoggingInterceptor(grpc.ServerInterceptor):
    """Interceptor for logging gRPC requests."""

    def intercept_service(self, continuation, handler_call_details):
        start_time = time.time()
        method = handler_call_details.method

        logger.info(f'gRPC request: {method}')

        response = continuation(handler_call_details)

        duration = time.time() - start_time
        logger.info(f'gRPC response: {method} - {duration:.3f}s')

        return response


class AuthInterceptor(grpc.ServerInterceptor):
    """Interceptor for authentication."""

    # Methods that don't require authentication
    PUBLIC_METHODS = [
        '/auth.AuthService/Login',
        '/auth.AuthService/Register',
        '/auth.AuthService/ValidateToken',  # 内部服务调用，用于验证 token
        '/auth.AuthService/RefreshToken',   # 刷新 token 不需要认证
        '/grpc.health.v1.Health/Check',
    ]

    def intercept_service(self, continuation, handler_call_details):
        method = handler_call_details.method

        # Skip auth for public methods
        if method in self.PUBLIC_METHODS:
            return continuation(handler_call_details)

        # Get metadata
        metadata = dict(handler_call_details.invocation_metadata or [])
        auth_header = metadata.get('authorization', '')

        if not auth_header.startswith('Bearer '):
            return self._unauthenticated_response()

        token = auth_header[7:]  # Remove 'Bearer ' prefix

        # Validate token
        if not self._validate_token(token):
            return self._unauthenticated_response()

        return continuation(handler_call_details)

    def _validate_token(self, token: str) -> bool:
        """Validate JWT token."""
        try:
            from rest_framework_simplejwt.tokens import AccessToken
            AccessToken(token)
            return True
        except Exception:
            return False

    def _unauthenticated_response(self):
        """Return unauthenticated response."""
        def abort(ignored_request, context):
            context.abort(grpc.StatusCode.UNAUTHENTICATED, 'Invalid or missing authentication token')
        return grpc.unary_unary_rpc_method_handler(abort)


class RateLimitInterceptor(grpc.ServerInterceptor):
    """Interceptor for rate limiting."""

    def __init__(self, max_requests: int = 100, window_seconds: int = 60):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self._request_counts = {}

    def intercept_service(self, continuation, handler_call_details):
        # Get client identifier from metadata
        metadata = dict(handler_call_details.invocation_metadata or [])
        client_id = metadata.get('x-client-id', 'unknown')

        # Check rate limit
        if self._is_rate_limited(client_id):
            return self._rate_limited_response()

        return continuation(handler_call_details)

    def _is_rate_limited(self, client_id: str) -> bool:
        """Check if client is rate limited."""
        current_time = time.time()

        if client_id not in self._request_counts:
            self._request_counts[client_id] = []

        # Remove old requests outside the window
        self._request_counts[client_id] = [
            t for t in self._request_counts[client_id]
            if current_time - t < self.window_seconds
        ]

        # Check if over limit
        if len(self._request_counts[client_id]) >= self.max_requests:
            return True

        # Add current request
        self._request_counts[client_id].append(current_time)
        return False

    def _rate_limited_response(self):
        """Return rate limited response."""
        def abort(ignored_request, context):
            context.abort(
                grpc.StatusCode.RESOURCE_EXHAUSTED,
                'Rate limit exceeded. Please try again later.'
            )
        return grpc.unary_unary_rpc_method_handler(abort)
