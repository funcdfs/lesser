"""
gRPC server configuration and startup.
"""
import logging
import os
import sys
from concurrent import futures

import django
import grpc

# Setup Django before importing models
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.dev')
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
django.setup()

from django.conf import settings

from .interceptors import LoggingInterceptor, AuthInterceptor

logger = logging.getLogger(__name__)


def create_server(port: int = None, max_workers: int = 50) -> grpc.Server:
    """Create and configure gRPC server."""
    if port is None:
        port = getattr(settings, 'GRPC_PORT', 50051)

    # Create server with interceptors
    interceptors = [
        LoggingInterceptor(),
        AuthInterceptor(),
    ]

    # Server options for better performance and stability
    options = [
        ('grpc.max_send_message_length', 4 * 1024 * 1024),  # 4MB
        ('grpc.max_receive_message_length', 4 * 1024 * 1024),  # 4MB
        ('grpc.keepalive_time_ms', 30000),  # 30 seconds
        ('grpc.keepalive_timeout_ms', 10000),  # 10 seconds
        ('grpc.keepalive_permit_without_calls', True),
        ('grpc.http2.max_pings_without_data', 0),
        ('grpc.http2.min_time_between_pings_ms', 10000),
        ('grpc.http2.min_ping_interval_without_data_ms', 30000),
        ('grpc.max_concurrent_streams', 100),
    ]

    server = grpc.server(
        futures.ThreadPoolExecutor(max_workers=max_workers),
        interceptors=interceptors,
        options=options,
    )

    # Register services
    try:
        from generated.protos.auth import auth_pb2_grpc
        from apps.users.grpc_services import get_auth_servicer
        auth_pb2_grpc.add_AuthServiceServicer_to_server(get_auth_servicer(), server)
        logger.info('AuthService registered')
    except ImportError as e:
        logger.warning(f'Failed to register AuthService: {e}')
        logger.warning('Run scripts/proto/generate.sh to generate proto code')

    # Register health service
    try:
        from grpc_health.v1 import health_pb2_grpc
        from grpc_health.v1.health import HealthServicer
        health_servicer = HealthServicer()
        health_pb2_grpc.add_HealthServicer_to_server(health_servicer, server)
        logger.info('HealthService registered')
    except ImportError:
        logger.warning('grpc-health-checking not installed, skipping health service')

    # Add insecure port for development
    server.add_insecure_port(f'[::]:{port}')

    return server


def serve(port: int = None):
    """Start the gRPC server."""
    if port is None:
        port = getattr(settings, 'GRPC_PORT', 50051)

    server = create_server(port)
    server.start()

    logger.info(f'gRPC server started on port {port}')
    print(f'gRPC server started on port {port}')

    try:
        server.wait_for_termination()
    except KeyboardInterrupt:
        logger.info('gRPC server shutting down...')
        server.stop(grace=5)


if __name__ == '__main__':
    serve()
