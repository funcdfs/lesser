package service

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/google/uuid"
	authpb "github.com/lesser/chat/generated/protos/auth"
	"google.golang.org/grpc"
	"google.golang.org/grpc/backoff"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/keepalive"
)

// AuthClient 通过 gRPC 与 Django auth 服务通信
type AuthClient struct {
	conn   *grpc.ClientConn
	client authpb.AuthServiceClient
	mu     sync.RWMutex
}

// NewAuthClient 创建新的 AuthClient
func NewAuthClient(addr string) (*AuthClient, error) {
	// 配置 keepalive 参数
	keepaliveParams := keepalive.ClientParameters{
		Time:                30 * time.Second, // 每 30 秒发送 ping
		Timeout:             10 * time.Second, // ping 超时时间
		PermitWithoutStream: true,             // 允许无活动流时发送 ping
	}

	// 配置重试策略
	backoffConfig := backoff.Config{
		BaseDelay:  100 * time.Millisecond,
		Multiplier: 1.6,
		Jitter:     0.2,
		MaxDelay:   5 * time.Second,
	}

	// 建立 gRPC 连接
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
		return nil, fmt.Errorf("连接 auth 服务失败: %w", err)
	}

	return &AuthClient{
		conn:   conn,
		client: authpb.NewAuthServiceClient(conn),
	}, nil
}

// Close 关闭 gRPC 连接
func (c *AuthClient) Close() error {
	if c.conn != nil {
		return c.conn.Close()
	}
	return nil
}

// ValidateToken 验证 JWT token，返回用户 ID
func (c *AuthClient) ValidateToken(ctx context.Context, accessToken string) (uuid.UUID, error) {
	resp, err := c.client.ValidateToken(ctx, &authpb.ValidateRequest{
		AccessToken: accessToken,
	})
	if err != nil {
		return uuid.Nil, fmt.Errorf("验证 token 失败: %w", err)
	}

	if !resp.Valid {
		return uuid.Nil, fmt.Errorf("token 无效")
	}

	userID, err := uuid.Parse(resp.UserId)
	if err != nil {
		return uuid.Nil, fmt.Errorf("解析用户 ID 失败: %w", err)
	}

	return userID, nil
}

// GetUser 通过 gRPC 获取用户信息
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
			// 记录错误但继续 - 用户可能已被删除
			fmt.Printf("警告: 获取用户 %s 失败: %v\n", userID, err)
			continue
		}
		result[userID] = user
	}

	return result, nil
}

// strPtr 将空字符串转换为 nil，非空字符串转换为指针
func strPtr(s string) *string {
	if s == "" {
		return nil
	}
	return &s
}
