// Package crypto 提供 JWT 管理器单元测试
package crypto

import (
	"testing"
	"time"
)

// ==================== JWT 管理器测试 ====================

func createTestJWTManager(t *testing.T) *JWTManager {
	t.Helper()

	manager, err := NewJWTManager(JWTManagerConfig{
		HMACSecret:           "test-secret-key-for-unit-tests",
		KeySize:              2048,
		AccessTokenDuration:  15 * time.Minute,
		RefreshTokenDuration: 7 * 24 * time.Hour,
		KeyRotationInterval:  30 * 24 * time.Hour,
	})
	if err != nil {
		t.Fatalf("创建 JWT 管理器失败: %v", err)
	}
	return manager
}

func TestGenerateAccessToken_Success(t *testing.T) {
	manager := createTestJWTManager(t)

	token, err := manager.GenerateAccessToken("user-123")
	if err != nil {
		t.Fatalf("生成 Access Token 失败: %v", err)
	}
	if token == "" {
		t.Error("生成的 Token 为空")
	}
}

func TestGenerateRefreshToken_Success(t *testing.T) {
	manager := createTestJWTManager(t)

	token, err := manager.GenerateRefreshToken("user-123")
	if err != nil {
		t.Fatalf("生成 Refresh Token 失败: %v", err)
	}
	if token == "" {
		t.Error("生成的 Token 为空")
	}
}

func TestValidateRefreshToken_Success(t *testing.T) {
	manager := createTestJWTManager(t)

	// 生成 Token
	token, err := manager.GenerateRefreshToken("user-123")
	if err != nil {
		t.Fatalf("生成 Refresh Token 失败: %v", err)
	}

	// 验证 Token
	claims, err := manager.ValidateRefreshToken(token)
	if err != nil {
		t.Fatalf("验证 Refresh Token 失败: %v", err)
	}
	if claims.UserID != "user-123" {
		t.Errorf("用户 ID 不匹配: got %s, want user-123", claims.UserID)
	}
	if claims.Type != TokenTypeRefresh {
		t.Errorf("Token 类型不匹配: got %s, want refresh", claims.Type)
	}
}

func TestValidateRefreshToken_InvalidToken(t *testing.T) {
	manager := createTestJWTManager(t)

	// 验证无效 Token
	_, err := manager.ValidateRefreshToken("invalid-token")
	if err == nil {
		t.Fatal("验证无效 Token 应该失败")
	}
}

func TestValidateRefreshToken_WrongTokenType(t *testing.T) {
	manager := createTestJWTManager(t)

	// 生成 Access Token
	accessToken, err := manager.GenerateAccessToken("user-123")
	if err != nil {
		t.Fatalf("生成 Access Token 失败: %v", err)
	}

	// 尝试用 Access Token 作为 Refresh Token 验证（应该失败，因为签名算法不同）
	_, err = manager.ValidateRefreshToken(accessToken)
	if err == nil {
		t.Fatal("使用 Access Token 作为 Refresh Token 验证应该失败")
	}
}

func TestGetPublicKeyInfo_Success(t *testing.T) {
	manager := createTestJWTManager(t)

	info := manager.GetPublicKeyInfo()
	if info == nil {
		t.Fatal("公钥信息为空")
	}
	if info.PublicKey == "" {
		t.Error("公钥为空")
	}
	if info.KeyID == "" {
		t.Error("KeyID 为空")
	}
	if info.Algorithm != "RS256" {
		t.Errorf("算法不匹配: got %s, want RS256", info.Algorithm)
	}
	if info.ExpiresAt == 0 {
		t.Error("过期时间为 0")
	}
}

func TestGetTokenID_Success(t *testing.T) {
	manager := createTestJWTManager(t)

	// 生成 Token
	token, err := manager.GenerateAccessToken("user-123")
	if err != nil {
		t.Fatalf("生成 Access Token 失败: %v", err)
	}

	// 获取 Token ID
	tokenID, err := manager.GetTokenID(token)
	if err != nil {
		t.Fatalf("获取 Token ID 失败: %v", err)
	}
	if tokenID == "" {
		t.Error("Token ID 为空")
	}
}

func TestGetTokenExpiry_Success(t *testing.T) {
	manager := createTestJWTManager(t)

	// 生成 Token
	token, err := manager.GenerateAccessToken("user-123")
	if err != nil {
		t.Fatalf("生成 Access Token 失败: %v", err)
	}

	// 获取过期时间
	expiry, err := manager.GetTokenExpiry(token)
	if err != nil {
		t.Fatalf("获取 Token 过期时间失败: %v", err)
	}
	if expiry.IsZero() {
		t.Error("过期时间为零值")
	}
	// 验证过期时间在合理范围内（15 分钟左右）
	expectedExpiry := time.Now().Add(15 * time.Minute)
	diff := expiry.Sub(expectedExpiry)
	if diff < -time.Minute || diff > time.Minute {
		t.Errorf("过期时间不在预期范围内: got %v, expected around %v", expiry, expectedExpiry)
	}
}

func TestTokensAreDifferent(t *testing.T) {
	manager := createTestJWTManager(t)

	// 生成两个 Token
	token1, err := manager.GenerateAccessToken("user-123")
	if err != nil {
		t.Fatalf("生成第一个 Token 失败: %v", err)
	}

	token2, err := manager.GenerateAccessToken("user-123")
	if err != nil {
		t.Fatalf("生成第二个 Token 失败: %v", err)
	}

	// 验证两个 Token 不同（因为 JTI 不同）
	if token1 == token2 {
		t.Error("两个 Token 应该不同")
	}
}

func TestAccessAndRefreshTokensAreDifferent(t *testing.T) {
	manager := createTestJWTManager(t)

	accessToken, err := manager.GenerateAccessToken("user-123")
	if err != nil {
		t.Fatalf("生成 Access Token 失败: %v", err)
	}

	refreshToken, err := manager.GenerateRefreshToken("user-123")
	if err != nil {
		t.Fatalf("生成 Refresh Token 失败: %v", err)
	}

	if accessToken == refreshToken {
		t.Error("Access Token 和 Refresh Token 应该不同")
	}
}
