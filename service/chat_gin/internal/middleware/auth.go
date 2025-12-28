package middleware

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// AuthMiddleware validates the user authentication
func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Get user ID from header
		// In production, this would validate a JWT token
		userIDStr := c.GetHeader("X-User-ID")
		if userIDStr == "" {
			// Also check Authorization header for Bearer token
			authHeader := c.GetHeader("Authorization")
			if authHeader == "" {
				c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
					"error": "authentication required",
				})
				return
			}

			// In production, validate the JWT token here
			// For now, we'll just continue without a user ID
			c.Next()
			return
		}

		// Validate user ID format
		userID, err := uuid.Parse(userIDStr)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{
				"error": "invalid user ID format",
			})
			return
		}

		// Store user ID in context
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

// OptionalAuthMiddleware allows requests without authentication
func OptionalAuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		userIDStr := c.GetHeader("X-User-ID")
		if userIDStr != "" {
			if userID, err := uuid.Parse(userIDStr); err == nil {
				c.Set("userID", userID)
			}
		}
		c.Next()
	}
}
