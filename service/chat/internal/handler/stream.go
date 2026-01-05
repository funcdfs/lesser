package handler

import (
	"context"
	"io"
	"sync"
	"sync/atomic"
	"time"

	pb "github.com/funcdfs/lesser/chat/gen_protos/chat"
	"github.com/funcdfs/lesser/chat/internal/data_access"
	"github.com/funcdfs/lesser/chat/internal/logic"
	"github.com/funcdfs/lesser/pkg/gen_protos/common"
	"github.com/funcdfs/lesser/pkg/log"
	"github.com/google/uuid"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

// StreamManager 管理所有活跃的双向流连接
type StreamManager struct {
	clients map[string]*StreamClient // userID -> client
	mu      sync.RWMutex
	chatSvc *logic.ChatService
}

// StreamClient 表示单个用户的流连接
type StreamClient struct {
	userID        string
	stream        pb.ChatService_StreamEventsServer
	subscriptions map[string]bool // conversationID -> subscribed
	mu            sync.RWMutex
	done          chan struct{}
	closed        atomic.Bool // 标记连接是否已关闭，避免重复关闭
}

// NewStreamManager 创建流管理器
func NewStreamManager(chatSvc *logic.ChatService) *StreamManager {
	return &StreamManager{
		clients: make(map[string]*StreamClient),
		chatSvc: chatSvc,
	}
}

// HandleStreamEvents 处理双向流 RPC
func (m *StreamManager) HandleStreamEvents(stream pb.ChatService_StreamEventsServer) error {
	// 从 metadata 获取 user_id
	userID, err := getUserIDFromStreamContext(stream.Context())
	if err != nil {
		return err
	}

	log.Info("用户连接", log.String("user_id", userID))

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
		// 使用 atomic 避免重复关闭
		if oldClient.closed.CompareAndSwap(false, true) {
			close(oldClient.done)
		}
	}
	m.clients[userID] = client
	m.mu.Unlock()

	defer func() {
		m.mu.Lock()
		if m.clients[userID] == client {
			delete(m.clients, userID)
		}
		m.mu.Unlock()
		// 标记当前客户端已关闭
		client.closed.Store(true)
		log.Info("用户断开连接", log.String("user_id", userID))
	}()

	// 处理客户端事件
	// 使用 goroutine 监听 done 和 context 取消，主循环阻塞在 Recv
	errCh := make(chan error, 1)
	go func() {
		select {
		case <-client.done:
			errCh <- nil
		case <-stream.Context().Done():
			errCh <- stream.Context().Err()
		}
	}()

	for {
		// stream.Recv() 是阻塞调用，不会导致 CPU 空转
		event, err := stream.Recv()
		if err == io.EOF {
			return nil
		}
		if err != nil {
			// 检查是否是因为 done 或 context 取消导致的错误
			select {
			case e := <-errCh:
				return e
			default:
				return err
			}
		}

		if err := m.handleClientEvent(client, event); err != nil {
			log.Error("处理事件失败", log.Any("error", err))
			client.SendError("INTERNAL_ERROR", err.Error(), "")
		}
	}
}

// handleClientEvent 处理客户端事件
func (m *StreamManager) handleClientEvent(client *StreamClient, event *pb.ClientEvent) error {
	switch e := event.Event.(type) {
	case *pb.ClientEvent_Subscribe:
		return m.handleSubscribe(client, e.Subscribe)
	case *pb.ClientEvent_Unsubscribe:
		return m.handleUnsubscribe(client, e.Unsubscribe)
	case *pb.ClientEvent_SendMessage:
		return m.handleSendMessage(client, e.SendMessage)
	case *pb.ClientEvent_Ping:
		return m.handlePing(client)
	case *pb.ClientEvent_Typing:
		return m.handleTyping(client, e.Typing)
	default:
		return nil
	}
}

// handleSubscribe 处理订阅会话
func (m *StreamManager) handleSubscribe(client *StreamClient, req *pb.SubscribeRequest) error {
	client.mu.Lock()
	client.subscriptions[req.ConversationId] = true
	client.mu.Unlock()

	log.Debug("用户订阅会话",
		log.String("user_id", client.userID),
		log.String("conversation_id", req.ConversationId),
	)

	return client.stream.Send(&pb.ServerEvent{
		Event: &pb.ServerEvent_Subscribed{
			Subscribed: &pb.SubscribedEvent{ConversationId: req.ConversationId},
		},
	})
}

// handleUnsubscribe 处理取消订阅
func (m *StreamManager) handleUnsubscribe(client *StreamClient, req *pb.UnsubscribeRequest) error {
	client.mu.Lock()
	delete(client.subscriptions, req.ConversationId)
	client.mu.Unlock()

	log.Debug("用户取消订阅会话",
		log.String("user_id", client.userID),
		log.String("conversation_id", req.ConversationId),
	)

	return client.stream.Send(&pb.ServerEvent{
		Event: &pb.ServerEvent_Unsubscribed{
			Unsubscribed: &pb.UnsubscribedEvent{ConversationId: req.ConversationId},
		},
	})
}

// handleSendMessage 处理通过流发送消息
func (m *StreamManager) handleSendMessage(client *StreamClient, req *pb.SendMessageEvent) error {
	ctx := context.Background()

	convID, err := uuid.Parse(req.ConversationId)
	if err != nil {
		client.SendError("INVALID_CONVERSATION_ID", "会话 ID 格式无效", req.ClientMessageId)
		return nil
	}

	userID, err := uuid.Parse(client.userID)
	if err != nil {
		client.SendError("INVALID_USER_ID", "用户 ID 格式无效", req.ClientMessageId)
		return nil
	}

	// 调用 ChatService 发送消息
	msg, err := m.chatSvc.SendMessage(ctx, logic.SendMessageRequest{
		ConversationID: convID,
		SenderID:       userID,
		Content:        req.Content,
		MessageType:    parseMessageType(req.MessageType),
	})
	if err != nil {
		client.SendError("SEND_FAILED", err.Error(), req.ClientMessageId)
		return nil
	}

	// 发送确认给发送者
	client.stream.Send(&pb.ServerEvent{
		Event: &pb.ServerEvent_MessageSent{
			MessageSent: &pb.MessageSentEvent{
				ClientMessageId: req.ClientMessageId,
				Message:         messageToProto(msg),
			},
		},
	})

	// 广播给会话中的其他成员
	m.BroadcastNewMessage(req.ConversationId, msg, client.userID)

	return nil
}

// handlePing 处理心跳
func (m *StreamManager) handlePing(client *StreamClient) error {
	return client.stream.Send(&pb.ServerEvent{
		Event: &pb.ServerEvent_Pong{Pong: &pb.PongEvent{}},
	})
}

// handleTyping 处理正在输入
func (m *StreamManager) handleTyping(client *StreamClient, req *pb.TypingEvent) error {
	m.BroadcastTyping(req.ConversationId, client.userID, req.IsTyping)
	return nil
}

// BroadcastNewMessage 广播新消息给会话成员
// 使用读锁保护并发访问，发送操作在锁外执行避免阻塞
func (m *StreamManager) BroadcastNewMessage(conversationID string, msg *data_access.Message, excludeUserID string) {
	m.mu.RLock()
	// 复制需要发送的客户端列表，避免长时间持有锁
	var targets []*StreamClient
	for userID, client := range m.clients {
		if userID == excludeUserID {
			continue
		}
		client.mu.RLock()
		subscribed := client.subscriptions[conversationID]
		client.mu.RUnlock()

		if subscribed {
			targets = append(targets, client)
		}
	}
	m.mu.RUnlock()

	// 在锁外执行发送操作
	event := &pb.ServerEvent{
		Event: &pb.ServerEvent_NewMessage{
			NewMessage: &pb.NewMessageEvent{Message: messageToProto(msg)},
		},
	}

	for _, client := range targets {
		// 使用 goroutine 异步发送，避免单个客户端阻塞影响其他客户端
		go func(c *StreamClient) {
			// 跳过已关闭的连接
			if c.closed.Load() {
				return
			}
			if err := c.stream.Send(event); err != nil {
				log.Warn("发送消息失败",
					log.String("user_id", c.userID),
					log.Any("error", err))
			}
		}(client)
	}
}

// BroadcastToConversation 广播消息给会话中的所有订阅者（用于 SendMessage RPC）
func (m *StreamManager) BroadcastToConversation(conversationID uuid.UUID, msg *data_access.Message) {
	m.BroadcastNewMessage(conversationID.String(), msg, msg.SenderID.String())
}

// NotifyReadReceipt 通知单条消息已读
func (m *StreamManager) NotifyReadReceipt(receipt *data_access.ReadReceipt) {
	messageIDs := []string{receipt.MessageID.String()}
	m.BroadcastMessageRead(receipt.ConversationID.String(), receipt.ReaderID.String(), messageIDs)
}

// NotifyBatchReadReceipt 通知批量消息已读
func (m *StreamManager) NotifyBatchReadReceipt(receipt *data_access.BatchReadReceipt) {
	messageIDs := make([]string, len(receipt.MessageIDs))
	for i, id := range receipt.MessageIDs {
		messageIDs[i] = id.String()
	}
	m.BroadcastMessageRead(receipt.ConversationID.String(), receipt.ReaderID.String(), messageIDs)
}

// BroadcastTyping 广播正在输入状态
// 使用读锁保护并发访问，发送操作在锁外执行避免阻塞
func (m *StreamManager) BroadcastTyping(conversationID, userID string, isTyping bool) {
	m.mu.RLock()
	// 复制需要发送的客户端列表
	var targets []*StreamClient
	for uid, client := range m.clients {
		if uid == userID {
			continue
		}
		client.mu.RLock()
		subscribed := client.subscriptions[conversationID]
		client.mu.RUnlock()

		if subscribed {
			targets = append(targets, client)
		}
	}
	m.mu.RUnlock()

	// 在锁外执行发送操作
	event := &pb.ServerEvent{
		Event: &pb.ServerEvent_TypingIndicator{
			TypingIndicator: &pb.TypingIndicatorEvent{
				ConversationId: conversationID,
				UserId:         userID,
				IsTyping:       isTyping,
			},
		},
	}

	for _, client := range targets {
		go func(c *StreamClient) {
			if c.closed.Load() {
				return
			}
			if err := c.stream.Send(event); err != nil {
				log.Warn("发送输入状态失败",
					log.String("user_id", c.userID),
					log.Any("error", err))
			}
		}(client)
	}
}

// BroadcastMessageRead 广播消息已读
// 使用读锁保护并发访问，发送操作在锁外执行避免阻塞
func (m *StreamManager) BroadcastMessageRead(conversationID, readerID string, messageIDs []string) {
	m.mu.RLock()
	// 复制需要发送的客户端列表
	var targets []*StreamClient
	for _, client := range m.clients {
		client.mu.RLock()
		subscribed := client.subscriptions[conversationID]
		client.mu.RUnlock()

		if subscribed {
			targets = append(targets, client)
		}
	}
	m.mu.RUnlock()

	// 在锁外执行发送操作
	now := time.Now()
	event := &pb.ServerEvent{
		Event: &pb.ServerEvent_MessageRead{
			MessageRead: &pb.MessageReadEvent{
				ConversationId: conversationID,
				ReaderId:       readerID,
				MessageIds:     messageIDs,
				ReadAt:         &common.Timestamp{Seconds: now.Unix()},
			},
		},
	}

	for _, client := range targets {
		go func(c *StreamClient) {
			if c.closed.Load() {
				return
			}
			if err := c.stream.Send(event); err != nil {
				log.Warn("发送已读状态失败",
					log.String("user_id", c.userID),
					log.Any("error", err))
			}
		}(client)
	}
}

// SendError 发送错误事件
// 检查客户端是否已关闭，避免向已关闭的流发送数据
func (c *StreamClient) SendError(code, message, action string) {
	if c.closed.Load() {
		return
	}
	c.stream.Send(&pb.ServerEvent{
		Event: &pb.ServerEvent_Error{
			Error: &pb.ErrorEvent{Code: code, Message: message, Action: action},
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
