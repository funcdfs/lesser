"""
Custom exception classes.
"""
from rest_framework import status
from rest_framework.exceptions import APIException


class ServiceUnavailable(APIException):
    """Service unavailable exception."""

    status_code = status.HTTP_503_SERVICE_UNAVAILABLE
    default_detail = 'Service temporarily unavailable, try again later.'
    default_code = 'service_unavailable'


class ResourceNotFound(APIException):
    """Resource not found exception."""

    status_code = status.HTTP_404_NOT_FOUND
    default_detail = 'Resource not found.'
    default_code = 'not_found'


class PermissionDenied(APIException):
    """Permission denied exception."""

    status_code = status.HTTP_403_FORBIDDEN
    default_detail = 'You do not have permission to perform this action.'
    default_code = 'permission_denied'


class ValidationError(APIException):
    """Validation error exception."""

    status_code = status.HTTP_400_BAD_REQUEST
    default_detail = 'Invalid input.'
    default_code = 'validation_error'


class ConflictError(APIException):
    """Conflict error exception."""

    status_code = status.HTTP_409_CONFLICT
    default_detail = 'Resource conflict.'
    default_code = 'conflict'


class RateLimitExceeded(APIException):
    """Rate limit exceeded exception."""

    status_code = status.HTTP_429_TOO_MANY_REQUESTS
    default_detail = 'Rate limit exceeded. Please try again later.'
    default_code = 'rate_limit_exceeded'
