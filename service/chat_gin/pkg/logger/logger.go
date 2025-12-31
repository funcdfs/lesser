package logger

import (
	"os"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

var Log *zap.Logger

func Init() {
	encoderConfig := zap.NewProductionEncoderConfig()
	encoderConfig.TimeKey = "timestamp"
	encoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
	encoderConfig.MessageKey = "msg"
	encoderConfig.LevelKey = "level"
	encoderConfig.EncodeLevel = zapcore.CapitalLevelEncoder

	// Custom configurations for other keys to match standard
	encoderConfig.CallerKey = "caller"
	encoderConfig.StacktraceKey = "stacktrace"

	config := zap.Config{
		Level:             zap.NewAtomicLevelAt(zap.InfoLevel),
		Development:       false,
		Sampling:          nil,
		Encoding:          "json",
		EncoderConfig:     encoderConfig,
		OutputPaths:       []string{"stdout"},
		ErrorOutputPaths:  []string{"stderr"},
		DisableStacktrace: false,
	}

	// Check if running in development (optional, but good for debugging locally outside container)
	if os.Getenv("GIN_MODE") == "debug" {
		config.Development = true
	}

	var err error
	Log, err = config.Build(zap.AddCaller())
	if err != nil {
		panic(err)
	}

	// Replace global logger
	zap.ReplaceGlobals(Log)
}

// Get returns the global logger
func Get() *zap.Logger {
	return Log
}
