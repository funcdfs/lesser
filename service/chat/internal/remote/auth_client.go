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

	authpb "github.com/funcdfs/lesser/chat/gen_protos/auth"
	"github.com/funcdfs/lesser/pkg/grpc/client"
	"github.com/funcdfs/lesser/pkg/log"
)

const (
	// authServiceName 服务名称，用于连接池注册
	authServiceName = "auth"
)

// AuthClient Auth 服务 gRPC 客户端
// 使用 client.Pool 管理连接，支持 OpenTelemetry 追踪
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

	client := &AuthClient{
		pool:   pool,
		log:    log,
		stopCh: make(chan struct{}),
	}

	// 获取公钥用于本地 JWT 验签
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := client.refreshPublicKey(ctx); err != nil {
		pool.Close()
		return nil, fmt.Errorf("获取公钥失败: %w", err)
	}

	// 启动后台公钥刷新
	go client.startKeyRefresh()

	return client, nil
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
	})

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

	// 检查 token 类型
	tokenType, _ := claims["type"].(string)
	if tokenType != "access" {
		return uuid.Nil, fmt.Errorf("token 类型错误")
	}

	// 获取用户 ID
	sub, ok := claims["sub"].(string)
	if !ok {
		return uuid.Nil, fmt.Errorf("缺少 sub claim")
	}

	userID, err := uuid.Parse(sub)
	if err != nil {
		return uuid.Nil, fmt.Errorf("解析用户 ID 失败: %w", err)
	}

	return userID, nil
}

// GetUser 获取用户信息
func (c *AuthClient) GetUser(ctx context.Context, userID uuid.UUID) (*UserInfo, error) {
	conn, err := c.pool.GetConn(ctx, authServiceName)
	if err != nil {
		c.log.WithContext(ctx).Error("获取 Auth 服务连接失败", "error", err)
		return nil, fmt.Errorf("获取 Auth 服务连接失败: %w", err)
	}

	client := authpb.NewAuthServiceClient(conn)
	resp, err := client.GetUser(ctx, &authpb.GetUserRequest{
		UserId: userID.String(),
	})
	if err != nil {
		c.log.WithContext(ctx).Error("获取用户信息失败",
			"user_id", userID.String(),
			"error", err)
		return nil, fmt.Errorf("获取用户信息失败: %w", err)
	}

	return &UserInfo{
		ID:          resp.Id,
		Username:    resp.Username,
		Email:       resp.Email,
		DisplayName: strPtr(resp.DisplayName),
		AvatarURL:   strPtr(resp.AvatarUrl),
		Bio:         strPtr(resp.Bio),
	}, nil
}

// GetUsers 批量获取用户信息
func (c *AuthClient) GetUsers(ctx context.Context, userIDs []uuid.UUID) (map[uuid.UUID]*UserInfo, error) {
	result := make(map[uuid.UUID]*UserInfo)

	for _, userID := range userIDs {
		user, err := c.GetUser(ctx, userID)
		if err != nil {
			c.log.WithContext(ctx).Warn("获取用户失败",
				"user_id", userID.String(),
				"error", err)
			continue
		}
		result[userID] = user
	}

	return result, nil
}

func strPtr(s string) *string {
	if s == "" {
		return nil
	}
	return &s
}
