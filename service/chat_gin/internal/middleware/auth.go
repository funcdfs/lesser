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
		// 优先从 Authorization header 获取 Bearer token
		authHeader := c.GetHeader("Authorization")
		if authHeader != "" && strings.HasPrefix(authHeader, "Bearer ") {
			token := strings.TrimPrefix(authHeader, "Bearer ")

			// 通过 gRPC 调用 Django 验证 token
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
			return
		}

		// 兼容旧的 X-User-ID header（仅用于开发/测试）
		userIDStr := c.GetHeader("X-User-ID")
		if userIDStr != "" {
			userID, err := uuid.Parse(userIDStr)
			if err != nil {
				c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{
					"error": "用户 ID 格式无效",
				})
				return
			}
			c.Set("userID", userID)
			c.Next()
			return
		}

		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
			"error": "需要认证",
		})
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

// OptionalAuthMiddleware 可选认证，支持 JWT 和 X-User-ID
func OptionalAuthMiddleware(authClient *service.AuthClient) gin.HandlerFunc {
	return func(c *gin.Context) {
		// 优先从 Authorization header 获取 Bearer token
		authHeader := c.GetHeader("Authorization")
		if authHeader != "" && strings.HasPrefix(authHeader, "Bearer ") {
			token := strings.TrimPrefix(authHeader, "Bearer ")

			ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
			defer cancel()

			if userID, err := authClient.ValidateToken(ctx, token); err == nil {
				c.Set("userID", userID)
			}
		} else {
			// 兼容旧的 X-User-ID header
			userIDStr := c.GetHeader("X-User-ID")
			if userIDStr != "" {
				if userID, err := uuid.Parse(userIDStr); err == nil {
					c.Set("userID", userID)
				}
			}
		}
		c.Next()
	}
}
