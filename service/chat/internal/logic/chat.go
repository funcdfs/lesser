// Package logic 提供 Chat 服务的业务逻辑层
package logic

import (
	"context"
	"database/sql"
	"fmt"
	"log/slog"
	"time"

	"github.com/google/uuid"
	"github.com/funcdfs/lesser/chat/internal/data_access"
	"github.com/funcdfs/lesser/chat/internal/remote"
	"github.com/funcdfs/lesser/pkg/cache"
)

// ChatService 聊天业务服务
type ChatService struct {
	conversationRepo   *data_access.ConversationRepository
	messageRepo        *data_access.MessageRepository
	cache              *cache.Client
	userClient         *remote.UserClient
	unreadCacheService *UnreadCacheService
}

// NewChatService 创建聊天服务
func NewChatService(
	conversationRepo *data_access.ConversationRepository,
	messageRepo *data_access.MessageRepository,
	cache *cache.Client,
	userClient *remote.UserClient,
	unreadCacheService *UnreadCacheService,
) *ChatService {
	return &ChatService{
		conversationRepo:   conversationRepo,
		messageRepo:        messageRepo,
		cache:              cache,
		userClient:         userClient,
		unreadCacheService: unreadCacheService,
	}
}

// CreateConversationRequest 创建会话请求
type CreateConversationRequest struct {
	Type      data_access.ConversationType
	Name      string
	MemberIDs []uuid.UUID
	CreatorID uuid.UUID
}

// Validate 验证请求
func (r *CreateConversationRequest) Validate() error {
	if len(r.MemberIDs) == 0 {
		return ErrNoMembers
	}
	if r.CreatorID == uuid.Nil {
		return ErrInvalidCreatorID
	}
	if r.Type == data_access.ConversationTypePrivate && len(r.MemberIDs) != 2 {
		return ErrPrivateMemberCount
	}
	if r.Type == data_access.ConversationTypeGroup && r.Name == "" {
		return ErrGroupNameRequired
	}
	return nil
}

// SendMessageRequest 发送消息请求
type SendMessageRequest struct {
	ConversationID uuid.UUID
	SenderID       uuid.UUID
	Content        string
	MessageType    data_access.MessageType
}

// Validate 验证请求
func (r *SendMessageRequest) Validate() error {
	if r.ConversationID == uuid.Nil {
		return ErrInvalidConversationID
	}
	if r.SenderID == uuid.Nil {
		return ErrInvalidSenderID
	}
	if r.Content == "" {
		return ErrEmptyContent
	}
	return nil
}

// ConversationsResult 会话列表结果
type ConversationsResult struct {
	Conversations []data_access.Conversation
	Total         int64
	Page          int
	PageSize      int
}

// MessagesResult 消息列表结果
type MessagesResult struct {
	Messages []data_access.Message
	Total    int64
	Page     int
	PageSize int
}

// CreateConversation 创建会话
func (s *ChatService) CreateConversation(ctx context.Context, req CreateConversationRequest) (*data_access.Conversation, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}

	// 私聊会话检查是否已存在
	if req.Type == data_access.ConversationTypePrivate && len(req.MemberIDs) == 2 {
		existing, err := s.conversationRepo.GetPrivateConversation(ctx, req.MemberIDs[0], req.MemberIDs[1])
		if err == nil && existing != nil {
			return existing, nil
		}
	}

	conv := &data_access.Conversation{
		Type:      req.Type,
		Name:      req.Name,
		CreatorID: req.CreatorID,
	}

	if err := s.conversationRepo.Create(ctx, conv, req.MemberIDs); err != nil {
		return nil, fmt.Errorf("%w: %v", ErrCreateConversationFailed, err)
	}

	return s.conversationRepo.GetByID(ctx, conv.ID)
}

// GetConversation 获取会话
func (s *ChatService) GetConversation(ctx context.Context, id uuid.UUID) (*data_access.Conversation, error) {
	conv, err := s.conversationRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	// 获取最新消息
	lastMsg, err := s.messageRepo.GetLatestByConversationID(ctx, id)
	if err == nil && lastMsg != nil {
		conv.LastMessage = lastMsg
	}

	// 填充成员用户信息
	s.populateMemberUserInfo(ctx, conv)

	return conv, nil
}

// GetUserConversations 获取用户的会话列表
func (s *ChatService) GetUserConversations(ctx context.Context, userID uuid.UUID, page, pageSize int) (*ConversationsResult, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}

	conversations, total, err := s.conversationRepo.GetByUserID(ctx, userID, page, pageSize)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrGetConversationsFailed, err)
	}

	// 批量获取未读数
	conversationIDs := make([]uuid.UUID, len(conversations))
	for i := range conversations {
		conversationIDs[i] = conversations[i].ID
	}

	unreadCounts, err := s.GetUnreadCounts(ctx, userID, conversationIDs)
	if err != nil {
		slog.Warn("批量获取未读数失败", slog.Any("error", err))
	}

	// 填充最新消息和未读数
	for i := range conversations {
		lastMsg, err := s.messageRepo.GetLatestByConversationID(ctx, conversations[i].ID)
		if err == nil && lastMsg != nil {
			conversations[i].LastMessage = lastMsg
		}
		if unreadCounts != nil {
			conversations[i].UnreadCount = int(unreadCounts[conversations[i].ID])
		}
		s.populateMemberUserInfo(ctx, &conversations[i])
	}

	return &ConversationsResult{
		Conversations: conversations,
		Total:         total,
		Page:          page,
		PageSize:      pageSize,
	}, nil
}

// SendMessage 发送消息
func (s *ChatService) SendMessage(ctx context.Context, req SendMessageRequest) (*data_access.Message, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}

	// 检查是否为会话成员
	isMember, err := s.conversationRepo.IsMember(ctx, req.ConversationID, req.SenderID)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrCheckMemberFailed, err)
	}
	if !isMember {
		return nil, ErrNotMember
	}

	msg := &data_access.Message{
		ConversationID: req.ConversationID,
		SenderID:       req.SenderID,
		Type:           req.MessageType,
		Content:        sql.NullString{String: req.Content, Valid: true},
	}

	if err := s.messageRepo.Create(ctx, msg); err != nil {
		return nil, fmt.Errorf("%w: %v", ErrCreateMessageFailed, err)
	}

	// 更新会话时间戳
	if err := s.conversationRepo.UpdateTimestamp(ctx, req.ConversationID); err != nil {
		slog.Warn("更新会话时间戳失败", slog.Any("error", err))
	}

	// 增加其他成员的未读数
	if s.unreadCacheService != nil {
		memberIDs, err := s.conversationRepo.GetMemberIDs(ctx, req.ConversationID)
		if err != nil {
			slog.Warn("获取会话成员失败", slog.Any("error", err))
		} else {
			for _, memberID := range memberIDs {
				if memberID != req.SenderID {
					if err := s.unreadCacheService.IncrementUnreadCount(ctx, memberID, req.ConversationID); err != nil {
						slog.Warn("增加未读数缓存失败", slog.Any("error", err))
					}
				}
			}
		}
	}

	// 发布消息到 Redis（用于实时推送）
	if s.cache != nil {
		channel := fmt.Sprintf("conversation:%s", req.ConversationID)
		if err := s.cache.Publish(ctx, channel, msg); err != nil {
			slog.Warn("发布消息到 Redis 失败", slog.Any("error", err))
		}
	}

	return msg, nil
}

// GetMessages 获取消息列表
func (s *ChatService) GetMessages(ctx context.Context, conversationID uuid.UUID, userID uuid.UUID, page, pageSize int) (*MessagesResult, error) {
	// 检查是否为会话成员
	if userID != uuid.Nil {
		isMember, err := s.conversationRepo.IsMember(ctx, conversationID, userID)
		if err != nil {
			return nil, fmt.Errorf("%w: %v", ErrCheckMemberFailed, err)
		}
		if !isMember {
			return nil, ErrNotMember
		}
	}

	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 50
	}

	messages, total, err := s.messageRepo.GetByConversationID(ctx, conversationID, page, pageSize)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrGetMessagesFailed, err)
	}

	return &MessagesResult{
		Messages: messages,
		Total:    total,
		Page:     page,
		PageSize: pageSize,
	}, nil
}

// AddMember 添加成员
func (s *ChatService) AddMember(ctx context.Context, conversationID, userID, addedBy uuid.UUID) error {
	// 检查操作者是否为成员
	isMember, err := s.conversationRepo.IsMember(ctx, conversationID, addedBy)
	if err != nil {
		return fmt.Errorf("%w: %v", ErrCheckMemberFailed, err)
	}
	if !isMember {
		return ErrNotMember
	}

	// 检查会话类型
	conv, err := s.conversationRepo.GetByID(ctx, conversationID)
	if err != nil {
		return fmt.Errorf("%w: %v", ErrGetConversationFailed, err)
	}

	if conv.Type == data_access.ConversationTypePrivate {
		return ErrCannotAddToPrivate
	}

	if err := s.conversationRepo.AddMember(ctx, conversationID, userID, data_access.MemberRoleMember); err != nil {
		return fmt.Errorf("%w: %v", ErrAddMemberFailed, err)
	}

	return nil
}

// RemoveMember 移除成员
func (s *ChatService) RemoveMember(ctx context.Context, conversationID, userID, removedBy uuid.UUID) error {
	conv, err := s.conversationRepo.GetByID(ctx, conversationID)
	if err != nil {
		return fmt.Errorf("%w: %v", ErrGetConversationFailed, err)
	}

	// 只有自己或群主可以移除成员
	if userID != removedBy {
		isOwner := conv.CreatorID == removedBy
		if !isOwner {
			return ErrNotAuthorized
		}
	}

	if err := s.conversationRepo.RemoveMember(ctx, conversationID, userID); err != nil {
		return fmt.Errorf("%w: %v", ErrRemoveMemberFailed, err)
	}

	return nil
}

// GetConversationMemberIDs 获取会话成员 ID 列表
func (s *ChatService) GetConversationMemberIDs(ctx context.Context, conversationID uuid.UUID) ([]uuid.UUID, error) {
	return s.conversationRepo.GetMemberIDs(ctx, conversationID)
}

// IsMember 检查是否为会话成员
func (s *ChatService) IsMember(ctx context.Context, conversationID, userID uuid.UUID) (bool, error) {
	return s.conversationRepo.IsMember(ctx, conversationID, userID)
}

// GetMessageByID 根据 ID 获取消息
func (s *ChatService) GetMessageByID(ctx context.Context, messageID uuid.UUID) (*data_access.Message, error) {
	return s.messageRepo.GetByID(ctx, messageID)
}

// GetUnreadCount 获取单个会话的未读数
func (s *ChatService) GetUnreadCount(ctx context.Context, conversationID, userID uuid.UUID) (int64, error) {
	if s.unreadCacheService != nil {
		return s.unreadCacheService.GetUnreadCount(ctx, userID, conversationID)
	}
	return s.messageRepo.GetUnreadCount(ctx, conversationID, userID)
}

// GetUnreadCounts 批量获取未读数
func (s *ChatService) GetUnreadCounts(ctx context.Context, userID uuid.UUID, conversationIDs []uuid.UUID) (map[uuid.UUID]int64, error) {
	if len(conversationIDs) == 0 {
		return make(map[uuid.UUID]int64), nil
	}

	if s.unreadCacheService != nil {
		return s.unreadCacheService.GetUnreadCountsBatch(ctx, userID, conversationIDs)
	}

	return s.messageRepo.GetUnreadCountsBatch(ctx, userID, conversationIDs)
}

// MarkConversationAsRead 标记会话所有消息为已读
func (s *ChatService) MarkConversationAsRead(ctx context.Context, conversationID, userID uuid.UUID) (*data_access.BatchReadReceipt, error) {
	member, err := s.conversationRepo.GetMember(ctx, conversationID, userID)
	if err != nil {
		if err == data_access.ErrNotFound {
			return nil, ErrNotMember
		}
		return nil, fmt.Errorf("%w: %v", ErrCheckMemberFailed, err)
	}

	readAt := time.Now()

	// 计算上次已读时间
	var lastRead time.Time
	if member.LastReadAt.Valid {
		lastRead = member.LastReadAt.Time
	} else {
		lastRead = member.JoinedAt
	}

	// 查找未读消息 ID
	messageIDs, err := s.messageRepo.FindUnreadMessageIDsInRange(ctx, conversationID, userID, lastRead, readAt)
	if err != nil {
		slog.Warn("查找未读消息失败", slog.Any("error", err))
	}

	// 更新最后已读时间
	if err := s.conversationRepo.UpdateLastReadAt(ctx, conversationID, userID, readAt); err != nil {
		return nil, fmt.Errorf("%w: %v", ErrMarkReadFailed, err)
	}

	// 重置未读数缓存
	if s.unreadCacheService != nil {
		if err := s.unreadCacheService.ResetUnreadCount(ctx, userID, conversationID); err != nil {
			slog.Warn("重置未读数缓存失败", slog.Any("error", err))
		}
	}

	return &data_access.BatchReadReceipt{
		ConversationID: conversationID,
		ReaderID:       userID,
		MessageIDs:     messageIDs,
		ReadAt:         readAt,
	}, nil
}

// MarkMessageAsRead 标记单条消息为已读
func (s *ChatService) MarkMessageAsRead(ctx context.Context, messageID uuid.UUID, userID uuid.UUID) (*data_access.ReadReceipt, error) {
	msg, err := s.messageRepo.GetByID(ctx, messageID)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrGetMessageFailed, err)
	}

	member, err := s.conversationRepo.GetMember(ctx, msg.ConversationID, userID)
	if err != nil {
		if err == data_access.ErrNotFound {
			return nil, ErrNotMember
		}
		return nil, fmt.Errorf("%w: %v", ErrCheckMemberFailed, err)
	}

	// 不能标记自己的消息为已读
	if msg.SenderID == userID {
		return nil, ErrCannotMarkOwnMessage
	}

	// 检查是否已读
	if member.LastReadAt.Valid && !msg.CreatedAt.After(member.LastReadAt.Time) {
		return nil, ErrAlreadyRead
	}

	readAt := msg.CreatedAt

	// 更新最后已读时间
	if err := s.conversationRepo.UpdateLastReadAt(ctx, msg.ConversationID, userID, readAt); err != nil {
		return nil, fmt.Errorf("%w: %v", ErrMarkReadFailed, err)
	}

	// 使缓存失效
	if s.unreadCacheService != nil {
		if err := s.unreadCacheService.InvalidateCache(ctx, userID, msg.ConversationID); err != nil {
			slog.Warn("使未读数缓存失效失败", slog.Any("error", err))
		}
	}

	return &data_access.ReadReceipt{
		MessageID:      messageID,
		ConversationID: msg.ConversationID,
		ReaderID:       userID,
		ReadAt:         time.Now(),
	}, nil
}

// populateMemberUserInfo 填充成员用户信息
func (s *ChatService) populateMemberUserInfo(ctx context.Context, conv *data_access.Conversation) {
	if s.userClient == nil || len(conv.Members) == 0 {
		return
	}

	userIDs := make([]uuid.UUID, len(conv.Members))
	for i, m := range conv.Members {
		userIDs[i] = m.UserID
	}

	users, err := s.userClient.GetUsers(ctx, userIDs)
	if err != nil {
		slog.Warn("获取用户信息失败", slog.Any("error", err))
		return
	}

	for i := range conv.Members {
		if user, ok := users[conv.Members[i].UserID]; ok {
			conv.Members[i].Username = user.Username
			conv.Members[i].Email = user.Email
			conv.Members[i].DisplayName = user.DisplayName
			conv.Members[i].AvatarURL = user.AvatarURL
		}
	}
}
