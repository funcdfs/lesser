package service

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/lesser/chat/internal/model"
	"github.com/lesser/chat/internal/repository"
	"github.com/lesser/chat/pkg/cache"
)

// ChatService 聊天业务服务层
type ChatService struct {
	conversationRepo   *repository.ConversationRepository
	messageRepo        *repository.MessageRepository
	cache              *cache.RedisClient
	userClient         *UserClient
	unreadCacheService *UnreadCacheService
}

// NewChatService 创建聊天服务实例
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

// CreateConversation 创建新会话
func (s *ChatService) CreateConversation(ctx context.Context, req CreateConversationRequest) (*model.Conversation, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}

	// 对于私聊，检查是否已存在相同的会话
	if req.Type == model.ConversationTypePrivate && len(req.MemberIDs) == 2 {
		existing, err := s.conversationRepo.GetPrivateConversation(ctx, req.MemberIDs[0], req.MemberIDs[1])
		if err == nil && existing != nil {
			return existing, nil
		}
	}

	// 创建会话实体
	conv := &model.Conversation{
		ID:        uuid.New(),
		Type:      req.Type,
		Name:      req.Name,
		CreatorID: req.CreatorID,
	}

	if err := s.conversationRepo.Create(ctx, conv, req.MemberIDs); err != nil {
		return nil, fmt.Errorf("%w: %v", ErrCreateConversationFailed, err)
	}

	// 重新加载会话（包含成员信息）
	return s.conversationRepo.GetByID(ctx, conv.ID)
}

// GetConversation 根据ID获取会话详情
func (s *ChatService) GetConversation(ctx context.Context, id uuid.UUID) (*model.Conversation, error) {
	conv, err := s.conversationRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	// 获取最后一条消息
	lastMsg, err := s.messageRepo.GetLatestByConversationID(ctx, id)
	if err == nil && lastMsg != nil {
		conv.LastMessage = lastMsg
	}

	// 填充成员的用户信息
	s.populateMemberUserInfo(ctx, conv)

	return conv, nil
}

// GetUserConversations 获取用户的所有会话列表
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

	// 收集所有会话ID用于批量查询未读数
	conversationIDs := make([]uuid.UUID, len(conversations))
	for i := range conversations {
		conversationIDs[i] = conversations[i].ID
	}

	// 批量获取未读数
	unreadCounts, err := s.GetUnreadCounts(ctx, userID, conversationIDs)
	if err != nil {
		fmt.Printf("警告: 批量获取未读数失败: %v\n", err)
		// 不影响主流程，继续处理
	}

	// 为每个会话获取最后一条消息、设置未读数并填充用户信息
	for i := range conversations {
		lastMsg, err := s.messageRepo.GetLatestByConversationID(ctx, conversations[i].ID)
		if err == nil && lastMsg != nil {
			conversations[i].LastMessage = lastMsg
		}
		// 设置未读消息数（从批量查询结果中获取）
		if unreadCounts != nil {
			conversations[i].UnreadCount = int(unreadCounts[conversations[i].ID])
		}
		// 填充成员的用户信息
		s.populateMemberUserInfo(ctx, &conversations[i])
	}

	return &ConversationsResult{
		Conversations: conversations,
		Total:         total,
		Page:          page,
		PageSize:      pageSize,
	}, nil
}

// SendMessage 发送消息到会话
func (s *ChatService) SendMessage(ctx context.Context, req SendMessageRequest) (*model.Message, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}

	// 检查用户是否是会话成员
	isMember, err := s.conversationRepo.IsMember(ctx, req.ConversationID, req.SenderID)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrCheckMemberFailed, err)
	}
	if !isMember {
		return nil, ErrNotMember
	}

	// 创建消息实体
	msg := &model.Message{
		ID:             uuid.New(),
		ConversationID: req.ConversationID,
		SenderID:       req.SenderID,
		Content:        req.Content,
		MessageType:    req.MessageType,
	}

	if err := s.messageRepo.Create(ctx, msg); err != nil {
		return nil, fmt.Errorf("%w: %v", ErrCreateMessageFailed, err)
	}

	// 更新会话的最后活动时间
	if err := s.conversationRepo.UpdateTimestamp(ctx, req.ConversationID); err != nil {
		// 记录日志但不影响主流程
		fmt.Printf("警告: 更新会话时间戳失败: %v\n", err)
	}

	// 增加会话成员的未读数缓存（发送者除外）
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

	// 通过 Redis 发布消息用于实时推送
	if s.cache != nil {
		channel := fmt.Sprintf("conversation:%s", req.ConversationID)
		if err := s.cache.Publish(ctx, channel, msg); err != nil {
			// 记录日志但不影响主流程
			fmt.Printf("警告: 发布消息到 Redis 失败: %v\n", err)
		}
	}

	return msg, nil
}

// GetMessages 获取会话的消息列表
func (s *ChatService) GetMessages(ctx context.Context, conversationID uuid.UUID, userID uuid.UUID, page, pageSize int) (*MessagesResult, error) {
	// 检查用户是否是会话成员（跳过内部调用的检查）
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

// AddMember 向会话添加成员
func (s *ChatService) AddMember(ctx context.Context, conversationID, userID, addedBy uuid.UUID) error {
	// 检查添加者是否是会话成员
	isMember, err := s.conversationRepo.IsMember(ctx, conversationID, addedBy)
	if err != nil {
		return fmt.Errorf("%w: %v", ErrCheckMemberFailed, err)
	}
	if !isMember {
		return ErrNotMember
	}

	// 获取会话信息以检查类型
	conv, err := s.conversationRepo.GetByID(ctx, conversationID)
	if err != nil {
		return fmt.Errorf("%w: %v", ErrGetConversationFailed, err)
	}

	// 私聊会话不能添加成员
	if conv.Type == model.ConversationTypePrivate {
		return ErrCannotAddToPrivate
	}

	// 添加成员
	if err := s.conversationRepo.AddMember(ctx, conversationID, userID, model.MemberRoleMember); err != nil {
		return fmt.Errorf("%w: %v", ErrAddMemberFailed, err)
	}

	return nil
}

// RemoveMember 从会话移除成员
func (s *ChatService) RemoveMember(ctx context.Context, conversationID, userID, removedBy uuid.UUID) error {
	// 获取会话信息
	conv, err := s.conversationRepo.GetByID(ctx, conversationID)
	if err != nil {
		return fmt.Errorf("%w: %v", ErrGetConversationFailed, err)
	}

	// 检查权限（只有群主/管理员可以移除他人，任何人可以退出）
	if userID != removedBy {
		// 检查移除者是否是群主或管理员
		isOwner := conv.CreatorID == removedBy
		if !isOwner {
			return ErrNotAuthorized
		}
	}

	// 移除成员
	if err := s.conversationRepo.RemoveMember(ctx, conversationID, userID); err != nil {
		return fmt.Errorf("%w: %v", ErrRemoveMemberFailed, err)
	}

	return nil
}

// GetConversationMemberIDs 获取会话的所有成员ID
func (s *ChatService) GetConversationMemberIDs(ctx context.Context, conversationID uuid.UUID) ([]uuid.UUID, error) {
	return s.conversationRepo.GetMemberIDs(ctx, conversationID)
}

// IsMember 检查用户是否是会话成员
func (s *ChatService) IsMember(ctx context.Context, conversationID, userID uuid.UUID) (bool, error) {
	return s.conversationRepo.IsMember(ctx, conversationID, userID)
}

// GetMessageByID 根据ID获取消息
func (s *ChatService) GetMessageByID(ctx context.Context, messageID uuid.UUID) (*model.Message, error) {
	return s.messageRepo.GetByID(ctx, messageID)
}

// GetUnreadCount 获取用户在指定会话中的未读消息数
func (s *ChatService) GetUnreadCount(ctx context.Context, conversationID, userID uuid.UUID) (int64, error) {
	// 优先使用缓存服务
	if s.unreadCacheService != nil {
		return s.unreadCacheService.GetUnreadCount(ctx, userID, conversationID)
	}
	return s.messageRepo.GetUnreadCount(ctx, conversationID, userID)
}

// GetUnreadCounts 批量获取用户在多个会话中的未读消息数
// 集成缓存服务，优先从缓存获取，缓存未命中时从数据库查询
func (s *ChatService) GetUnreadCounts(ctx context.Context, userID uuid.UUID, conversationIDs []uuid.UUID) (map[uuid.UUID]int64, error) {
	if len(conversationIDs) == 0 {
		return make(map[uuid.UUID]int64), nil
	}

	// 优先使用缓存服务
	if s.unreadCacheService != nil {
		return s.unreadCacheService.GetUnreadCountsBatch(ctx, userID, conversationIDs)
	}

	// 降级到直接查询数据库
	return s.messageRepo.GetUnreadCountsBatch(ctx, userID, conversationIDs)
}

// MarkConversationAsRead 标记会话中的消息为已读
func (s *ChatService) MarkConversationAsRead(ctx context.Context, conversationID, userID uuid.UUID) (*model.BatchReadReceipt, error) {
	// 检查用户是否是会话成员
	isMember, err := s.conversationRepo.IsMember(ctx, conversationID, userID)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrCheckMemberFailed, err)
	}
	if !isMember {
		return nil, ErrNotMember
	}

	readAt := time.Now()
	messageIDs, err := s.messageRepo.MarkConversationAsRead(ctx, conversationID, userID, readAt)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrMarkReadFailed, err)
	}

	// 重置未读数缓存
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

// MarkMessageAsRead 标记单条消息为已读
// 返回已读回执，用于通知消息发送者
func (s *ChatService) MarkMessageAsRead(ctx context.Context, messageID, userID uuid.UUID) (*model.ReadReceipt, error) {
	// 获取消息信息
	msg, err := s.messageRepo.GetByID(ctx, messageID)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrGetMessageFailed, err)
	}

	// 检查用户是否是会话成员
	isMember, err := s.conversationRepo.IsMember(ctx, msg.ConversationID, userID)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrCheckMemberFailed, err)
	}
	if !isMember {
		return nil, ErrNotMember
	}

	// 不能标记自己发送的消息为已读
	if msg.SenderID == userID {
		return nil, ErrCannotMarkOwnMessage
	}

	// 消息已经被标记为已读
	if msg.IsReadByRecipient() {
		return nil, ErrAlreadyRead
	}

	readAt := time.Now()
	if err := s.messageRepo.MarkAsRead(ctx, messageID, readAt); err != nil {
		return nil, fmt.Errorf("%w: %v", ErrMarkReadFailed, err)
	}

	// 减少未读数缓存
	if s.unreadCacheService != nil {
		if err := s.unreadCacheService.DecrementUnreadCount(ctx, userID, msg.ConversationID, 1); err != nil {
			fmt.Printf("警告: 减少未读数缓存失败: %v\n", err)
		}
	}

	return &model.ReadReceipt{
		MessageID:      messageID,
		ConversationID: msg.ConversationID,
		ReaderID:       userID,
		ReadAt:         readAt,
	}, nil
}

// MarkMessagesUpToAsRead 标记指定消息及之前的所有消息为已读
// 返回批量已读回执，用于通知消息发送者
func (s *ChatService) MarkMessagesUpToAsRead(ctx context.Context, conversationID, userID, upToMessageID uuid.UUID) (*model.BatchReadReceipt, error) {
	// 检查用户是否是会话成员
	isMember, err := s.conversationRepo.IsMember(ctx, conversationID, userID)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrCheckMemberFailed, err)
	}
	if !isMember {
		return nil, ErrNotMember
	}

	readAt := time.Now()
	messageIDs, err := s.messageRepo.MarkMessagesUpToAsRead(ctx, conversationID, userID, upToMessageID, readAt)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrMarkReadFailed, err)
	}

	// 重置未读数缓存（因为标记到某条消息为止，可能还有更新的未读消息）
	// 这里选择使缓存失效，让下次查询时重新从数据库获取
	if s.unreadCacheService != nil {
		if err := s.unreadCacheService.InvalidateCache(ctx, userID, conversationID); err != nil {
			fmt.Printf("警告: 使未读数缓存失效失败: %v\n", err)
		}
	}

	return &model.BatchReadReceipt{
		ConversationID: conversationID,
		ReaderID:       userID,
		MessageIDs:     messageIDs,
		ReadAt:         readAt,
	}, nil
}

// SubscribeToConversation 订阅会话的实时消息
func (s *ChatService) SubscribeToConversation(ctx context.Context, conversationID uuid.UUID, userID uuid.UUID) (<-chan *model.Message, error) {
	// 检查用户是否是会话成员
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

	// 订阅 Redis 频道
	channel := fmt.Sprintf("conversation:%s", conversationID)
	pubsub := s.cache.Subscribe(ctx, channel)

	// 创建消息通道
	msgChan := make(chan *model.Message, 100)

	// 启动协程接收消息
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
				if err := s.cache.Get(ctx, redisMsg.Payload, &msg); err == nil {
					msgChan <- &msg
				}
			}
		}
	}()

	return msgChan, nil
}

// 请求/响应类型定义

// CreateConversationRequest 创建会话请求
type CreateConversationRequest struct {
	Type      model.ConversationType
	Name      string
	MemberIDs []uuid.UUID
	CreatorID uuid.UUID
}

// Validate 验证创建会话请求
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

// SendMessageRequest 发送消息请求
type SendMessageRequest struct {
	ConversationID uuid.UUID
	SenderID       uuid.UUID
	Content        string
	MessageType    model.MessageType
}

// Validate 验证发送消息请求
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
	if r.MessageType == "" {
		r.MessageType = model.MessageTypeText
	}
	return nil
}

// ConversationsResult 会话列表分页结果
type ConversationsResult struct {
	Conversations []model.Conversation
	Total         int64
	Page          int
	PageSize      int
}

// MessagesResult 消息列表分页结果
type MessagesResult struct {
	Messages []model.Message
	Total    int64
	Page     int
	PageSize int
}

// 缓存键生成辅助函数
func conversationCacheKey(id uuid.UUID) string {
	return fmt.Sprintf("conversation:%s", id)
}

func userConversationsCacheKey(userID uuid.UUID) string {
	return fmt.Sprintf("user_conversations:%s", userID)
}

// 缓存过期时间
const (
	conversationCacheTTL = 5 * time.Minute
)

// populateMemberUserInfo 从用户服务获取并填充会话成员的用户信息
func (s *ChatService) populateMemberUserInfo(ctx context.Context, conv *model.Conversation) {
	if s.userClient == nil || len(conv.Members) == 0 {
		return
	}

	// 收集所有成员的用户ID
	userIDs := make([]uuid.UUID, len(conv.Members))
	for i, m := range conv.Members {
		userIDs[i] = m.UserID
	}

	// 批量获取用户信息
	users, err := s.userClient.GetUsers(ctx, userIDs)
	if err != nil {
		fmt.Printf("警告: 获取用户信息失败: %v\n", err)
		return
	}

	// 填充成员信息
	for i := range conv.Members {
		if user, ok := users[conv.Members[i].UserID]; ok {
			conv.Members[i].Username = user.Username
			conv.Members[i].Email = user.Email
			conv.Members[i].DisplayName = user.DisplayName
			conv.Members[i].AvatarURL = user.AvatarURL
		}
	}
}
