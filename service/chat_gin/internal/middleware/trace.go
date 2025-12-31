package middleware

import (
	"context"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"go.uber.org/zap"
)

const (
	TraceIDHeaderKey = "X-Trace-ID"
	TraceIDKey       = "trace_id"
)

// TraceMiddleware extracts Trace ID from header or generates a new one
func TraceMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		traceID := c.GetHeader(TraceIDHeaderKey)
		if traceID == "" {
			traceID = uuid.New().String()
		}

		// Set to context for use in other middlewares/handlers
		c.Set(TraceIDKey, traceID)
		
		// Also set to standard context so GORM can see it
		ctx := context.WithValue(c.Request.Context(), TraceIDKey, traceID) // "trace_id"
		c.Request = c.Request.WithContext(ctx)

		// Set back to response header for debugging
		c.Header(TraceIDHeaderKey, traceID)

		c.Next()
	}
}

// GetTraceID helper to extract trace ID from gin context
func GetTraceID(c *gin.Context) string {
	if val, exists := c.Get(TraceIDKey); exists {
		if id, ok := val.(string); ok {
			return id
		}
	}
	return ""
}

// GetTraceField returns a zap field for trace_id
func GetTraceField(c *gin.Context) zap.Field {
	return zap.String("trace_id", GetTraceID(c))
}
