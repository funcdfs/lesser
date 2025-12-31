package server

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/lesser/chat/internal/config"
	"github.com/lesser/chat/internal/handler/ws"
	"github.com/lesser/chat/internal/middleware"
	"github.com/lesser/chat/internal/model"
	"github.com/lesser/chat/internal/service"
)

// HTTPServer HTTP 服务器结构体
type HTTPServer struct {
	config      *config.Config
	chatService *service.ChatService
	authClient  *service.AuthClient
	hub         *ws.Hub
	server      *http.Server
	router      *gin.Engine
}

// NewHTTPServer 创建新的 HTTP 服务器实例
func NewHTTPServer(cfg *config.Config, chatService *service.ChatService, authClient *service.AuthClient, hub *ws.Hub) *HTTPServer {
	// 根据环境设置 Gin 模式
	if cfg.IsProduction() {
		gin.SetMode(gin.ReleaseMode)
	}

	// Use customized Gin instance
	router := gin.New()
	router.Use(gin.Recovery())

	// Add Trace ID middleware
	router.Use(middleware.TraceMiddleware())

	// Add Zap Logger middleware (covers health check skipping log)
	router.Use(middleware.ZapLogger())

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
		authClient:  authClient,
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
	// 健康检查端点（无需认证）
	s.router.GET("/health", s.healthCheck)

	// API v1 路由组（需要认证）
	v1 := s.router.Group("/api/v1/chat")

	// 根据是否有 AuthClient 决定使用哪种认证方式
	if s.authClient != nil {
		v1.Use(middleware.AuthMiddleware(s.authClient))
	} else {
		// 开发模式：仅使用 X-User-ID header
		v1.Use(middleware.DevAuthMiddleware())
	}

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
		v1.POST("/conversations/:id/read", s.markAsRead)
		v1.POST("/conversations/:id/read/", s.markAsRead)

		// 标记到指定消息已读路由（Requirements: 2.6）
		v1.POST("/conversations/:id/read-up-to", s.markMessagesUpToAsRead)
		v1.POST("/conversations/:id/read-up-to/", s.markMessagesUpToAsRead)

		// 单条消息已读路由（Requirements: 2.5）
		v1.POST("/messages/:id/read", s.markMessageAsRead)
		v1.POST("/messages/:id/read/", s.markMessageAsRead)

		// 批量获取未读数路由（Requirements: 6.1）
		v1.GET("/unread-counts", s.getUnreadCounts)
		v1.GET("/unread-counts/", s.getUnreadCounts)

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
	// 从 context 获取用户ID（由认证中间件设置）
	userID, exists := middleware.GetUserID(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "需要用户ID"})
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

	// 从 context 获取创建者ID
	creatorID, exists := middleware.GetUserID(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "需要用户ID"})
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

	// 从 context 获取用户ID
	userID, exists := middleware.GetUserID(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "需要用户ID"})
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

	// 从 context 获取发送者ID
	senderID, exists := middleware.GetUserID(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "需要用户ID"})
		return
	}

	// 简单的字符串到 int 映射 (默认 text=0)
	var msgType model.MessageType
	switch req.MessageType {
	case "image":
		msgType = model.MessageTypeImage
	case "video":
		msgType = model.MessageTypeVideo
	case "link":
		msgType = model.MessageTypeLink
	case "file":
		msgType = model.MessageTypeFile
	case "system":
		msgType = model.MessageTypeSystem
	default:
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

	// 通过 WebSocket 广播消息给订阅了该会话的客户端（在聊天室内的用户）
	s.hub.BroadcastToConversation(convID, msg)

	// 异步获取会话成员并发送通知（不阻塞 HTTP 响应）
	go func() {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		memberIDs, err := s.chatService.GetConversationMemberIDs(ctx, convID)
		if err != nil {
			log.Printf("获取会话 %s 成员失败: %v", convID, err)
			return
		}

		// 向除发送者外的所有成员发送会话更新通知
		for _, memberID := range memberIDs {
			if memberID != senderID {
				// 获取该成员的真实未读数
				unreadCount, err := s.chatService.GetUnreadCount(ctx, convID, memberID)
				if err != nil {
					log.Printf("获取用户 %s 在会话 %s 的未读数失败: %v", memberID, convID, err)
					unreadCount = 1 // 降级为增量 1
				}

				s.hub.NotifyUser(memberID, "conversation_update", ws.ConversationUpdatePayload{
					ConversationID: convID.String(),
					LastMessage:    msg,
					UnreadCount:    int(unreadCount),
				})
			}
		}
	}()

	c.JSON(http.StatusCreated, msg)
}

// markAsRead 标记会话消息为已读
// POST /api/v1/chat/conversations/:id/read
// Requirements: 2.1, 3.1
func (s *HTTPServer) markAsRead(c *gin.Context) {
	convIDStr := c.Param("id")
	convID, err := uuid.Parse(convIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "会话ID格式无效"})
		return
	}

	// 从 context 获取用户ID
	userID, exists := middleware.GetUserID(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "需要用户ID"})
		return
	}

	receipt, err := s.chatService.MarkConversationAsRead(c.Request.Context(), convID, userID)
	if err != nil {
		if err == service.ErrNotMember {
			c.JSON(http.StatusForbidden, gin.H{"error": "您不是该会话的成员"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 通过 WebSocket 推送已读回执给消息发送者
	// 异步处理，不阻塞 HTTP 响应
	if receipt != nil && len(receipt.MessageIDs) > 0 {
		go func() {
			ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
			defer cancel()

			// 获取被标记消息的发送者ID列表（去重）
			senderIDs := s.getMessageSenderIDs(ctx, receipt.MessageIDs)
			for _, senderID := range senderIDs {
				if senderID != userID && s.hub.IsUserOnline(senderID) {
					s.hub.NotifyBatchReadReceipt(senderID, receipt)
				}
			}
		}()
	}

	c.JSON(http.StatusOK, gin.H{
		"message":     "已标记为已读",
		"marked_count": len(receipt.MessageIDs),
	})
}

// markMessageAsRead 标记单条消息为已读
// POST /api/v1/chat/messages/:id/read
// Requirements: 2.5
func (s *HTTPServer) markMessageAsRead(c *gin.Context) {
	msgIDStr := c.Param("id")
	msgID, err := strconv.ParseInt(msgIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "消息ID格式无效"})
		return
	}

	// 从 context 获取用户ID
	userID, exists := middleware.GetUserID(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "需要用户ID"})
		return
	}

	receipt, err := s.chatService.MarkMessageAsRead(c.Request.Context(), msgID, userID)
	if err != nil {
		switch err {
		case service.ErrNotMember:
			c.JSON(http.StatusForbidden, gin.H{"error": "您不是该会话的成员"})
		case service.ErrCannotMarkOwnMessage:
			c.JSON(http.StatusBadRequest, gin.H{"error": "不能标记自己发送的消息为已读"})
		case service.ErrAlreadyRead:
			c.JSON(http.StatusOK, gin.H{"message": "消息已被标记为已读"})
		case service.ErrMessageNotFound:
			c.JSON(http.StatusNotFound, gin.H{"error": "消息不存在"})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		}
		return
	}

	// 通过 WebSocket 推送已读回执给消息发送者
	// 异步处理，不阻塞 HTTP 响应
	if receipt != nil {
		go func() {
			ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
			defer cancel()

			// 获取消息发送者ID
			senderID := s.getMessageSenderID(ctx, receipt.MessageID)
			if senderID != uuid.Nil && senderID != userID && s.hub.IsUserOnline(senderID) {
				s.hub.NotifyReadReceipt(senderID, receipt)
			}
		}()
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "已标记为已读",
		"read_at":    receipt.ReadAt,
		"message_id": receipt.MessageID,
	})
}

// markMessagesUpToAsRead 标记到指定消息为已读
// POST /api/v1/chat/conversations/:id/read-up-to
// Requirements: 2.6
func (s *HTTPServer) markMessagesUpToAsRead(c *gin.Context) {
	convIDStr := c.Param("id")
	convID, err := uuid.Parse(convIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "会话ID格式无效"})
		return
	}

	// 从 context 获取用户ID
	userID, exists := middleware.GetUserID(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "需要用户ID"})
		return
	}

	// 解析请求体获取目标消息ID
	var req struct {
		MessageID string `json:"message_id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请求参数无效: " + err.Error()})
		return
	}

	upToMsgID, err := strconv.ParseInt(req.MessageID, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "消息ID格式无效"})
		return
	}

	receipt, err := s.chatService.MarkMessagesUpToAsRead(c.Request.Context(), convID, userID, upToMsgID)
	if err != nil {
		if err == service.ErrNotMember {
			c.JSON(http.StatusForbidden, gin.H{"error": "您不是该会话的成员"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 通过 WebSocket 推送已读回执给消息发送者
	// 异步处理，不阻塞 HTTP 响应
	if receipt != nil && len(receipt.MessageIDs) > 0 {
		go func() {
			ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
			defer cancel()

			// 获取被标记消息的发送者ID列表（去重）
			senderIDs := s.getMessageSenderIDs(ctx, receipt.MessageIDs)
			for _, senderID := range senderIDs {
				if senderID != userID && s.hub.IsUserOnline(senderID) {
					s.hub.NotifyBatchReadReceipt(senderID, receipt)
				}
			}
		}()
	}

	c.JSON(http.StatusOK, gin.H{
		"message":      "已标记为已读",
		"marked_count": len(receipt.MessageIDs),
		"up_to":        upToMsgID,
	})
}

// getUnreadCounts 批量获取未读数
// GET /api/v1/chat/unread-counts?conversation_ids=uuid1,uuid2,uuid3
// Requirements: 6.1
func (s *HTTPServer) getUnreadCounts(c *gin.Context) {
	// 从 context 获取用户ID
	userID, exists := middleware.GetUserID(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "需要用户ID"})
		return
	}

	// 解析会话ID列表
	convIDsStr := c.Query("conversation_ids")
	if convIDsStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "需要提供 conversation_ids 参数"})
		return
	}

	// 分割并解析会话ID
	convIDStrs := splitAndTrim(convIDsStr, ",")
	conversationIDs := make([]uuid.UUID, 0, len(convIDStrs))
	for _, idStr := range convIDStrs {
		if idStr == "" {
			continue
		}
		id, err := uuid.Parse(idStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "会话ID格式无效: " + idStr})
			return
		}
		conversationIDs = append(conversationIDs, id)
	}

	if len(conversationIDs) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "需要至少一个有效的会话ID"})
		return
	}

	counts, err := s.chatService.GetUnreadCounts(c.Request.Context(), userID, conversationIDs)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 转换为字符串键的 map（JSON 兼容）
	result := make(map[string]int64, len(counts))
	for convID, count := range counts {
		result[convID.String()] = count
	}

	c.JSON(http.StatusOK, gin.H{
		"unread_counts": result,
	})
}

// getMessageSenderID 获取单条消息的发送者ID
func (s *HTTPServer) getMessageSenderID(ctx context.Context, messageID int64) uuid.UUID {
	// 通过 chatService 获取消息信息
	// 这里简化处理，实际可以通过 repository 直接查询
	msg, err := s.chatService.GetMessageByID(ctx, messageID)
	if err != nil {
		log.Printf("获取消息 %d 发送者失败: %v", messageID, err)
		return uuid.Nil
	}
	return msg.SenderID
}

// getMessageSenderIDs 获取多条消息的发送者ID列表（去重）
func (s *HTTPServer) getMessageSenderIDs(ctx context.Context, messageIDs []int64) []uuid.UUID {
	senderMap := make(map[uuid.UUID]bool)
	for _, msgID := range messageIDs {
		senderID := s.getMessageSenderID(ctx, msgID)
		if senderID != uuid.Nil {
			senderMap[senderID] = true
		}
	}

	senders := make([]uuid.UUID, 0, len(senderMap))
	for senderID := range senderMap {
		senders = append(senders, senderID)
	}
	return senders
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

	// 从 context 获取添加者ID
	adderID, exists := middleware.GetUserID(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "需要用户ID"})
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

	// 从 context 获取移除者ID
	removerID, exists := middleware.GetUserID(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "需要用户ID"})
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

// splitAndTrim 分割字符串并去除空白
func splitAndTrim(s string, sep string) []string {
	parts := make([]string, 0)
	for _, part := range strings.Split(s, sep) {
		trimmed := strings.TrimSpace(part)
		if trimmed != "" {
			parts = append(parts, trimmed)
		}
	}
	return parts
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
