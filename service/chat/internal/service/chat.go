package service

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/funcdfs/lesser/chat/internal/model"
	"github.com/funcdfs/lesser/chat/internal/repository"
	"github.com/funcdfs/lesser/chat/pkg/cache"
)

type ChatService struct {
	conversationRepo   *repository.ConversationRepository
	messageRepo        *repository.MessageRepository
	cache              *cache.RedisClient
	userClient         *UserClient
	unreadCacheService *UnreadCacheService
}

func NewChatService(
	conversationRepo *repository.ConversationRepository,
	messageRepo *repository.MessageRepository,
	cache *cache.RedisClient,
	userClient *UserClient,
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

func (s *ChatService) CreateConversation(ctx context.Context, req CreateConversationRequest) (*model.Conversation, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}

	if req.Type == model.ConversationTypePrivate && len(req.MemberIDs) == 2 {
		existing, err := s.conversationRepo.GetPrivateConversation(ctx, req.MemberIDs[0], req.MemberIDs[1])
		if err == nil && existing != nil {
			return existing, nil
		}
	}

	conv := &model.Conversation{
		ID:        uuid.New(),
		Type:      req.Type,
		Name:      req.Name,
		CreatorID: req.CreatorID,
	}

	if err := s.conversationRepo.Create(ctx, conv, req.MemberIDs); err != nil {
		return nil, fmt.Errorf("%w: %v", ErrCreateConversationFailed, err)
	}

	return s.conversationRepo.GetByID(ctx, conv.ID)
}

func (s *ChatService) GetConversation(ctx context.Context, id uuid.UUID) (*model.Conversation, error) {
	conv, err := s.conversationRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	lastMsg, err := s.messageRepo.GetLatestByConversationID(ctx, id)
	if err == nil && lastMsg != nil {
		conv.LastMessage = lastMsg
	}

	s.populateMemberUserInfo(ctx, conv)

	return conv, nil
}

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

	conversationIDs := make([]uuid.UUID, len(conversations))
	for i := range conversations {
		conversationIDs[i] = conversations[i].ID
	}

	unreadCounts, err := s.GetUnreadCounts(ctx, userID, conversationIDs)
	if err != nil {
		fmt.Printf("警告: 批量获取未读数失败: %v\n", err)
	}

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

func (s *ChatService) SendMessage(ctx context.Context, req SendMessageRequest) (*model.Message, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}

	isMember, err := s.conversationRepo.IsMember(ctx, req.ConversationID, req.SenderID)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrCheckMemberFailed, err)
	}
	if !isMember {
		return nil, ErrNotMember
	}

	msg := &model.Message{
		DialogID:   req.ConversationID,
		SenderID:   req.SenderID,
		Content:    req.Content,
		MsgType:    req.MessageType,
		Date:       time.Now().UTC(),
		IsOutgoing: true,
		IsUnread:   true,
	}

	if err := s.messageRepo.Create(ctx, msg); err != nil {
		return nil, fmt.Errorf("%w: %v", ErrCreateMessageFailed, err)
	}

	if err := s.conversationRepo.UpdateTimestamp(ctx, req.ConversationID); err != nil {
		fmt.Printf("警告: 更新会话时间戳失败: %v\n", err)
	}

	if s.unreadCacheService != nil {
		memberIDs, err := s.conversationRepo.GetMemberIDs(ctx, req.ConversationID)
		if err != nil {
			fmt.Printf("警告: 获取会话成员失败: %v\n", err)
		} else {
			for _, memberID := range memberIDs {
				if memberID != req.SenderID {
					if err := s.unreadCacheService.IncrementUnreadCount(ctx, memberID, req.ConversationID); err != nil {
						fmt.Printf("警告: 增加未读数缓存失败: %v\n", err)
					}
				}
			}
		}
	}

	if s.cache != nil {
		channel := fmt.Sprintf("conversation:%s", req.ConversationID)
		if err := s.cache.Publish(ctx, channel, msg); err != nil {
			fmt.Printf("警告: 发布消息到 Redis 失败: %v\n", err)
		}
	}

	return msg, nil
}

func (s *ChatService) GetMessages(ctx context.Context, conversationID uuid.UUID, userID uuid.UUID, page, pageSize int) (*MessagesResult, error) {
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

func (s *ChatService) AddMember(ctx context.Context, conversationID, userID, addedBy uuid.UUID) error {
	isMember, err := s.conversationRepo.IsMember(ctx, conversationID, addedBy)
	if err != nil {
		return fmt.Errorf("%w: %v", ErrCheckMemberFailed, err)
	}
	if !isMember {
		return ErrNotMember
	}

	conv, err := s.conversationRepo.GetByID(ctx, conversationID)
	if err != nil {
		return fmt.Errorf("%w: %v", ErrGetConversationFailed, err)
	}

	if conv.Type == model.ConversationTypePrivate {
		return ErrCannotAddToPrivate
	}

	if err := s.conversationRepo.AddMember(ctx, conversationID, userID, model.MemberRoleMember); err != nil {
		return fmt.Errorf("%w: %v", ErrAddMemberFailed, err)
	}

	return nil
}

func (s *ChatService) RemoveMember(ctx context.Context, conversationID, userID, removedBy uuid.UUID) error {
	conv, err := s.conversationRepo.GetByID(ctx, conversationID)
	if err != nil {
		return fmt.Errorf("%w: %v", ErrGetConversationFailed, err)
	}

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

func (s *ChatService) GetConversationMemberIDs(ctx context.Context, conversationID uuid.UUID) ([]uuid.UUID, error) {
	return s.conversationRepo.GetMemberIDs(ctx, conversationID)
}

func (s *ChatService) IsMember(ctx context.Context, conversationID, userID uuid.UUID) (bool, error) {
	return s.conversationRepo.IsMember(ctx, conversationID, userID)
}

func (s *ChatService) GetMessageByID(ctx context.Context, messageID int64) (*model.Message, error) {
	return s.messageRepo.GetByID(ctx, messageID)
}

func (s *ChatService) GetUnreadCount(ctx context.Context, conversationID, userID uuid.UUID) (int64, error) {
	if s.unreadCacheService != nil {
		return s.unreadCacheService.GetUnreadCount(ctx, userID, conversationID)
	}
	return s.messageRepo.GetUnreadCount(ctx, conversationID, userID)
}

func (s *ChatService) GetUnreadCounts(ctx context.Context, userID uuid.UUID, conversationIDs []uuid.UUID) (map[uuid.UUID]int64, error) {
	if len(conversationIDs) == 0 {
		return make(map[uuid.UUID]int64), nil
	}

	if s.unreadCacheService != nil {
		return s.unreadCacheService.GetUnreadCountsBatch(ctx, userID, conversationIDs)
	}

	return s.messageRepo.GetUnreadCountsBatch(ctx, userID, conversationIDs)
}

func (s *ChatService) MarkConversationAsRead(ctx context.Context, conversationID, userID uuid.UUID) (*model.BatchReadReceipt, error) {
	member, err := s.conversationRepo.GetMember(ctx, conversationID, userID)
	if err != nil {
		if err == repository.ErrNotFound {
			return nil, ErrNotMember
		}
		return nil, fmt.Errorf("%w: %v", ErrCheckMemberFailed, err)
	}

	readAt := time.Now()

	lastRead := member.LastReadAt
	if lastRead.IsZero() {
		lastRead = member.JoinedAt
	}

	messageIDs, err := s.messageRepo.FindUnreadMessageIDsInRange(ctx, conversationID, userID, lastRead, readAt)
	if err != nil {
		fmt.Printf("警告: 查找未读消息失败: %v\n", err)
	}

	if err := s.conversationRepo.UpdateLastReadAt(ctx, conversationID, userID, readAt); err != nil {
		return nil, fmt.Errorf("%w: %v", ErrMarkReadFailed, err)
	}

	if s.unreadCacheService != nil {
		if err := s.unreadCacheService.ResetUnreadCount(ctx, userID, conversationID); err != nil {
			fmt.Printf("警告: 重置未读数缓存失败: %v\n", err)
		}
	}

	return &model.BatchReadReceipt{
		ConversationID: conversationID,
		ReaderID:       userID,
		MessageIDs:     messageIDs,
		ReadAt:         readAt,
	}, nil
}

func (s *ChatService) MarkMessageAsRead(ctx context.Context, messageID int64, userID uuid.UUID) (*model.ReadReceipt, error) {
	msg, err := s.messageRepo.GetByID(ctx, messageID)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrGetMessageFailed, err)
	}

	member, err := s.conversationRepo.GetMember(ctx, msg.DialogID, userID)
	if err != nil {
		if err == repository.ErrNotFound {
			return nil, ErrNotMember
		}
		return nil, fmt.Errorf("%w: %v", ErrCheckMemberFailed, err)
	}

	if msg.SenderID == userID {
		return nil, ErrCannotMarkOwnMessage
	}

	if !member.LastReadAt.IsZero() && !msg.Date.After(member.LastReadAt) {
		return nil, ErrAlreadyRead
	}

	readAt := msg.Date

	if err := s.conversationRepo.UpdateLastReadAt(ctx, msg.DialogID, userID, readAt); err != nil {
		return nil, fmt.Errorf("%w: %v", ErrMarkReadFailed, err)
	}

	if s.unreadCacheService != nil {
		if err := s.unreadCacheService.InvalidateCache(ctx, userID, msg.DialogID); err != nil {
			fmt.Printf("警告: 使未读数缓存失效失败: %v\n", err)
		}
	}

	return &model.ReadReceipt{
		MessageID:      messageID,
		ConversationID: msg.DialogID,
		ReaderID:       userID,
		ReadAt:         time.Now(),
	}, nil
}

func (s *ChatService) MarkMessagesUpToAsRead(ctx context.Context, conversationID, userID uuid.UUID, upToMessageID int64) (*model.BatchReadReceipt, error) {
	targetMsg, err := s.messageRepo.GetByID(ctx, upToMessageID)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrGetMessageFailed, err)
	}

	if targetMsg.DialogID != conversationID {
		return nil, fmt.Errorf("消息不属于该会话")
	}

	member, err := s.conversationRepo.GetMember(ctx, conversationID, userID)
	if err != nil {
		if err == repository.ErrNotFound {
			return nil, ErrNotMember
		}
		return nil, fmt.Errorf("%w: %v", ErrCheckMemberFailed, err)
	}

	if !member.LastReadAt.IsZero() && !targetMsg.Date.After(member.LastReadAt) {
		return &model.BatchReadReceipt{
			ConversationID: conversationID,
			ReaderID:       userID,
			MessageIDs:     []int64{},
			ReadAt:         time.Now(),
		}, nil
	}

	readAt := targetMsg.Date

	lastRead := member.LastReadAt
	if lastRead.IsZero() {
		lastRead = member.JoinedAt
	}

	allUnreadIDs, err := s.messageRepo.FindUnreadMessageIDsInRange(ctx, conversationID, userID, lastRead, readAt)
	var markedIDs []int64

	if err == nil {
		markedIDs = allUnreadIDs
	}

	if err := s.conversationRepo.UpdateLastReadAt(ctx, conversationID, userID, readAt); err != nil {
		return nil, fmt.Errorf("%w: %v", ErrMarkReadFailed, err)
	}

	if s.unreadCacheService != nil {
		if err := s.unreadCacheService.InvalidateCache(ctx, userID, conversationID); err != nil {
			fmt.Printf("警告: 使未读数缓存失效失败: %v\n", err)
		}
	}

	return &model.BatchReadReceipt{
		ConversationID: conversationID,
		ReaderID:       userID,
		MessageIDs:     markedIDs,
		ReadAt:         time.Now(),
	}, nil
}

func (s *ChatService) SubscribeToConversation(ctx context.Context, conversationID uuid.UUID, userID uuid.UUID) (<-chan *model.Message, error) {
	isMember, err := s.conversationRepo.IsMember(ctx, conversationID, userID)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrCheckMemberFailed, err)
	}
	if !isMember {
		return nil, ErrNotMember
	}

	if s.cache == nil {
		return nil, ErrCacheNotAvailable
	}

	channel := fmt.Sprintf("conversation:%s", conversationID)
	pubsub := s.cache.Subscribe(ctx, channel)

	msgChan := make(chan *model.Message, 100)

	go func() {
		defer close(msgChan)
		defer pubsub.Close()

		ch := pubsub.Channel()
		for {
			select {
			case <-ctx.Done():
				return
			case redisMsg, ok := <-ch:
				if !ok {
					return
				}
				var msg model.Message
				if err := json.Unmarshal([]byte(redisMsg.Payload), &msg); err == nil {
					msgChan <- &msg
				}
			}
		}
	}()

	return msgChan, nil
}

type CreateConversationRequest struct {
	Type      model.ConversationType
	Name      string
	MemberIDs []uuid.UUID
	CreatorID uuid.UUID
}

func (r *CreateConversationRequest) Validate() error {
	if len(r.MemberIDs) == 0 {
		return ErrNoMembers
	}
	if r.CreatorID == uuid.Nil {
		return ErrInvalidCreatorID
	}
	if r.Type == model.ConversationTypePrivate && len(r.MemberIDs) != 2 {
		return ErrPrivateMemberCount
	}
	if r.Type == model.ConversationTypeGroup && r.Name == "" {
		return ErrGroupNameRequired
	}
	return nil
}

type SendMessageRequest struct {
	ConversationID uuid.UUID
	SenderID       uuid.UUID
	Content        string
	MessageType    model.MessageType
}

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
	if r.MessageType < 0 {
		r.MessageType = model.MessageTypeText
	}
	return nil
}

type ConversationsResult struct {
	Conversations []model.Conversation
	Total         int64
	Page          int
	PageSize      int
}

type MessagesResult struct {
	Messages []model.Message
	Total    int64
	Page     int
	PageSize int
}

func (s *ChatService) populateMemberUserInfo(ctx context.Context, conv *model.Conversation) {
	if s.userClient == nil || len(conv.Members) == 0 {
		return
	}

	userIDs := make([]uuid.UUID, len(conv.Members))
	for i, m := range conv.Members {
		userIDs[i] = m.UserID
	}

	users, err := s.userClient.GetUsers(ctx, userIDs)
	if err != nil {
		fmt.Printf("警告: 获取用户信息失败: %v\n", err)
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
