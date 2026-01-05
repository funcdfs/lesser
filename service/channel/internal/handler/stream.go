// Package handler Channel 双向流处理
package handler

import (
	"context"
	"encoding/json"
	"io"
	"sync"

	pb "github.com/funcdfs/lesser/channel/gen_protos/channel"
	"github.com/funcdfs/lesser/channel/internal/data_access"
	"github.com/funcdfs/lesser/pkg/db"
	"github.com/funcdfs/lesser/pkg/log"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

// StreamManager 管理所有活跃的双向流连接
type StreamManager struct {
	clients     map[string]*StreamClient // userID -> client
	mu          sync.RWMutex
	redisClient *db.RedisClient
}

// StreamClient 表示单个用户的流连接
type StreamClient struct {
	userID        string
	stream        grpc.BidiStreamingServer[pb.ChannelClientEvent, pb.ChannelServerEvent]
	subscriptions map[string]bool // channelID -> subscribed
	mu            sync.RWMutex
	done          chan struct{}
}

// NewStreamManager 创建流管理器
func NewStreamManager(redisClient *db.RedisClient) *StreamManager {
	return &StreamManager{
		clients:     make(map[string]*StreamClient),
		redisClient: redisClient,
	}
}

// HandleStreamUpdates 处理双向流 RPC
func (m *StreamManager) HandleStreamUpdates(stream grpc.BidiStreamingServer[pb.ChannelClientEvent, pb.ChannelServerEvent]) error {
	// 从 metadata 获取 user_id
	userID, err := getUserIDFromStreamContext(stream.Context())
	if err != nil {
		return err
	}

	log.Info("用户连接 Channel 流", log.String("user_id", userID))

	// 创建客户端
	client := &StreamClient{
		userID:        userID,
		stream:        stream,
		subscriptions: make(map[string]bool),
		done:          make(chan struct{}),
	}

	// 注册客户端（如果已存在则关闭旧连接）
	m.mu.Lock()
	if oldClient, exists := m.clients[userID]; exists {
		close(oldClient.done)
	}
	m.clients[userID] = client
	m.mu.Unlock()

	defer func() {
		m.mu.Lock()
		if m.clients[userID] == client {
			delete(m.clients, userID)
		}
		m.mu.Unlock()
		log.Info("用户断开 Channel 流连接", log.String("user_id", userID))
	}()

	// 启动 Redis Pub/Sub 监听
	go m.subscribeToRedis(client)

	// 处理客户端事件
	for {
		select {
		case <-client.done:
			return nil
		case <-stream.Context().Done():
			return stream.Context().Err()
		default:
			event, err := stream.Recv()
			if err == io.EOF {
				return nil
			}
			if err != nil {
				return err
			}

			if err := m.handleClientEvent(client, event); err != nil {
				log.Error("处理 Channel 事件失败", log.Any("error", err))
				client.SendError("INTERNAL_ERROR", err.Error())
			}
		}
	}
}

// handleClientEvent 处理客户端事件
func (m *StreamManager) handleClientEvent(client *StreamClient, event *pb.ChannelClientEvent) error {
	switch e := event.Event.(type) {
	case *pb.ChannelClientEvent_Subscribe:
		return m.handleSubscribe(client, e.Subscribe)
	case *pb.ChannelClientEvent_Unsubscribe:
		return m.handleUnsubscribe(client, e.Unsubscribe)
	case *pb.ChannelClientEvent_Ping:
		return m.handlePing(client)
	default:
		return nil
	}
}

// handleSubscribe 处理订阅频道更新
func (m *StreamManager) handleSubscribe(client *StreamClient, req *pb.ChannelSubscribeEvent) error {
	client.mu.Lock()
	client.subscriptions[req.ChannelId] = true
	client.mu.Unlock()

	log.Debug("用户订阅频道更新",
		log.String("user_id", client.userID),
		log.String("channel_id", req.ChannelId),
	)

	return client.stream.Send(&pb.ChannelServerEvent{
		Event: &pb.ChannelServerEvent_Subscribed{
			Subscribed: &pb.ChannelSubscribedEvent{ChannelId: req.ChannelId},
		},
	})
}

// handleUnsubscribe 处理取消订阅
func (m *StreamManager) handleUnsubscribe(client *StreamClient, req *pb.ChannelUnsubscribeEvent) error {
	client.mu.Lock()
	delete(client.subscriptions, req.ChannelId)
	client.mu.Unlock()

	log.Debug("用户取消订阅频道更新",
		log.String("user_id", client.userID),
		log.String("channel_id", req.ChannelId),
	)

	return client.stream.Send(&pb.ChannelServerEvent{
		Event: &pb.ChannelServerEvent_Unsubscribed{
			Unsubscribed: &pb.ChannelUnsubscribedEvent{ChannelId: req.ChannelId},
		},
	})
}

// handlePing 处理心跳
func (m *StreamManager) handlePing(client *StreamClient) error {
	return client.stream.Send(&pb.ChannelServerEvent{
		Event: &pb.ChannelServerEvent_Pong{Pong: &pb.ChannelPongEvent{}},
	})
}

// subscribeToRedis 订阅 Redis Pub/Sub 接收频道更新
func (m *StreamManager) subscribeToRedis(client *StreamClient) {
	if m.redisClient == nil {
		return
	}

	ctx := context.Background()
	pubsub := m.redisClient.Subscribe(ctx, "channel:updates")
	defer pubsub.Close()

	ch := pubsub.Channel()
	for {
		select {
		case <-client.done:
			return
		case msg := <-ch:
			if msg == nil {
				continue
			}

			// 解析消息
			var update ChannelUpdate
			if err := json.Unmarshal([]byte(msg.Payload), &update); err != nil {
				log.Error("解析频道更新失败", log.Any("error", err))
				continue
			}

			// 检查用户是否订阅了该频道
			client.mu.RLock()
			subscribed := client.subscriptions[update.ChannelID]
			client.mu.RUnlock()

			if subscribed {
				m.sendUpdateToClient(client, &update)
			}
		}
	}
}

// ChannelUpdate 频道更新消息
type ChannelUpdate struct {
	Type      string                   `json:"type"` // "new_post", "post_deleted", "channel_updated"
	ChannelID string                   `json:"channel_id"`
	Post      *data_access.ChannelPost `json:"post,omitempty"`
}

// sendUpdateToClient 发送更新给客户端
func (m *StreamManager) sendUpdateToClient(client *StreamClient, update *ChannelUpdate) {
	switch update.Type {
	case "new_post":
		if update.Post != nil {
			client.stream.Send(&pb.ChannelServerEvent{
				Event: &pb.ChannelServerEvent_NewPost{
					NewPost: &pb.NewPostEvent{Post: postToProto(update.Post)},
				},
			})
		}
	case "post_deleted":
		if update.Post != nil {
			client.stream.Send(&pb.ChannelServerEvent{
				Event: &pb.ChannelServerEvent_PostDeleted{
					PostDeleted: &pb.PostDeletedEvent{
						ChannelId: update.ChannelID,
						PostId:    update.Post.ID,
					},
				},
			})
		}
	case "channel_updated":
		// 频道更新事件需要完整的频道信息，这里只发送通知
		// 客户端收到后应该重新获取频道详情
		client.stream.Send(&pb.ChannelServerEvent{
			Event: &pb.ChannelServerEvent_ChannelUpdated{
				ChannelUpdated: &pb.ChannelUpdatedEvent{Channel: nil},
			},
		})
	}
}

// BroadcastNewPost 广播新内容给订阅者
func (m *StreamManager) BroadcastNewPost(channelID string, post *data_access.ChannelPost) {
	// 发布到 Redis
	if m.redisClient != nil {
		update := ChannelUpdate{
			Type:      "new_post",
			ChannelID: channelID,
			Post:      post,
		}
		data, _ := json.Marshal(update)
		m.redisClient.Publish(context.Background(), "channel:updates", string(data))
	}

	// 直接广播给本地连接的客户端
	m.mu.RLock()
	var targets []*StreamClient
	for _, client := range m.clients {
		client.mu.RLock()
		subscribed := client.subscriptions[channelID]
		client.mu.RUnlock()

		if subscribed {
			targets = append(targets, client)
		}
	}
	m.mu.RUnlock()

	event := &pb.ChannelServerEvent{
		Event: &pb.ChannelServerEvent_NewPost{
			NewPost: &pb.NewPostEvent{Post: postToProto(post)},
		},
	}

	for _, client := range targets {
		go func(c *StreamClient) {
			if err := c.stream.Send(event); err != nil {
				log.Warn("发送新内容失败",
					log.String("user_id", c.userID),
					log.Any("error", err))
			}
		}(client)
	}
}

// BroadcastPostDeleted 广播内容删除给订阅者
func (m *StreamManager) BroadcastPostDeleted(channelID, postID string) {
	// 发布到 Redis
	if m.redisClient != nil {
		update := ChannelUpdate{
			Type:      "post_deleted",
			ChannelID: channelID,
			Post:      &data_access.ChannelPost{ID: postID},
		}
		data, _ := json.Marshal(update)
		m.redisClient.Publish(context.Background(), "channel:updates", string(data))
	}

	// 直接广播给本地连接的客户端
	m.mu.RLock()
	var targets []*StreamClient
	for _, client := range m.clients {
		client.mu.RLock()
		subscribed := client.subscriptions[channelID]
		client.mu.RUnlock()

		if subscribed {
			targets = append(targets, client)
		}
	}
	m.mu.RUnlock()

	event := &pb.ChannelServerEvent{
		Event: &pb.ChannelServerEvent_PostDeleted{
			PostDeleted: &pb.PostDeletedEvent{
				ChannelId: channelID,
				PostId:    postID,
			},
		},
	}

	for _, client := range targets {
		go func(c *StreamClient) {
			if err := c.stream.Send(event); err != nil {
				log.Warn("发送删除通知失败",
					log.String("user_id", c.userID),
					log.Any("error", err))
			}
		}(client)
	}
}

// SendError 发送错误事件
func (c *StreamClient) SendError(code, message string) {
	c.stream.Send(&pb.ChannelServerEvent{
		Event: &pb.ChannelServerEvent_Error{
			Error: &pb.ChannelErrorEvent{Code: code, Message: message},
		},
	})
}

// getUserIDFromStreamContext 从 context 获取 user_id
func getUserIDFromStreamContext(ctx context.Context) (string, error) {
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return "", status.Error(codes.Unauthenticated, "缺少 metadata")
	}

	// 尝试从 x-user-id 获取（Gateway 转发）
	if userIDs := md.Get("x-user-id"); len(userIDs) > 0 {
		return userIDs[0], nil
	}

	// 尝试从 user_id 获取（客户端直接传递）
	if userIDs := md.Get("user_id"); len(userIDs) > 0 {
		return userIDs[0], nil
	}

	return "", status.Error(codes.Unauthenticated, "缺少 user_id")
}
