// Package auth JWT 验签器单元测试
package auth

import (
	"context"
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"google.golang.org/grpc"
)

// mockAuthClient 模拟 Auth 服务客户端
type mockAuthClient struct {
	publicKey *rsa.PublicKey
	keyID     string
	callCount int
}

func (m *mockAuthClient) GetPublicKey(ctx context.Context, in *GetPublicKeyRequest, opts ...grpc.CallOption) (*GetPublicKeyResponse, error) {
	m.callCount++

	// 将公钥编码为 PEM 格式
	pubBytes, err := x509.MarshalPKIXPublicKey(m.publicKey)
	if err != nil {
		return nil, err
	}

	pemBlock := &pem.Block{
		Type:  "PUBLIC KEY",
		Bytes: pubBytes,
	}

	return &GetPublicKeyResponse{
		PublicKey: string(pem.EncodeToMemory(pemBlock)),
		KeyID:     m.keyID,
		Algorithm: "RS256",
		ExpiresAt: time.Now().Add(time.Hour).Unix(),
	}, nil
}

// generateTestKeyPair 生成测试用的 RSA 密钥对
func generateTestKeyPair(t *testing.T) (*rsa.PrivateKey, *rsa.PublicKey) {
	privateKey, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatalf("生成密钥对失败: %v", err)
	}
	return privateKey, &privateKey.PublicKey
}

// generateTestToken 生成测试用的 JWT 令牌
func generateTestToken(t *testing.T, privateKey *rsa.PrivateKey, keyID, userID, tokenType string, expiry time.Duration) string {
	claims := &Claims{
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(expiry)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Subject:   userID,
		},
		UserID: userID,
		Type:   tokenType,
	}

	token := jwt.NewWithClaims(jwt.SigningMethodRS256, claims)
	token.Header["kid"] = keyID

	tokenString, err := token.SignedString(privateKey)
	if err != nil {
		t.Fatalf("签名令牌失败: %v", err)
	}

	return tokenString
}

func TestJWTValidator_ValidateToken_Success(t *testing.T) {
	// 生成测试密钥对
	privateKey, publicKey := generateTestKeyPair(t)
	keyID := "test-key-id"

	// 创建模拟客户端
	mockClient := &mockAuthClient{
		publicKey: publicKey,
		keyID:     keyID,
	}

	// 创建验签器
	validator := NewJWTValidator(ValidatorConfig{
		RefreshInterval: time.Hour,
		RefreshTimeout:  5 * time.Second,
	}, nil)

	// 启动验签器
	ctx := context.Background()
	if err := validator.Start(ctx, mockClient); err != nil {
		t.Fatalf("启动验签器失败: %v", err)
	}
	defer validator.Stop()

	// 生成有效令牌
	userID := "user-123"
	token := generateTestToken(t, privateKey, keyID, userID, "access", time.Hour)

	// 验证令牌
	claims, err := validator.ValidateToken(token)
	if err != nil {
		t.Fatalf("验证令牌失败: %v", err)
	}

	if claims.UserID != userID {
		t.Errorf("用户 ID 不匹配: 期望 %s, 实际 %s", userID, claims.UserID)
	}

	if claims.Type != "access" {
		t.Errorf("令牌类型不匹配: 期望 access, 实际 %s", claims.Type)
	}
}

func TestJWTValidator_ValidateToken_ExpiredToken(t *testing.T) {
	// 生成测试密钥对
	privateKey, publicKey := generateTestKeyPair(t)
	keyID := "test-key-id"

	// 创建模拟客户端
	mockClient := &mockAuthClient{
		publicKey: publicKey,
		keyID:     keyID,
	}

	// 创建验签器
	validator := NewJWTValidator(DefaultValidatorConfig(), nil)

	// 启动验签器
	ctx := context.Background()
	if err := validator.Start(ctx, mockClient); err != nil {
		t.Fatalf("启动验签器失败: %v", err)
	}
	defer validator.Stop()

	// 生成过期令牌
	token := generateTestToken(t, privateKey, keyID, "user-123", "access", -time.Hour)

	// 验证令牌应该失败
	_, err := validator.ValidateToken(token)
	if err == nil {
		t.Error("期望验证过期令牌失败，但成功了")
	}
}

func TestJWTValidator_ValidateToken_InvalidTokenType(t *testing.T) {
	// 生成测试密钥对
	privateKey, publicKey := generateTestKeyPair(t)
	keyID := "test-key-id"

	// 创建模拟客户端
	mockClient := &mockAuthClient{
		publicKey: publicKey,
		keyID:     keyID,
	}

	// 创建验签器
	validator := NewJWTValidator(DefaultValidatorConfig(), nil)

	// 启动验签器
	ctx := context.Background()
	if err := validator.Start(ctx, mockClient); err != nil {
		t.Fatalf("启动验签器失败: %v", err)
	}
	defer validator.Stop()

	// 生成 refresh 类型令牌（应该被拒绝）
	token := generateTestToken(t, privateKey, keyID, "user-123", "refresh", time.Hour)

	// 验证令牌应该失败
	_, err := validator.ValidateToken(token)
	if err != ErrInvalidTokenType {
		t.Errorf("期望错误 ErrInvalidTokenType, 实际: %v", err)
	}
}

func TestJWTValidator_ValidateToken_PublicKeyNotLoaded(t *testing.T) {
	// 创建验签器但不启动
	validator := NewJWTValidator(DefaultValidatorConfig(), nil)

	// 验证令牌应该失败
	_, err := validator.ValidateToken("some-token")
	if err != ErrPublicKeyNotLoaded {
		t.Errorf("期望错误 ErrPublicKeyNotLoaded, 实际: %v", err)
	}
}

func TestJWTValidator_IsReady(t *testing.T) {
	// 生成测试密钥对
	_, publicKey := generateTestKeyPair(t)
	keyID := "test-key-id"

	// 创建模拟客户端
	mockClient := &mockAuthClient{
		publicKey: publicKey,
		keyID:     keyID,
	}

	// 创建验签器
	validator := NewJWTValidator(DefaultValidatorConfig(), nil)

	// 未启动时应该不就绪
	if validator.IsReady() {
		t.Error("未启动时验签器不应该就绪")
	}

	// 启动验签器
	ctx := context.Background()
	if err := validator.Start(ctx, mockClient); err != nil {
		t.Fatalf("启动验签器失败: %v", err)
	}
	defer validator.Stop()

	// 启动后应该就绪
	if !validator.IsReady() {
		t.Error("启动后验签器应该就绪")
	}
}

func TestJWTValidator_GetPublicKeyID(t *testing.T) {
	// 生成测试密钥对
	_, publicKey := generateTestKeyPair(t)
	keyID := "test-key-id-123"

	// 创建模拟客户端
	mockClient := &mockAuthClient{
		publicKey: publicKey,
		keyID:     keyID,
	}

	// 创建验签器
	validator := NewJWTValidator(DefaultValidatorConfig(), nil)

	// 未启动时应该返回空
	if validator.GetPublicKeyID() != "" {
		t.Error("未启动时应该返回空 Key ID")
	}

	// 启动验签器
	ctx := context.Background()
	if err := validator.Start(ctx, mockClient); err != nil {
		t.Fatalf("启动验签器失败: %v", err)
	}
	defer validator.Stop()

	// 启动后应该返回正确的 Key ID
	if validator.GetPublicKeyID() != keyID {
		t.Errorf("Key ID 不匹配: 期望 %s, 实际 %s", keyID, validator.GetPublicKeyID())
	}
}

func TestJWTValidator_Stop_Idempotent(t *testing.T) {
	// 生成测试密钥对
	_, publicKey := generateTestKeyPair(t)

	// 创建模拟客户端
	mockClient := &mockAuthClient{
		publicKey: publicKey,
		keyID:     "test-key-id",
	}

	// 创建验签器
	validator := NewJWTValidator(DefaultValidatorConfig(), nil)

	// 启动验签器
	ctx := context.Background()
	if err := validator.Start(ctx, mockClient); err != nil {
		t.Fatalf("启动验签器失败: %v", err)
	}

	// 多次调用 Stop 不应该 panic
	validator.Stop()
	validator.Stop()
	validator.Stop()
}
