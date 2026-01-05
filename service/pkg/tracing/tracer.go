// Package tracing 提供 OpenTelemetry 分布式追踪封装
// Deprecated: 请使用 github.com/funcdfs/lesser/pkg/trace 包
package tracing

import (
	"context"

	"github.com/funcdfs/lesser/pkg/trace"
	"go.opentelemetry.io/otel/attribute"
	oteltrace "go.opentelemetry.io/otel/trace"
)

// Config 追踪配置
// Deprecated: 请使用 trace.Config
type Config = trace.Config

// ShutdownFunc 关闭函数类型
// Deprecated: 请使用 trace.ShutdownFunc
type ShutdownFunc = trace.ShutdownFunc

// DefaultConfig 返回默认配置
// Deprecated: 请使用 trace.DefaultConfig
func DefaultConfig(serviceName string) Config {
	return trace.DefaultConfig(serviceName)
}

// InitTracer 初始化 OpenTelemetry Tracer
// Deprecated: 请使用 trace.Init
func InitTracer(ctx context.Context, cfg Config) (ShutdownFunc, error) {
	return trace.Init(ctx, cfg)
}

// Tracer 返回指定名称的 Tracer
// Deprecated: 请使用 trace.Tracer
func Tracer(name string) oteltrace.Tracer {
	return trace.Tracer(name)
}

// StartSpan 创建新的 Span
// Deprecated: 请使用 trace.StartSpan
func StartSpan(ctx context.Context, name string, opts ...oteltrace.SpanStartOption) (context.Context, oteltrace.Span) {
	return trace.StartSpan(ctx, name, opts...)
}

// SpanFromContext 从 context 中获取当前 Span
// Deprecated: 请使用 trace.SpanFromContext
func SpanFromContext(ctx context.Context) oteltrace.Span {
	return trace.SpanFromContext(ctx)
}

// SetSpanAttributes 设置 Span 属性
// Deprecated: 请使用 trace.SetSpanAttributes
func SetSpanAttributes(span oteltrace.Span, attrs ...attribute.KeyValue) {
	trace.SetSpanAttributes(span, attrs...)
}

// RecordError 记录错误到 Span
// Deprecated: 请使用 trace.RecordError
func RecordError(span oteltrace.Span, err error) {
	trace.RecordError(span, err)
}

// TraceIDFromContext 从 context 中提取 trace_id
// Deprecated: 请使用 trace.TraceIDFromContext
func TraceIDFromContext(ctx context.Context) string {
	return trace.TraceIDFromContext(ctx)
}

// SpanIDFromContext 从 context 中提取 span_id
// Deprecated: 请使用 trace.SpanIDFromContext
func SpanIDFromContext(ctx context.Context) string {
	return trace.SpanIDFromContext(ctx)
}
