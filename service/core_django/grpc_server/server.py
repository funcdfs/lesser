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


def create_server(port: int = None, max_workers: int = 10) -> grpc.Server:
    """Create and configure gRPC server."""
    if port is None:
        port = getattr(settings, 'GRPC_PORT', 50051)

    # Create server with interceptors
    interceptors = [
        LoggingInterceptor(),
        AuthInterceptor(),
    ]

    server = grpc.server(
        futures.ThreadPoolExecutor(max_workers=max_workers),
        interceptors=interceptors,
    )

    # Register services
    # Note: These will be uncommented after proto code generation
    # from generated.protos.auth import auth_pb2_grpc
    # from apps.users.grpc_services import get_auth_servicer
    # auth_pb2_grpc.add_AuthServiceServicer_to_server(get_auth_servicer(), server)

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
