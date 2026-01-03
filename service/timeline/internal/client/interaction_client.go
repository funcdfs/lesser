// Package client 提供外部服务客户端
package client

import (
	"context"
	"log/slog"

	"github.com/funcdfs/lesser/timeline/internal/service"
	interactionpb "github.com/funcdfs/lesser/timeline/proto/interaction"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

// InteractionServiceClient Interaction 服务客户端
type InteractionServiceClient struct {
	conn   *grpc.ClientConn
	client interactionpb.InteractionServiceClient
	log    *slog.Logger
}

// NewInteractionServiceClient 创建 Interaction 服务客户端
func NewInteractionServiceClient(addr string) (*InteractionServiceClient, error) {
	conn, err := grpc.NewClient(addr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return nil, err
	}
	return &InteractionServiceClient{
		conn:   conn,
		client: interactionpb.NewInteractionServiceClient(conn),
		log:    slog.Default().With(slog.String("component", "interaction_client")),
	}, nil
}

// Close 关闭连接
func (c *InteractionServiceClient) Close() error {
	return c.conn.Close()
}

// BatchGetInteractionStatus 批量获取交互状态
// 调用 Interaction Service 获取用户对多个内容的点赞、收藏、转发状态
func (c *InteractionServiceClient) BatchGetInteractionStatus(ctx context.Context, userID string, contentIDs []string) ([]*service.InteractionStatus, error) {
	if len(contentIDs) == 0 {
		return nil, nil
	}

	resp, err := c.client.BatchGetInteractionStatus(ctx, &interactionpb.BatchGetInteractionStatusRequest{
		UserId:     userID,
		ContentIds: contentIDs,
	})
	if err != nil {
		c.log.Error("批量获取交互状态失败", slog.String("user_id", userID), slog.Int("content_count", len(contentIDs)), slog.Any("error", err))
		return nil, err
	}

	result := make([]*service.InteractionStatus, len(resp.Statuses))
	for i, s := range resp.Statuses {
		result[i] = &service.InteractionStatus{
			ContentID:    s.ContentId,
			IsLiked:      s.IsLiked,
			IsBookmarked: s.IsBookmarked,
			IsReposted:   s.IsReposted,
		}
	}

	c.log.Debug("批量获取交互状态成功", slog.String("user_id", userID), slog.Int("content_count", len(contentIDs)), slog.Int("result_count", len(result)))
	return result, nil
}
