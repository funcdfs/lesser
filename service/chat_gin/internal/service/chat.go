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

// ChatService handles chat business logic
type ChatService struct {
	conversationRepo *repository.ConversationRepository
	messageRepo      *repository.MessageRepository
	cache            *cache.RedisClient
}

// NewChatService creates a new ChatService
func NewChatService(
	conversationRepo *repository.ConversationRepository,
	messageRepo *repository.MessageRepository,
	cache *cache.RedisClient,
) *ChatService {
	return &ChatService{
		conversationRepo: conversationRepo,
		messageRepo:      messageRepo,
		cache:            cache,
	}
}

// CreateConversation creates a new conversation
func (s *ChatService) CreateConversation(ctx context.Context, req CreateConversationRequest) (*model.Conversation, error) {
	// Validate request
	if err := req.Validate(); err != nil {
		return nil, fmt.Errorf("invalid request: %w", err)
	}

	// For private conversations, check if one already exists
	if req.Type == model.ConversationTypePrivate && len(req.MemberIDs) == 2 {
		existing, err := s.conversationRepo.GetPrivateConversation(ctx, req.MemberIDs[0], req.MemberIDs[1])
		if err == nil && existing != nil {
			return existing, nil
		}
	}

	// Create conversation
	conv := &model.Conversation{
		ID:        uuid.New(),
		Type:      req.Type,
		Name:      req.Name,
		CreatorID: req.CreatorID,
	}

	if err := s.conversationRepo.Create(ctx, conv, req.MemberIDs); err != nil {
		return nil, fmt.Errorf("failed to create conversation: %w", err)
	}

	// Reload with members
	return s.conversationRepo.GetByID(ctx, conv.ID)
}

// GetConversation retrieves a conversation by ID
func (s *ChatService) GetConversation(ctx context.Context, id uuid.UUID) (*model.Conversation, error) {
	conv, err := s.conversationRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	// Get last message
	lastMsg, err := s.messageRepo.GetLatestByConversationID(ctx, id)
	if err == nil && lastMsg != nil {
		conv.LastMessage = lastMsg
	}

	return conv, nil
}

// GetUserConversations retrieves all conversations for a user
func (s *ChatService) GetUserConversations(ctx context.Context, userID uuid.UUID, page, pageSize int) (*ConversationsResult, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}

	conversations, total, err := s.conversationRepo.GetByUserID(ctx, userID, page, pageSize)
	if err != nil {
		return nil, fmt.Errorf("failed to get conversations: %w", err)
	}

	// Get last message for each conversation
	for i := range conversations {
		lastMsg, err := s.messageRepo.GetLatestByConversationID(ctx, conversations[i].ID)
		if err == nil && lastMsg != nil {
			conversations[i].LastMessage = lastMsg
		}
	}

	return &ConversationsResult{
		Conversations: conversations,
		Total:         total,
		Page:          page,
		PageSize:      pageSize,
	}, nil
}

// SendMessage sends a message to a conversation
func (s *ChatService) SendMessage(ctx context.Context, req SendMessageRequest) (*model.Message, error) {
	// Validate request
	if err := req.Validate(); err != nil {
		return nil, fmt.Errorf("invalid request: %w", err)
	}

	// Check if user is a member of the conversation
	isMember, err := s.conversationRepo.IsMember(ctx, req.ConversationID, req.SenderID)
	if err != nil {
		return nil, fmt.Errorf("failed to check membership: %w", err)
	}
	if !isMember {
		return nil, ErrNotMember
	}

	// Create message
	msg := &model.Message{
		ID:             uuid.New(),
		ConversationID: req.ConversationID,
		SenderID:       req.SenderID,
		Content:        req.Content,
		MessageType:    req.MessageType,
	}

	if err := s.messageRepo.Create(ctx, msg); err != nil {
		return nil, fmt.Errorf("failed to create message: %w", err)
	}

	// Update conversation timestamp
	if err := s.conversationRepo.UpdateTimestamp(ctx, req.ConversationID); err != nil {
		// Log but don't fail
		fmt.Printf("Warning: failed to update conversation timestamp: %v\n", err)
	}

	// Publish message to Redis for real-time delivery
	if s.cache != nil {
		channel := fmt.Sprintf("conversation:%s", req.ConversationID)
		if err := s.cache.Publish(ctx, channel, msg); err != nil {
			// Log but don't fail
			fmt.Printf("Warning: failed to publish message: %v\n", err)
		}
	}

	return msg, nil
}

// GetMessages retrieves messages for a conversation
func (s *ChatService) GetMessages(ctx context.Context, conversationID uuid.UUID, userID uuid.UUID, page, pageSize int) (*MessagesResult, error) {
	// Check if user is a member of the conversation
	isMember, err := s.conversationRepo.IsMember(ctx, conversationID, userID)
	if err != nil {
		return nil, fmt.Errorf("failed to check membership: %w", err)
	}
	if !isMember {
		return nil, ErrNotMember
	}

	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 50
	}

	messages, total, err := s.messageRepo.GetByConversationID(ctx, conversationID, page, pageSize)
	if err != nil {
		return nil, fmt.Errorf("failed to get messages: %w", err)
	}

	return &MessagesResult{
		Messages: messages,
		Total:    total,
		Page:     page,
		PageSize: pageSize,
	}, nil
}

// AddMember adds a member to a conversation
func (s *ChatService) AddMember(ctx context.Context, conversationID, userID, addedBy uuid.UUID) error {
	// Check if the adder is a member
	isMember, err := s.conversationRepo.IsMember(ctx, conversationID, addedBy)
	if err != nil {
		return fmt.Errorf("failed to check membership: %w", err)
	}
	if !isMember {
		return ErrNotMember
	}

	// Get conversation to check type
	conv, err := s.conversationRepo.GetByID(ctx, conversationID)
	if err != nil {
		return fmt.Errorf("failed to get conversation: %w", err)
	}

	// Private conversations can't have members added
	if conv.Type == model.ConversationTypePrivate {
		return ErrCannotAddToPrivate
	}

	// Add member
	if err := s.conversationRepo.AddMember(ctx, conversationID, userID, model.MemberRoleMember); err != nil {
		return fmt.Errorf("failed to add member: %w", err)
	}

	return nil
}

// RemoveMember removes a member from a conversation
func (s *ChatService) RemoveMember(ctx context.Context, conversationID, userID, removedBy uuid.UUID) error {
	// Get conversation
	conv, err := s.conversationRepo.GetByID(ctx, conversationID)
	if err != nil {
		return fmt.Errorf("failed to get conversation: %w", err)
	}

	// Check permissions (only owner/admin can remove others, anyone can leave)
	if userID != removedBy {
		// Check if remover is owner or admin
		isOwner := conv.CreatorID == removedBy
		if !isOwner {
			return ErrNotAuthorized
		}
	}

	// Remove member
	if err := s.conversationRepo.RemoveMember(ctx, conversationID, userID); err != nil {
		return fmt.Errorf("failed to remove member: %w", err)
	}

	return nil
}

// SubscribeToConversation subscribes to real-time messages for a conversation
func (s *ChatService) SubscribeToConversation(ctx context.Context, conversationID uuid.UUID, userID uuid.UUID) (<-chan *model.Message, error) {
	// Check if user is a member
	isMember, err := s.conversationRepo.IsMember(ctx, conversationID, userID)
	if err != nil {
		return nil, fmt.Errorf("failed to check membership: %w", err)
	}
	if !isMember {
		return nil, ErrNotMember
	}

	if s.cache == nil {
		return nil, ErrCacheNotAvailable
	}

	// Subscribe to Redis channel
	channel := fmt.Sprintf("conversation:%s", conversationID)
	pubsub := s.cache.Subscribe(ctx, channel)

	// Create message channel
	msgChan := make(chan *model.Message, 100)

	// Start goroutine to receive messages
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

// Request/Response types

// CreateConversationRequest represents a request to create a conversation
type CreateConversationRequest struct {
	Type      model.ConversationType
	Name      string
	MemberIDs []uuid.UUID
	CreatorID uuid.UUID
}

// Validate validates the request
func (r *CreateConversationRequest) Validate() error {
	if len(r.MemberIDs) == 0 {
		return fmt.Errorf("at least one member is required")
	}
	if r.CreatorID == uuid.Nil {
		return fmt.Errorf("creator ID is required")
	}
	if r.Type == model.ConversationTypePrivate && len(r.MemberIDs) != 2 {
		return fmt.Errorf("private conversations must have exactly 2 members")
	}
	if r.Type == model.ConversationTypeGroup && r.Name == "" {
		return fmt.Errorf("group conversations must have a name")
	}
	return nil
}

// SendMessageRequest represents a request to send a message
type SendMessageRequest struct {
	ConversationID uuid.UUID
	SenderID       uuid.UUID
	Content        string
	MessageType    model.MessageType
}

// Validate validates the request
func (r *SendMessageRequest) Validate() error {
	if r.ConversationID == uuid.Nil {
		return fmt.Errorf("conversation ID is required")
	}
	if r.SenderID == uuid.Nil {
		return fmt.Errorf("sender ID is required")
	}
	if r.Content == "" {
		return fmt.Errorf("content is required")
	}
	if r.MessageType == "" {
		r.MessageType = model.MessageTypeText
	}
	return nil
}

// ConversationsResult represents a paginated list of conversations
type ConversationsResult struct {
	Conversations []model.Conversation
	Total         int64
	Page          int
	PageSize      int
}

// MessagesResult represents a paginated list of messages
type MessagesResult struct {
	Messages []model.Message
	Total    int64
	Page     int
	PageSize int
}

// CacheKey helpers
func conversationCacheKey(id uuid.UUID) string {
	return fmt.Sprintf("conversation:%s", id)
}

func userConversationsCacheKey(userID uuid.UUID) string {
	return fmt.Sprintf("user_conversations:%s", userID)
}

// Cache TTL
const (
	conversationCacheTTL = 5 * time.Minute
)
