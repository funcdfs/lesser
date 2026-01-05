package interceptor

import (
	"context"
	"time"

	"google.golang.org/grpc"
)

// UnaryServerInterceptor 一元 RPC 拦截器类型
type UnaryServerInterceptor = grpc.UnaryServerInterceptor

// StreamServerInterceptor 流式 RPC 拦截器类型
type StreamServerInterceptor = grpc.StreamServerInterceptor

// TimeoutInterceptor 创建超时拦截器
func TimeoutInterceptor(timeout time.Duration) grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		ctx, cancel := context.WithTimeout(ctx, timeout)
		defer cancel()
		return handler(ctx, req)
	}
}

// ChainUnaryServer 链接多个一元拦截器
// 使用递归方式构建拦截器链，避免闭包变量捕获问题
func ChainUnaryServer(interceptors ...grpc.UnaryServerInterceptor) grpc.UnaryServerInterceptor {
	n := len(interceptors)
	if n == 0 {
		return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
			return handler(ctx, req)
		}
	}
	if n == 1 {
		return interceptors[0]
	}

	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		return interceptors[0](ctx, req, info, buildUnaryChainHandler(interceptors[1:], info, handler))
	}
}

// buildUnaryChainHandler 递归构建一元拦截器链
func buildUnaryChainHandler(interceptors []grpc.UnaryServerInterceptor, info *grpc.UnaryServerInfo, finalHandler grpc.UnaryHandler) grpc.UnaryHandler {
	if len(interceptors) == 0 {
		return finalHandler
	}
	return func(ctx context.Context, req interface{}) (interface{}, error) {
		return interceptors[0](ctx, req, info, buildUnaryChainHandler(interceptors[1:], info, finalHandler))
	}
}

// ChainStreamServer 链接多个流式拦截器
// 使用递归方式构建拦截器链，避免闭包变量捕获问题
func ChainStreamServer(interceptors ...grpc.StreamServerInterceptor) grpc.StreamServerInterceptor {
	n := len(interceptors)
	if n == 0 {
		return func(srv interface{}, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
			return handler(srv, ss)
		}
	}
	if n == 1 {
		return interceptors[0]
	}

	return func(srv interface{}, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
		return interceptors[0](srv, ss, info, buildStreamChainHandler(interceptors[1:], info, handler))
	}
}

// buildStreamChainHandler 递归构建流式拦截器链
func buildStreamChainHandler(interceptors []grpc.StreamServerInterceptor, info *grpc.StreamServerInfo, finalHandler grpc.StreamHandler) grpc.StreamHandler {
	if len(interceptors) == 0 {
		return finalHandler
	}
	return func(srv interface{}, ss grpc.ServerStream) error {
		return interceptors[0](srv, ss, info, buildStreamChainHandler(interceptors[1:], info, finalHandler))
	}
}
