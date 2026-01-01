package ws

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"
	"github.com/lesser/chat/internal/config"
	"github.com/lesser/chat/internal/model"
	"github.com/lesser/chat/internal/service"
)

const (
	writeWait            = 10 * time.Second
	pongWait             = 60 * time.Second
	pingPeriod           = (pongWait * 9) / 10
	maxMessageSize       = 4096
	clientSendBufferSize = 256
	broadcastBufferSize  = 256
	notifyBufferSize     = 256
)

func createUpgrader(cfg *config.Config) websocket.Upgrader {
	return websocket.Upgrader{
		ReadBufferSize:  1024,
		WriteBufferSize: 1024,
		CheckOrigin: func(r *http.Request) bool {
			origin := r.Header.Get("Origin")
			if origin == "" {
				return true
			}
			return cfg.IsOriginAllowed(origin)
		},
	}
}

type Client struct {
	hub           *Hub
	conn          *websocket.Conn
	send          chan []byte
	userID        uuid.UUID
	conversations map[uuid.UUID]bool
	mu            sync.RWMutex
}

type Hub struct {
	clients             map[uuid.UUID]*Client
	conversationClients map[uuid.UUID]map[*Client]bool
	register            chan *Client
	unregister          chan *Client
	broadcast           chan *BroadcastMessage
	userNotify          chan *UserNotification
	chatService         *service.ChatService
	config              *config.Config
	upgrader            websocket.Upgrader
	mu                  sync.RWMutex
}

type BroadcastMessage struct {
	ConversationID uuid.UUID
	Message        *model.Message
}

type UserNotification struct {
	UserID  uuid.UUID
	Type    string
	Payload interface{}
}

type WSMessage struct {
	Type    string      `json:"type"`
	Payload interface{} `json:"payload"`
}

type WSCommand struct {
	Action         string `json:"action"`
	ConversationID string `json:"conversation_id,omitempty"`
}

type ConversationUpdatePayload struct {
	ConversationID string      `json:"conversation_id"`
	LastMessage    interface{} `json:"last_message,omitempty"`
	UnreadCount    int         `json:"unread_count"`
}

type ReadReceiptPayload struct {
	MessageID      string   `json:"message_id,omitempty"`
	ConversationID string   `json:"conversation_id"`
	ReaderID       string   `json:"reader_id"`
	ReadAt         string   `json:"read_at"`
	MessageIDs     []string `json:"message_ids,omitempty"`
}

func NewHub(chatService *service.ChatService, cfg *config.Config) *Hub {
	return &Hub{
		clients:             make(map[uuid.UUID]*Client),
		conversationClients: make(map[uuid.UUID]map[*Client]bool),
		register:            make(chan *Client),
		unregister:          make(chan *Client),
		broadcast:           make(chan *BroadcastMessage, broadcastBufferSize),
		userNotify:          make(chan *UserNotification, notifyBufferSize),
		chatService:         chatService,
		config:              cfg,
		upgrader:            createUpgrader(cfg),
	}
}

func (h *Hub) Run() {
	log.Println("[WebSocket] Hub 已启动")

	for {
		select {
		case client := <-h.register:
			h.handleRegister(client)
		case client := <-h.unregister:
			h.handleUnregister(client)
		case msg := <-h.broadcast:
			h.handleBroadcast(msg)
		case notify := <-h.userNotify:
			h.handleUserNotify(notify)
		}
	}
}

func (h *Hub) handleRegister(client *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()

	if oldClient, exists := h.clients[client.userID]; exists {
		h.cleanupClientLocked(oldClient)
		log.Printf("[WebSocket] 用户 %s 的旧连接已被踢掉", client.userID)
	}

	h.clients[client.userID] = client
	log.Printf("[WebSocket] 用户 %s 已连接，当前在线: %d", client.userID, len(h.clients))
}

func (h *Hub) handleUnregister(client *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()

	if currentClient, exists := h.clients[client.userID]; exists && currentClient == client {
		h.cleanupClientLocked(client)
		log.Printf("[WebSocket] 用户 %s 已断开，当前在线: %d", client.userID, len(h.clients))
	}
}

func (h *Hub) cleanupClientLocked(client *Client) {
	client.mu.RLock()
	for convID := range client.conversations {
		if clients, ok := h.conversationClients[convID]; ok {
			delete(clients, client)
			if len(clients) == 0 {
				delete(h.conversationClients, convID)
			}
		}
	}
	client.mu.RUnlock()

	delete(h.clients, client.userID)
	close(client.send)
}

func (h *Hub) handleBroadcast(msg *BroadcastMessage) {
	h.mu.RLock()
	clientsMap, ok := h.conversationClients[msg.ConversationID]
	if !ok || len(clientsMap) == 0 {
		h.mu.RUnlock()
		return
	}

	clients := make([]*Client, 0, len(clientsMap))
	for client := range clientsMap {
		clients = append(clients, client)
	}
	h.mu.RUnlock()

	data, err := json.Marshal(WSMessage{
		Type:    "message",
		Payload: msg.Message,
	})
	if err != nil {
		log.Printf("[WebSocket] 序列化广播消息失败: %v", err)
		return
	}

	for _, client := range clients {
		h.sendToClient(client, data)
	}
}

func (h *Hub) handleUserNotify(notify *UserNotification) {
	h.mu.RLock()
	client, ok := h.clients[notify.UserID]
	h.mu.RUnlock()

	if !ok {
		return
	}

	data, err := json.Marshal(WSMessage{
		Type:    notify.Type,
		Payload: notify.Payload,
	})
	if err != nil {
		log.Printf("[WebSocket] 序列化用户通知失败: %v", err)
		return
	}

	h.sendToClient(client, data)
}

func (h *Hub) sendToClient(client *Client, data []byte) {
	select {
	case client.send <- data:
	default:
		log.Printf("[WebSocket] 用户 %s 发送缓冲区已满，消息被丢弃", client.userID)
	}
}

func (h *Hub) BroadcastToConversation(conversationID uuid.UUID, message *model.Message) {
	h.broadcast <- &BroadcastMessage{
		ConversationID: conversationID,
		Message:        message,
	}
}

func (h *Hub) NotifyUser(userID uuid.UUID, notifyType string, payload interface{}) {
	h.userNotify <- &UserNotification{
		UserID:  userID,
		Type:    notifyType,
		Payload: payload,
	}
}

func (h *Hub) NotifyReadReceipt(senderID uuid.UUID, receipt *model.ReadReceipt) {
	if receipt == nil {
		return
	}

	h.userNotify <- &UserNotification{
		UserID: senderID,
		Type:   "message_read",
		Payload: &ReadReceiptPayload{
			MessageID:      strconv.FormatInt(receipt.MessageID, 10),
			ConversationID: receipt.ConversationID.String(),
			ReaderID:       receipt.ReaderID.String(),
			ReadAt:         receipt.ReadAt.Format(time.RFC3339),
		},
	}
}

func (h *Hub) NotifyBatchReadReceipt(senderID uuid.UUID, receipt *model.BatchReadReceipt) {
	if receipt == nil || len(receipt.MessageIDs) == 0 {
		return
	}

	messageIDs := make([]string, len(receipt.MessageIDs))
	for i, id := range receipt.MessageIDs {
		messageIDs[i] = strconv.FormatInt(id, 10)
	}

	h.userNotify <- &UserNotification{
		UserID: senderID,
		Type:   "messages_read",
		Payload: &ReadReceiptPayload{
			ConversationID: receipt.ConversationID.String(),
			ReaderID:       receipt.ReaderID.String(),
			ReadAt:         receipt.ReadAt.Format(time.RFC3339),
			MessageIDs:     messageIDs,
		},
	}
}

func (h *Hub) IsUserOnline(userID uuid.UUID) bool {
	h.mu.RLock()
	defer h.mu.RUnlock()
	_, ok := h.clients[userID]
	return ok
}

func (h *Hub) GetOnlineCount() int {
	h.mu.RLock()
	defer h.mu.RUnlock()
	return len(h.clients)
}

func (h *Hub) SubscribeToConversation(client *Client, conversationID uuid.UUID) error {
	if h.chatService != nil {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		isMember, err := h.chatService.IsMember(ctx, conversationID, client.userID)
		if err != nil {
			log.Printf("[WebSocket] 验证会话成员身份失败: userID=%s, convID=%s, err=%v",
				client.userID, conversationID, err)
			return fmt.Errorf("验证成员身份失败")
		}
		if !isMember {
			log.Printf("[WebSocket] 非会话成员尝试订阅: userID=%s, convID=%s", client.userID, conversationID)
			return fmt.Errorf("您不是该会话的成员")
		}
	}

	h.mu.Lock()
	defer h.mu.Unlock()

	if _, ok := h.conversationClients[conversationID]; !ok {
		h.conversationClients[conversationID] = make(map[*Client]bool)
	}
	h.conversationClients[conversationID][client] = true

	client.mu.Lock()
	client.conversations[conversationID] = true
	client.mu.Unlock()

	return nil
}

func (h *Hub) UnsubscribeFromConversation(client *Client, conversationID uuid.UUID) {
	h.mu.Lock()
	defer h.mu.Unlock()

	if clients, ok := h.conversationClients[conversationID]; ok {
		delete(clients, client)
		if len(clients) == 0 {
			delete(h.conversationClients, conversationID)
		}
	}

	client.mu.Lock()
	delete(client.conversations, conversationID)
	client.mu.Unlock()
}

func (h *Hub) HandleWebSocket(w http.ResponseWriter, r *http.Request, userID uuid.UUID) {
	conn, err := h.upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("[WebSocket] 升级失败: userID=%s, err=%v", userID, err)
		return
	}

	client := &Client{
		hub:           h,
		conn:          conn,
		send:          make(chan []byte, clientSendBufferSize),
		userID:        userID,
		conversations: make(map[uuid.UUID]bool),
	}

	h.register <- client

	go client.writePump()
	go client.readPump()
}

func (c *Client) readPump() {
	defer func() {
		c.hub.unregister <- c
		c.conn.Close()
	}()

	c.conn.SetReadLimit(maxMessageSize)
	c.conn.SetReadDeadline(time.Now().Add(pongWait))
	c.conn.SetPongHandler(func(string) error {
		c.conn.SetReadDeadline(time.Now().Add(pongWait))
		return nil
	})

	for {
		_, message, err := c.conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("[WebSocket] 异常关闭: userID=%s, err=%v", c.userID, err)
			}
			return
		}

		var cmd WSCommand
		if err := json.Unmarshal(message, &cmd); err != nil {
			log.Printf("[WebSocket] 解析命令失败: userID=%s, err=%v", c.userID, err)
			c.sendError("parse_error", "无效的命令格式")
			continue
		}

		c.handleCommand(&cmd)
	}
}

func (c *Client) handleCommand(cmd *WSCommand) {
	switch cmd.Action {
	case "subscribe":
		c.handleSubscribe(cmd.ConversationID)
	case "unsubscribe":
		c.handleUnsubscribe(cmd.ConversationID)
	case "ping":
		c.sendJSON(WSMessage{Type: "pong", Payload: nil})
	default:
		log.Printf("[WebSocket] 未知命令: userID=%s, action=%s", c.userID, cmd.Action)
		c.sendError(cmd.Action, "未知的操作类型")
	}
}

func (c *Client) handleSubscribe(conversationIDStr string) {
	if conversationIDStr == "" {
		c.sendError("subscribe", "会话ID不能为空")
		return
	}

	convID, err := uuid.Parse(conversationIDStr)
	if err != nil {
		c.sendError("subscribe", "会话ID格式无效")
		return
	}

	if err := c.hub.SubscribeToConversation(c, convID); err != nil {
		c.sendError("subscribe", err.Error())
		return
	}

	c.sendJSON(WSMessage{Type: "subscribed", Payload: conversationIDStr})
}

func (c *Client) handleUnsubscribe(conversationIDStr string) {
	if conversationIDStr == "" {
		c.sendError("unsubscribe", "会话ID不能为空")
		return
	}

	convID, err := uuid.Parse(conversationIDStr)
	if err != nil {
		c.sendError("unsubscribe", "会话ID格式无效")
		return
	}

	c.hub.UnsubscribeFromConversation(c, convID)
	c.sendJSON(WSMessage{Type: "unsubscribed", Payload: conversationIDStr})
}

func (c *Client) writePump() {
	ticker := time.NewTicker(pingPeriod)
	defer func() {
		ticker.Stop()
		c.conn.Close()
	}()

	for {
		select {
		case message, ok := <-c.send:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if !ok {
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			if err := c.conn.WriteMessage(websocket.TextMessage, message); err != nil {
				log.Printf("[WebSocket] 写入失败: userID=%s, err=%v", c.userID, err)
				return
			}

		case <-ticker.C:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}

func (c *Client) sendJSON(msg WSMessage) {
	data, err := json.Marshal(msg)
	if err != nil {
		log.Printf("[WebSocket] 序列化消息失败: %v", err)
		return
	}

	select {
	case c.send <- data:
	default:
		log.Printf("[WebSocket] 用户 %s 发送缓冲区已满", c.userID)
	}
}

func (c *Client) sendError(action, message string) {
	c.sendJSON(WSMessage{
		Type: "error",
		Payload: map[string]string{
			"action":  action,
			"message": message,
		},
	})
}
