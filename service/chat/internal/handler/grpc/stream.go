package grpc

import (
	"context"
	"fmt"
	"io"
	"log"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/lesser/chat/internal/model"
	"github.com/lesser/chat/internal/service"
	pb "github.com/lesser/chat/proto/chat"
	"github.com/lesser/pkg/proto/common"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

// StreamManager 管理所有活跃的双向流连接
type StreamManager struct {
	clients    map[string]*StreamClient // userID -> client
	mu         sync.RWMutex
	chatSvc    *service.ChatService
}

// StreamClient 表示单个用户的流连接
type StreamClient struct {
	userID        string
	stream        pb.ChatService_StreamEventsServer
	subscriptions map[string]bool // conversationID -> subscribed
	mu            sync.RWMutex
	done          chan struct{}
}

// NewStreamManager 创建流管理器
func NewStreamManager(chatSvc *service.ChatService) *StreamManager {
	return &StreamManager{
		clients: make(map[string]*StreamClient),
		chatSvc: chatSvc,
	}
}

// HandleStreamEvents 处理双向流 RPC
func (m *StreamManager) HandleStreamEvents(stream pb.ChatService_StreamEventsServer) error {
	// 从 metadata 获取 user_id
	userID, err := getUserIDFromContext(stream.Context())
	if err != nil {
		return err
	}

	log.Printf("[Stream] User %s connected", userID)

	// 创建客户端
	client := &StreamClient{
		userID:        userID,
		stream:        stream,
		subscriptions: make(map[string]bool),
		done:          make(chan struct{}),
	}

	// 注册客户端
	m.mu.Lock()
	if oldClient, exists := m.clients[userID]; exists {
		close(oldClient.done) // 关闭旧连接
	}
	m.clients[userID] = client
	m.mu.Unlock()

	defer func() {
		m.mu.Lock()
		if m.clients[userID] == client {
			delete(m.clients, userID)
		}
		m.mu.Unlock()
		log.Printf("[Stream] User %s disconnected", userID)
	}()

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
				log.Printf("[Stream] Error handling event: %v", err)
				// 发送错误事件但不断开连接
				client.SendError("INTERNAL_ERROR", err.Error(), "")
			}
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

	log.Printf("[Stream] User %s subscribed to conversation %s", client.userID, req.ConversationId)

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

	log.Printf("[Stream] User %s unsubscribed from conversation %s", client.userID, req.ConversationId)

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
		client.SendError("INVALID_CONVERSATION_ID", "invalid conversation ID", req.ClientMessageId)
		return nil
	}

	userID, err := uuid.Parse(client.userID)
	if err != nil {
		client.SendError("INVALID_USER_ID", "invalid user ID", req.ClientMessageId)
		return nil
	}

	// 调用 ChatService 发送消息
	msg, err := m.chatSvc.SendMessage(ctx, service.SendMessageRequest{
		ConversationID: convID,
		SenderID:       userID,
		Content:        req.Content,
		MessageType:    model.MessageTypeText, // 简化处理
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
				Message:         modelMessageToProto(msg),
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
func (m *StreamManager) BroadcastNewMessage(conversationID string, msg *model.Message, excludeUserID string) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	event := &pb.ServerEvent{
		Event: &pb.ServerEvent_NewMessage{
			NewMessage: &pb.NewMessageEvent{Message: modelMessageToProto(msg)},
		},
	}

	for userID, client := range m.clients {
		if userID == excludeUserID {
			continue
		}
		client.mu.RLock()
		subscribed := client.subscriptions[conversationID]
		client.mu.RUnlock()

		if subscribed {
			client.stream.Send(event)
		}
	}
}

// BroadcastToConversation 广播消息给会话中的所有订阅者（用于 SendMessage RPC）
func (m *StreamManager) BroadcastToConversation(conversationID uuid.UUID, msg *model.Message) {
	m.BroadcastNewMessage(conversationID.String(), msg, msg.SenderID.String())
}

// NotifyReadReceipt 通知单条消息已读
func (m *StreamManager) NotifyReadReceipt(receipt *model.ReadReceipt) {
	messageIDs := []string{fmt.Sprintf("%d", receipt.MessageID)}
	m.BroadcastMessageRead(receipt.ConversationID.String(), receipt.ReaderID.String(), messageIDs)
}

// NotifyBatchReadReceipt 通知批量消息已读
func (m *StreamManager) NotifyBatchReadReceipt(receipt *model.BatchReadReceipt) {
	messageIDs := make([]string, len(receipt.MessageIDs))
	for i, id := range receipt.MessageIDs {
		messageIDs[i] = fmt.Sprintf("%d", id)
	}
	m.BroadcastMessageRead(receipt.ConversationID.String(), receipt.ReaderID.String(), messageIDs)
}

// BroadcastTyping 广播正在输入状态
func (m *StreamManager) BroadcastTyping(conversationID, userID string, isTyping bool) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	event := &pb.ServerEvent{
		Event: &pb.ServerEvent_TypingIndicator{
			TypingIndicator: &pb.TypingIndicatorEvent{
				ConversationId: conversationID,
				UserId:         userID,
				IsTyping:       isTyping,
			},
		},
	}

	for uid, client := range m.clients {
		if uid == userID {
			continue
		}
		client.mu.RLock()
		subscribed := client.subscriptions[conversationID]
		client.mu.RUnlock()

		if subscribed {
			client.stream.Send(event)
		}
	}
}

// BroadcastMessageRead 广播消息已读
func (m *StreamManager) BroadcastMessageRead(conversationID, readerID string, messageIDs []string) {
	m.mu.RLock()
	defer m.mu.RUnlock()

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

	for _, client := range m.clients {
		client.mu.RLock()
		subscribed := client.subscriptions[conversationID]
		client.mu.RUnlock()

		if subscribed {
			client.stream.Send(event)
		}
	}
}

// SendError 发送错误事件
func (c *StreamClient) SendError(code, message, action string) {
	c.stream.Send(&pb.ServerEvent{
		Event: &pb.ServerEvent_Error{
			Error: &pb.ErrorEvent{Code: code, Message: message, Action: action},
		},
	})
}

// getUserIDFromContext 从 context 获取 user_id
func getUserIDFromContext(ctx context.Context) (string, error) {
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return "", status.Error(codes.Unauthenticated, "missing metadata")
	}

	userIDs := md.Get("user_id")
	if len(userIDs) == 0 {
		return "", status.Error(codes.Unauthenticated, "missing user_id")
	}

	return userIDs[0], nil
}

// modelMessageToProto 转换消息为 proto
func modelMessageToProto(msg *model.Message) *pb.Message {
	m := &pb.Message{
		Id:             fmt.Sprintf("%d", msg.ID),
		ConversationId: msg.DialogID.String(),
		SenderId:       msg.SenderID.String(),
		Content:        msg.Content,
		MessageType:    string(msg.MsgType),
		CreatedAt:      &common.Timestamp{Seconds: msg.Date.Unix()},
	}
	return m
}
