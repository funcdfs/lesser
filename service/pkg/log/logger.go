// Package log 提供统一的日志封装
// 这是 logger 包的别名，提供更简洁的包名
package log

import (
	"context"
	"log/slog"

	"github.com/funcdfs/lesser/pkg/logger"
)

// Logger 封装 slog.Logger
type Logger = logger.Logger

// Fields 日志字段集合
type Fields = logger.Fields

// New 创建新的 Logger 实例
func New(service string) *Logger {
	return logger.New(service)
}

// ContextWithTraceID 将 trace_id 注入到 context 中
func ContextWithTraceID(ctx context.Context, traceID string) context.Context {
	return logger.ContextWithTraceID(ctx, traceID)
}

// ContextWithUserID 将 user_id 注入到 context 中
func ContextWithUserID(ctx context.Context, userID string) context.Context {
	return logger.ContextWithUserID(ctx, userID)
}

// ContextWithRequestID 将 request_id 注入到 context 中
func ContextWithRequestID(ctx context.Context, requestID string) context.Context {
	return logger.ContextWithRequestID(ctx, requestID)
}

// TraceIDFromContext 从 context 中获取 trace_id
func TraceIDFromContext(ctx context.Context) string {
	return logger.TraceIDFromContext(ctx)
}

// UserIDFromContext 从 context 中获取 user_id
func UserIDFromContext(ctx context.Context) string {
	return logger.UserIDFromContext(ctx)
}

// RequestIDFromContext 从 context 中获取 request_id
func RequestIDFromContext(ctx context.Context) string {
	return logger.RequestIDFromContext(ctx)
}


// Attr 创建日志属性的便捷函数
func String(key, value string) slog.Attr {
	return logger.String(key, value)
}

func Int(key string, value int) slog.Attr {
	return logger.Int(key, value)
}

func Int64(key string, value int64) slog.Attr {
	return logger.Int64(key, value)
}

func Bool(key string, value bool) slog.Attr {
	return logger.Bool(key, value)
}

func Any(key string, value any) slog.Attr {
	return logger.Any(key, value)
}

func Err(err error) slog.Attr {
	return logger.Err(err)
}

func Duration(key string, value any) slog.Attr {
	return logger.Duration(key, value)
}

// SetGlobal 设置全局 Logger
func SetGlobal(l *Logger) {
	logger.SetGlobal(l)
}

// Global 获取全局 Logger
func Global() *Logger {
	return logger.Global()
}

// Info 使用全局 Logger 记录 Info 日志
func Info(msg string, args ...any) {
	logger.Info(msg, args...)
}

// Error 使用全局 Logger 记录 Error 日志
func Error(msg string, args ...any) {
	logger.Error(msg, args...)
}

// Warn 使用全局 Logger 记录 Warn 日志
func Warn(msg string, args ...any) {
	logger.Warn(msg, args...)
}

// Debug 使用全局 Logger 记录 Debug 日志
func Debug(msg string, args ...any) {
	logger.Debug(msg, args...)
}
