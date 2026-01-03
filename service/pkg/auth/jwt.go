// Package auth 提供 JWT 认证相关功能
// 支持 Token 生成、验证、刷新、公钥管理
package auth

import (
	"context"
	"crypto/rsa"
	"errors"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// 预定义错误
var (
	ErrTokenExpired     = errors.New("token 已过期")
	ErrTokenInvalid     = errors.New("token 无效")
	ErrTokenMalformed   = errors.New("token 格式错误")
	ErrKeyNotFound      = errors.New("密钥不存在")
	ErrInvalidKeyID     = errors.New("无效的 Key ID")
	ErrInvalidSignature = errors.New("签名验证失败")
)

// Claims JWT 声明
type Claims struct {
	jwt.RegisteredClaims
	UserID   string `json:"user_id"`
	Username string `json:"username,omitempty"`
	Email    string `json:"email,omitempty"`
	Role     string `json:"role,omitempty"`
}

// TokenPair Token 对
type TokenPair struct {
	AccessToken  string
	RefreshToken string
	ExpiresAt    time.Time
}

// TokenConfig Token 配置
type TokenConfig struct {
	// AccessTokenTTL Access Token 有效期
	AccessTokenTTL time.Duration
	// RefreshTokenTTL Refresh Token 有效期
	RefreshTokenTTL time.Duration
	// Issuer 签发者
	Issuer string
}

// DefaultTokenConfig 默认配置
func DefaultTokenConfig() TokenConfig {
	return TokenConfig{
		AccessTokenTTL:  time.Hour,
		RefreshTokenTTL: 7 * 24 * time.Hour,
		Issuer:          "lesser",
	}
}

// JWTManager JWT 管理器
type JWTManager struct {
	config     TokenConfig
	privateKey *rsa.PrivateKey
	publicKey  *rsa.PublicKey
	keyID      string
}

// NewJWTManager 创建 JWT 管理器
func NewJWTManager(privateKey *rsa.PrivateKey, publicKey *rsa.PublicKey, keyID string, config TokenConfig) *JWTManager {
	return &JWTManager{
		config:     config,
		privateKey: privateKey,
		publicKey:  publicKey,
		keyID:      keyID,
	}
}

// GenerateTokenPair 生成 Token 对
func (m *JWTManager) GenerateTokenPair(ctx context.Context, userID, username, email, role string) (*TokenPair, error) {
	now := time.Now()

	// 生成 Access Token
	accessClaims := &Claims{
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    m.config.Issuer,
			Subject:   userID,
			ExpiresAt: jwt.NewNumericDate(now.Add(m.config.AccessTokenTTL)),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
		},
		UserID:   userID,
		Username: username,
		Email:    email,
		Role:     role,
	}

	accessToken := jwt.NewWithClaims(jwt.SigningMethodRS256, accessClaims)
	accessToken.Header["kid"] = m.keyID

	accessTokenStr, err := accessToken.SignedString(m.privateKey)
	if err != nil {
		return nil, fmt.Errorf("签名 access token 失败: %w", err)
	}

	// 生成 Refresh Token
	refreshClaims := &Claims{
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    m.config.Issuer,
			Subject:   userID,
			ExpiresAt: jwt.NewNumericDate(now.Add(m.config.RefreshTokenTTL)),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
		},
		UserID: userID,
	}

	refreshToken := jwt.NewWithClaims(jwt.SigningMethodRS256, refreshClaims)
	refreshToken.Header["kid"] = m.keyID

	refreshTokenStr, err := refreshToken.SignedString(m.privateKey)
	if err != nil {
		return nil, fmt.Errorf("签名 refresh token 失败: %w", err)
	}

	return &TokenPair{
		AccessToken:  accessTokenStr,
		RefreshToken: refreshTokenStr,
		ExpiresAt:    now.Add(m.config.AccessTokenTTL),
	}, nil
}

// ValidateToken 验证 Token
func (m *JWTManager) ValidateToken(tokenStr string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenStr, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		// 验证签名算法
		if _, ok := token.Method.(*jwt.SigningMethodRSA); !ok {
			return nil, fmt.Errorf("不支持的签名算法: %v", token.Header["alg"])
		}
		return m.publicKey, nil
	})

	if err != nil {
		if errors.Is(err, jwt.ErrTokenExpired) {
			return nil, ErrTokenExpired
		}
		if errors.Is(err, jwt.ErrTokenMalformed) {
			return nil, ErrTokenMalformed
		}
		return nil, fmt.Errorf("%w: %v", ErrTokenInvalid, err)
	}

	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, ErrTokenInvalid
	}

	return claims, nil
}

// RefreshToken 刷新 Token
func (m *JWTManager) RefreshToken(ctx context.Context, refreshTokenStr string) (*TokenPair, error) {
	claims, err := m.ValidateToken(refreshTokenStr)
	if err != nil {
		return nil, err
	}

	// 生成新的 Token 对
	return m.GenerateTokenPair(ctx, claims.UserID, claims.Username, claims.Email, claims.Role)
}

// GetKeyID 获取当前 Key ID
func (m *JWTManager) GetKeyID() string {
	return m.keyID
}

// GetPublicKey 获取公钥
func (m *JWTManager) GetPublicKey() *rsa.PublicKey {
	return m.publicKey
}

// ExtractKeyID 从 Token 中提取 Key ID
func ExtractKeyID(tokenStr string) (string, error) {
	parser := jwt.NewParser()
	token, _, err := parser.ParseUnverified(tokenStr, &Claims{})
	if err != nil {
		return "", fmt.Errorf("解析 token 失败: %w", err)
	}

	kid, ok := token.Header["kid"].(string)
	if !ok || kid == "" {
		return "", ErrInvalidKeyID
	}

	return kid, nil
}

// ExtractClaims 从 Token 中提取声明（不验证签名）
func ExtractClaims(tokenStr string) (*Claims, error) {
	parser := jwt.NewParser()
	token, _, err := parser.ParseUnverified(tokenStr, &Claims{})
	if err != nil {
		return nil, fmt.Errorf("解析 token 失败: %w", err)
	}

	claims, ok := token.Claims.(*Claims)
	if !ok {
		return nil, ErrTokenInvalid
	}

	return claims, nil
}

// IsTokenExpired 检查 Token 是否过期
func IsTokenExpired(tokenStr string) bool {
	claims, err := ExtractClaims(tokenStr)
	if err != nil {
		return true
	}

	if claims.ExpiresAt == nil {
		return true
	}

	return claims.ExpiresAt.Time.Before(time.Now())
}
