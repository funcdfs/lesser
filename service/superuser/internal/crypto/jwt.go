// Package crypto JWT 工具
package crypto

import (
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

// JWTManager JWT 管理器
type JWTManager struct {
	secret               []byte
	accessTokenDuration  time.Duration
	refreshTokenDuration time.Duration
}

// JWTClaims JWT 声明
type JWTClaims struct {
	SuperUserID string `json:"superuser_id"`
	Username    string `json:"username"`
	TokenType   string `json:"token_type"` // access 或 refresh
	jwt.RegisteredClaims
}

// NewJWTManager 创建 JWT 管理器
func NewJWTManager(secret string, accessDuration, refreshDuration time.Duration) *JWTManager {
	return &JWTManager{
		secret:               []byte(secret),
		accessTokenDuration:  accessDuration,
		refreshTokenDuration: refreshDuration,
	}
}

// GenerateAccessToken 生成访问令牌
func (m *JWTManager) GenerateAccessToken(superUserID uuid.UUID, username string) (string, error) {
	return m.generateToken(superUserID, username, "access", m.accessTokenDuration)
}

// GenerateRefreshToken 生成刷新令牌
func (m *JWTManager) GenerateRefreshToken(superUserID uuid.UUID, username string) (string, error) {
	return m.generateToken(superUserID, username, "refresh", m.refreshTokenDuration)
}

// generateToken 生成令牌
func (m *JWTManager) generateToken(superUserID uuid.UUID, username, tokenType string, duration time.Duration) (string, error) {
	now := time.Now()
	claims := &JWTClaims{
		SuperUserID: superUserID.String(),
		Username:    username,
		TokenType:   tokenType,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(now.Add(duration)),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
			Issuer:    "lesser-superuser",
			Subject:   superUserID.String(),
			ID:        uuid.New().String(),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(m.secret)
}

// ValidateAccessToken 验证访问令牌
func (m *JWTManager) ValidateAccessToken(tokenString string) (*JWTClaims, error) {
	claims, err := m.validateToken(tokenString)
	if err != nil {
		return nil, err
	}
	if claims.TokenType != "access" {
		return nil, errors.New("无效的令牌类型")
	}
	return claims, nil
}

// ValidateRefreshToken 验证刷新令牌
func (m *JWTManager) ValidateRefreshToken(tokenString string) (*JWTClaims, error) {
	claims, err := m.validateToken(tokenString)
	if err != nil {
		return nil, err
	}
	if claims.TokenType != "refresh" {
		return nil, errors.New("无效的令牌类型")
	}
	return claims, nil
}

// validateToken 验证令牌
func (m *JWTManager) validateToken(tokenString string) (*JWTClaims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &JWTClaims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("意外的签名方法: %v", token.Header["alg"])
		}
		return m.secret, nil
	})

	if err != nil {
		return nil, fmt.Errorf("解析令牌失败: %w", err)
	}

	claims, ok := token.Claims.(*JWTClaims)
	if !ok || !token.Valid {
		return nil, errors.New("无效的令牌")
	}

	return claims, nil
}

// HashToken 哈希令牌（用于存储）
func HashToken(token string) string {
	hash := sha256.Sum256([]byte(token))
	return hex.EncodeToString(hash[:])
}

// GetAccessTokenDuration 获取访问令牌有效期
func (m *JWTManager) GetAccessTokenDuration() time.Duration {
	return m.accessTokenDuration
}

// GetRefreshTokenDuration 获取刷新令牌有效期
func (m *JWTManager) GetRefreshTokenDuration() time.Duration {
	return m.refreshTokenDuration
}
