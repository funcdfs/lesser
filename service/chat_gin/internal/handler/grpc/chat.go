package grpc

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/lesser/chat/internal/auth"
	"github.com/lesser/chat/internal/model"
	"github.com/lesser/chat/internal/service"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// ChatHandler gRPC 聊天服务处理器
type ChatHandler struct {
	chatService *service.ChatService
}

// NewChatHandler 创建新的 gRPC 聊天处理器
func NewChatHandler(chatService *service.ChatService) *ChatHandler {
	return &ChatHandler{
		chatService: chatService,
	}
}

// Register 将处理器注册到 gRPC 服务器
func (h *ChatHandler) Register(server *grpc.Server) {
	RegisterChatServiceServer(server, h)
}

// GetConversations 获取用户的所有会话列表
func (h *ChatHandler) GetConversations(ctx context.Context, req *GetConversationsRequest) (*ConversationsResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "用户ID不能为空")
	}

	userID, err := uuid.Parse(req.UserId)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "用户ID格式无效")
	}

	page := int(req.Pagination.GetPage())
	if page < 1 {
		page = 1
	}
	pageSize := int(req.Pagination.GetPageSize())
	if pageSize < 1 {
		pageSize = 20
	}
   // 分页就是把“大餐”切成“小块”（比如每页20条），让服务器和客户端都能“吃得消”。
	result, err := h.chatService.GetUserConversations(ctx, userID, page, pageSize)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	conversations := make([]*Conversation, len(result.Conversations))
	for i, conv := range result.Conversations {
		conversations[i] = modelToProtoConversation(&conv)
	}

	return &ConversationsResponse{
		Conversations: conversations,
		Pagination: &Pagination{
			Page:     int32(result.Page),
			PageSize: int32(result.PageSize),
			Total:    int32(result.Total),
		},
	}, nil
}

// GetConversation 根据ID获取单个会话
func (h *ChatHandler) GetConversation(ctx context.Context, req *GetConversationRequest) (*Conversation, error) {
	if req.ConversationId == "" {
		return nil, status.Error(codes.InvalidArgument, "会话ID不能为空")
	}

	convID, err := uuid.Parse(req.ConversationId)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "会话ID格式无效")
	}

	conv, err := h.chatService.GetConversation(ctx, convID)
	if err != nil {
		return nil, status.Error(codes.NotFound, "会话不存在")
	}

	return modelToProtoConversation(conv), nil
}

// CreateConversation 创建新会话
func (h *ChatHandler) CreateConversation(ctx context.Context, req *CreateConversationRequest) (*Conversation, error) {
	if req.CreatorId == "" {
		return nil, status.Error(codes.InvalidArgument, "创建者用户 ID 不能为空")
	}
	if len(req.MemberIds) == 0 {
		return nil, status.Error(codes.InvalidArgument, "成员用户 ID 列表不能为空")
	}

	creatorID, err := uuid.Parse(req.CreatorId)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "创建者用户 ID 格式无效")
	}

	memberIDs := make([]uuid.UUID, len(req.MemberIds))
	for i, idStr := range req.MemberIds {
		id, err := uuid.Parse(idStr)
		if err != nil {
			return nil, status.Errorf(codes.InvalidArgument, "成员用户 ID 格式无效: %s", idStr)
		}
		memberIDs[i] = id
	}

	convType := protoToModelConversationType(req.Type)

	// 构造服务层请求对象 service.CreateConversationRequest
	conv, err := h.chatService.CreateConversation(ctx, service.CreateConversationRequest{
		Type:      convType,
		Name:      req.Name,
		MemberIDs: memberIDs,   
		CreatorID: creatorID,
	})
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	return modelToProtoConversation(conv), nil
}

// GetMessages 获取会话的消息列表
func (h *ChatHandler) GetMessages(ctx context.Context, req *GetMessagesRequest) (*MessagesResponse, error) {
	if req.ConversationId == "" {
		return nil, status.Error(codes.InvalidArgument, "会话 ID 不能为空")
	}

	convID, err := uuid.Parse(req.ConversationId)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "会话 ID 格式无效")
	}

	// 从认证上下文获取用户 ID
	userID, ok := auth.GetUserIDFromContext(ctx)
	if !ok {
		return nil, status.Error(codes.Unauthenticated, "需要认证")
	}

	page := int(req.Pagination.GetPage())
	if page < 1 {
		page = 1
	}
	pageSize := int(req.Pagination.GetPageSize())
	if pageSize < 1 {
		pageSize = 50
	}

	result, err := h.chatService.GetMessages(ctx, convID, userID, page, pageSize)
	if err != nil {
		if err == service.ErrNotMember {
			return nil, status.Error(codes.PermissionDenied, "您不是该会话的成员")
		}
		return nil, status.Error(codes.Internal, err.Error())
	}

	messages := make([]*Message, len(result.Messages))
	for i, msg := range result.Messages {
		messages[i] = modelToProtoMessage(&msg)
	}

	return &MessagesResponse{
		Messages: messages,
		Pagination: &Pagination{
			Page:     int32(result.Page),
			PageSize: int32(result.PageSize),
			Total:    int32(result.Total),
		},
	}, nil
}

// SendMessage 发送消息到会话
func (h *ChatHandler) SendMessage(ctx context.Context, req *SendMessageRequest) (*Message, error) {
	if req.ConversationId == "" {
		return nil, status.Error(codes.InvalidArgument, "会话ID不能为空")
	}
	if req.SenderId == "" {
		return nil, status.Error(codes.InvalidArgument, "发送者ID不能为空")
	}
	if req.Content == "" {
		return nil, status.Error(codes.InvalidArgument, "消息内容不能为空")
	}

	convID, err := uuid.Parse(req.ConversationId)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "会话ID格式无效")
	}

	senderID, err := uuid.Parse(req.SenderId)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "发送者ID格式无效")
	}

	msgType := model.MessageType(req.MessageType)
	if msgType == "" {
		msgType = model.MessageTypeText
	}

	msg, err := h.chatService.SendMessage(ctx, service.SendMessageRequest{
		ConversationID: convID,
		SenderID:       senderID,
		Content:        req.Content,
		MessageType:    msgType,
	})
	if err != nil {
		if err == service.ErrNotMember {
			return nil, status.Error(codes.PermissionDenied, "您不是该会话的成员")
		}
		return nil, status.Error(codes.Internal, err.Error())
	}

	return modelToProtoMessage(msg), nil
}

// StreamMessages 实时消息流（服务端流式 RPC）
func (h *ChatHandler) StreamMessages(req *StreamRequest, stream ChatService_StreamMessagesServer) error {
	if req.UserId == "" {
		return status.Error(codes.InvalidArgument, "用户ID不能为空")
	}

	userID, err := uuid.Parse(req.UserId)
	if err != nil {
		return status.Error(codes.InvalidArgument, "用户ID格式无效")
	}

	// 这是一个占位实现
	// 生产环境中应订阅 Redis pub/sub 或类似机制
	_ = userID

	// 保持流连接直到客户端断开
	<-stream.Context().Done()
	return nil
}

// 类型转换辅助函数

// modelToProtoConversation 将模型会话转换为 Proto 会话
func modelToProtoConversation(conv *model.Conversation) *Conversation {
	memberIDs := make([]string, len(conv.Members))
	for i, m := range conv.Members {
		memberIDs[i] = m.UserID.String()
	}

	protoConv := &Conversation{
		Id:        conv.ID.String(),
		Type:      modelToProtoConversationType(conv.Type),
		Name:      conv.Name,
		MemberIds: memberIDs,
		CreatorId: conv.CreatorID.String(),
		CreatedAt: &Timestamp{
			Seconds: conv.CreatedAt.Unix(),
			Nanos:   int32(conv.CreatedAt.Nanosecond()),
		},
	}

	if conv.LastMessage != nil {
		protoConv.LastMessage = modelToProtoMessage(conv.LastMessage)
	}

	return protoConv
}

// modelToProtoMessage 将模型消息转换为 Proto 消息
func modelToProtoMessage(msg *model.Message) *Message {
	return &Message{
		Id:             msg.ID.String(),
		ConversationId: msg.ConversationID.String(),
		SenderId:       msg.SenderID.String(),
		Content:        msg.Content,
		MessageType:    string(msg.MessageType),
		CreatedAt: &Timestamp{
			Seconds: msg.CreatedAt.Unix(),
			Nanos:   int32(msg.CreatedAt.Nanosecond()),
		},
	}
}

// modelToProtoConversationType 将模型会话类型转换为 Proto 会话类型
func modelToProtoConversationType(t model.ConversationType) ConversationType {
	switch t {
	case model.ConversationTypePrivate:
		return ConversationType_PRIVATE
	case model.ConversationTypeGroup:
		return ConversationType_GROUP
	case model.ConversationTypeChannel:
		return ConversationType_CHANNEL
	default:
		return ConversationType_PRIVATE
	}
}

// protoToModelConversationType 将 Proto 会话类型转换为模型会话类型
func protoToModelConversationType(t ConversationType) model.ConversationType {
	switch t {
	case ConversationType_PRIVATE:
		return model.ConversationTypePrivate
	case ConversationType_GROUP:
		return model.ConversationTypeGroup
	case ConversationType_CHANNEL:
		return model.ConversationTypeChannel
	default:
		return model.ConversationTypePrivate
	}
}

// protoTimestampToTime 将 Proto 时间戳转换为 Go time.Time
func protoTimestampToTime(ts *Timestamp) time.Time {
	if ts == nil {
		return time.Time{}
	}
	return time.Unix(ts.Seconds, int64(ts.Nanos))
}
