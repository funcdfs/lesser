package grpc

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/lesser/chat/internal/model"
	"github.com/lesser/chat/internal/service"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// ChatHandler implements the gRPC ChatService
type ChatHandler struct {
	chatService *service.ChatService
	UnimplementedChatServiceServer
}

// NewChatHandler creates a new ChatHandler
func NewChatHandler(chatService *service.ChatService) *ChatHandler {
	return &ChatHandler{
		chatService: chatService,
	}
}

// Register registers the handler with a gRPC server
func (h *ChatHandler) Register(server *grpc.Server) {
	RegisterChatServiceServer(server, h)
}

// GetConversations retrieves all conversations for a user
func (h *ChatHandler) GetConversations(ctx context.Context, req *GetConversationsRequest) (*ConversationsResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id is required")
	}

	userID, err := uuid.Parse(req.UserId)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "invalid user_id")
	}

	page := int(req.Pagination.GetPage())
	if page < 1 {
		page = 1
	}
	pageSize := int(req.Pagination.GetPageSize())
	if pageSize < 1 {
		pageSize = 20
	}

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

// GetConversation retrieves a single conversation by ID
func (h *ChatHandler) GetConversation(ctx context.Context, req *GetConversationRequest) (*Conversation, error) {
	if req.ConversationId == "" {
		return nil, status.Error(codes.InvalidArgument, "conversation_id is required")
	}

	convID, err := uuid.Parse(req.ConversationId)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "invalid conversation_id")
	}

	conv, err := h.chatService.GetConversation(ctx, convID)
	if err != nil {
		return nil, status.Error(codes.NotFound, "conversation not found")
	}

	return modelToProtoConversation(conv), nil
}

// CreateConversation creates a new conversation
func (h *ChatHandler) CreateConversation(ctx context.Context, req *CreateConversationRequest) (*Conversation, error) {
	if req.CreatorId == "" {
		return nil, status.Error(codes.InvalidArgument, "creator_id is required")
	}
	if len(req.MemberIds) == 0 {
		return nil, status.Error(codes.InvalidArgument, "member_ids is required")
	}

	creatorID, err := uuid.Parse(req.CreatorId)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "invalid creator_id")
	}

	memberIDs := make([]uuid.UUID, len(req.MemberIds))
	for i, idStr := range req.MemberIds {
		id, err := uuid.Parse(idStr)
		if err != nil {
			return nil, status.Errorf(codes.InvalidArgument, "invalid member_id: %s", idStr)
		}
		memberIDs[i] = id
	}

	convType := protoToModelConversationType(req.Type)

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

// GetMessages retrieves messages for a conversation
func (h *ChatHandler) GetMessages(ctx context.Context, req *GetMessagesRequest) (*MessagesResponse, error) {
	if req.ConversationId == "" {
		return nil, status.Error(codes.InvalidArgument, "conversation_id is required")
	}

	convID, err := uuid.Parse(req.ConversationId)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "invalid conversation_id")
	}

	// Note: In production, get user ID from auth context
	// For now, we'll skip the membership check in gRPC
	page := int(req.Pagination.GetPage())
	if page < 1 {
		page = 1
	}
	pageSize := int(req.Pagination.GetPageSize())
	if pageSize < 1 {
		pageSize = 50
	}

	// Use a placeholder user ID for internal gRPC calls
	// In production, this should come from the auth context
	result, err := h.chatService.GetMessages(ctx, convID, uuid.Nil, page, pageSize)
	if err != nil {
		if err == service.ErrNotMember {
			return nil, status.Error(codes.PermissionDenied, "not a member of this conversation")
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

// SendMessage sends a message to a conversation
func (h *ChatHandler) SendMessage(ctx context.Context, req *SendMessageRequest) (*Message, error) {
	if req.ConversationId == "" {
		return nil, status.Error(codes.InvalidArgument, "conversation_id is required")
	}
	if req.SenderId == "" {
		return nil, status.Error(codes.InvalidArgument, "sender_id is required")
	}
	if req.Content == "" {
		return nil, status.Error(codes.InvalidArgument, "content is required")
	}

	convID, err := uuid.Parse(req.ConversationId)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "invalid conversation_id")
	}

	senderID, err := uuid.Parse(req.SenderId)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "invalid sender_id")
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
			return nil, status.Error(codes.PermissionDenied, "not a member of this conversation")
		}
		return nil, status.Error(codes.Internal, err.Error())
	}

	return modelToProtoMessage(msg), nil
}

// StreamMessages streams messages in real-time
func (h *ChatHandler) StreamMessages(req *StreamRequest, stream ChatService_StreamMessagesServer) error {
	if req.UserId == "" {
		return status.Error(codes.InvalidArgument, "user_id is required")
	}

	userID, err := uuid.Parse(req.UserId)
	if err != nil {
		return status.Error(codes.InvalidArgument, "invalid user_id")
	}

	// This is a placeholder implementation
	// In production, this would subscribe to Redis pub/sub or similar
	_ = userID

	// Keep the stream open
	<-stream.Context().Done()
	return nil
}

// Conversion helpers

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

// Timestamp helper
func protoTimestampToTime(ts *Timestamp) time.Time {
	if ts == nil {
		return time.Time{}
	}
	return time.Unix(ts.Seconds, int64(ts.Nanos))
}
