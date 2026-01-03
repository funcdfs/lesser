// Package interceptor 拦截器单元测试
package interceptor

import (
	"context"
	"testing"

	"google.golang.org/grpc/metadata"
)

func TestExtractToken_FromAuthorization(t *testing.T) {
	// 创建带有 authorization header 的 context
	md := metadata.Pairs("authorization", "Bearer test-token-123")
	ctx := metadata.NewIncomingContext(context.Background(), md)

	token, err := extractToken(ctx)
	if err != nil {
		t.Fatalf("提取令牌失败: %v", err)
	}

	if token != "test-token-123" {
		t.Errorf("令牌不匹配: 期望 test-token-123, 实际 %s", token)
	}
}

func TestExtractToken_FromAuthorizationWithoutBearer(t *testing.T) {
	// 创建不带 Bearer 前缀的 authorization header
	md := metadata.Pairs("authorization", "test-token-456")
	ctx := metadata.NewIncomingContext(context.Background(), md)

	token, err := extractToken(ctx)
	if err != nil {
		t.Fatalf("提取令牌失败: %v", err)
	}

	if token != "test-token-456" {
		t.Errorf("令牌不匹配: 期望 test-token-456, 实际 %s", token)
	}
}

func TestExtractToken_FromAccessToken(t *testing.T) {
	// 创建带有 access_token 的 context
	md := metadata.Pairs("access_token", "test-token-789")
	ctx := metadata.NewIncomingContext(context.Background(), md)

	token, err := extractToken(ctx)
	if err != nil {
		t.Fatalf("提取令牌失败: %v", err)
	}

	if token != "test-token-789" {
		t.Errorf("令牌不匹配: 期望 test-token-789, 实际 %s", token)
	}
}

func TestExtractToken_MissingMetadata(t *testing.T) {
	// 创建没有 metadata 的 context
	ctx := context.Background()

	_, err := extractToken(ctx)
	if err == nil {
		t.Error("缺少 metadata 应该返回错误")
	}
}

func TestExtractToken_MissingToken(t *testing.T) {
	// 创建有 metadata 但没有令牌的 context
	md := metadata.Pairs("other-header", "some-value")
	ctx := metadata.NewIncomingContext(context.Background(), md)

	_, err := extractToken(ctx)
	if err == nil {
		t.Error("缺少令牌应该返回错误")
	}
}

func TestUserIDFromContext_WithUserID(t *testing.T) {
	// 创建带有用户 ID 的 context
	ctx := context.WithValue(context.Background(), UserIDKey, "user-123")

	userID := UserIDFromContext(ctx)
	if userID != "user-123" {
		t.Errorf("用户 ID 不匹配: 期望 user-123, 实际 %s", userID)
	}
}

func TestUserIDFromContext_WithoutUserID(t *testing.T) {
	// 创建没有用户 ID 的 context
	ctx := context.Background()

	userID := UserIDFromContext(ctx)
	if userID != "" {
		t.Errorf("没有用户 ID 应该返回空字符串, 实际 %s", userID)
	}
}

func TestUserIDFromContext_WrongType(t *testing.T) {
	// 创建带有错误类型值的 context
	ctx := context.WithValue(context.Background(), UserIDKey, 12345)

	userID := UserIDFromContext(ctx)
	if userID != "" {
		t.Errorf("错误类型应该返回空字符串, 实际 %s", userID)
	}
}

func TestPublicMethods(t *testing.T) {
	// 验证公开方法列表
	expectedPublicMethods := []string{
		"/gateway.GatewayService/Health",
		"/auth.AuthService/Login",
		"/auth.AuthService/Register",
		"/auth.AuthService/GetPublicKey",
		"/auth.AuthService/RefreshToken",
	}

	for _, method := range expectedPublicMethods {
		if !publicMethods[method] {
			t.Errorf("方法 %s 应该是公开的", method)
		}
	}

	// 验证非公开方法
	nonPublicMethods := []string{
		"/user.UserService/GetProfile",
		"/content.ContentService/CreateContent",
		"/auth.AuthService/Logout",
	}

	for _, method := range nonPublicMethods {
		if publicMethods[method] {
			t.Errorf("方法 %s 不应该是公开的", method)
		}
	}
}
