// Package log 提供统一的日志封装，基于 Go 标准库 slog
// 支持生产环境（JSON）和开发环境（Text）的日志格式
// 自动注入 trace_id 到日志上下文中
package log

import (
	"context"
	"io"
	"log/slog"
	"os"
	"runtime"
	"time"
)

// 上下文键类型
type ctxKey string

const (
	// TraceIDKey 用于从 context 中获取 trace_id
	TraceIDKey ctxKey = "trace_id"
	// UserIDKey 用于从 context 中获取 user_id
	UserIDKey ctxKey = "user_id"
	// RequestIDKey 用于从 context 中获取 request_id
	RequestIDKey ctxKey = "request_id"
)

// Logger 封装 slog.Logger，提供带上下文的日志方法
type Logger struct {
	*slog.Logger
	service string
}

// New 创建新的 Logger 实例
// service: 服务名称，会自动注入到每条日志中
func New(service string) *Logger {
	var handler slog.Handler

	// 根据环境选择配置
	if os.Getenv("ENV") == "production" || os.Getenv("GIN_MODE") == "release" {
		handler = newProductionHandler(os.Stdout)
	} else {
		handler = newDevelopmentHandler(os.Stdout)
	}

	logger := slog.New(handler).With(slog.String("service", service))

	return &Logger{
		Logger:  logger,
		service: service,
	}
}

// newProductionHandler 生产环境处理器（JSON 格式）
func newProductionHandler(w io.Writer) slog.Handler {
	return slog.NewJSONHandler(w, &slog.HandlerOptions{
		Level:     slog.LevelInfo,
		AddSource: true,
	})
}

// newDevelopmentHandler 开发环境处理器（Text 格式）
func newDevelopmentHandler(w io.Writer) slog.Handler {
	return slog.NewTextHandler(w, &slog.HandlerOptions{
		Level:     slog.LevelDebug,
		AddSource: true,
	})
}

// WithContext 从 context 中提取 trace_id 和 user_id，返回带字段的 Logger
func (l *Logger) WithContext(ctx context.Context) *slog.Logger {
	logger := l.Logger

	if traceID, ok := ctx.Value(TraceIDKey).(string); ok && traceID != "" {
		logger = logger.With(slog.String("trace_id", traceID))
	}

	if userID, ok := ctx.Value(UserIDKey).(string); ok && userID != "" {
		logger = logger.With(slog.String("user_id", userID))
	}

	return logger
}

// With 返回带有额外属性的新 Logger
func (l *Logger) With(args ...any) *Logger {
	return &Logger{
		Logger:  l.Logger.With(args...),
		service: l.service,
	}
}

// Info 记录 Info 级别日志
func (l *Logger) Info(msg string, args ...any) {
	l.Logger.Info(msg, args...)
}

// Error 记录 Error 级别日志
func (l *Logger) Error(msg string, args ...any) {
	l.Logger.Error(msg, args...)
}

// Warn 记录 Warn 级别日志
func (l *Logger) Warn(msg string, args ...any) {
	l.Logger.Warn(msg, args...)
}

// Debug 记录 Debug 级别日志
func (l *Logger) Debug(msg string, args ...any) {
	l.Logger.Debug(msg, args...)
}

// Fatal 记录 Error 级别日志并退出程序
func (l *Logger) Fatal(msg string, args ...any) {
	l.Logger.Error(msg, args...)
	os.Exit(1)
}

// Sync 刷新日志缓冲区（slog 不需要，保留接口兼容）
func (l *Logger) Sync() error {
	return nil
}

// ContextWithTraceID 将 trace_id 注入到 context 中
func ContextWithTraceID(ctx context.Context, traceID string) context.Context {
	return context.WithValue(ctx, TraceIDKey, traceID)
}

// ContextWithUserID 将 user_id 注入到 context 中
func ContextWithUserID(ctx context.Context, userID string) context.Context {
	return context.WithValue(ctx, UserIDKey, userID)
}

// ContextWithRequestID 将 request_id 注入到 context 中
func ContextWithRequestID(ctx context.Context, requestID string) context.Context {
	return context.WithValue(ctx, RequestIDKey, requestID)
}

// TraceIDFromContext 从 context 中获取 trace_id
func TraceIDFromContext(ctx context.Context) string {
	if traceID, ok := ctx.Value(TraceIDKey).(string); ok {
		return traceID
	}
	return ""
}

// UserIDFromContext 从 context 中获取 user_id
func UserIDFromContext(ctx context.Context) string {
	if userID, ok := ctx.Value(UserIDKey).(string); ok {
		return userID
	}
	return ""
}

// RequestIDFromContext 从 context 中获取 request_id
func RequestIDFromContext(ctx context.Context) string {
	if requestID, ok := ctx.Value(RequestIDKey).(string); ok {
		return requestID
	}
	return ""
}

// Attr 创建日志属性的便捷函数
func String(key, value string) slog.Attr {
	return slog.String(key, value)
}

func Int(key string, value int) slog.Attr {
	return slog.Int(key, value)
}

func Int64(key string, value int64) slog.Attr {
	return slog.Int64(key, value)
}

func Bool(key string, value bool) slog.Attr {
	return slog.Bool(key, value)
}

func Any(key string, value any) slog.Attr {
	return slog.Any(key, value)
}

func Err(err error) slog.Attr {
	return slog.Any("error", err)
}

func Duration(key string, value any) slog.Attr {
	return slog.Any(key, value)
}

// ---- 结构化日志辅助 ----

// Fields 日志字段集合
type Fields map[string]any

// ToAttrs 转换为 slog.Attr 切片
func (f Fields) ToAttrs() []any {
	attrs := make([]any, 0, len(f)*2)
	for k, v := range f {
		attrs = append(attrs, k, v)
	}
	return attrs
}

// LogOperation 记录操作日志
func (l *Logger) LogOperation(ctx context.Context, operation string, fields Fields) {
	attrs := []any{slog.String("operation", operation)}
	attrs = append(attrs, fields.ToAttrs()...)
	l.WithContext(ctx).Info("operation", attrs...)
}

// LogError 记录错误日志
func (l *Logger) LogError(ctx context.Context, operation string, err error, fields Fields) {
	attrs := []any{
		slog.String("operation", operation),
		slog.Any("error", err),
	}
	attrs = append(attrs, fields.ToAttrs()...)
	l.WithContext(ctx).Error("operation failed", attrs...)
}

// LogDuration 记录耗时日志
func (l *Logger) LogDuration(ctx context.Context, operation string, start time.Time, fields Fields) {
	duration := time.Since(start)
	attrs := []any{
		slog.String("operation", operation),
		slog.Duration("duration", duration),
	}
	attrs = append(attrs, fields.ToAttrs()...)
	l.WithContext(ctx).Info("operation completed", attrs...)
}

// LogPanic 记录 panic 日志
func (l *Logger) LogPanic(ctx context.Context, recovered any) {
	buf := make([]byte, 4096)
	n := runtime.Stack(buf, false)
	l.WithContext(ctx).Error("panic recovered",
		slog.Any("panic", recovered),
		slog.String("stack", string(buf[:n])))
}

// ---- 全局 Logger ----

var globalLogger *Logger

// SetGlobal 设置全局 Logger
func SetGlobal(l *Logger) {
	globalLogger = l
}

// Global 获取全局 Logger
func Global() *Logger {
	if globalLogger == nil {
		globalLogger = New("app")
	}
	return globalLogger
}

// Default 获取全局 Logger（Global 的别名，保持兼容性）
func Default() *Logger {
	return Global()
}

// Info 使用全局 Logger 记录 Info 日志
func Info(msg string, args ...any) {
	Global().Info(msg, args...)
}

// Error 使用全局 Logger 记录 Error 日志
func Error(msg string, args ...any) {
	Global().Error(msg, args...)
}

// Warn 使用全局 Logger 记录 Warn 日志
func Warn(msg string, args ...any) {
	Global().Warn(msg, args...)
}

// Debug 使用全局 Logger 记录 Debug 日志
func Debug(msg string, args ...any) {
	Global().Debug(msg, args...)
}
