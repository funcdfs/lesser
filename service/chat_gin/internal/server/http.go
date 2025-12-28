package server

import (
	"context"
	"fmt"
	"net/http"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/lesser/chat/internal/config"
	"github.com/lesser/chat/internal/handler/ws"
	"github.com/lesser/chat/internal/model"
	"github.com/lesser/chat/internal/service"
)

// HTTPServer HTTP 服务器结构体
type HTTPServer struct {
	config      *config.Config
	chatService *service.ChatService
	hub         *ws.Hub
	server      *http.Server
	router      *gin.Engine
}

// NewHTTPServer 创建新的 HTTP 服务器实例
func NewHTTPServer(cfg *config.Config, chatService *service.ChatService, hub *ws.Hub) *HTTPServer {
	// 根据环境设置 Gin 模式
	if cfg.IsProduction() {
		gin.SetMode(gin.ReleaseMode)
	}

	router := gin.Default()

	// 禁用尾部斜杠重定向，避免 CORS 的 301 问题
	router.RedirectTrailingSlash = false

	// CORS 中间件配置 - 处理 OPTIONS 预检请求
	router.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization", "X-Requested-With", "Accept", "X-User-ID"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           86400,
	}))

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


// setupRoutes 配置所有 HTTP 路由
func (s *HTTPServer) setupRoutes() {
	// 健康检查端点
	s.router.GET("/health", s.healthCheck)

	// API v1 路由组
	v1 := s.router.Group("/api/v1/chat")
	{
		// 测试端点
		v1.GET("/hello", s.helloChat)

		// 会话相关路由（支持带/不带尾部斜杠）
		v1.GET("/conversations", s.getConversations)
		v1.GET("/conversations/", s.getConversations)
		v1.POST("/conversations", s.createConversation)
		v1.POST("/conversations/", s.createConversation)
		v1.GET("/conversations/:id", s.getConversation)
		v1.GET("/conversations/:id/", s.getConversation)

		// 消息相关路由（支持带/不带尾部斜杠）
		v1.GET("/conversations/:id/messages", s.getMessages)
		v1.GET("/conversations/:id/messages/", s.getMessages)
		v1.POST("/conversations/:id/messages", s.sendMessage)
		v1.POST("/conversations/:id/messages/", s.sendMessage)

		// 成员管理路由（支持带/不带尾部斜杠）
		v1.POST("/conversations/:id/members", s.addMember)
		v1.POST("/conversations/:id/members/", s.addMember)
		v1.DELETE("/conversations/:id/members/:userId", s.removeMember)
		v1.DELETE("/conversations/:id/members/:userId/", s.removeMember)
	}

	// WebSocket 端点
	s.router.GET("/ws/chat", s.handleWebSocket)
}

// Start 启动 HTTP 服务器
func (s *HTTPServer) Start() error {
	return s.server.ListenAndServe()
}

// Shutdown 优雅关闭服务器
func (s *HTTPServer) Shutdown(ctx context.Context) error {
	return s.server.Shutdown(ctx)
}

// healthCheck 健康检查处理器
func (s *HTTPServer) healthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":  "healthy",
		"service": "chat",
	})
}

// helloChat 测试端点处理器
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

// getConversations 获取用户的会话列表
func (s *HTTPServer) getConversations(c *gin.Context) {
	// 从请求头获取用户ID（生产环境应从认证中间件获取）
	userIDStr := c.GetHeader("X-User-ID")
	if userIDStr == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "需要用户ID"})
		return
	}

	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "用户ID格式无效"})
		return
	}

	// 解析分页参数
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

// createConversation 创建新会话
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

	// 从请求头获取创建者ID
	creatorIDStr := c.GetHeader("X-User-ID")
	if creatorIDStr == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "需要用户ID"})
		return
	}

	creatorID, err := uuid.Parse(creatorIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "用户ID格式无效"})
		return
	}

	// 解析成员ID列表
	memberIDs := make([]uuid.UUID, len(req.MemberIDs))
	for i, idStr := range req.MemberIDs {
		id, err := uuid.Parse(idStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "成员ID格式无效: " + idStr})
			return
		}
		memberIDs[i] = id
	}

	// 解析会话类型
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

// getConversation 获取单个会话详情
func (s *HTTPServer) getConversation(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "会话ID格式无效"})
		return
	}

	conv, err := s.chatService.GetConversation(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "会话不存在"})
		return
	}

	c.JSON(http.StatusOK, conv)
}


// getMessages 获取会话的消息列表
func (s *HTTPServer) getMessages(c *gin.Context) {
	convIDStr := c.Param("id")
	convID, err := uuid.Parse(convIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "会话ID格式无效"})
		return
	}

	// 从请求头获取用户ID
	userIDStr := c.GetHeader("X-User-ID")
	if userIDStr == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "需要用户ID"})
		return
	}

	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "用户ID格式无效"})
		return
	}

	// 解析分页参数
	page := parseIntQuery(c, "page", 1)
	pageSize := parseIntQuery(c, "page_size", 50)

	result, err := s.chatService.GetMessages(c.Request.Context(), convID, userID, page, pageSize)
	if err != nil {
		if err == service.ErrNotMember {
			c.JSON(http.StatusForbidden, gin.H{"error": "您不是该会话的成员"})
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

// sendMessage 发送消息
func (s *HTTPServer) sendMessage(c *gin.Context) {
	convIDStr := c.Param("id")
	convID, err := uuid.Parse(convIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "会话ID格式无效"})
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

	// 从请求头获取发送者ID
	senderIDStr := c.GetHeader("X-User-ID")
	if senderIDStr == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "需要用户ID"})
		return
	}

	senderID, err := uuid.Parse(senderIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "用户ID格式无效"})
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
			c.JSON(http.StatusForbidden, gin.H{"error": "您不是该会话的成员"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 通过 WebSocket 广播消息给会话中的所有客户端
	s.hub.BroadcastToConversation(convID, msg)

	c.JSON(http.StatusCreated, msg)
}

// addMember 添加会话成员
func (s *HTTPServer) addMember(c *gin.Context) {
	convIDStr := c.Param("id")
	convID, err := uuid.Parse(convIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "会话ID格式无效"})
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
		c.JSON(http.StatusBadRequest, gin.H{"error": "用户ID格式无效"})
		return
	}

	// 从请求头获取添加者ID
	adderIDStr := c.GetHeader("X-User-ID")
	if adderIDStr == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "需要用户ID"})
		return
	}

	adderID, err := uuid.Parse(adderIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "用户ID格式无效"})
		return
	}

	if err := s.chatService.AddMember(c.Request.Context(), convID, userID, adderID); err != nil {
		if err == service.ErrNotMember {
			c.JSON(http.StatusForbidden, gin.H{"error": "您不是该会话的成员"})
			return
		}
		if err == service.ErrCannotAddToPrivate {
			c.JSON(http.StatusBadRequest, gin.H{"error": "无法向私聊会话添加成员"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "成员添加成功"})
}

// removeMember 移除会话成员
func (s *HTTPServer) removeMember(c *gin.Context) {
	convIDStr := c.Param("id")
	convID, err := uuid.Parse(convIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "会话ID格式无效"})
		return
	}

	userIDStr := c.Param("userId")
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "用户ID格式无效"})
		return
	}

	// 从请求头获取移除者ID
	removerIDStr := c.GetHeader("X-User-ID")
	if removerIDStr == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "需要用户ID"})
		return
	}

	removerID, err := uuid.Parse(removerIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "用户ID格式无效"})
		return
	}

	if err := s.chatService.RemoveMember(c.Request.Context(), convID, userID, removerID); err != nil {
		if err == service.ErrNotAuthorized {
			c.JSON(http.StatusForbidden, gin.H{"error": "您无权移除该成员"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "成员移除成功"})
}

// handleWebSocket 处理 WebSocket 连接
func (s *HTTPServer) handleWebSocket(c *gin.Context) {
	// 从查询参数获取用户ID
	userIDStr := c.Query("user_id")
	if userIDStr == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "需要用户ID"})
		return
	}

	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "用户ID格式无效"})
		return
	}

	s.hub.HandleWebSocket(c.Writer, c.Request, userID)
}

// parseIntQuery 解析整数类型的查询参数
func parseIntQuery(c *gin.Context, key string, defaultValue int) int {
	if val := c.Query(key); val != "" {
		var result int
		if _, err := fmt.Sscanf(val, "%d", &result); err == nil {
			return result
		}
	}
	return defaultValue
}
