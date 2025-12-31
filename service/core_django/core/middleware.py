"""
Custom middleware for the application.
"""
import logging
import time
import threading
import uuid
from django.http import HttpRequest, HttpResponse

logger = logging.getLogger(__name__)

_thread_locals = threading.local()

def get_current_trace_id():
    return getattr(_thread_locals, 'trace_id', None)

class TraceIDMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        trace_id = request.headers.get('X-Trace-ID')
        if not trace_id:
            trace_id = str(uuid.uuid4())
        
        _thread_locals.trace_id = trace_id
        
        # Add to request scope for convenience
        request.trace_id = trace_id
        
        response = self.get_response(request)
        
        # Add to response header
        response['X-Trace-ID'] = trace_id
        
        return response


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
