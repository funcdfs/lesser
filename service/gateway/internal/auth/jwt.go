// Package auth 提供 JWT 本地验签功能
//
// 设计要点：
//   - 内存持有公钥，本地验签（不调用 AuthService）
//   - 定时刷新（默认每小时）
//   - 惰性刷新（Key ID 不匹配时立即刷新）
//   - 线程安全的公钥更新
package auth

import (
	"context"
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"errors"
	"fmt"
	"sync"
	"sync/atomic"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"go.uber.org/zap"
	"google.golang.org/grpc"
)

// ============================================================================
// 错误定义
// ============================================================================

var (
	ErrPublicKeyNotLoaded = errors.New("公钥未加载")
	ErrAuthClientNil      = errors.New("认证客户端未初始化")
	ErrPEMDecodeFailed    = errors.New("PEM 解码失败")
	ErrNotRSAKey          = errors.New("公钥类型不是 RSA")
	ErrInvalidTokenType   = errors.New("无效的令牌类型: 期望 access")
	ErrInvalidClaims      = errors.New("无效的令牌声明")
	ErrValidatorStopped   = errors.New("验签器已停止")
)

// ============================================================================
// Claims 定义
// ============================================================================

// Claims JWT 声明结构
type Claims struct {
	jwt.RegisteredClaims
	UserID string `json:"sub"`  // 用户 ID
	Type   string `json:"type"` // 令牌类型: access / refresh
}

// ============================================================================
// Auth 服务客户端接口
// ============================================================================

// AuthServiceClient 定义获取公钥的接口
// 由 gateway.go 中的 authClientAdapter 实现
type AuthServiceClient interface {
	GetPublicKey(ctx context.Context, in *GetPublicKeyRequest, opts ...grpc.CallOption) (*GetPublicKeyResponse, error)
}

// GetPublicKeyRequest 获取公钥请求
type GetPublicKeyRequest struct {
	// 预留字段，未来可扩展：
	// KeyID string // 请求特定 Key ID 的公钥
}

// GetPublicKeyResponse 获取公钥响应
type GetPublicKeyResponse struct {
	PublicKey string // PEM 格式的公钥
	KeyID     string // Key ID，用于密钥轮换
	Algorithm string // 签名算法，如 "RS256"
	ExpiresAt int64  // 公钥过期时间戳（Unix 秒）
}

// ============================================================================
// JWT 验签器配置
// ============================================================================

// ValidatorConfig 验签器配置
type ValidatorConfig struct {
	RefreshInterval time.Duration // 公钥定时刷新间隔
	RefreshTimeout  time.Duration // 刷新公钥的超时时间
}

// DefaultValidatorConfig 返回默认配置
func DefaultValidatorConfig() ValidatorConfig {
	return ValidatorConfig{
		RefreshInterval: time.Hour,
		RefreshTimeout:  10 * time.Second,
	}
}

// ============================================================================
// JWT 验签器
// ============================================================================

// publicKeyState 公钥状态（用于原子更新）
type publicKeyState struct {
	key   *rsa.PublicKey
	keyID string
}

// JWTValidator JWT 本地验签器
type JWTValidator struct {
	// 公钥状态（原子更新，避免锁竞争）
	keyState atomic.Pointer[publicKeyState]

	// 配置
	config ValidatorConfig

	// 依赖
	authClient AuthServiceClient
	log        *zap.Logger

	// 生命周期管理
	refreshTicker *time.Ticker
	stopChan      chan struct{}
	stopped       atomic.Bool
	mu            sync.Mutex // 保护 Start/Stop 操作
}

// NewJWTValidator 创建 JWT 验签器
func NewJWTValidator(config ValidatorConfig, log *zap.Logger) *JWTValidator {
	if config.RefreshInterval <= 0 {
		config.RefreshInterval = time.Hour
	}
	if config.RefreshTimeout <= 0 {
		config.RefreshTimeout = 10 * time.Second
	}
	if log == nil {
		log = zap.NewNop()
	}

	return &JWTValidator{
		config:   config,
		stopChan: make(chan struct{}),
		log:      log.Named("jwt"),
	}
}

// Start 启动验签器
func (v *JWTValidator) Start(ctx context.Context, authClient AuthServiceClient) error {
	v.mu.Lock()
	defer v.mu.Unlock()

	if v.stopped.Load() {
		return ErrValidatorStopped
	}

	v.authClient = authClient

	// 首次加载公钥（带超时）
	loadCtx, cancel := context.WithTimeout(ctx, v.config.RefreshTimeout)
	defer cancel()

	if err := v.refreshPublicKey(loadCtx); err != nil {
		return fmt.Errorf("加载初始公钥失败: %w", err)
	}

	// 启动定时刷新
	v.refreshTicker = time.NewTicker(v.config.RefreshInterval)
	go v.backgroundRefresh()

	state := v.keyState.Load()
	v.log.Info("验签器已启动",
		zap.String("key_id", state.keyID),
		zap.Duration("refresh_interval", v.config.RefreshInterval))

	return nil
}

// Stop 停止验签器（幂等操作）
func (v *JWTValidator) Stop() {
	v.mu.Lock()
	defer v.mu.Unlock()

	// 防止重复关闭
	if v.stopped.Swap(true) {
		return
	}

	if v.refreshTicker != nil {
		v.refreshTicker.Stop()
	}
	close(v.stopChan)
	v.log.Info("验签器已停止")
}

// ValidateToken 验证 JWT 令牌
func (v *JWTValidator) ValidateToken(tokenString string) (*Claims, error) {
	state := v.keyState.Load()
	if state == nil || state.key == nil {
		return nil, ErrPublicKeyNotLoaded
	}

	publicKey := state.key
	keyID := state.keyID

	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		// 验证签名算法
		if _, ok := token.Method.(*jwt.SigningMethodRSA); !ok {
			return nil, fmt.Errorf("不支持的签名算法: %v", token.Header["alg"])
		}

		// 检查 Key ID 是否匹配
		if kid, ok := token.Header["kid"].(string); ok && kid != keyID {
			v.log.Warn("密钥 ID 不匹配，尝试惰性刷新",
				zap.String("token_kid", kid),
				zap.String("current_kid", keyID))

			// 惰性刷新（带超时）
			ctx, cancel := context.WithTimeout(context.Background(), v.config.RefreshTimeout)
			defer cancel()

			if err := v.refreshPublicKey(ctx); err != nil {
				v.log.Error("惰性刷新失败", zap.Error(err))
				return nil, fmt.Errorf("密钥 ID 不匹配且刷新失败: %w", err)
			}

			// 使用新公钥
			newState := v.keyState.Load()
			if newState != nil {
				publicKey = newState.key
				v.log.Info("惰性刷新成功", zap.String("new_kid", newState.keyID))
			}
		}

		return publicKey, nil
	})

	if err != nil {
		return nil, fmt.Errorf("令牌验证失败: %w", err)
	}

	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, ErrInvalidClaims
	}

	// 验证令牌类型必须是 access
	if claims.Type != "access" {
		return nil, ErrInvalidTokenType
	}

	return claims, nil
}

// GetPublicKeyID 获取当前公钥 ID
func (v *JWTValidator) GetPublicKeyID() string {
	state := v.keyState.Load()
	if state == nil {
		return ""
	}
	return state.keyID
}

// IsReady 检查验签器是否就绪
func (v *JWTValidator) IsReady() bool {
	state := v.keyState.Load()
	return state != nil && state.key != nil
}

// backgroundRefresh 后台定时刷新公钥
func (v *JWTValidator) backgroundRefresh() {
	for {
		select {
		case <-v.stopChan:
			v.log.Debug("后台刷新停止")
			return
		case <-v.refreshTicker.C:
			ctx, cancel := context.WithTimeout(context.Background(), v.config.RefreshTimeout)
			if err := v.refreshPublicKey(ctx); err != nil {
				v.log.Warn("定时刷新失败，继续使用旧密钥", zap.Error(err))
			} else {
				state := v.keyState.Load()
				v.log.Debug("公钥已刷新", zap.String("key_id", state.keyID))
			}
			cancel()
		}
	}
}

// refreshPublicKey 从 AuthService 获取公钥
func (v *JWTValidator) refreshPublicKey(ctx context.Context) error {
	if v.authClient == nil {
		return ErrAuthClientNil
	}

	resp, err := v.authClient.GetPublicKey(ctx, &GetPublicKeyRequest{})
	if err != nil {
		return fmt.Errorf("获取公钥失败: %w", err)
	}

	// 解析 PEM 格式公钥
	block, _ := pem.Decode([]byte(resp.PublicKey))
	if block == nil {
		return ErrPEMDecodeFailed
	}

	pub, err := x509.ParsePKIXPublicKey(block.Bytes)
	if err != nil {
		return fmt.Errorf("解析公钥失败: %w", err)
	}

	rsaPub, ok := pub.(*rsa.PublicKey)
	if !ok {
		return ErrNotRSAKey
	}

	// 原子更新公钥状态
	v.keyState.Store(&publicKeyState{
		key:   rsaPub,
		keyID: resp.KeyID,
	})

	return nil
}
