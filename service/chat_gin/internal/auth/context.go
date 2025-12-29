package auth

import (
	"context"

	"github.com/google/uuid"
)

// 定义 context key 类型，避免冲突
type contextKey string

const (
	// UserIDKey 用于在 context 中存储用户 ID
	UserIDKey contextKey = "userID"
)

// GetUserIDFromContext 从 context 中获取用户 ID
func GetUserIDFromContext(ctx context.Context) (uuid.UUID, bool) {
	userID, ok := ctx.Value(UserIDKey).(uuid.UUID)
	return userID, ok
}

// SetUserIDInContext 将用户 ID 存入 context
func SetUserIDInContext(ctx context.Context, userID uuid.UUID) context.Context {
	return context.WithValue(ctx, UserIDKey, userID)
}
