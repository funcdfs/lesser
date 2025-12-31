package middleware

import (
	"time"

	"github.com/gin-gonic/gin"
	"github.com/lesser/chat/pkg/logger"
	"go.uber.org/zap"
)

// ZapLogger is a replacement for gin.Logger using Zap
func ZapLogger() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		path := c.Request.URL.Path
		query := c.Request.URL.RawQuery

		c.Next()

		end := time.Now()
		latency := end.Sub(start)
		
		traceID := GetTraceID(c)

		if len(c.Errors) > 0 {
			for _, e := range c.Errors.Errors() {
				logger.Log.Error(e,
					zap.String("trace_id", traceID),
					zap.String("service", "go-chat-service"),
				)
			}
		} else {
			fields := []zap.Field{
				zap.String("service", "go-chat-service"),
				zap.String("trace_id", traceID),
				zap.Int("status_code", c.Writer.Status()),
				zap.String("http_method", c.Request.Method),
				zap.String("http_path", path),
				zap.String("query", query),
				zap.String("client_ip", c.ClientIP()),
				zap.Float64("latency_ms", float64(latency.Nanoseconds())/1e6),
				zap.String("user_agent", c.Request.UserAgent()),
			}
			
			// Extract User ID if available
			if userID, exists := GetUserID(c); exists {
				fields = append(fields, zap.String("user_id", userID.String()))
			}

			logger.Log.Info("http_request", fields...)
		}
	}
}
