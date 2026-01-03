// Package logger 提供 Chat 服务的日志封装，基于 Go 标准库 slog
package logger

import (
	"context"
	"io"
	"log/slog"
	"os"
)

// 上下文键类型
type ctxKey string

const (
	// TraceIDKey 用于从 context 中获取 trace_id
	TraceIDKey ctxKey = "trace_id"
	// UserIDKey 用于从 context 中获取 user_id
	UserIDKey ctxKey = "user_id"
)

// Log 全局日志实例
var Log *slog.Logger

// Init 初始化日志
func Init() {
	var handler slog.Handler

	if os.Getenv("ENVIRONMENT") == "development" {
		handler = slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{
			Level:     slog.LevelDebug,
			AddSource: true,
		})
	} else {
		handler = slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
			Level:     slog.LevelInfo,
			AddSource: true,
		})
	}

	Log = slog.New(handler).With(slog.String("service", "chat"))
	slog.SetDefault(Log)
}

// Get 获取全局日志实例
func Get() *slog.Logger {
	if Log == nil {
		Init()
	}
	return Log
}

// Logger 封装 slog.Logger，提供带上下文的日志方法
type Logger struct {
	*slog.Logger
	service string
}

// New 创建新的 Logger 实例
func New(service string) *Logger {
	var handler slog.Handler

	if os.Getenv("ENVIRONMENT") == "development" || os.Getenv("ENV") != "production" {
		handler = newDevelopmentHandler(os.Stdout)
	} else {
		handler = newProductionHandler(os.Stdout)
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
