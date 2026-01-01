// Package logger 提供统一的日志封装，基于 Zap
// 支持生产环境（JSON）和开发环境（Console）的日志格式
// 自动注入 trace_id 到日志上下文中
package logger

import (
	"context"
	"os"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

// 上下文键类型
type ctxKey string

const (
	// TraceIDKey 用于从 context 中获取 trace_id
	TraceIDKey ctxKey = "trace_id"
	// UserIDKey 用于从 context 中获取 user_id
	UserIDKey ctxKey = "user_id"
)

// Logger 封装 zap.Logger，提供带上下文的日志方法
type Logger struct {
	*zap.Logger
	service string
}

// New 创建新的 Logger 实例
// service: 服务名称，会自动注入到每条日志中
func New(service string) *Logger {
	var config zap.Config

	// 根据环境选择配置
	if os.Getenv("ENV") == "production" || os.Getenv("GIN_MODE") == "release" {
		config = newProductionConfig()
	} else {
		config = newDevelopmentConfig()
	}

	logger, err := config.Build(zap.AddCaller(), zap.AddCallerSkip(1))
	if err != nil {
		panic(err)
	}

	return &Logger{
		Logger:  logger,
		service: service,
	}
}

// newProductionConfig 生产环境配置（JSON 格式）
func newProductionConfig() zap.Config {
	encoderConfig := zap.NewProductionEncoderConfig()
	encoderConfig.TimeKey = "timestamp"
	encoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
	encoderConfig.MessageKey = "msg"
	encoderConfig.LevelKey = "level"
	encoderConfig.EncodeLevel = zapcore.CapitalLevelEncoder
	encoderConfig.CallerKey = "caller"
	encoderConfig.StacktraceKey = "stacktrace"

	return zap.Config{
		Level:             zap.NewAtomicLevelAt(zap.InfoLevel),
		Development:       false,
		Encoding:          "json",
		EncoderConfig:     encoderConfig,
		OutputPaths:       []string{"stdout"},
		ErrorOutputPaths:  []string{"stderr"},
		DisableStacktrace: false,
	}
}

// newDevelopmentConfig 开发环境配置（Console 格式，带颜色）
func newDevelopmentConfig() zap.Config {
	encoderConfig := zap.NewDevelopmentEncoderConfig()
	encoderConfig.EncodeLevel = zapcore.CapitalColorLevelEncoder
	encoderConfig.EncodeTime = zapcore.TimeEncoderOfLayout("15:04:05.000")

	return zap.Config{
		Level:            zap.NewAtomicLevelAt(zap.DebugLevel),
		Development:      true,
		Encoding:         "console",
		EncoderConfig:    encoderConfig,
		OutputPaths:      []string{"stdout"},
		ErrorOutputPaths: []string{"stderr"},
	}
}

// WithContext 从 context 中提取 trace_id 和 user_id，返回带字段的 Logger
func (l *Logger) WithContext(ctx context.Context) *zap.Logger {
	fields := []zap.Field{
		zap.String("service", l.service),
	}

	if traceID, ok := ctx.Value(TraceIDKey).(string); ok && traceID != "" {
		fields = append(fields, zap.String("trace_id", traceID))
	}

	if userID, ok := ctx.Value(UserIDKey).(string); ok && userID != "" {
		fields = append(fields, zap.String("user_id", userID))
	}

	return l.Logger.With(fields...)
}

// Info 记录 Info 级别日志（带 service 字段）
func (l *Logger) Info(msg string, fields ...zap.Field) {
	l.Logger.Info(msg, append(fields, zap.String("service", l.service))...)
}

// Error 记录 Error 级别日志（带 service 字段）
func (l *Logger) Error(msg string, fields ...zap.Field) {
	l.Logger.Error(msg, append(fields, zap.String("service", l.service))...)
}

// Warn 记录 Warn 级别日志（带 service 字段）
func (l *Logger) Warn(msg string, fields ...zap.Field) {
	l.Logger.Warn(msg, append(fields, zap.String("service", l.service))...)
}

// Debug 记录 Debug 级别日志（带 service 字段）
func (l *Logger) Debug(msg string, fields ...zap.Field) {
	l.Logger.Debug(msg, append(fields, zap.String("service", l.service))...)
}

// Fatal 记录 Fatal 级别日志并退出程序
func (l *Logger) Fatal(msg string, fields ...zap.Field) {
	l.Logger.Fatal(msg, append(fields, zap.String("service", l.service))...)
}

// Sync 刷新日志缓冲区
func (l *Logger) Sync() error {
	return l.Logger.Sync()
}

// ContextWithTraceID 将 trace_id 注入到 context 中
func ContextWithTraceID(ctx context.Context, traceID string) context.Context {
	return context.WithValue(ctx, TraceIDKey, traceID)
}

// ContextWithUserID 将 user_id 注入到 context 中
func ContextWithUserID(ctx context.Context, userID string) context.Context {
	return context.WithValue(ctx, UserIDKey, userID)
}

// TraceIDFromContext 从 context 中获取 trace_id
func TraceIDFromContext(ctx context.Context) string {
	if traceID, ok := ctx.Value(TraceIDKey).(string); ok {
		return traceID
	}
	return ""
}
