package server

import (
	"context"
	"log"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// unaryServerInterceptor returns a unary server interceptor for logging and recovery
func unaryServerInterceptor() grpc.UnaryServerInterceptor {
	return func(
		ctx context.Context,
		req interface{},
		info *grpc.UnaryServerInfo,
		handler grpc.UnaryHandler,
	) (interface{}, error) {
		start := time.Now()

		// Recover from panics
		defer func() {
			if r := recover(); r != nil {
				log.Printf("Panic recovered in gRPC handler: %v", r)
			}
		}()

		// Call the handler
		resp, err := handler(ctx, req)

		// Log the request
		duration := time.Since(start)
		statusCode := codes.OK
		if err != nil {
			statusCode = status.Code(err)
		}

		log.Printf("gRPC %s | %s | %v | %v",
			info.FullMethod,
			statusCode,
			duration,
			err,
		)

		return resp, err
	}
}

// streamServerInterceptor returns a stream server interceptor for logging and recovery
func streamServerInterceptor() grpc.StreamServerInterceptor {
	return func(
		srv interface{},
		ss grpc.ServerStream,
		info *grpc.StreamServerInfo,
		handler grpc.StreamHandler,
	) error {
		start := time.Now()

		// Recover from panics
		defer func() {
			if r := recover(); r != nil {
				log.Printf("Panic recovered in gRPC stream handler: %v", r)
			}
		}()

		// Call the handler
		err := handler(srv, ss)

		// Log the request
		duration := time.Since(start)
		statusCode := codes.OK
		if err != nil {
			statusCode = status.Code(err)
		}

		log.Printf("gRPC Stream %s | %s | %v | %v",
			info.FullMethod,
			statusCode,
			duration,
			err,
		)

		return err
	}
}
