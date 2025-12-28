"""
Custom middleware for the application.
"""
import logging
import time

from django.http import HttpRequest, HttpResponse

logger = logging.getLogger(__name__)


class RequestLoggingMiddleware:
    """Middleware to log request details."""

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request: HttpRequest) -> HttpResponse:
        start_time = time.time()

        response = self.get_response(request)

        duration = time.time() - start_time
        logger.info(
            f"{request.method} {request.path} - {response.status_code} - {duration:.3f}s"
        )

        return response
