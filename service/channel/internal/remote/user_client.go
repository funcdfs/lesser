// Package remote User 服务客户端
package remote

import (
	"context"

	"github.com/funcdfs/lesser/pkg/grpc/client"
	"github.com/funcdfs/lesser/pkg/log"
	"google.golang.org/grpc"
)

// UserClient User 服务客户端
type UserClient struct {
	pool *client.Pool
	log  *log.Logger
}

// NewUserClient 创建 User 服务客户端
func NewUserClient(addr string, logger *log.Logger) (*UserClient, error) {
	pool := client.NewPool(logger)
	pool.Register("user", client.Config{
		Target:     addr,
		MaxRetries: 3,
	})

	return &UserClient{
		pool: pool,
		log:  logger,
	}, nil
}

// Close 关闭客户端连接池
func (c *UserClient) Close() error {
	return c.pool.Close()
}

// GetConn 获取连接
func (c *UserClient) GetConn(ctx context.Context) (*grpc.ClientConn, error) {
	return c.pool.GetConn(ctx, "user")
}

// GetUser 获取用户信息（示例方法）
func (c *UserClient) GetUser(ctx context.Context, userID string) error {
	// TODO: 实现获取用户信息逻辑
	// conn, err := c.GetConn(ctx)
	// if err != nil {
	//     return err
	// }
	// client := pb.NewUserServiceClient(conn)
	// return client.GetUser(ctx, &pb.GetUserRequest{UserId: userID})
	return nil
}
