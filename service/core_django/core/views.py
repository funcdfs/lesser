"""
Core views including health check.
"""
from django.http import JsonResponse
from django.db import connection


def health_check(request):
    """
    Health check endpoint for container orchestration.
    Returns 200 if the service is healthy.
    """
    health_status = {
        'status': 'healthy',
        'service': 'core_django',
    }
    
    # Check database connection
    try:
        with connection.cursor() as cursor:
            cursor.execute('SELECT 1')
        health_status['database'] = 'connected'
    except Exception as e:
        health_status['database'] = 'disconnected'
        health_status['status'] = 'unhealthy'
        return JsonResponse(health_status, status=503)
    
    return JsonResponse(health_status)


def hello(request):
    """
    Hello endpoint for testing the development setup.
    """
    return JsonResponse({
        'message': 'Hello from Django Core Service! 🎉',
        'service': 'core_django',
        'version': '1.0.0',
        'modules': [
            'users',
            'posts',
            'feeds',
            'search',
            'notifications',
        ],
    })
