// Package trace 提供 OpenTelemetry 分布式追踪封装
// 支持 OTLP gRPC Exporter，将追踪数据发送到 Jaeger
package trace

import (
	"context"
	"fmt"
	"os"
	"time"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.26.0"
	oteltrace "go.opentelemetry.io/otel/trace"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

// Config 追踪配置
type Config struct {
	// ServiceName 服务名称
	ServiceName string
	// ServiceVersion 服务版本（可选）
	ServiceVersion string
	// Environment 环境（dev/staging/production）
	Environment string
	// Endpoint OTLP gRPC 端点（默认从 OTEL_EXPORTER_OTLP_ENDPOINT 读取）
	Endpoint string
	// Insecure 是否使用不安全连接（默认 true）
	Insecure bool
	// SampleRate 采样率（0.0-1.0，默认 1.0 全采样）
	SampleRate float64
}

// DefaultConfig 返回默认配置
func DefaultConfig(serviceName string) Config {
	endpoint := os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT")
	if endpoint == "" {
		endpoint = "jaeger:4317"
	}

	env := os.Getenv("ENV")
	if env == "" {
		env = "development"
	}

	return Config{
		ServiceName: serviceName,
		Environment: env,
		Endpoint:    endpoint,
		Insecure:    true,
		SampleRate:  1.0,
	}
}

// ShutdownFunc 关闭函数类型
type ShutdownFunc func(context.Context) error

// Init 初始化 OpenTelemetry Tracer
// 返回 shutdown 函数用于优雅关闭
func Init(ctx context.Context, cfg Config) (ShutdownFunc, error) {
	// 验证配置
	if cfg.ServiceName == "" {
		return nil, fmt.Errorf("服务名称不能为空")
	}

	// 创建 OTLP gRPC Exporter
	opts := []otlptracegrpc.Option{
		otlptracegrpc.WithEndpoint(cfg.Endpoint),
	}

	if cfg.Insecure {
		opts = append(opts, otlptracegrpc.WithInsecure())
		opts = append(opts, otlptracegrpc.WithDialOption(grpc.WithTransportCredentials(insecure.NewCredentials())))
	}

	exporter, err := otlptracegrpc.New(ctx, opts...)
	if err != nil {
		return nil, fmt.Errorf("创建 OTLP exporter 失败: %w", err)
	}

	// 创建 Resource
	res, err := resource.Merge(
		resource.Default(),
		resource.NewWithAttributes(
			semconv.SchemaURL,
			semconv.ServiceName(cfg.ServiceName),
			semconv.ServiceVersion(cfg.ServiceVersion),
			semconv.DeploymentEnvironment(cfg.Environment),
		),
	)
	if err != nil {
		return nil, fmt.Errorf("创建 resource 失败: %w", err)
	}

	// 配置采样器
	var sampler sdktrace.Sampler
	if cfg.SampleRate >= 1.0 {
		sampler = sdktrace.AlwaysSample()
	} else if cfg.SampleRate <= 0 {
		sampler = sdktrace.NeverSample()
	} else {
		sampler = sdktrace.TraceIDRatioBased(cfg.SampleRate)
	}

	// 创建 TracerProvider
	tp := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(exporter),
		sdktrace.WithResource(res),
		sdktrace.WithSampler(sampler),
	)

	// 设置全局 TracerProvider
	otel.SetTracerProvider(tp)

	// 设置全局 Propagator（支持 W3C Trace Context 和 Baggage）
	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(
		propagation.TraceContext{},
		propagation.Baggage{},
	))

	// 返回 shutdown 函数
	return func(ctx context.Context) error {
		// 设置关闭超时
		shutdownCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
		defer cancel()
		return tp.Shutdown(shutdownCtx)
	}, nil
}

// Tracer 返回指定名称的 Tracer
func Tracer(name string) oteltrace.Tracer {
	return otel.Tracer(name)
}

// StartSpan 创建新的 Span
func StartSpan(ctx context.Context, name string, opts ...oteltrace.SpanStartOption) (context.Context, oteltrace.Span) {
	return otel.Tracer("").Start(ctx, name, opts...)
}

// SpanFromContext 从 context 中获取当前 Span
func SpanFromContext(ctx context.Context) oteltrace.Span {
	return oteltrace.SpanFromContext(ctx)
}

// SetSpanAttributes 设置 Span 属性
func SetSpanAttributes(span oteltrace.Span, attrs ...attribute.KeyValue) {
	span.SetAttributes(attrs...)
}

// RecordError 记录错误到 Span
func RecordError(span oteltrace.Span, err error) {
	if err != nil {
		span.RecordError(err)
	}
}

// TraceIDFromContext 从 context 中提取 trace_id
// 如果没有活跃的 Span，返回空字符串
func TraceIDFromContext(ctx context.Context) string {
	span := oteltrace.SpanFromContext(ctx)
	if span == nil {
		return ""
	}
	sc := span.SpanContext()
	if !sc.IsValid() {
		return ""
	}
	return sc.TraceID().String()
}

// SpanIDFromContext 从 context 中提取 span_id
func SpanIDFromContext(ctx context.Context) string {
	span := oteltrace.SpanFromContext(ctx)
	if span == nil {
		return ""
	}
	sc := span.SpanContext()
	if !sc.IsValid() {
		return ""
	}
	return sc.SpanID().String()
}
