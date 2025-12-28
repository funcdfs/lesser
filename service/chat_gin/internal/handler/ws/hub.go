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

const (
	// Time allowed to write a message to the peer
	writeWait = 10 * time.Second

	// Time allowed to read the next pong message from the peer
	pongWait = 60 * time.Second

	// Send pings to peer with this period (must be less than pongWait)
	pingPeriod = (pongWait * 9) / 10

	// Maximum message size allowed from peer
	maxMessageSize = 4096
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		// In production, implement proper origin checking
		return true
	},
}

// Client represents a WebSocket client
type Client struct {
	hub    *Hub
	conn   *websocket.Conn
	send   chan []byte
	userID uuid.UUID
	// Conversations this client is subscribed to
	conversations map[uuid.UUID]bool
	mu            sync.RWMutex
}

// Hub maintains the set of active clients and broadcasts messages
type Hub struct {
	// Registered clients by user ID
	clients map[uuid.UUID]*Client

	// Clients by conversation ID for efficient broadcasting
	conversationClients map[uuid.UUID]map[*Client]bool

	// Register requests from clients
	register chan *Client

	// Unregister requests from clients
	unregister chan *Client

	// Broadcast messages to conversation
	broadcast chan *BroadcastMessage

	// Chat service for business logic
	chatService *service.ChatService

	mu sync.RWMutex
}

// BroadcastMessage represents a message to broadcast
type BroadcastMessage struct {
	ConversationID uuid.UUID
	Message        *model.Message
}

// NewHub creates a new Hub
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

// Run starts the hub's main loop
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

func (h *Hub) registerClient(client *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()

	// If user already has a connection, close the old one
	if oldClient, ok := h.clients[client.userID]; ok {
		close(oldClient.send)
		delete(h.clients, client.userID)
	}

	h.clients[client.userID] = client
	log.Printf("Client registered: %s", client.userID)
}

func (h *Hub) unregisterClient(client *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()

	if _, ok := h.clients[client.userID]; ok {
		// Remove from all conversation subscriptions
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
		log.Printf("Client unregistered: %s", client.userID)
	}
}

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
		log.Printf("Failed to marshal message: %v", err)
		return
	}

	for client := range clients {
		select {
		case client.send <- data:
		default:
			// Client's send buffer is full, skip
			log.Printf("Client %s send buffer full, skipping", client.userID)
		}
	}
}

// BroadcastToConversation broadcasts a message to all clients in a conversation
func (h *Hub) BroadcastToConversation(conversationID uuid.UUID, message *model.Message) {
	h.broadcast <- &BroadcastMessage{
		ConversationID: conversationID,
		Message:        message,
	}
}

// SubscribeToConversation subscribes a client to a conversation
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

	log.Printf("Client %s subscribed to conversation %s", client.userID, conversationID)
}

// UnsubscribeFromConversation unsubscribes a client from a conversation
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

	log.Printf("Client %s unsubscribed from conversation %s", client.userID, conversationID)
}

// HandleWebSocket handles WebSocket connections
func (h *Hub) HandleWebSocket(w http.ResponseWriter, r *http.Request, userID uuid.UUID) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("Failed to upgrade connection: %v", err)
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

	// Start goroutines for reading and writing
	go client.writePump()
	go client.readPump()
}

// WSMessage represents a WebSocket message
type WSMessage struct {
	Type    string      `json:"type"`
	Payload interface{} `json:"payload"`
}

// WSCommand represents a command from the client
type WSCommand struct {
	Action         string `json:"action"`
	ConversationID string `json:"conversation_id,omitempty"`
}

// readPump pumps messages from the WebSocket connection to the hub
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
				log.Printf("WebSocket error: %v", err)
			}
			break
		}

		// Parse command
		var cmd WSCommand
		if err := json.Unmarshal(message, &cmd); err != nil {
			log.Printf("Failed to parse command: %v", err)
			continue
		}

		// Handle command
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

// writePump pumps messages from the hub to the WebSocket connection
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
				// Hub closed the channel
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			w, err := c.conn.NextWriter(websocket.TextMessage)
			if err != nil {
				return
			}
			w.Write(message)

			// Add queued messages to the current WebSocket message
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

// sendJSON sends a JSON message to the client
func (c *Client) sendJSON(msg WSMessage) {
	data, err := json.Marshal(msg)
	if err != nil {
		log.Printf("Failed to marshal message: %v", err)
		return
	}

	select {
	case c.send <- data:
	default:
		log.Printf("Client %s send buffer full", c.userID)
	}
}
