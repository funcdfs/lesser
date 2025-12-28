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
	conversationRepo *repository.ConversationRepository
	messageRepo      *repository.MessageRepository
	cache            *cache.RedisClient
	userClient       *UserClient
}

// NewChatService 创建聊天服务实例
func NewChatService(
	conversationRepo *repository.ConversationRepository,
	messageRepo *repository.MessageRepository,
	cache *cache.RedisClient,
	userClient *UserClient,
) *ChatService {
	return &ChatService{
		conversationRepo: conversationRepo,
		messageRepo:      messageRepo,
		cache:            cache,
		userClient:       userClient,
	}
}

// CreateConversation 创建新会话
func (s *ChatService) CreateConversation(ctx context.Context, req CreateConversationRequest) (*model.Conversation, error) {
	// 验证请求参数
	if err := req.Validate(); err != nil {
		return nil, fmt.Errorf("请求参数无效: %w", err)
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
		return nil, fmt.Errorf("创建会话失败: %w", err)
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
		return nil, fmt.Errorf("获取会话列表失败: %w", err)
	}

	// 为每个会话获取最后一条消息并填充用户信息
	for i := range conversations {
		lastMsg, err := s.messageRepo.GetLatestByConversationID(ctx, conversations[i].ID)
		if err == nil && lastMsg != nil {
			conversations[i].LastMessage = lastMsg
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
	// 验证请求参数
	if err := req.Validate(); err != nil {
		return nil, fmt.Errorf("请求参数无效: %w", err)
	}

	// 检查用户是否是会话成员
	isMember, err := s.conversationRepo.IsMember(ctx, req.ConversationID, req.SenderID)
	if err != nil {
		return nil, fmt.Errorf("检查成员身份失败: %w", err)
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
		return nil, fmt.Errorf("创建消息失败: %w", err)
	}

	// 更新会话的最后活动时间
	if err := s.conversationRepo.UpdateTimestamp(ctx, req.ConversationID); err != nil {
		// 记录日志但不影响主流程
		fmt.Printf("警告: 更新会话时间戳失败: %v\n", err)
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
			return nil, fmt.Errorf("检查成员身份失败: %w", err)
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
		return nil, fmt.Errorf("获取消息列表失败: %w", err)
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
		return fmt.Errorf("检查成员身份失败: %w", err)
	}
	if !isMember {
		return ErrNotMember
	}

	// 获取会话信息以检查类型
	conv, err := s.conversationRepo.GetByID(ctx, conversationID)
	if err != nil {
		return fmt.Errorf("获取会话信息失败: %w", err)
	}

	// 私聊会话不能添加成员
	if conv.Type == model.ConversationTypePrivate {
		return ErrCannotAddToPrivate
	}

	// 添加成员
	if err := s.conversationRepo.AddMember(ctx, conversationID, userID, model.MemberRoleMember); err != nil {
		return fmt.Errorf("添加成员失败: %w", err)
	}

	return nil
}

// RemoveMember 从会话移除成员
func (s *ChatService) RemoveMember(ctx context.Context, conversationID, userID, removedBy uuid.UUID) error {
	// 获取会话信息
	conv, err := s.conversationRepo.GetByID(ctx, conversationID)
	if err != nil {
		return fmt.Errorf("获取会话信息失败: %w", err)
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
		return fmt.Errorf("移除成员失败: %w", err)
	}

	return nil
}

// SubscribeToConversation 订阅会话的实时消息
func (s *ChatService) SubscribeToConversation(ctx context.Context, conversationID uuid.UUID, userID uuid.UUID) (<-chan *model.Message, error) {
	// 检查用户是否是会话成员
	isMember, err := s.conversationRepo.IsMember(ctx, conversationID, userID)
	if err != nil {
		return nil, fmt.Errorf("检查成员身份失败: %w", err)
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
		return fmt.Errorf("至少需要一个成员")
	}
	if r.CreatorID == uuid.Nil {
		return fmt.Errorf("创建者ID不能为空")
	}
	if r.Type == model.ConversationTypePrivate && len(r.MemberIDs) != 2 {
		return fmt.Errorf("私聊会话必须有且仅有2个成员")
	}
	if r.Type == model.ConversationTypeGroup && r.Name == "" {
		return fmt.Errorf("群聊会话必须有名称")
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
		return fmt.Errorf("会话ID不能为空")
	}
	if r.SenderID == uuid.Nil {
		return fmt.Errorf("发送者ID不能为空")
	}
	if r.Content == "" {
		return fmt.Errorf("消息内容不能为空")
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
