// Package crypto 提供 JWT 令牌生成和管理功能
// 使用 RS256 签名 Access Token，HS256 签名 Refresh Token
package crypto

import (
	"context"
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"errors"
	"fmt"
	"sync"
	"sync/atomic"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

// 错误定义
var (
	ErrKeyNotInitialized = errors.New("密钥未初始化")
	ErrInvalidToken      = errors.New("无效的令牌")
	ErrTokenExpired      = errors.New("令牌已过期")
	ErrInvalidTokenType  = errors.New("无效的令牌类型")
)

// TokenType 令牌类型
type TokenType string

const (
	TokenTypeAccess  TokenType = "access"
	TokenTypeRefresh TokenType = "refresh"
)

// Claims JWT 声明
type Claims struct {
	jwt.RegisteredClaims
	UserID string    `json:"sub"`
	Type   TokenType `json:"type"`
}

// KeyPair RSA 密钥对
type KeyPair struct {
	PrivateKey   *rsa.PrivateKey
	PublicKey    *rsa.PublicKey
	PublicKeyPEM string
	KeyID        string
	CreatedAt    time.Time
	ExpiresAt    time.Time
}

// JWTManager JWT 令牌管理器
type JWTManager struct {
	// 当前密钥对（原子更新）
	currentKey atomic.Pointer[KeyPair]
	// 旧密钥对（用于密钥轮换过渡期）
	previousKey atomic.Pointer[KeyPair]

	// HMAC 密钥（用于 Refresh Token）
	hmacSecret []byte

	// 配置
	keySize              int
	accessTokenDuration  time.Duration
	refreshTokenDuration time.Duration
	keyRotationInterval  time.Duration

	// 生命周期管理
	stopChan chan struct{}
	stopped  atomic.Bool
	mu       sync.Mutex
}

// JWTManagerConfig JWT 管理器配置
type JWTManagerConfig struct {
	HMACSecret           string
	KeySize              int
	AccessTokenDuration  time.Duration
	RefreshTokenDuration time.Duration
	KeyRotationInterval  time.Duration
}

// NewJWTManager 创建 JWT 管理器
func NewJWTManager(cfg JWTManagerConfig) (*JWTManager, error) {
	if cfg.KeySize == 0 {
		cfg.KeySize = 2048
	}
	if cfg.AccessTokenDuration == 0 {
		cfg.AccessTokenDuration = 15 * time.Minute
	}
	if cfg.RefreshTokenDuration == 0 {
		cfg.RefreshTokenDuration = 7 * 24 * time.Hour
	}
	if cfg.KeyRotationInterval == 0 {
		cfg.KeyRotationInterval = 30 * 24 * time.Hour
	}

	m := &JWTManager{
		hmacSecret:           []byte(cfg.HMACSecret),
		keySize:              cfg.KeySize,
		accessTokenDuration:  cfg.AccessTokenDuration,
		refreshTokenDuration: cfg.RefreshTokenDuration,
		keyRotationInterval:  cfg.KeyRotationInterval,
		stopChan:             make(chan struct{}),
	}

	// 生成初始密钥对
	if err := m.rotateKey(); err != nil {
		return nil, fmt.Errorf("生成初始密钥失败: %w", err)
	}

	return m, nil
}

// Start 启动密钥轮换定时器
func (m *JWTManager) Start(ctx context.Context) {
	go m.keyRotationLoop(ctx)
}

// Stop 停止管理器
func (m *JWTManager) Stop() {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.stopped.Swap(true) {
		return
	}
	close(m.stopChan)
}

// GenerateAccessToken 生成 Access Token（RS256 签名）
func (m *JWTManager) GenerateAccessToken(userID string) (string, error) {
	keyPair := m.currentKey.Load()
	if keyPair == nil {
		return "", ErrKeyNotInitialized
	}

	now := time.Now()
	claims := &Claims{
		RegisteredClaims: jwt.RegisteredClaims{
			ID:        uuid.New().String(),
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(m.accessTokenDuration)),
			Issuer:    "lesser-auth",
		},
		UserID: userID,
		Type:   TokenTypeAccess,
	}

	token := jwt.NewWithClaims(jwt.SigningMethodRS256, claims)
	token.Header["kid"] = keyPair.KeyID

	return token.SignedString(keyPair.PrivateKey)
}

// GenerateRefreshToken 生成 Refresh Token（HS256 签名）
func (m *JWTManager) GenerateRefreshToken(userID string) (string, error) {
	now := time.Now()
	claims := &Claims{
		RegisteredClaims: jwt.RegisteredClaims{
			ID:        uuid.New().String(),
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(m.refreshTokenDuration)),
			Issuer:    "lesser-auth",
		},
		UserID: userID,
		Type:   TokenTypeRefresh,
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(m.hmacSecret)
}

// ValidateRefreshToken 验证 Refresh Token
func (m *JWTManager) ValidateRefreshToken(tokenString string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("不支持的签名算法: %v", token.Header["alg"])
		}
		return m.hmacSecret, nil
	})

	if err != nil {
		if errors.Is(err, jwt.ErrTokenExpired) {
			return nil, ErrTokenExpired
		}
		return nil, fmt.Errorf("%w: %v", ErrInvalidToken, err)
	}

	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, ErrInvalidToken
	}

	if claims.Type != TokenTypeRefresh {
		return nil, ErrInvalidTokenType
	}

	return claims, nil
}

// GetPublicKeyInfo 获取当前公钥信息
func (m *JWTManager) GetPublicKeyInfo() *PublicKeyInfo {
	keyPair := m.currentKey.Load()
	if keyPair == nil {
		return nil
	}

	return &PublicKeyInfo{
		PublicKey: keyPair.PublicKeyPEM,
		KeyID:     keyPair.KeyID,
		Algorithm: "RS256",
		ExpiresAt: keyPair.ExpiresAt.Unix(),
	}
}

// PublicKeyInfo 公钥信息
type PublicKeyInfo struct {
	PublicKey string
	KeyID     string
	Algorithm string
	ExpiresAt int64
}

// GetTokenID 从令牌中提取 JTI（用于黑名单）
func (m *JWTManager) GetTokenID(tokenString string) (string, error) {
	// 不验证签名，只解析 claims
	token, _, err := jwt.NewParser().ParseUnverified(tokenString, &Claims{})
	if err != nil {
		return "", fmt.Errorf("解析令牌失败: %w", err)
	}

	claims, ok := token.Claims.(*Claims)
	if !ok {
		return "", ErrInvalidToken
	}

	return claims.ID, nil
}

// GetTokenExpiry 获取令牌过期时间
func (m *JWTManager) GetTokenExpiry(tokenString string) (time.Time, error) {
	token, _, err := jwt.NewParser().ParseUnverified(tokenString, &Claims{})
	if err != nil {
		return time.Time{}, fmt.Errorf("解析令牌失败: %w", err)
	}

	claims, ok := token.Claims.(*Claims)
	if !ok {
		return time.Time{}, ErrInvalidToken
	}

	if claims.ExpiresAt == nil {
		return time.Time{}, ErrInvalidToken
	}

	return claims.ExpiresAt.Time, nil
}

// rotateKey 轮换密钥
func (m *JWTManager) rotateKey() error {
	// 生成新密钥对
	privateKey, err := rsa.GenerateKey(rand.Reader, m.keySize)
	if err != nil {
		return fmt.Errorf("生成 RSA 密钥失败: %w", err)
	}

	// 编码公钥为 PEM 格式
	publicKeyBytes, err := x509.MarshalPKIXPublicKey(&privateKey.PublicKey)
	if err != nil {
		return fmt.Errorf("编码公钥失败: %w", err)
	}

	publicKeyPEM := pem.EncodeToMemory(&pem.Block{
		Type:  "PUBLIC KEY",
		Bytes: publicKeyBytes,
	})

	now := time.Now()
	newKeyPair := &KeyPair{
		PrivateKey:   privateKey,
		PublicKey:    &privateKey.PublicKey,
		PublicKeyPEM: string(publicKeyPEM),
		KeyID:        uuid.New().String()[:8],
		CreatedAt:    now,
		ExpiresAt:    now.Add(m.keyRotationInterval),
	}

	// 保存旧密钥（用于过渡期验证）
	oldKey := m.currentKey.Load()
	if oldKey != nil {
		m.previousKey.Store(oldKey)
	}

	// 更新当前密钥
	m.currentKey.Store(newKeyPair)

	return nil
}

// keyRotationLoop 密钥轮换循环
func (m *JWTManager) keyRotationLoop(ctx context.Context) {
	ticker := time.NewTicker(m.keyRotationInterval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-m.stopChan:
			return
		case <-ticker.C:
			if err := m.rotateKey(); err != nil {
				// 记录错误但继续运行
				continue
			}
		}
	}
}
