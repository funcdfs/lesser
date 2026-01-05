package interceptor

import (
	"context"

	"github.com/funcdfs/lesser/pkg/log"
	"github.com/google/uuid"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/codes"
	"go.opentelemetry.io/otel/trace"
	"google.golang.org/grpc"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

// TraceInterceptor 创建链路追踪拦截器（增强版）
// 创建 OpenTelemetry Span，设置属性，记录错误
func TraceInterceptor() grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		// 从 metadata 中提取 trace_id
		var traceID string
		if md, ok := metadata.FromIncomingContext(ctx); ok {
			if values := md.Get("trace_id"); len(values) > 0 {
				traceID = values[0]
			}
		}

		// 如果没有 trace_id，生成一个新的
		if traceID == "" {
			traceID = uuid.New().String()
		}

		// 注入 trace_id 到 context（用于日志）
		ctx = log.ContextWithTraceID(ctx, traceID)

		// 创建 OpenTelemetry Span
		tracer := otel.Tracer("grpc-server")
		ctx, span := tracer.Start(ctx, info.FullMethod,
			trace.WithSpanKind(trace.SpanKindServer),
		)
		defer span.End()

		// 设置 Span 属性
		span.SetAttributes(
			attribute.String("trace_id", traceID),
			attribute.String("rpc.system", "grpc"),
			attribute.String("rpc.method", info.FullMethod),
			attribute.String("rpc.service", extractServiceName(info.FullMethod)),
		)

		// 调用处理器
		resp, err := handler(ctx, req)

		// 记录错误到 Span
		if err != nil {
			span.RecordError(err)
			span.SetStatus(codes.Error, err.Error())

			// 设置 gRPC 状态码属性
			if s, ok := status.FromError(err); ok {
				span.SetAttributes(attribute.String("rpc.grpc.status_code", s.Code().String()))
			}
		} else {
			span.SetStatus(codes.Ok, "")
			span.SetAttributes(attribute.String("rpc.grpc.status_code", "OK"))
		}

		return resp, err
	}
}

// extractServiceName 从完整方法名中提取服务名
// 例如：/auth.AuthService/Login -> auth.AuthService
func extractServiceName(fullMethod string) string {
	if len(fullMethod) == 0 {
		return ""
	}
	// 移除开头的 /
	if fullMethod[0] == '/' {
		fullMethod = fullMethod[1:]
	}
	// 找到最后一个 /
	for i := len(fullMethod) - 1; i >= 0; i-- {
		if fullMethod[i] == '/' {
			return fullMethod[:i]
		}
	}
	return fullMethod
}

// StreamTraceInterceptor 创建流式链路追踪拦截器（增强版）
// 创建 OpenTelemetry Span，设置属性，记录错误
func StreamTraceInterceptor() grpc.StreamServerInterceptor {
	return func(srv interface{}, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
		ctx := ss.Context()

		// 从 metadata 中提取 trace_id
		var traceID string
		if md, ok := metadata.FromIncomingContext(ctx); ok {
			if values := md.Get("trace_id"); len(values) > 0 {
				traceID = values[0]
			}
		}

		// 如果没有 trace_id，生成一个新的
		if traceID == "" {
			traceID = uuid.New().String()
		}

		// 注入 trace_id 到 context（用于日志）
		ctx = log.ContextWithTraceID(ctx, traceID)

		// 创建 OpenTelemetry Span
		tracer := otel.Tracer("grpc-server")
		ctx, span := tracer.Start(ctx, info.FullMethod,
			trace.WithSpanKind(trace.SpanKindServer),
		)
		defer span.End()

		// 设置 Span 属性
		span.SetAttributes(
			attribute.String("trace_id", traceID),
			attribute.String("rpc.system", "grpc"),
			attribute.String("rpc.method", info.FullMethod),
			attribute.String("rpc.service", extractServiceName(info.FullMethod)),
			attribute.Bool("rpc.stream", true),
			attribute.Bool("rpc.stream.client", info.IsClientStream),
			attribute.Bool("rpc.stream.server", info.IsServerStream),
		)

		// 包装 ServerStream 以注入 trace_id 和 span context
		wrapped := &wrappedServerStream{
			ServerStream: ss,
			ctx:          ctx,
		}

		// 调用处理器
		err := handler(srv, wrapped)

		// 记录错误到 Span
		if err != nil {
			span.RecordError(err)
			span.SetStatus(codes.Error, err.Error())

			// 设置 gRPC 状态码属性
			if s, ok := status.FromError(err); ok {
				span.SetAttributes(attribute.String("rpc.grpc.status_code", s.Code().String()))
			}
		} else {
			span.SetStatus(codes.Ok, "")
			span.SetAttributes(attribute.String("rpc.grpc.status_code", "OK"))
		}

		return err
	}
}

// wrappedServerStream 包装 ServerStream 以支持自定义 context
type wrappedServerStream struct {
	grpc.ServerStream
	ctx context.Context
}

func (w *wrappedServerStream) Context() context.Context {
	return w.ctx
}
