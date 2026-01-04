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
	"google.golang.org/grpc"
	"google.golang.org/grpc/backoff"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/keepalive"
)

// AuthClient Auth 服务 gRPC 客户端
type AuthClient struct {
	conn      *grpc.ClientConn
	client    authpb.AuthServiceClient
	publicKey *rsa.PublicKey
	keyID     string
	mu        sync.RWMutex
}

// NewAuthClient 创建 Auth 客户端
func NewAuthClient(addr string) (*AuthClient, error) {
	keepaliveParams := keepalive.ClientParameters{
		Time:                30 * time.Second,
		Timeout:             10 * time.Second,
		PermitWithoutStream: true,
	}

	backoffConfig := backoff.Config{
		BaseDelay:  100 * time.Millisecond,
		Multiplier: 1.6,
		Jitter:     0.2,
		MaxDelay:   5 * time.Second,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	conn, err := grpc.DialContext(ctx, addr,
		grpc.WithTransportCredentials(insecure.NewCredentials()),
		grpc.WithBlock(),
		grpc.WithKeepaliveParams(keepaliveParams),
		grpc.WithConnectParams(grpc.ConnectParams{
			Backoff:           backoffConfig,
			MinConnectTimeout: 5 * time.Second,
		}),
		grpc.WithDefaultServiceConfig(`{
			"methodConfig": [{
				"name": [{"service": "auth.AuthService"}],
				"retryPolicy": {
					"maxAttempts": 3,
					"initialBackoff": "0.1s",
					"maxBackoff": "1s",
					"backoffMultiplier": 2,
					"retryableStatusCodes": ["UNAVAILABLE", "DEADLINE_EXCEEDED"]
				}
			}]
		}`),
	)
	if err != nil {
		return nil, fmt.Errorf("连接 Auth 服务失败: %w", err)
	}

	client := &AuthClient{
		conn:   conn,
		client: authpb.NewAuthServiceClient(conn),
	}

	// 获取公钥用于本地 JWT 验签
	if err := client.refreshPublicKey(context.Background()); err != nil {
		conn.Close()
		return nil, fmt.Errorf("获取公钥失败: %w", err)
	}

	// 启动后台公钥刷新
	go client.startKeyRefresh()

	return client, nil
}

// refreshPublicKey 刷新公钥
func (c *AuthClient) refreshPublicKey(ctx context.Context) error {
	resp, err := c.client.GetPublicKey(ctx, &authpb.GetPublicKeyRequest{})
	if err != nil {
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

	return nil
}

// startKeyRefresh 启动后台公钥刷新
func (c *AuthClient) startKeyRefresh() {
	ticker := time.NewTicker(1 * time.Hour)
	defer ticker.Stop()

	for range ticker.C {
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		if err := c.refreshPublicKey(ctx); err != nil {
			fmt.Printf("刷新公钥失败: %v\n", err)
		}
		cancel()
	}
}

// Close 关闭连接
func (c *AuthClient) Close() error {
	if c.conn != nil {
		return c.conn.Close()
	}
	return nil
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
	resp, err := c.client.GetUser(ctx, &authpb.GetUserRequest{
		UserId: userID.String(),
	})
	if err != nil {
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
			fmt.Printf("警告: 获取用户 %s 失败: %v\n", userID, err)
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
