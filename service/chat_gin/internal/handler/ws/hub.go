package ws

import (
	"encoding/json"
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"
	"github.com/lesser/chat/internal/model"
	"github.com/lesser/chat/internal/service"
)

// WebSocket 连接配置常量
const (
	// writeWait 写入消息的超时时间
	writeWait = 10 * time.Second

	// pongWait 等待 pong 响应的超时时间
	pongWait = 60 * time.Second

	// pingPeriod 发送 ping 的间隔（必须小于 pongWait）
	pingPeriod = (pongWait * 9) / 10

	// maxMessageSize 允许接收的最大消息大小
	maxMessageSize = 4096
)

// upgrader WebSocket 升级器配置
var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		// 生产环境中应实现正确的来源检查
		return true
	},
}

// Client WebSocket 客户端连接
type Client struct {
	hub    *Hub
	conn   *websocket.Conn
	send   chan []byte
	userID uuid.UUID
	// 该客户端订阅的会话列表
	conversations map[uuid.UUID]bool
	mu            sync.RWMutex
}

// Hub WebSocket 连接管理中心
// 维护所有活跃的客户端连接并负责消息广播
type Hub struct {
	// 按用户ID索引的客户端映射
	clients map[uuid.UUID]*Client

	// 按会话ID索引的客户端映射（用于高效广播）
	conversationClients map[uuid.UUID]map[*Client]bool

	// 客户端注册请求通道
	register chan *Client

	// 客户端注销请求通道
	unregister chan *Client

	// 消息广播通道
	broadcast chan *BroadcastMessage

	// 聊天业务服务
	chatService *service.ChatService

	mu sync.RWMutex
}

// BroadcastMessage 广播消息结构
type BroadcastMessage struct {
	ConversationID uuid.UUID      // 目标会话ID
	Message        *model.Message // 消息内容
}

// NewHub 创建新的 WebSocket 连接管理中心
func NewHub(chatService *service.ChatService) *Hub {
	return &Hub{
		clients:             make(map[uuid.UUID]*Client),
		conversationClients: make(map[uuid.UUID]map[*Client]bool),
		register:            make(chan *Client),
		unregister:          make(chan *Client),
		broadcast:           make(chan *BroadcastMessage, 256),
		chatService:         chatService,
	}
}

// Run 启动 Hub 的主事件循环
func (h *Hub) Run() {
	for {
		select {
		case client := <-h.register:
			h.registerClient(client)

		case client := <-h.unregister:
			h.unregisterClient(client)

		case msg := <-h.broadcast:
			h.broadcastMessage(msg)
		}
	}
}

// registerClient 注册新客户端
func (h *Hub) registerClient(client *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()

	// 如果用户已有连接，关闭旧连接
	if oldClient, ok := h.clients[client.userID]; ok {
		close(oldClient.send)
		delete(h.clients, client.userID)
	}

	h.clients[client.userID] = client
	log.Printf("客户端已注册: %s", client.userID)
}

// unregisterClient 注销客户端
func (h *Hub) unregisterClient(client *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()

	if _, ok := h.clients[client.userID]; ok {
		// 从所有会话订阅中移除
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
		log.Printf("客户端已注销: %s", client.userID)
	}
}

// broadcastMessage 广播消息到会话中的所有客户端
func (h *Hub) broadcastMessage(msg *BroadcastMessage) {
	h.mu.RLock()
	clients, ok := h.conversationClients[msg.ConversationID]
	h.mu.RUnlock()

	if !ok {
		return
	}

	data, err := json.Marshal(WSMessage{
		Type:    "message",
		Payload: msg.Message,
	})
	if err != nil {
		log.Printf("序列化消息失败: %v", err)
		return
	}

	for client := range clients {
		select {
		case client.send <- data:
		default:
			// 客户端发送缓冲区已满，跳过
			log.Printf("客户端 %s 发送缓冲区已满，跳过", client.userID)
		}
	}
}

// BroadcastToConversation 向会话中的所有客户端广播消息
func (h *Hub) BroadcastToConversation(conversationID uuid.UUID, message *model.Message) {
	h.broadcast <- &BroadcastMessage{
		ConversationID: conversationID,
		Message:        message,
	}
}

// SubscribeToConversation 订阅客户端到指定会话
func (h *Hub) SubscribeToConversation(client *Client, conversationID uuid.UUID) {
	h.mu.Lock()
	defer h.mu.Unlock()

	if _, ok := h.conversationClients[conversationID]; !ok {
		h.conversationClients[conversationID] = make(map[*Client]bool)
	}
	h.conversationClients[conversationID][client] = true

	client.mu.Lock()
	client.conversations[conversationID] = true
	client.mu.Unlock()

	log.Printf("客户端 %s 已订阅会话 %s", client.userID, conversationID)
}

// UnsubscribeFromConversation 取消客户端对指定会话的订阅
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

	log.Printf("客户端 %s 已取消订阅会话 %s", client.userID, conversationID)
}

// HandleWebSocket 处理 WebSocket 连接升级
func (h *Hub) HandleWebSocket(w http.ResponseWriter, r *http.Request, userID uuid.UUID) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("升级 WebSocket 连接失败: %v", err)
		return
	}

	client := &Client{
		hub:           h,
		conn:          conn,
		send:          make(chan []byte, 256),
		userID:        userID,
		conversations: make(map[uuid.UUID]bool),
	}

	h.register <- client

	// 启动读写协程
	go client.writePump()
	go client.readPump()
}

// WSMessage WebSocket 消息格式
type WSMessage struct {
	Type    string      `json:"type"`    // 消息类型
	Payload interface{} `json:"payload"` // 消息载荷
}

// WSCommand 客户端发送的命令格式
type WSCommand struct {
	Action         string `json:"action"`                    // 操作类型
	ConversationID string `json:"conversation_id,omitempty"` // 会话ID（可选）
}

// readPump 从 WebSocket 连接读取消息
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
				log.Printf("WebSocket 错误: %v", err)
			}
			break
		}

		// 解析命令
		var cmd WSCommand
		if err := json.Unmarshal(message, &cmd); err != nil {
			log.Printf("解析命令失败: %v", err)
			continue
		}

		// 处理命令
		switch cmd.Action {
		case "subscribe":
			if convID, err := uuid.Parse(cmd.ConversationID); err == nil {
				c.hub.SubscribeToConversation(c, convID)
				c.sendJSON(WSMessage{Type: "subscribed", Payload: cmd.ConversationID})
			}
		case "unsubscribe":
			if convID, err := uuid.Parse(cmd.ConversationID); err == nil {
				c.hub.UnsubscribeFromConversation(c, convID)
				c.sendJSON(WSMessage{Type: "unsubscribed", Payload: cmd.ConversationID})
			}
		}
	}
}

// writePump 向 WebSocket 连接写入消息
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
				// Hub 关闭了通道
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			w, err := c.conn.NextWriter(websocket.TextMessage)
			if err != nil {
				return
			}
			w.Write(message)

			// 将队列中的消息合并到当前 WebSocket 消息
			n := len(c.send)
			for i := 0; i < n; i++ {
				w.Write([]byte{'\n'})
				w.Write(<-c.send)
			}

			if err := w.Close(); err != nil {
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

// sendJSON 向客户端发送 JSON 消息
func (c *Client) sendJSON(msg WSMessage) {
	data, err := json.Marshal(msg)
	if err != nil {
		log.Printf("序列化消息失败: %v", err)
		return
	}

	select {
	case c.send <- data:
	default:
		log.Printf("客户端 %s 发送缓冲区已满", c.userID)
	}
}
