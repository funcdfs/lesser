// Package ws 提供 WebSocket 连接管理功能
// 包含 Hub（连接管理中心）和 Client（客户端连接）的实现
package ws

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"
	"github.com/lesser/chat/internal/config"
	"github.com/lesser/chat/internal/model"
	"github.com/lesser/chat/internal/service"
)

// ============================================================================
// 常量定义
// ============================================================================

const (
	// writeWait 写入消息的超时时间
	// 如果在此时间内无法写入消息，连接将被关闭
	writeWait = 10 * time.Second

	// pongWait 等待客户端 pong 响应的超时时间
	// 超过此时间未收到 pong，认为连接已断开
	pongWait = 60 * time.Second

	// pingPeriod 服务端发送 ping 的间隔
	// 必须小于 pongWait，确保在超时前能检测到连接状态
	pingPeriod = (pongWait * 9) / 10 // 54 秒

	// maxMessageSize 允许接收的最大消息大小（字节）
	// 防止恶意客户端发送超大消息导致内存溢出
	maxMessageSize = 4096

	// clientSendBufferSize 客户端发送缓冲区大小
	// 缓冲区满时新消息将被丢弃
	clientSendBufferSize = 256

	// broadcastBufferSize 广播通道缓冲区大小
	broadcastBufferSize = 256

	// notifyBufferSize 通知通道缓冲区大小
	notifyBufferSize = 256
)

// ============================================================================
// WebSocket 升级器
// ============================================================================

// createUpgrader 创建 WebSocket 协议升级器
func createUpgrader(cfg *config.Config) websocket.Upgrader {
	return websocket.Upgrader{
		ReadBufferSize:  1024,
		WriteBufferSize: 1024,
		// CheckOrigin 检查请求来源，防止跨站 WebSocket 劫持
		CheckOrigin: func(r *http.Request) bool {
			origin := r.Header.Get("Origin")
			// 无 Origin 头（同源请求）允许通过
			if origin == "" {
				return true
			}
			return cfg.IsOriginAllowed(origin)
		},
	}
}

// ============================================================================
// Client 客户端连接
// ============================================================================

// Client 表示一个 WebSocket 客户端连接
// 每个用户同时只能有一个活跃连接，新连接会踢掉旧连接
type Client struct {
	hub    *Hub            // 所属的 Hub
	conn   *websocket.Conn // WebSocket 连接
	send   chan []byte     // 发送消息的缓冲通道
	userID uuid.UUID       // 用户ID

	// conversations 该客户端订阅的会话集合
	// key: 会话ID, value: 是否订阅（始终为 true）
	conversations map[uuid.UUID]bool
	mu            sync.RWMutex // 保护 conversations 的并发访问
}

// ============================================================================
// Hub 连接管理中心
// ============================================================================

// Hub WebSocket 连接管理中心
// 职责：
// 1. 管理所有客户端连接的生命周期（注册/注销）
// 2. 维护会话订阅关系
// 3. 消息广播（向订阅了特定会话的客户端发送消息）
// 4. 用户通知（向特定用户发送通知，无需订阅）
type Hub struct {
	// clients 用户ID -> 客户端映射
	// 每个用户只能有一个活跃连接
	clients map[uuid.UUID]*Client

	// conversationClients 会话ID -> 订阅该会话的客户端集合
	// 用于高效地向会话内所有在线用户广播消息
	conversationClients map[uuid.UUID]map[*Client]bool

	// register 客户端注册通道
	register chan *Client

	// unregister 客户端注销通道
	unregister chan *Client

	// broadcast 消息广播通道
	// 向订阅了特定会话的所有客户端发送消息
	broadcast chan *BroadcastMessage

	// userNotify 用户通知通道
	// 向特定用户发送通知（不需要订阅会话）
	userNotify chan *UserNotification

	// chatService 聊天业务服务
	// 用于验证用户是否有权订阅某个会话
	chatService *service.ChatService

	// config 服务配置
	config *config.Config

	// upgrader WebSocket 升级器
	upgrader websocket.Upgrader

	// mu 保护 clients 和 conversationClients 的并发访问
	mu sync.RWMutex
}


// ============================================================================
// 消息结构定义
// ============================================================================

// BroadcastMessage 广播消息
// 发送给订阅了指定会话的所有客户端
type BroadcastMessage struct {
	ConversationID uuid.UUID      // 目标会话ID
	Message        *model.Message // 消息内容
}

// UserNotification 用户通知
// 发送给特定用户，不需要订阅会话
type UserNotification struct {
	UserID  uuid.UUID   // 目标用户ID
	Type    string      // 通知类型
	Payload interface{} // 通知内容
}

// WSMessage WebSocket 消息格式（服务端 -> 客户端）
type WSMessage struct {
	Type    string      `json:"type"`    // 消息类型
	Payload interface{} `json:"payload"` // 消息载荷
}

// WSCommand 客户端命令格式（客户端 -> 服务端）
type WSCommand struct {
	Action         string `json:"action"`                    // 操作类型: subscribe, unsubscribe
	ConversationID string `json:"conversation_id,omitempty"` // 会话ID
}

// ============================================================================
// Payload 结构定义
// ============================================================================

// ConversationUpdatePayload 会话更新通知载荷
type ConversationUpdatePayload struct {
	ConversationID string      `json:"conversation_id"`        // 会话ID
	LastMessage    interface{} `json:"last_message,omitempty"` // 最新消息
	UnreadCount    int         `json:"unread_count"`           // 未读数
}

// ReadReceiptPayload 已读回执载荷
type ReadReceiptPayload struct {
	MessageID      string   `json:"message_id,omitempty"`  // 单条消息ID
	ConversationID string   `json:"conversation_id"`       // 会话ID
	ReaderID       string   `json:"reader_id"`             // 阅读者ID
	ReadAt         string   `json:"read_at"`               // 已读时间（RFC3339）
	MessageIDs     []string `json:"message_ids,omitempty"` // 批量消息ID列表
}

// ============================================================================
// Hub 构造与运行
// ============================================================================

// NewHub 创建 WebSocket 连接管理中心
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

// Run 启动 Hub 主事件循环
// 必须在单独的 goroutine 中运行
// 通过 channel 串行处理所有事件，避免并发问题
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

// ============================================================================
// Hub 内部事件处理
// ============================================================================

// handleRegister 处理客户端注册
func (h *Hub) handleRegister(client *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()

	// 检查用户是否已有连接
	if oldClient, exists := h.clients[client.userID]; exists {
		// 踢掉旧连接
		h.cleanupClientLocked(oldClient)
		log.Printf("[WebSocket] 用户 %s 的旧连接已被踢掉", client.userID)
	}

	// 注册新连接
	h.clients[client.userID] = client
	log.Printf("[WebSocket] 用户 %s 已连接，当前在线: %d", client.userID, len(h.clients))
}

// handleUnregister 处理客户端注销
func (h *Hub) handleUnregister(client *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()

	// 检查是否是当前活跃的连接
	// 避免重复注销或注销错误的连接
	if currentClient, exists := h.clients[client.userID]; exists && currentClient == client {
		h.cleanupClientLocked(client)
		log.Printf("[WebSocket] 用户 %s 已断开，当前在线: %d", client.userID, len(h.clients))
	}
}

// cleanupClientLocked 清理客户端（必须持有 h.mu 锁）
func (h *Hub) cleanupClientLocked(client *Client) {
	// 从所有会话订阅中移除
	client.mu.RLock()
	for convID := range client.conversations {
		if clients, ok := h.conversationClients[convID]; ok {
			delete(clients, client)
			// 如果会话没有订阅者了，删除会话映射
			if len(clients) == 0 {
				delete(h.conversationClients, convID)
			}
		}
	}
	client.mu.RUnlock()

	// 从用户映射中删除
	delete(h.clients, client.userID)

	// 关闭发送通道（会触发 writePump 退出）
	close(client.send)
}

// handleBroadcast 处理消息广播
func (h *Hub) handleBroadcast(msg *BroadcastMessage) {
	h.mu.RLock()
	clientsMap, ok := h.conversationClients[msg.ConversationID]
	if !ok || len(clientsMap) == 0 {
		h.mu.RUnlock()
		return
	}

	// 复制客户端列表，避免持有锁时发送消息
	clients := make([]*Client, 0, len(clientsMap))
	for client := range clientsMap {
		clients = append(clients, client)
	}
	h.mu.RUnlock()

	// 序列化消息
	data, err := json.Marshal(WSMessage{
		Type:    "message",
		Payload: msg.Message,
	})
	if err != nil {
		log.Printf("[WebSocket] 序列化广播消息失败: %v", err)
		return
	}

	// 发送给所有订阅者
	for _, client := range clients {
		h.sendToClient(client, data)
	}
}

// handleUserNotify 处理用户通知
func (h *Hub) handleUserNotify(notify *UserNotification) {
	h.mu.RLock()
	client, ok := h.clients[notify.UserID]
	h.mu.RUnlock()

	if !ok {
		// 用户不在线，忽略通知
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

// sendToClient 向客户端发送消息（非阻塞）
func (h *Hub) sendToClient(client *Client, data []byte) {
	select {
	case client.send <- data:
		// 发送成功
	default:
		// 缓冲区已满，丢弃消息
		log.Printf("[WebSocket] 用户 %s 发送缓冲区已满，消息被丢弃", client.userID)
	}
}


// ============================================================================
// Hub 公开方法
// ============================================================================

// BroadcastToConversation 向会话广播消息
// 消息会发送给所有订阅了该会话的在线客户端
func (h *Hub) BroadcastToConversation(conversationID uuid.UUID, message *model.Message) {
	h.broadcast <- &BroadcastMessage{
		ConversationID: conversationID,
		Message:        message,
	}
}

// NotifyUser 向特定用户发送通知
// 用户必须在线才能收到通知
func (h *Hub) NotifyUser(userID uuid.UUID, notifyType string, payload interface{}) {
	h.userNotify <- &UserNotification{
		UserID:  userID,
		Type:    notifyType,
		Payload: payload,
	}
}

// NotifyReadReceipt 发送单条消息已读回执
func (h *Hub) NotifyReadReceipt(senderID uuid.UUID, receipt *model.ReadReceipt) {
	if receipt == nil {
		return
	}

	h.userNotify <- &UserNotification{
		UserID: senderID,
		Type:   "read_receipt",
		Payload: &ReadReceiptPayload{
			MessageID:      receipt.MessageID.String(),
			ConversationID: receipt.ConversationID.String(),
			ReaderID:       receipt.ReaderID.String(),
			ReadAt:         receipt.ReadAt.Format(time.RFC3339),
		},
	}
}

// NotifyBatchReadReceipt 发送批量已读回执
func (h *Hub) NotifyBatchReadReceipt(senderID uuid.UUID, receipt *model.BatchReadReceipt) {
	if receipt == nil || len(receipt.MessageIDs) == 0 {
		return
	}

	// 转换 UUID 列表为字符串列表
	messageIDs := make([]string, len(receipt.MessageIDs))
	for i, id := range receipt.MessageIDs {
		messageIDs[i] = id.String()
	}

	h.userNotify <- &UserNotification{
		UserID: senderID,
		Type:   "read_receipt_batch",
		Payload: &ReadReceiptPayload{
			ConversationID: receipt.ConversationID.String(),
			ReaderID:       receipt.ReaderID.String(),
			ReadAt:         receipt.ReadAt.Format(time.RFC3339),
			MessageIDs:     messageIDs,
		},
	}
}

// IsUserOnline 检查用户是否在线
func (h *Hub) IsUserOnline(userID uuid.UUID) bool {
	h.mu.RLock()
	defer h.mu.RUnlock()
	_, ok := h.clients[userID]
	return ok
}

// GetOnlineCount 获取当前在线用户数
func (h *Hub) GetOnlineCount() int {
	h.mu.RLock()
	defer h.mu.RUnlock()
	return len(h.clients)
}

// ============================================================================
// 会话订阅管理
// ============================================================================

// SubscribeToConversation 订阅会话
// 订阅后客户端会收到该会话的实时消息
func (h *Hub) SubscribeToConversation(client *Client, conversationID uuid.UUID) error {
	// 验证用户是否是会话成员
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

	// 添加到会话订阅映射
	if _, ok := h.conversationClients[conversationID]; !ok {
		h.conversationClients[conversationID] = make(map[*Client]bool)
	}
	h.conversationClients[conversationID][client] = true

	// 更新客户端的订阅列表
	client.mu.Lock()
	client.conversations[conversationID] = true
	client.mu.Unlock()

	return nil
}

// UnsubscribeFromConversation 取消订阅会话
func (h *Hub) UnsubscribeFromConversation(client *Client, conversationID uuid.UUID) {
	h.mu.Lock()
	defer h.mu.Unlock()

	// 从会话订阅映射中移除
	if clients, ok := h.conversationClients[conversationID]; ok {
		delete(clients, client)
		if len(clients) == 0 {
			delete(h.conversationClients, conversationID)
		}
	}

	// 更新客户端的订阅列表
	client.mu.Lock()
	delete(client.conversations, conversationID)
	client.mu.Unlock()
}

// ============================================================================
// WebSocket 连接处理
// ============================================================================

// HandleWebSocket 处理 WebSocket 连接升级请求
func (h *Hub) HandleWebSocket(w http.ResponseWriter, r *http.Request, userID uuid.UUID) {
	// 升级 HTTP 连接为 WebSocket
	conn, err := h.upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("[WebSocket] 升级失败: userID=%s, err=%v", userID, err)
		return
	}

	// 创建客户端实例
	client := &Client{
		hub:           h,
		conn:          conn,
		send:          make(chan []byte, clientSendBufferSize),
		userID:        userID,
		conversations: make(map[uuid.UUID]bool),
	}

	// 注册客户端
	h.register <- client

	// 启动读写协程
	go client.writePump()
	go client.readPump()
}


// ============================================================================
// Client 读写协程
// ============================================================================

// readPump 读取客户端消息
// 负责：
// 1. 接收客户端发送的命令（subscribe/unsubscribe）
// 2. 处理心跳（pong）
// 3. 检测连接断开
func (c *Client) readPump() {
	defer func() {
		c.hub.unregister <- c
		c.conn.Close()
	}()

	// 配置连接参数
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

		// 解析命令
		var cmd WSCommand
		if err := json.Unmarshal(message, &cmd); err != nil {
			log.Printf("[WebSocket] 解析命令失败: userID=%s, err=%v", c.userID, err)
			c.sendError("parse_error", "无效的命令格式")
			continue
		}

		// 处理命令
		c.handleCommand(&cmd)
	}
}

// handleCommand 处理客户端命令
func (c *Client) handleCommand(cmd *WSCommand) {
	switch cmd.Action {
	case "subscribe":
		c.handleSubscribe(cmd.ConversationID)

	case "unsubscribe":
		c.handleUnsubscribe(cmd.ConversationID)

	case "ping":
		// 客户端主动 ping，回复 pong
		c.sendJSON(WSMessage{Type: "pong", Payload: nil})

	default:
		log.Printf("[WebSocket] 未知命令: userID=%s, action=%s", c.userID, cmd.Action)
		c.sendError(cmd.Action, "未知的操作类型")
	}
}

// handleSubscribe 处理订阅命令
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

// handleUnsubscribe 处理取消订阅命令
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

// writePump 向客户端发送消息
// 负责：
// 1. 从 send 通道读取消息并发送
// 2. 定期发送 ping 保持连接
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
				// send 通道已关闭，发送关闭帧
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			if err := c.conn.WriteMessage(websocket.TextMessage, message); err != nil {
				log.Printf("[WebSocket] 写入失败: userID=%s, err=%v", c.userID, err)
				return
			}

		case <-ticker.C:
			// 发送 ping 保持连接
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}

// ============================================================================
// Client 辅助方法
// ============================================================================

// sendJSON 发送 JSON 消息
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

// sendError 发送错误消息
func (c *Client) sendError(action, message string) {
	c.sendJSON(WSMessage{
		Type: "error",
		Payload: map[string]string{
			"action":  action,
			"message": message,
		},
	})
}
