// Package remote 提供外部服务客户端
package remote

import (
	"context"
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"fmt"
	"sync"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"

	authpb "github.com/funcdfs/lesser/channel/gen_protos/auth"
	"github.com/funcdfs/lesser/pkg/grpc/client"
	"github.com/funcdfs/lesser/pkg/log"
)

const (
	// authServiceName 服务名称，用于连接池注册
	authServiceName = "auth"
)

// AuthClient Auth 服务 gRPC 客户端
// 使用 client.Pool 管理连接，支持 JWT 本地验签
type AuthClient struct {
	pool      *client.Pool
	log       *log.Logger
	publicKey *rsa.PublicKey
	keyID     string
	mu        sync.RWMutex
	stopCh    chan struct{}
}

// NewAuthClient 创建 Auth 客户端
// addr: Auth 服务地址（host:port）
func NewAuthClient(addr string, log *log.Logger) (*AuthClient, error) {
	pool := client.NewPool(log)

	// 注册服务配置
	cfg := client.DefaultConfig()
	cfg.Target = addr
	pool.Register(authServiceName, cfg)

	c := &AuthClient{
		pool:   pool,
		log:    log,
		stopCh: make(chan struct{}),
	}

	// 获取公钥用于本地 JWT 验签
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := c.refreshPublicKey(ctx); err != nil {
		pool.Close()
		return nil, fmt.Errorf("获取公钥失败: %w", err)
	}

	// 启动后台公钥刷新
	go c.startKeyRefresh()

	return c, nil
}

// refreshPublicKey 刷新公钥
func (c *AuthClient) refreshPublicKey(ctx context.Context) error {
	conn, err := c.pool.GetConn(ctx, authServiceName)
	if err != nil {
		c.log.WithContext(ctx).Error("获取 Auth 服务连接失败", "error", err)
		return fmt.Errorf("获取 Auth 服务连接失败: %w", err)
	}

	client := authpb.NewAuthServiceClient(conn)
	resp, err := client.GetPublicKey(ctx, &authpb.GetPublicKeyRequest{})
	if err != nil {
		c.log.WithContext(ctx).Error("获取公钥失败", "error", err)
		return fmt.Errorf("获取公钥失败: %w", err)
	}

	block, _ := pem.Decode([]byte(resp.PublicKey))
	if block == nil {
		return fmt.Errorf("解析 PEM 格式公钥失败")
	}

	pub, err := x509.ParsePKIXPublicKey(block.Bytes)
	if err != nil {
		return fmt.Errorf("解析公钥失败: %w", err)
	}

	rsaPub, ok := pub.(*rsa.PublicKey)
	if !ok {
		return fmt.Errorf("公钥类型不是 RSA")
	}

	c.mu.Lock()
	c.publicKey = rsaPub
	c.keyID = resp.KeyId
	c.mu.Unlock()

	c.log.Info("公钥刷新成功", "key_id", resp.KeyId)
	return nil
}

// startKeyRefresh 启动后台公钥刷新
func (c *AuthClient) startKeyRefresh() {
	ticker := time.NewTicker(1 * time.Hour)
	defer ticker.Stop()

	for {
		select {
		case <-c.stopCh:
			return
		case <-ticker.C:
			ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
			if err := c.refreshPublicKey(ctx); err != nil {
				c.log.Error("刷新公钥失败", "error", err)
			}
			cancel()
		}
	}
}

// Close 关闭客户端连接池
func (c *AuthClient) Close() error {
	close(c.stopCh)
	return c.pool.Close()
}

// ValidateToken 本地验证 JWT token
// 验证签名、过期时间、token 类型等
func (c *AuthClient) ValidateToken(ctx context.Context, accessToken string) (uuid.UUID, error) {
	c.mu.RLock()
	publicKey := c.publicKey
	c.mu.RUnlock()

	if publicKey == nil {
		return uuid.Nil, fmt.Errorf("公钥未初始化")
	}

	token, err := jwt.Parse(accessToken, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodRSA); !ok {
			return nil, fmt.Errorf("不支持的签名方法: %v", token.Header["alg"])
		}
		return publicKey, nil
	}, jwt.WithValidMethods([]string{"RS256", "RS384", "RS512"}))

	if err != nil {
		c.log.WithContext(ctx).Debug("解析 token 失败", "error", err)
		return uuid.Nil, fmt.Errorf("解析 token 失败: %w", err)
	}

	if !token.Valid {
		return uuid.Nil, fmt.Errorf("token 无效")
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return uuid.Nil, fmt.Errorf("无法解析 claims")
	}

	// 检查 token 类型（如果存在）
	if tokenType, exists := claims["type"].(string); exists && tokenType != "access" {
		return uuid.Nil, fmt.Errorf("token 类型错误: 期望 access，实际 %s", tokenType)
	}

	// 获取用户 ID（优先从 user_id 获取，其次从 sub 获取）
	var userIDStr string
	if uid, ok := claims["user_id"].(string); ok && uid != "" {
		userIDStr = uid
	} else if sub, ok := claims["sub"].(string); ok && sub != "" {
		userIDStr = sub
	} else {
		return uuid.Nil, fmt.Errorf("缺少用户 ID claim")
	}

	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		return uuid.Nil, fmt.Errorf("解析用户 ID 失败: %w", err)
	}

	return userID, nil
}
