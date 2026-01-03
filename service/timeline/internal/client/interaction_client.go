// Package client 提供外部服务客户端
package client

import (
	"context"

	"github.com/funcdfs/lesser/timeline/internal/service"
	interactionpb "github.com/funcdfs/lesser/timeline/proto/interaction"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

// InteractionServiceClient Interaction 服务客户端
type InteractionServiceClient struct {
	conn   *grpc.ClientConn
	client interactionpb.InteractionServiceClient
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
	}, nil
}

// Close 关闭连接
func (c *InteractionServiceClient) Close() error {
	return c.conn.Close()
}

// BatchGetInteractionStatus 批量获取交互状态
func (c *InteractionServiceClient) BatchGetInteractionStatus(ctx context.Context, userID string, contentIDs []string) ([]*service.InteractionStatus, error) {
	resp, err := c.client.BatchGetInteractionStatus(ctx, &interactionpb.BatchGetInteractionStatusRequest{
		UserId:     userID,
		ContentIds: contentIDs,
	})
	if err != nil {
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
	return result, nil
}
