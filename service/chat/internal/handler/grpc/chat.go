package grpc

import (
	"context"
	"strconv"

	"github.com/google/uuid"
	"github.com/funcdfs/lesser/chat/internal/auth"
	"github.com/funcdfs/lesser/chat/internal/model"
	"github.com/funcdfs/lesser/chat/internal/service"
	chatpb "github.com/funcdfs/lesser/chat/proto/chat"
	"github.com/funcdfs/lesser/pkg/proto/common"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type ChatHandler struct {
	chatpb.UnimplementedChatServiceServer
	chatService   *service.ChatService
	streamManager *StreamManager
}

func NewChatHandler(chatService *service.ChatService) *ChatHandler {
	return &ChatHandler{
		chatService:   chatService,
		streamManager: NewStreamManager(chatService),
	}
}

func (h *ChatHandler) Register(server *grpc.Server) {
	chatpb.RegisterChatServiceServer(server, h)
}

func (h *ChatHandler) GetConversations(ctx context.Context, req *chatpb.GetConversationsRequest) (*chatpb.ConversationsResponse, error) {
	if req.GetUserId() == "" {
		return nil, status.Error(codes.InvalidArgument, "用户ID不能为空")
	}

	userID, err := uuid.Parse(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "用户ID格式无效")
	}

	page := int(req.GetPagination().GetPage())
	if page < 1 {
		page = 1
	}
	pageSize := int(req.GetPagination().GetPageSize())
	if pageSize < 1 {
		pageSize = 20
	}

	result, err := h.chatService.GetUserConversations(ctx, userID, page, pageSize)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	conversations := make([]*chatpb.Conversation, len(result.Conversations))
	for i, conv := range result.Conversations {
		conversations[i] = modelToProtoConversation(&conv)
	}

	return &chatpb.ConversationsResponse{
		Conversations: conversations,
		Pagination: &common.Pagination{
			Page:     int32(result.Page),
			PageSize: int32(result.PageSize),
			Total:    int32(result.Total),
		},
	}, nil
}

func (h *ChatHandler) GetConversation(ctx context.Context, req *chatpb.GetConversationRequest) (*chatpb.Conversation, error) {
	if req.GetConversationId() == "" {
		return nil, status.Error(codes.InvalidArgument, "会话ID不能为空")
	}

	convID, err := uuid.Parse(req.GetConversationId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "会话ID格式无效")
	}

	conv, err := h.chatService.GetConversation(ctx, convID)
	if err != nil {
		return nil, status.Error(codes.NotFound, "会话不存在")
	}

	return modelToProtoConversation(conv), nil
}

func (h *ChatHandler) CreateConversation(ctx context.Context, req *chatpb.CreateConversationRequest) (*chatpb.Conversation, error) {
	if req.GetCreatorId() == "" {
		return nil, status.Error(codes.InvalidArgument, "创建者用户 ID 不能为空")
	}
	if len(req.GetMemberIds()) == 0 {
		return nil, status.Error(codes.InvalidArgument, "成员用户 ID 列表不能为空")
	}

	creatorID, err := uuid.Parse(req.GetCreatorId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "创建者用户 ID 格式无效")
	}

	memberIDs := make([]uuid.UUID, len(req.GetMemberIds()))
	for i, idStr := range req.GetMemberIds() {
		id, err := uuid.Parse(idStr)
		if err != nil {
			return nil, status.Errorf(codes.InvalidArgument, "成员用户 ID 格式无效: %s", idStr)
		}
		memberIDs[i] = id
	}

	convType := protoToModelConversationType(req.GetType())

	conv, err := h.chatService.CreateConversation(ctx, service.CreateConversationRequest{
		Type:      convType,
		Name:      req.GetName(),
		MemberIDs: memberIDs,
		CreatorID: creatorID,
	})
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	return modelToProtoConversation(conv), nil
}


func (h *ChatHandler) GetMessages(ctx context.Context, req *chatpb.GetMessagesRequest) (*chatpb.MessagesResponse, error) {
	if req.GetConversationId() == "" {
		return nil, status.Error(codes.InvalidArgument, "会话 ID 不能为空")
	}

	convID, err := uuid.Parse(req.GetConversationId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "会话 ID 格式无效")
	}

	userID, ok := auth.GetUserIDFromContext(ctx)
	if !ok {
		return nil, status.Error(codes.Unauthenticated, "需要认证")
	}

	page := int(req.GetPagination().GetPage())
	if page < 1 {
		page = 1
	}
	pageSize := int(req.GetPagination().GetPageSize())
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

	messages := make([]*chatpb.Message, len(result.Messages))
	for i, msg := range result.Messages {
		messages[i] = modelToProtoMessage(&msg)
	}

	return &chatpb.MessagesResponse{
		Messages: messages,
		Pagination: &common.Pagination{
			Page:     int32(result.Page),
			PageSize: int32(result.PageSize),
			Total:    int32(result.Total),
		},
	}, nil
}

func (h *ChatHandler) SendMessage(ctx context.Context, req *chatpb.SendMessageRequest) (*chatpb.Message, error) {
	if req.GetConversationId() == "" {
		return nil, status.Error(codes.InvalidArgument, "会话ID不能为空")
	}
	if req.GetSenderId() == "" {
		return nil, status.Error(codes.InvalidArgument, "发送者ID不能为空")
	}
	if req.GetContent() == "" {
		return nil, status.Error(codes.InvalidArgument, "消息内容不能为空")
	}

	convID, err := uuid.Parse(req.GetConversationId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "会话ID格式无效")
	}

	senderID, err := uuid.Parse(req.GetSenderId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "发送者ID格式无效")
	}

	var msgType model.MessageType
	switch req.GetMessageType() {
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

	msg, err := h.chatService.SendMessage(ctx, service.SendMessageRequest{
		ConversationID: convID,
		SenderID:       senderID,
		Content:        req.GetContent(),
		MessageType:    msgType,
	})
	if err != nil {
		if err == service.ErrNotMember {
			return nil, status.Error(codes.PermissionDenied, "您不是该会话的成员")
		}
		return nil, status.Error(codes.Internal, err.Error())
	}

	// 通过 gRPC 双向流广播消息给在线用户
	h.streamManager.BroadcastToConversation(convID, msg)

	return modelToProtoMessage(msg), nil
}


func (h *ChatHandler) MarkAsRead(ctx context.Context, req *chatpb.MarkAsReadRequest) (*chatpb.ReadReceipt, error) {
	if req.GetMessageId() == "" {
		return nil, status.Error(codes.InvalidArgument, "消息ID不能为空")
	}
	if req.GetUserId() == "" {
		return nil, status.Error(codes.InvalidArgument, "用户ID不能为空")
	}

	messageID, err := strconv.ParseInt(req.GetMessageId(), 10, 64)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "消息ID格式无效")
	}

	userID, err := uuid.Parse(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "用户ID格式无效")
	}

	receipt, err := h.chatService.MarkMessageAsRead(ctx, messageID, userID)
	if err != nil {
		if err == service.ErrNotMember {
			return nil, status.Error(codes.PermissionDenied, "您不是该会话的成员")
		}
		if err == service.ErrCannotMarkOwnMessage {
			return nil, status.Error(codes.InvalidArgument, "不能标记自己发送的消息为已读")
		}
		if err == service.ErrAlreadyRead {
			return nil, status.Error(codes.AlreadyExists, "消息已经标记为已读")
		}
		return nil, status.Error(codes.Internal, err.Error())
	}

	// 通过 gRPC 双向流通知消息发送者
	h.streamManager.NotifyReadReceipt(receipt)

	return &chatpb.ReadReceipt{
		MessageId:      strconv.FormatInt(receipt.MessageID, 10),
		ConversationId: receipt.ConversationID.String(),
		ReaderId:       receipt.ReaderID.String(),
		ReadAt: &common.Timestamp{
			Seconds: receipt.ReadAt.Unix(),
			Nanos:   int32(receipt.ReadAt.Nanosecond()),
		},
	}, nil
}

func (h *ChatHandler) MarkConversationAsRead(ctx context.Context, req *chatpb.MarkConversationAsReadRequest) (*chatpb.BatchReadReceipt, error) {
	if req.GetConversationId() == "" {
		return nil, status.Error(codes.InvalidArgument, "会话ID不能为空")
	}
	if req.GetUserId() == "" {
		return nil, status.Error(codes.InvalidArgument, "用户ID不能为空")
	}

	convID, err := uuid.Parse(req.GetConversationId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "会话ID格式无效")
	}

	userID, err := uuid.Parse(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "用户ID格式无效")
	}

	receipt, err := h.chatService.MarkConversationAsRead(ctx, convID, userID)
	if err != nil {
		if err == service.ErrNotMember {
			return nil, status.Error(codes.PermissionDenied, "您不是该会话的成员")
		}
		return nil, status.Error(codes.Internal, err.Error())
	}

	// 通过 gRPC 双向流通知消息发送者
	h.streamManager.NotifyBatchReadReceipt(receipt)

	messageIDs := make([]string, len(receipt.MessageIDs))
	for i, id := range receipt.MessageIDs {
		messageIDs[i] = strconv.FormatInt(id, 10)
	}

	return &chatpb.BatchReadReceipt{
		ConversationId: receipt.ConversationID.String(),
		ReaderId:       receipt.ReaderID.String(),
		MessageIds:     messageIDs,
		ReadAt: &common.Timestamp{
			Seconds: receipt.ReadAt.Unix(),
			Nanos:   int32(receipt.ReadAt.Nanosecond()),
		},
	}, nil
}

func (h *ChatHandler) GetUnreadCounts(ctx context.Context, req *chatpb.GetUnreadCountsRequest) (*chatpb.GetUnreadCountsResponse, error) {
	if req.GetUserId() == "" {
		return nil, status.Error(codes.InvalidArgument, "用户ID不能为空")
	}

	userID, err := uuid.Parse(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "用户ID格式无效")
	}

	conversationIDs := make([]uuid.UUID, len(req.GetConversationIds()))
	for i, idStr := range req.GetConversationIds() {
		id, err := uuid.Parse(idStr)
		if err != nil {
			return nil, status.Errorf(codes.InvalidArgument, "会话ID格式无效: %s", idStr)
		}
		conversationIDs[i] = id
	}

	counts, err := h.chatService.GetUnreadCounts(ctx, userID, conversationIDs)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	unreadCounts := make([]*chatpb.UnreadCount, 0, len(counts))
	for convID, count := range counts {
		unreadCounts = append(unreadCounts, &chatpb.UnreadCount{
			ConversationId: convID.String(),
			Count:          count,
		})
	}

	return &chatpb.GetUnreadCountsResponse{
		UnreadCounts: unreadCounts,
	}, nil
}

// StreamEvents 双向流 RPC（替代 WebSocket）
func (h *ChatHandler) StreamEvents(stream chatpb.ChatService_StreamEventsServer) error {
	return h.streamManager.HandleStreamEvents(stream)
}


func (h *ChatHandler) getMessageSenderIDs(ctx context.Context, messageIDs []int64) []uuid.UUID {
	senderMap := make(map[uuid.UUID]bool)
	for _, msgID := range messageIDs {
		msg, err := h.chatService.GetMessageByID(ctx, msgID)
		if err == nil {
			senderMap[msg.SenderID] = true
		}
	}

	senders := make([]uuid.UUID, 0, len(senderMap))
	for senderID := range senderMap {
		senders = append(senders, senderID)
	}
	return senders
}

func modelToProtoConversation(conv *model.Conversation) *chatpb.Conversation {
	memberIDs := make([]string, len(conv.Members))
	for i, m := range conv.Members {
		memberIDs[i] = m.UserID.String()
	}

	protoConv := &chatpb.Conversation{
		Id:        conv.ID.String(),
		Type:      modelToProtoConversationType(conv.Type),
		Name:      conv.Name,
		MemberIds: memberIDs,
		CreatorId: conv.CreatorID.String(),
		CreatedAt: &common.Timestamp{
			Seconds: conv.CreatedAt.Unix(),
			Nanos:   int32(conv.CreatedAt.Nanosecond()),
		},
	}

	if conv.LastMessage != nil {
		protoConv.LastMessage = modelToProtoMessage(conv.LastMessage)
	}

	return protoConv
}

func modelToProtoMessage(msg *model.Message) *chatpb.Message {
	var msgTypeStr string
	switch msg.MsgType {
	case model.MessageTypeImage:
		msgTypeStr = "image"
	case model.MessageTypeVideo:
		msgTypeStr = "video"
	case model.MessageTypeLink:
		msgTypeStr = "link"
	case model.MessageTypeFile:
		msgTypeStr = "file"
	case model.MessageTypeSystem:
		msgTypeStr = "system"
	default:
		msgTypeStr = "text"
	}

	return &chatpb.Message{
		Id:             strconv.FormatInt(msg.ID, 10),
		ConversationId: msg.DialogID.String(),
		SenderId:       msg.SenderID.String(),
		Content:        msg.Content,
		MessageType:    msgTypeStr,
		CreatedAt: &common.Timestamp{
			Seconds: msg.Date.Unix(),
			Nanos:   int32(msg.Date.Nanosecond()),
		},
	}
}

func modelToProtoConversationType(t model.ConversationType) chatpb.ConversationType {
	switch t {
	case model.ConversationTypePrivate:
		return chatpb.ConversationType_PRIVATE
	case model.ConversationTypeGroup:
		return chatpb.ConversationType_GROUP
	case model.ConversationTypeChannel:
		return chatpb.ConversationType_CHANNEL
	default:
		return chatpb.ConversationType_PRIVATE
	}
}

func protoToModelConversationType(t chatpb.ConversationType) model.ConversationType {
	switch t {
	case chatpb.ConversationType_PRIVATE:
		return model.ConversationTypePrivate
	case chatpb.ConversationType_GROUP:
		return model.ConversationTypeGroup
	case chatpb.ConversationType_CHANNEL:
		return model.ConversationTypeChannel
	default:
		return model.ConversationTypePrivate
	}
}
