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
	// serviceName 服务名称，用于连接池注册
	serviceName = "interaction"
)

// InteractionClient Interaction 服务客户端
// 使用 client.Pool 管理连接，支持 OpenTelemetry 追踪
type InteractionClient struct {
	pool *client.Pool
	log  *log.Logger
}

// NewInteractionServiceClient 创建 Interaction 服务客户端
// addr: Interaction 服务地址（host:port）
func NewInteractionServiceClient(addr string, logger *log.Logger) (*InteractionClient, error) {
	pool := client.NewPool(logger)

	// 注册服务配置
	cfg := client.DefaultConfig()
	cfg.Target = addr
	pool.Register(serviceName, cfg)

	return &InteractionClient{
		pool: pool,
		log:  logger.With(log.String("component", "interaction_client")),
	}, nil
}

// Close 关闭客户端连接池
func (c *InteractionClient) Close() error {
	return c.pool.Close()
}

// BatchGetInteractionStatus 批量获取交互状态
// 调用 Interaction Service 获取用户对多个内容的点赞、收藏、转发状态
func (c *InteractionClient) BatchGetInteractionStatus(ctx context.Context, userID string, contentIDs []string) ([]*logic.InteractionStatus, error) {
	if len(contentIDs) == 0 {
		return nil, nil
	}

	// 从连接池获取连接
	conn, err := c.pool.GetConn(ctx, serviceName)
	if err != nil {
		c.log.WithContext(ctx).Error("获取 Interaction 服务连接失败", log.Any("error", err))
		return nil, err
	}

	grpcClient := interactionpb.NewInteractionServiceClient(conn)
	resp, err := grpcClient.BatchGetInteractionStatus(ctx, &interactionpb.BatchGetInteractionStatusRequest{
		UserId:     userID,
		ContentIds: contentIDs,
	})
	if err != nil {
		c.log.WithContext(ctx).Error("批量获取交互状态失败",
			log.String("user_id", userID),
			log.Int("content_count", len(contentIDs)),
			log.Any("error", err))
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
		log.String("user_id", userID),
		log.Int("content_count", len(contentIDs)),
		log.Int("result_count", len(result)))

	return result, nil
}
