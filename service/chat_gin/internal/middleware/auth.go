package middleware

import (
	"context"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/lesser/chat/internal/service"
)

// AuthMiddleware 使用 gRPC 调用 Django auth 服务验证 JWT token
func AuthMiddleware(authClient *service.AuthClient) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": "需要认证",
			})
			return
		}

		token := strings.TrimPrefix(authHeader, "Bearer ")

		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()

		userID, err := authClient.ValidateToken(ctx, token)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": "token 验证失败",
			})
			return
		}

		c.Set("userID", userID)
		c.Next()
	}
}

// GetUserID retrieves the user ID from the context
func GetUserID(c *gin.Context) (uuid.UUID, bool) {
	userID, exists := c.Get("userID")
	if !exists {
		return uuid.Nil, false
	}
	return userID.(uuid.UUID), true
}

// OptionalAuthMiddleware 可选认证，验证 JWT（如果提供）
func OptionalAuthMiddleware(authClient *service.AuthClient) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader != "" && strings.HasPrefix(authHeader, "Bearer ") {
			token := strings.TrimPrefix(authHeader, "Bearer ")

			ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
			defer cancel()

			if userID, err := authClient.ValidateToken(ctx, token); err == nil {
				c.Set("userID", userID)
			}
		}
		c.Next()
	}
}
