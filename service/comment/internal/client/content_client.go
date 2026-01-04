// Package client 提供外部服务客户端
package client

import (
	"context"

	contentpb "github.com/funcdfs/lesser/comment/proto/content"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

// ContentServiceClient Content 服务客户端
type ContentServiceClient struct {
	conn   *grpc.ClientConn
	client contentpb.ContentServiceClient
}

// NewContentServiceClient 创建 Content 服务客户端
// 使用懒连接模式，不阻塞启动
func NewContentServiceClient(addr string) (*ContentServiceClient, error) {
	// 使用 grpc.NewClient（非阻塞），连接会在首次 RPC 调用时建立
	conn, err := grpc.NewClient(addr,
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	)
	if err != nil {
		return nil, err
	}
	return &ContentServiceClient{
		conn:   conn,
		client: contentpb.NewContentServiceClient(conn),
	}, nil
}

// Close 关闭连接
func (c *ContentServiceClient) Close() error {
	if c.conn != nil {
		return c.conn.Close()
	}
	return nil
}

// UpdateCounter 更新内容计数器
func (c *ContentServiceClient) UpdateCounter(ctx context.Context, contentID string, counterType contentpb.CounterType, delta int32) (int32, error) {
	resp, err := c.client.UpdateCounter(ctx, &contentpb.UpdateCounterRequest{
		ContentId:   contentID,
		CounterType: counterType,
		Delta:       delta,
	})
	if err != nil {
		return 0, err
	}
	return resp.NewCount, nil
}

// CheckContentExists 检查内容是否存在
func (c *ContentServiceClient) CheckContentExists(ctx context.Context, contentID string) (exists bool, commentsDisabled bool, err error) {
	resp, err := c.client.CheckContentExists(ctx, &contentpb.CheckContentExistsRequest{
		ContentId: contentID,
	})
	if err != nil {
		return false, false, err
	}
	return resp.Exists, resp.CommentsDisabled, nil
}

// GetContentAuthorID 获取内容作者 ID
func (c *ContentServiceClient) GetContentAuthorID(ctx context.Context, contentID string) (string, error) {
	resp, err := c.client.GetContent(ctx, &contentpb.GetContentRequest{
		ContentId: contentID,
	})
	if err != nil {
		return "", err
	}
	if resp.Content == nil {
		return "", nil
	}
	return resp.Content.AuthorId, nil
}
