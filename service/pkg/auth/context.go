package auth

import (
	"context"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

// 上下文键类型
type ctxKey string

const (
	// UserIDKey 用户 ID 上下文键
	UserIDKey ctxKey = "user_id"
	// UsernameKey 用户名上下文键
	UsernameKey ctxKey = "username"
	// EmailKey 邮箱上下文键
	EmailKey ctxKey = "email"
	// RoleKey 角色上下文键
	RoleKey ctxKey = "role"
	// ClaimsKey JWT Claims 上下文键
	ClaimsKey ctxKey = "claims"
)

// ContextWithUserID 将用户 ID 注入到 context
func ContextWithUserID(ctx context.Context, userID string) context.Context {
	return context.WithValue(ctx, UserIDKey, userID)
}

// ContextWithUsername 将用户名注入到 context
func ContextWithUsername(ctx context.Context, username string) context.Context {
	return context.WithValue(ctx, UsernameKey, username)
}

// ContextWithEmail 将邮箱注入到 context
func ContextWithEmail(ctx context.Context, email string) context.Context {
	return context.WithValue(ctx, EmailKey, email)
}

// ContextWithRole 将角色注入到 context
func ContextWithRole(ctx context.Context, role string) context.Context {
	return context.WithValue(ctx, RoleKey, role)
}

// ContextWithClaims 将 Claims 注入到 context
func ContextWithClaims(ctx context.Context, claims *Claims) context.Context {
	ctx = context.WithValue(ctx, ClaimsKey, claims)
	ctx = context.WithValue(ctx, UserIDKey, claims.UserID)
	ctx = context.WithValue(ctx, UsernameKey, claims.Username)
	ctx = context.WithValue(ctx, EmailKey, claims.Email)
	ctx = context.WithValue(ctx, RoleKey, claims.Role)
	return ctx
}

// UserIDFromContext 从 context 获取用户 ID
func UserIDFromContext(ctx context.Context) string {
	if userID, ok := ctx.Value(UserIDKey).(string); ok {
		return userID
	}
	return ""
}

// UsernameFromContext 从 context 获取用户名
func UsernameFromContext(ctx context.Context) string {
	if username, ok := ctx.Value(UsernameKey).(string); ok {
		return username
	}
	return ""
}

// EmailFromContext 从 context 获取邮箱
func EmailFromContext(ctx context.Context) string {
	if email, ok := ctx.Value(EmailKey).(string); ok {
		return email
	}
	return ""
}

// RoleFromContext 从 context 获取角色
func RoleFromContext(ctx context.Context) string {
	if role, ok := ctx.Value(RoleKey).(string); ok {
		return role
	}
	return ""
}

// ClaimsFromContext 从 context 获取 Claims
func ClaimsFromContext(ctx context.Context) *Claims {
	if claims, ok := ctx.Value(ClaimsKey).(*Claims); ok {
		return claims
	}
	return nil
}

// MustUserIDFromContext 从 context 获取用户 ID，不存在则返回错误
func MustUserIDFromContext(ctx context.Context) (string, error) {
	userID := UserIDFromContext(ctx)
	if userID == "" {
		return "", status.Error(codes.Unauthenticated, "未认证")
	}
	return userID, nil
}

// ExtractTokenFromMetadata 从 gRPC metadata 中提取 Token
func ExtractTokenFromMetadata(ctx context.Context) (string, error) {
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return "", status.Error(codes.Unauthenticated, "缺少认证信息")
	}

	// 尝试从 authorization header 获取
	values := md.Get("authorization")
	if len(values) == 0 {
		// 尝试从 token header 获取
		values = md.Get("token")
	}

	if len(values) == 0 {
		return "", status.Error(codes.Unauthenticated, "缺少认证 Token")
	}

	token := values[0]

	// 移除 Bearer 前缀
	if len(token) > 7 && token[:7] == "Bearer " {
		token = token[7:]
	}

	return token, nil
}

// ExtractUserIDFromMetadata 从 gRPC metadata 中提取用户 ID（Gateway 注入）
func ExtractUserIDFromMetadata(ctx context.Context) (string, error) {
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return "", status.Error(codes.Unauthenticated, "缺少认证信息")
	}

	values := md.Get("x-user-id")
	if len(values) == 0 {
		return "", status.Error(codes.Unauthenticated, "缺少用户 ID")
	}

	return values[0], nil
}

// InjectUserIDToMetadata 将用户 ID 注入到 gRPC metadata（用于服务间调用）
func InjectUserIDToMetadata(ctx context.Context, userID string) context.Context {
	md, ok := metadata.FromOutgoingContext(ctx)
	if !ok {
		md = metadata.New(nil)
	}
	md = md.Copy()
	md.Set("x-user-id", userID)
	return metadata.NewOutgoingContext(ctx, md)
}

// InjectTokenToMetadata 将 Token 注入到 gRPC metadata
func InjectTokenToMetadata(ctx context.Context, token string) context.Context {
	md, ok := metadata.FromOutgoingContext(ctx)
	if !ok {
		md = metadata.New(nil)
	}
	md = md.Copy()
	md.Set("authorization", "Bearer "+token)
	return metadata.NewOutgoingContext(ctx, md)
}
