// Package remote 提供外部服务客户端
package remote

import (
	"context"

	"github.com/funcdfs/lesser/pkg/grpc/client"
	"github.com/funcdfs/lesser/pkg/log"
	interactionpb "github.com/funcdfs/lesser/timeline/gen_protos/interaction"
	"github.com/funcdfs/lesser/timeline/internal/logic"
)

const (
	// interactionServiceName 服务名称，用于连接池注册
	interactionServiceName = "interaction"
)

// InteractionServiceClient Interaction 服务客户端
// 使用 client.Pool 管理连接，支持 OpenTelemetry 追踪
type InteractionServiceClient struct {
	pool *client.Pool
	log  *log.Logger
}

// NewInteractionServiceClient 创建 Interaction 服务客户端
// addr: Interaction 服务地址（host:port）
func NewInteractionServiceClient(addr string, log *log.Logger) (*InteractionServiceClient, error) {
	pool := client.NewPool(log)

	// 注册服务配置
	cfg := client.DefaultConfig()
	cfg.Target = addr
	pool.Register(interactionServiceName, cfg)

	return &InteractionServiceClient{
		pool: pool,
		log:  log,
	}, nil
}

// Close 关闭客户端连接池
func (c *InteractionServiceClient) Close() error {
	return c.pool.Close()
}

// BatchGetInteractionStatus 批量获取交互状态
// 调用 Interaction Service 获取用户对多个内容的点赞、收藏、转发状态
func (c *InteractionServiceClient) BatchGetInteractionStatus(ctx context.Context, userID string, contentIDs []string) ([]*logic.InteractionStatus, error) {
	if len(contentIDs) == 0 {
		return nil, nil
	}

	// 从连接池获取连接
	conn, err := c.pool.GetConn(ctx, interactionServiceName)
	if err != nil {
		c.log.WithContext(ctx).Error("获取 Interaction 服务连接失败", "error", err)
		return nil, err
	}

	client := interactionpb.NewInteractionServiceClient(conn)
	resp, err := client.BatchGetInteractionStatus(ctx, &interactionpb.BatchGetInteractionStatusRequest{
		UserId:     userID,
		ContentIds: contentIDs,
	})
	if err != nil {
		c.log.WithContext(ctx).Error("批量获取交互状态失败",
			"user_id", userID,
			"content_count", len(contentIDs),
			"error", err)
		return nil, err
	}

	result := make([]*logic.InteractionStatus, len(resp.Statuses))
	for i, s := range resp.Statuses {
		result[i] = &logic.InteractionStatus{
			ContentID:    s.ContentId,
			IsLiked:      s.IsLiked,
			IsBookmarked: s.IsBookmarked,
			IsReposted:   s.IsReposted,
		}
	}

	c.log.WithContext(ctx).Debug("批量获取交互状态成功",
		"user_id", userID,
		"content_count", len(contentIDs),
		"result_count", len(result))
	return result, nil
}
