package service

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/google/uuid"
	authpb "github.com/lesser/chat/proto/auth"
	"google.golang.org/grpc"
	"google.golang.org/grpc/backoff"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/keepalive"
)

type AuthClient struct {
	conn   *grpc.ClientConn
	client authpb.AuthServiceClient
	mu     sync.RWMutex
}

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
		return nil, fmt.Errorf("连接 auth 服务失败: %w", err)
	}

	return &AuthClient{
		conn:   conn,
		client: authpb.NewAuthServiceClient(conn),
	}, nil
}

func (c *AuthClient) Close() error {
	if c.conn != nil {
		return c.conn.Close()
	}
	return nil
}

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
