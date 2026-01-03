// Package database 提供 GORM 的 slog 日志适配器
package database

import (
	"context"
	"errors"
	"log/slog"
	"time"

	"gorm.io/gorm"
	gormlogger "gorm.io/gorm/logger"
)

// SlogGormLogger 基于 slog 的 GORM 日志适配器
type SlogGormLogger struct {
	Logger                    *slog.Logger
	LogLevel                  gormlogger.LogLevel
	SlowThreshold             time.Duration
	IgnoreRecordNotFoundError bool
}

// NewSlogGormLogger 创建 slog GORM 日志适配器
func NewSlogGormLogger(logger *slog.Logger) *SlogGormLogger {
	return &SlogGormLogger{
		Logger:                    logger,
		LogLevel:                  gormlogger.Warn,
		SlowThreshold:             time.Second,
		IgnoreRecordNotFoundError: true,
	}
}

// LogMode 设置日志级别
func (l *SlogGormLogger) LogMode(level gormlogger.LogLevel) gormlogger.Interface {
	newLogger := *l
	newLogger.LogLevel = level
	return &newLogger
}

// Info 记录 Info 级别日志
func (l *SlogGormLogger) Info(ctx context.Context, msg string, data ...interface{}) {
	if l.LogLevel >= gormlogger.Info {
		l.Logger.InfoContext(ctx, msg, slog.Any("data", data))
	}
}

// Warn 记录 Warn 级别日志
func (l *SlogGormLogger) Warn(ctx context.Context, msg string, data ...interface{}) {
	if l.LogLevel >= gormlogger.Warn {
		l.Logger.WarnContext(ctx, msg, slog.Any("data", data))
	}
}

// Error 记录 Error 级别日志
func (l *SlogGormLogger) Error(ctx context.Context, msg string, data ...interface{}) {
	if l.LogLevel >= gormlogger.Error {
		l.Logger.ErrorContext(ctx, msg, slog.Any("data", data))
	}
}

// Trace 记录 SQL 查询日志
func (l *SlogGormLogger) Trace(ctx context.Context, begin time.Time, fc func() (sql string, rowsAffected int64), err error) {
	if l.LogLevel <= gormlogger.Silent {
		return
	}

	elapsed := time.Since(begin)
	sql, rows := fc()

	attrs := []slog.Attr{
		slog.String("service", "chat"),
		slog.String("db_instance", "postgres"),
		slog.Float64("latency_ms", float64(elapsed.Nanoseconds())/1e6),
		slog.Int64("rows_affected", rows),
		slog.String("sql", sql),
	}

	// 从 context 提取 trace_id
	if traceID, ok := ctx.Value("trace_id").(string); ok {
		attrs = append(attrs, slog.String("trace_id", traceID))
	}

	switch {
	case err != nil && l.LogLevel >= gormlogger.Error && (!errors.Is(err, gorm.ErrRecordNotFound) || !l.IgnoreRecordNotFoundError):
		attrs = append(attrs, slog.Any("error", err))
		l.Logger.LogAttrs(ctx, slog.LevelError, "db_query_error", attrs...)
	case elapsed > l.SlowThreshold && l.SlowThreshold != 0 && l.LogLevel >= gormlogger.Warn:
		l.Logger.LogAttrs(ctx, slog.LevelWarn, "db_slow_query", attrs...)
	case l.LogLevel >= gormlogger.Info:
		l.Logger.LogAttrs(ctx, slog.LevelInfo, "db_query", attrs...)
	}
}
