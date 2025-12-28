package server

import (
	"context"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/lesser/chat/internal/config"
	"github.com/lesser/chat/internal/handler/ws"
	"github.com/lesser/chat/internal/model"
	"github.com/lesser/chat/internal/service"
)

// HTTPServer represents the HTTP server
type HTTPServer struct {
	config      *config.Config
	chatService *service.ChatService
	hub         *ws.Hub
	server      *http.Server
	router      *gin.Engine
}

// NewHTTPServer creates a new HTTP server
func NewHTTPServer(cfg *config.Config, chatService *service.ChatService, hub *ws.Hub) *HTTPServer {
	// Set Gin mode based on environment
	if cfg.IsProduction() {
		gin.SetMode(gin.ReleaseMode)
	}

	router := gin.Default()

	s := &HTTPServer{
		config:      cfg,
		chatService: chatService,
		hub:         hub,
		router:      router,
	}

	s.setupRoutes()

	s.server = &http.Server{
		Addr:    ":" + cfg.HTTPPort,
		Handler: router,
	}

	return s
}

// setupRoutes configures all HTTP routes
func (s *HTTPServer) setupRoutes() {
	// Health check
	s.router.GET("/health", s.healthCheck)

	// API v1 routes
	v1 := s.router.Group("/api/v1/chat")
	{
		// Hello endpoint for testing
		v1.GET("/hello", s.helloChat)
		
		// Conversations
		v1.GET("/conversations", s.getConversations)
		v1.POST("/conversations", s.createConversation)
		v1.GET("/conversations/:id", s.getConversation)

		// Messages
		v1.GET("/conversations/:id/messages", s.getMessages)
		v1.POST("/conversations/:id/messages", s.sendMessage)

		// Members
		v1.POST("/conversations/:id/members", s.addMember)
		v1.DELETE("/conversations/:id/members/:userId", s.removeMember)
	}

	// WebSocket endpoint
	s.router.GET("/ws/chat", s.handleWebSocket)
}

// Start starts the HTTP server
func (s *HTTPServer) Start() error {
	return s.server.ListenAndServe()
}

// Shutdown gracefully shuts down the server
func (s *HTTPServer) Shutdown(ctx context.Context) error {
	return s.server.Shutdown(ctx)
}

// Handler implementations

func (s *HTTPServer) healthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":  "healthy",
		"service": "chat",
	})
}

func (s *HTTPServer) helloChat(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"message": "Hello from Chat Service! 🚀",
		"service": "chat-gin",
		"version": "1.0.0",
		"features": []string{
			"private_chat",
			"group_chat",
			"channel_chat",
			"websocket_realtime",
		},
	})
}

func (s *HTTPServer) getConversations(c *gin.Context) {
	// Get user ID from header (in production, this would come from auth middleware)
	userIDStr := c.GetHeader("X-User-ID")
	if userIDStr == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user ID required"})
		return
	}

	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
		return
	}

	// Parse pagination
	page := parseIntQuery(c, "page", 1)
	pageSize := parseIntQuery(c, "page_size", 20)

	result, err := s.chatService.GetUserConversations(c.Request.Context(), userID, page, pageSize)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"conversations": result.Conversations,
		"pagination": gin.H{
			"page":      result.Page,
			"page_size": result.PageSize,
			"total":     result.Total,
		},
	})
}

func (s *HTTPServer) createConversation(c *gin.Context) {
	var req struct {
		Type      string   `json:"type" binding:"required"`
		Name      string   `json:"name"`
		MemberIDs []string `json:"member_ids" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get creator ID from header
	creatorIDStr := c.GetHeader("X-User-ID")
	if creatorIDStr == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user ID required"})
		return
	}

	creatorID, err := uuid.Parse(creatorIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
		return
	}

	// Parse member IDs
	memberIDs := make([]uuid.UUID, len(req.MemberIDs))
	for i, idStr := range req.MemberIDs {
		id, err := uuid.Parse(idStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid member ID: " + idStr})
			return
		}
		memberIDs[i] = id
	}

	// Parse conversation type
	convType := model.ConversationType(req.Type)

	conv, err := s.chatService.CreateConversation(c.Request.Context(), service.CreateConversationRequest{
		Type:      convType,
		Name:      req.Name,
		MemberIDs: memberIDs,
		CreatorID: creatorID,
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, conv)
}

func (s *HTTPServer) getConversation(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid conversation ID"})
		return
	}

	conv, err := s.chatService.GetConversation(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "conversation not found"})
		return
	}

	c.JSON(http.StatusOK, conv)
}

func (s *HTTPServer) getMessages(c *gin.Context) {
	convIDStr := c.Param("id")
	convID, err := uuid.Parse(convIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid conversation ID"})
		return
	}

	// Get user ID from header
	userIDStr := c.GetHeader("X-User-ID")
	if userIDStr == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user ID required"})
		return
	}

	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
		return
	}

	// Parse pagination
	page := parseIntQuery(c, "page", 1)
	pageSize := parseIntQuery(c, "page_size", 50)

	result, err := s.chatService.GetMessages(c.Request.Context(), convID, userID, page, pageSize)
	if err != nil {
		if err == service.ErrNotMember {
			c.JSON(http.StatusForbidden, gin.H{"error": "not a member of this conversation"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"messages": result.Messages,
		"pagination": gin.H{
			"page":      result.Page,
			"page_size": result.PageSize,
			"total":     result.Total,
		},
	})
}

func (s *HTTPServer) sendMessage(c *gin.Context) {
	convIDStr := c.Param("id")
	convID, err := uuid.Parse(convIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid conversation ID"})
		return
	}

	var req struct {
		Content     string `json:"content" binding:"required"`
		MessageType string `json:"message_type"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get sender ID from header
	senderIDStr := c.GetHeader("X-User-ID")
	if senderIDStr == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user ID required"})
		return
	}

	senderID, err := uuid.Parse(senderIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
		return
	}

	msgType := model.MessageType(req.MessageType)
	if msgType == "" {
		msgType = model.MessageTypeText
	}

	msg, err := s.chatService.SendMessage(c.Request.Context(), service.SendMessageRequest{
		ConversationID: convID,
		SenderID:       senderID,
		Content:        req.Content,
		MessageType:    msgType,
	})
	if err != nil {
		if err == service.ErrNotMember {
			c.JSON(http.StatusForbidden, gin.H{"error": "not a member of this conversation"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Broadcast message to WebSocket clients
	s.hub.BroadcastToConversation(convID, msg)

	c.JSON(http.StatusCreated, msg)
}

func (s *HTTPServer) addMember(c *gin.Context) {
	convIDStr := c.Param("id")
	convID, err := uuid.Parse(convIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid conversation ID"})
		return
	}

	var req struct {
		UserID string `json:"user_id" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID, err := uuid.Parse(req.UserID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
		return
	}

	// Get adder ID from header
	adderIDStr := c.GetHeader("X-User-ID")
	if adderIDStr == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user ID required"})
		return
	}

	adderID, err := uuid.Parse(adderIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
		return
	}

	if err := s.chatService.AddMember(c.Request.Context(), convID, userID, adderID); err != nil {
		if err == service.ErrNotMember {
			c.JSON(http.StatusForbidden, gin.H{"error": "not a member of this conversation"})
			return
		}
		if err == service.ErrCannotAddToPrivate {
			c.JSON(http.StatusBadRequest, gin.H{"error": "cannot add members to private conversations"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "member added"})
}

func (s *HTTPServer) removeMember(c *gin.Context) {
	convIDStr := c.Param("id")
	convID, err := uuid.Parse(convIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid conversation ID"})
		return
	}

	userIDStr := c.Param("userId")
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
		return
	}

	// Get remover ID from header
	removerIDStr := c.GetHeader("X-User-ID")
	if removerIDStr == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user ID required"})
		return
	}

	removerID, err := uuid.Parse(removerIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
		return
	}

	if err := s.chatService.RemoveMember(c.Request.Context(), convID, userID, removerID); err != nil {
		if err == service.ErrNotAuthorized {
			c.JSON(http.StatusForbidden, gin.H{"error": "not authorized to remove this member"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "member removed"})
}

func (s *HTTPServer) handleWebSocket(c *gin.Context) {
	// Get user ID from query parameter
	userIDStr := c.Query("user_id")
	if userIDStr == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user ID required"})
		return
	}

	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
		return
	}

	s.hub.HandleWebSocket(c.Writer, c.Request, userID)
}

// Helper functions

func parseIntQuery(c *gin.Context, key string, defaultValue int) int {
	if val := c.Query(key); val != "" {
		var result int
		if _, err := fmt.Sscanf(val, "%d", &result); err == nil {
			return result
		}
	}
	return defaultValue
}
