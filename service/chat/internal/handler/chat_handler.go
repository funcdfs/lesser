// Package handler 提供 Chat 服务的 gRPC 处理器
package handler

import (
	"context"
	"log/slog"

	"github.com/google/uuid"
	"github.com/funcdfs/lesser/chat/internal/logic"
	pb "github.com/funcdfs/lesser/chat/gen_protos/chat"
	"github.com/funcdfs/lesser/chat/gen_protos/common"
	"github.com/funcdfs/lesser/pkg/auth"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// ChatHandler gRPC 处理器
type ChatHandler struct {
	pb.UnimplementedChatServiceServer
	chatService   *logic.ChatService
	streamManager *StreamManager
	log           *slog.Logger
}

// NewChatHandler 创建处理器
func NewChatHandler(chatService *logic.ChatService, log interface{}) *ChatHandler {
	var slogger *slog.Logger
	switch l := log.(type) {
	case *slog.Logger:
		slogger = l
	case interface{ Logger() *slog.Logger }:
		slogger = l.Logger()
	default:
		slogger = slog.Default()
	}

	return &ChatHandler{
		chatService:   chatService,
		streamManager: NewStreamManager(chatService),
		log:           slogger.With(slog.String("component", "handler")),
	}
}

// GetConversations 获取用户的所有会话
func (h *ChatHandler) GetConversations(ctx context.Context, req *pb.GetConversationsRequest) (*pb.ConversationsResponse, error) {
	if req.GetUserId() == "" {
		return nil, status.Error(codes.InvalidArgument, "用户 ID 不能为空")
	}

	userID, err := uuid.Parse(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "用户 ID 格式无效")
	}

	page := int(req.GetPagination().GetPage())
	if page < 1 {
		page = 1
	}
	pageSize := int(req.GetPagination().GetPageSize())
	if pageSize < 1 {
		pageSize = 20
	}

	h.log.Debug("获取会话列表",
		slog.String("user_id", userID.String()),
		slog.Int("page", page),
		slog.Int("page_size", pageSize),
	)

	result, err := h.chatService.GetUserConversations(ctx, userID, page, pageSize)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	conversations := make([]*pb.Conversation, len(result.Conversations))
	for i, conv := range result.Conversations {
		conversations[i] = conversationToProto(&conv)
	}

	return &pb.ConversationsResponse{
		Conversations: conversations,
		Pagination: &common.Pagination{
			Page:     int32(result.Page),
			PageSize: int32(result.PageSize),
			Total:    int32(result.Total),
		},
	}, nil
}

// GetConversation 根据 ID 获取单个会话
func (h *ChatHandler) GetConversation(ctx context.Context, req *pb.GetConversationRequest) (*pb.Conversation, error) {
	if req.GetConversationId() == "" {
		return nil, status.Error(codes.InvalidArgument, "会话 ID 不能为空")
	}

	convID, err := uuid.Parse(req.GetConversationId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "会话 ID 格式无效")
	}

	conv, err := h.chatService.GetConversation(ctx, convID)
	if err != nil {
		return nil, status.Error(codes.NotFound, "会话不存在")
	}

	return conversationToProto(conv), nil
}

// CreateConversation 创建新会话
func (h *ChatHandler) CreateConversation(ctx context.Context, req *pb.CreateConversationRequest) (*pb.Conversation, error) {
	if req.GetCreatorId() == "" {
		return nil, status.Error(codes.InvalidArgument, "创建者 ID 不能为空")
	}
	if len(req.GetMemberIds()) == 0 {
		return nil, status.Error(codes.InvalidArgument, "成员列表不能为空")
	}

	creatorID, err := uuid.Parse(req.GetCreatorId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "创建者 ID 格式无效")
	}

	memberIDs := make([]uuid.UUID, len(req.GetMemberIds()))
	for i, idStr := range req.GetMemberIds() {
		id, err := uuid.Parse(idStr)
		if err != nil {
			return nil, status.Errorf(codes.InvalidArgument, "成员 ID 格式无效: %s", idStr)
		}
		memberIDs[i] = id
	}

	convType := protoToConversationType(req.GetType())

	h.log.Debug("创建会话",
		slog.String("creator_id", creatorID.String()),
		slog.String("type", string(convType)),
		slog.Int("member_count", len(memberIDs)),
	)

	conv, err := h.chatService.CreateConversation(ctx, logic.CreateConversationRequest{
		Type:      convType,
		Name:      req.GetName(),
		MemberIDs: memberIDs,
		CreatorID: creatorID,
	})
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	return conversationToProto(conv), nil
}

// GetMessages 获取会话中的消息
func (h *ChatHandler) GetMessages(ctx context.Context, req *pb.GetMessagesRequest) (*pb.MessagesResponse, error) {
	if req.GetConversationId() == "" {
		return nil, status.Error(codes.InvalidArgument, "会话 ID 不能为空")
	}

	convID, err := uuid.Parse(req.GetConversationId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "会话 ID 格式无效")
	}

	// 从 context 获取用户 ID
	userIDStr := auth.UserIDFromContext(ctx)
	if userIDStr == "" {
		return nil, status.Error(codes.Unauthenticated, "需要认证")
	}

	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "用户 ID 格式无效")
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
		if err == logic.ErrNotMember {
			return nil, status.Error(codes.PermissionDenied, "您不是该会话的成员")
		}
		return nil, status.Error(codes.Internal, err.Error())
	}

	messages := make([]*pb.Message, len(result.Messages))
	for i, msg := range result.Messages {
		messages[i] = messageToProto(&msg)
	}

	return &pb.MessagesResponse{
		Messages: messages,
		Pagination: &common.Pagination{
			Page:     int32(result.Page),
			PageSize: int32(result.PageSize),
			Total:    int32(result.Total),
		},
	}, nil
}

// SendMessage 发送消息到会话
func (h *ChatHandler) SendMessage(ctx context.Context, req *pb.SendMessageRequest) (*pb.Message, error) {
	if req.GetConversationId() == "" {
		return nil, status.Error(codes.InvalidArgument, "会话 ID 不能为空")
	}
	if req.GetSenderId() == "" {
		return nil, status.Error(codes.InvalidArgument, "发送者 ID 不能为空")
	}
	if req.GetContent() == "" {
		return nil, status.Error(codes.InvalidArgument, "消息内容不能为空")
	}

	convID, err := uuid.Parse(req.GetConversationId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "会话 ID 格式无效")
	}

	senderID, err := uuid.Parse(req.GetSenderId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "发送者 ID 格式无效")
	}

	msgType := parseMessageType(req.GetMessageType())

	h.log.Debug("发送消息",
		slog.String("conversation_id", convID.String()),
		slog.String("sender_id", senderID.String()),
		slog.String("type", string(msgType)),
	)

	msg, err := h.chatService.SendMessage(ctx, logic.SendMessageRequest{
		ConversationID: convID,
		SenderID:       senderID,
		Content:        req.GetContent(),
		MessageType:    msgType,
	})
	if err != nil {
		if err == logic.ErrNotMember {
			return nil, status.Error(codes.PermissionDenied, "您不是该会话的成员")
		}
		return nil, status.Error(codes.Internal, err.Error())
	}

	// 通过双向流广播消息给在线用户
	h.streamManager.BroadcastToConversation(convID, msg)

	return messageToProto(msg), nil
}

// MarkAsRead 标记单条消息为已读
func (h *ChatHandler) MarkAsRead(ctx context.Context, req *pb.MarkAsReadRequest) (*pb.ReadReceipt, error) {
	if req.GetMessageId() == "" {
		return nil, status.Error(codes.InvalidArgument, "消息 ID 不能为空")
	}
	if req.GetUserId() == "" {
		return nil, status.Error(codes.InvalidArgument, "用户 ID 不能为空")
	}

	messageID, err := uuid.Parse(req.GetMessageId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "消息 ID 格式无效")
	}

	userID, err := uuid.Parse(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "用户 ID 格式无效")
	}

	receipt, err := h.chatService.MarkMessageAsRead(ctx, messageID, userID)
	if err != nil {
		switch err {
		case logic.ErrNotMember:
			return nil, status.Error(codes.PermissionDenied, "您不是该会话的成员")
		case logic.ErrCannotMarkOwnMessage:
			return nil, status.Error(codes.InvalidArgument, "不能标记自己发送的消息为已读")
		case logic.ErrAlreadyRead:
			return nil, status.Error(codes.AlreadyExists, "消息已经标记为已读")
		default:
			return nil, status.Error(codes.Internal, err.Error())
		}
	}

	// 通知消息发送者
	h.streamManager.NotifyReadReceipt(receipt)

	return &pb.ReadReceipt{
		MessageId:      receipt.MessageID.String(),
		ConversationId: receipt.ConversationID.String(),
		ReaderId:       receipt.ReaderID.String(),
		ReadAt: &common.Timestamp{
			Seconds: receipt.ReadAt.Unix(),
			Nanos:   int32(receipt.ReadAt.Nanosecond()),
		},
	}, nil
}

// MarkConversationAsRead 标记会话中所有消息为已读
func (h *ChatHandler) MarkConversationAsRead(ctx context.Context, req *pb.MarkConversationAsReadRequest) (*pb.BatchReadReceipt, error) {
	if req.GetConversationId() == "" {
		return nil, status.Error(codes.InvalidArgument, "会话 ID 不能为空")
	}
	if req.GetUserId() == "" {
		return nil, status.Error(codes.InvalidArgument, "用户 ID 不能为空")
	}

	convID, err := uuid.Parse(req.GetConversationId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "会话 ID 格式无效")
	}

	userID, err := uuid.Parse(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "用户 ID 格式无效")
	}

	receipt, err := h.chatService.MarkConversationAsRead(ctx, convID, userID)
	if err != nil {
		if err == logic.ErrNotMember {
			return nil, status.Error(codes.PermissionDenied, "您不是该会话的成员")
		}
		return nil, status.Error(codes.Internal, err.Error())
	}

	// 通知消息发送者
	h.streamManager.NotifyBatchReadReceipt(receipt)

	messageIDs := make([]string, len(receipt.MessageIDs))
	for i, id := range receipt.MessageIDs {
		messageIDs[i] = id.String()
	}

	return &pb.BatchReadReceipt{
		ConversationId: receipt.ConversationID.String(),
		ReaderId:       receipt.ReaderID.String(),
		MessageIds:     messageIDs,
		ReadAt: &common.Timestamp{
			Seconds: receipt.ReadAt.Unix(),
			Nanos:   int32(receipt.ReadAt.Nanosecond()),
		},
	}, nil
}

// GetUnreadCounts 批量获取多个会话的未读数
func (h *ChatHandler) GetUnreadCounts(ctx context.Context, req *pb.GetUnreadCountsRequest) (*pb.GetUnreadCountsResponse, error) {
	if req.GetUserId() == "" {
		return nil, status.Error(codes.InvalidArgument, "用户 ID 不能为空")
	}

	userID, err := uuid.Parse(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "用户 ID 格式无效")
	}

	conversationIDs := make([]uuid.UUID, len(req.GetConversationIds()))
	for i, idStr := range req.GetConversationIds() {
		id, err := uuid.Parse(idStr)
		if err != nil {
			return nil, status.Errorf(codes.InvalidArgument, "会话 ID 格式无效: %s", idStr)
		}
		conversationIDs[i] = id
	}

	counts, err := h.chatService.GetUnreadCounts(ctx, userID, conversationIDs)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	unreadCounts := make([]*pb.UnreadCount, 0, len(counts))
	for convID, count := range counts {
		unreadCounts = append(unreadCounts, &pb.UnreadCount{
			ConversationId: convID.String(),
			Count:          count,
		})
	}

	return &pb.GetUnreadCountsResponse{
		UnreadCounts: unreadCounts,
	}, nil
}

// StreamEvents 双向流 RPC（替代 WebSocket）
func (h *ChatHandler) StreamEvents(stream pb.ChatService_StreamEventsServer) error {
	return h.streamManager.HandleStreamEvents(stream)
}
