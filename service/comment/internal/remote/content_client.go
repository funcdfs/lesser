// Package remote 提供外部服务客户端
package remote

import (
	"context"

	contentpb "github.com/funcdfs/lesser/comment/gen_protos/content"
	"github.com/funcdfs/lesser/pkg/grpc/client"
	"github.com/funcdfs/lesser/pkg/log"
)

const (
	// contentServiceName 服务名称，用于连接池注册
	contentServiceName = "content"
)

// ContentServiceClient Content 服务客户端
// 使用 client.Pool 管理连接，支持 OpenTelemetry 追踪
type ContentServiceClient struct {
	pool *client.Pool
	log  *log.Logger
}

// NewContentServiceClient 创建 Content 服务客户端
// addr: Content 服务地址（host:port）
func NewContentServiceClient(addr string, log *log.Logger) (*ContentServiceClient, error) {
	pool := client.NewPool(log)

	// 注册服务配置
	cfg := client.DefaultConfig()
	cfg.Target = addr
	pool.Register(contentServiceName, cfg)

	return &ContentServiceClient{
		pool: pool,
		log:  log,
	}, nil
}

// Close 关闭客户端连接池
func (c *ContentServiceClient) Close() error {
	return c.pool.Close()
}

// UpdateCounter 更新内容计数器
func (c *ContentServiceClient) UpdateCounter(ctx context.Context, contentID string, counterType contentpb.CounterType, delta int32) (int32, error) {
	conn, err := c.pool.GetConn(ctx, contentServiceName)
	if err != nil {
		c.log.WithContext(ctx).Error("获取 Content 服务连接失败", "error", err)
		return 0, err
	}

	client := contentpb.NewContentServiceClient(conn)
	resp, err := client.UpdateCounter(ctx, &contentpb.UpdateCounterRequest{
		ContentId:   contentID,
		CounterType: counterType,
		Delta:       delta,
	})
	if err != nil {
		c.log.WithContext(ctx).Error("更新内容计数器失败",
			"content_id", contentID,
			"counter_type", counterType,
			"delta", delta,
			"error", err)
		return 0, err
	}
	return resp.NewCount, nil
}

// CheckContentExists 检查内容是否存在
func (c *ContentServiceClient) CheckContentExists(ctx context.Context, contentID string) (exists bool, commentsDisabled bool, err error) {
	conn, err := c.pool.GetConn(ctx, contentServiceName)
	if err != nil {
		c.log.WithContext(ctx).Error("获取 Content 服务连接失败", "error", err)
		return false, false, err
	}

	client := contentpb.NewContentServiceClient(conn)
	resp, err := client.CheckContentExists(ctx, &contentpb.CheckContentExistsRequest{
		ContentId: contentID,
	})
	if err != nil {
		c.log.WithContext(ctx).Error("检查内容是否存在失败",
			"content_id", contentID,
			"error", err)
		return false, false, err
	}
	return resp.Exists, resp.CommentsDisabled, nil
}

// GetContentAuthorID 获取内容作者 ID
func (c *ContentServiceClient) GetContentAuthorID(ctx context.Context, contentID string) (string, error) {
	conn, err := c.pool.GetConn(ctx, contentServiceName)
	if err != nil {
		c.log.WithContext(ctx).Error("获取 Content 服务连接失败", "error", err)
		return "", err
	}

	client := contentpb.NewContentServiceClient(conn)
	resp, err := client.GetContent(ctx, &contentpb.GetContentRequest{
		ContentId: contentID,
	})
	if err != nil {
		c.log.WithContext(ctx).Error("获取内容作者 ID 失败",
			"content_id", contentID,
			"error", err)
		return "", err
	}
	if resp.Content == nil {
		return "", nil
	}
	return resp.Content.AuthorId, nil
}
