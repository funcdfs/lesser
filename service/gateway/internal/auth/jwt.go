package auth

import (
	"context"
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"errors"
	"fmt"
	"log"
	"sync"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"google.golang.org/grpc"
)

var (
	ErrPublicKeyNotLoaded = errors.New("public key not loaded")
	ErrKeyIDMismatch      = errors.New("key ID mismatch")
)

// Claims JWT 声明
type Claims struct {
	jwt.RegisteredClaims
	UserID string `json:"sub"`
	Type   string `json:"type"`
}

// AuthServiceClient 定义 AuthService 客户端接口（用于获取公钥）
type AuthServiceClient interface {
	GetPublicKey(ctx context.Context, in *GetPublicKeyRequest, opts ...grpc.CallOption) (*GetPublicKeyResponse, error)
}

// GetPublicKeyRequest 获取公钥请求
type GetPublicKeyRequest struct{}

// GetPublicKeyResponse 获取公钥响应
type GetPublicKeyResponse struct {
	PublicKey string
	KeyID     string
	Algorithm string
	ExpiresAt int64
}

// JWTValidator JWT 本地验签器
// 设计要点：
// 1. 内存持有公钥，本地验签（不调用 AuthService）
// 2. 定时刷新（每小时）
// 3. 惰性刷新（Key ID 不匹配时立即刷新）
type JWTValidator struct {
	publicKey     *rsa.PublicKey
	publicKeyPEM  string // 原始 PEM 格式，用于调试
	publicKeyID   string // Key ID，用于密钥轮换
	algorithm     string
	expiresAt     time.Time
	mu            sync.RWMutex
	authClient    AuthServiceClient
	refreshTicker *time.Ticker
	stopChan      chan struct{}
	
	// 配置
	refreshInterval time.Duration
}

// JWTValidatorConfig 验签器配置
type JWTValidatorConfig struct {
	RefreshInterval time.Duration // 公钥刷新间隔，默认 1 小时
}

// DefaultJWTValidatorConfig 默认配置
func DefaultJWTValidatorConfig() JWTValidatorConfig {
	return JWTValidatorConfig{
		RefreshInterval: 1 * time.Hour,
	}
}

// NewJWTValidator 创建 JWT 验签器
func NewJWTValidator(config JWTValidatorConfig) *JWTValidator {
	if config.RefreshInterval == 0 {
		config.RefreshInterval = 1 * time.Hour
	}
	return &JWTValidator{
		refreshInterval: config.RefreshInterval,
		stopChan:        make(chan struct{}),
	}
}


// Start 启动验签器，从 AuthService 获取公钥并启动定时刷新
func (v *JWTValidator) Start(ctx context.Context, authClient AuthServiceClient) error {
	v.authClient = authClient

	// 首次加载公钥
	if err := v.refreshPublicKey(ctx); err != nil {
		return fmt.Errorf("failed to load initial public key: %w", err)
	}

	// 启动定时刷新
	v.refreshTicker = time.NewTicker(v.refreshInterval)
	go v.backgroundRefresh(ctx)

	log.Printf("[JWT] Validator started, KeyID: %s, refresh interval: %v", v.publicKeyID, v.refreshInterval)
	return nil
}

// backgroundRefresh 后台定时刷新公钥
func (v *JWTValidator) backgroundRefresh(ctx context.Context) {
	for {
		select {
		case <-ctx.Done():
			log.Println("[JWT] Background refresh stopped: context cancelled")
			return
		case <-v.stopChan:
			log.Println("[JWT] Background refresh stopped")
			return
		case <-v.refreshTicker.C:
			if err := v.refreshPublicKey(context.Background()); err != nil {
				log.Printf("[JWT] Scheduled refresh failed: %v (continuing with old key)", err)
			} else {
				log.Printf("[JWT] Public key refreshed, KeyID: %s", v.publicKeyID)
			}
		}
	}
}

// refreshPublicKey 从 AuthService 获取公钥
func (v *JWTValidator) refreshPublicKey(ctx context.Context) error {
	if v.authClient == nil {
		return errors.New("auth client not initialized")
	}

	resp, err := v.authClient.GetPublicKey(ctx, &GetPublicKeyRequest{})
	if err != nil {
		return fmt.Errorf("failed to get public key from AuthService: %w", err)
	}

	// 解析 PEM 格式公钥
	block, _ := pem.Decode([]byte(resp.PublicKey))
	if block == nil {
		return errors.New("failed to decode PEM block")
	}

	pub, err := x509.ParsePKIXPublicKey(block.Bytes)
	if err != nil {
		return fmt.Errorf("failed to parse public key: %w", err)
	}

	rsaPub, ok := pub.(*rsa.PublicKey)
	if !ok {
		return errors.New("public key is not RSA")
	}

	// 更新公钥
	v.mu.Lock()
	v.publicKey = rsaPub
	v.publicKeyPEM = resp.PublicKey
	v.publicKeyID = resp.KeyID
	v.algorithm = resp.Algorithm
	v.expiresAt = time.Unix(resp.ExpiresAt, 0)
	v.mu.Unlock()

	return nil
}

// ValidateToken 本地验签 JWT（不调用 AuthService）
func (v *JWTValidator) ValidateToken(tokenString string) (*Claims, error) {
	v.mu.RLock()
	publicKey := v.publicKey
	keyID := v.publicKeyID
	v.mu.RUnlock()

	if publicKey == nil {
		return nil, ErrPublicKeyNotLoaded
	}

	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		// 验证签名算法
		if _, ok := token.Method.(*jwt.SigningMethodRSA); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}

		// 检查 Key ID 是否匹配
		if kid, ok := token.Header["kid"].(string); ok && kid != keyID {
			log.Printf("[JWT] Key ID mismatch: token kid=%s, current kid=%s, attempting refresh", kid, keyID)
			
			// Key ID 不匹配，尝试惰性刷新
			if refreshErr := v.refreshPublicKey(context.Background()); refreshErr != nil {
				log.Printf("[JWT] Lazy refresh failed: %v", refreshErr)
				return nil, fmt.Errorf("key ID mismatch and refresh failed: %w", refreshErr)
			}
			
			// 刷新成功，使用新公钥
			v.mu.RLock()
			publicKey = v.publicKey
			v.mu.RUnlock()
			log.Printf("[JWT] Lazy refresh succeeded, new KeyID: %s", v.publicKeyID)
		}

		return publicKey, nil
	})

	if err != nil {
		return nil, fmt.Errorf("token validation failed: %w", err)
	}

	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, errors.New("invalid token claims")
	}

	// 验证 token 类型
	if claims.Type != "access" {
		return nil, errors.New("invalid token type: expected access token")
	}

	return claims, nil
}

// GetPublicKeyID 获取当前公钥 ID
func (v *JWTValidator) GetPublicKeyID() string {
	v.mu.RLock()
	defer v.mu.RUnlock()
	return v.publicKeyID
}

// Stop 停止验签器
func (v *JWTValidator) Stop() {
	if v.refreshTicker != nil {
		v.refreshTicker.Stop()
	}
	close(v.stopChan)
	log.Println("[JWT] Validator stopped")
}
