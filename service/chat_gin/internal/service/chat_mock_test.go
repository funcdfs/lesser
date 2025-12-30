package service

import (
	"context"
	"testing"

	"github.com/google/uuid"
	"github.com/lesser/chat/internal/model"
	"github.com/lesser/chat/internal/repository"
)

// MockConversationRepository 模拟会话仓库
type MockConversationRepository struct {
	conversations map[uuid.UUID]*model.Conversation
	members       map[uuid.UUID][]uuid.UUID
}

func NewMockConversationRepository() *MockConversationRepository {
	return &MockConversationRepository{
		conversations: make(map[uuid.UUID]*model.Conversation),
		members:       make(map[uuid.UUID][]uuid.UUID),
	}
}

func (m *MockConversationRepository) Create(ctx context.Context, conv *model.Conversation, memberIDs []uuid.UUID) error {
	m.conversations[conv.ID] = conv
	m.members[conv.ID] = memberIDs
	return nil
}

func (m *MockConversationRepository) GetByID(ctx context.Context, id uuid.UUID) (*model.Conversation, error) {
	if conv, ok := m.conversations[id]; ok {
		return conv, nil
	}
	return nil, repository.ErrNotFound
}

func (m *MockConversationRepository) IsMember(ctx context.Context, conversationID, userID uuid.UUID) (bool, error) {
	if members, ok := m.members[conversationID]; ok {
		for _, id := range members {
			if id == userID {
				return true, nil
			}
		}
	}
	return false, nil
}

func (m *MockConversationRepository) GetMemberIDs(ctx context.Context, conversationID uuid.UUID) ([]uuid.UUID, error) {
	if members, ok := m.members[conversationID]; ok {
		return members, nil
	}
	return nil, repository.ErrNotFound
}

// MockMessageRepository 模拟消息仓库
type MockMessageRepository struct {
	messages map[int64]*model.Message
	nextID   int64
}

func NewMockMessageRepository() *MockMessageRepository {
	return &MockMessageRepository{
		messages: make(map[int64]*model.Message),
		nextID:   1,
	}
}

func (m *MockMessageRepository) Create(ctx context.Context, msg *model.Message) error {
	msg.ID = m.nextID
	m.nextID++
	m.messages[msg.ID] = msg
	return nil
}

func (m *MockMessageRepository) GetByID(ctx context.Context, id int64) (*model.Message, error) {
	if msg, ok := m.messages[id]; ok {
		return msg, nil
	}
	return nil, repository.ErrNotFound
}

// 测试 ChatService 的辅助函数

func TestChatService_CreateConversation_Validation(t *testing.T) {
	tests := []struct {
		name    string
		req     CreateConversationRequest
		wantErr bool
	}{
		{
			name: "valid private conversation",
			req: CreateConversationRequest{
				Type:      model.ConversationTypePrivate,
				MemberIDs: []uuid.UUID{uuid.New(), uuid.New()},
				CreatorID: uuid.New(),
			},
			wantErr: false,
		},
		{
			name: "invalid - no members",
			req: CreateConversationRequest{
				Type:      model.ConversationTypePrivate,
				MemberIDs: []uuid.UUID{},
				CreatorID: uuid.New(),
			},
			wantErr: true,
		},
		{
			name: "invalid - nil creator",
			req: CreateConversationRequest{
				Type:      model.ConversationTypePrivate,
				MemberIDs: []uuid.UUID{uuid.New(), uuid.New()},
				CreatorID: uuid.Nil,
			},
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.req.Validate()
			if (err != nil) != tt.wantErr {
				t.Errorf("Validate() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}

func TestChatService_SendMessage_Validation(t *testing.T) {
	tests := []struct {
		name    string
		req     SendMessageRequest
		wantErr bool
	}{
		{
			name: "valid message",
			req: SendMessageRequest{
				ConversationID: uuid.New(),
				SenderID:       uuid.New(),
				Content:        "Hello",
				MessageType:    model.MessageTypeText,
			},
			wantErr: false,
		},
		{
			name: "invalid - empty content",
			req: SendMessageRequest{
				ConversationID: uuid.New(),
				SenderID:       uuid.New(),
				Content:        "",
			},
			wantErr: true,
		},
		{
			name: "invalid - nil conversation ID",
			req: SendMessageRequest{
				ConversationID: uuid.Nil,
				SenderID:       uuid.New(),
				Content:        "Hello",
			},
			wantErr: true,
		},
		{
			name: "invalid - nil sender ID",
			req: SendMessageRequest{
				ConversationID: uuid.New(),
				SenderID:       uuid.Nil,
				Content:        "Hello",
			},
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.req.Validate()
			if (err != nil) != tt.wantErr {
				t.Errorf("Validate() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}

func TestConversationType_Values(t *testing.T) {
	if model.ConversationTypePrivate != "private" {
		t.Errorf("ConversationTypePrivate = %v, want 'private'", model.ConversationTypePrivate)
	}
	if model.ConversationTypeGroup != "group" {
		t.Errorf("ConversationTypeGroup = %v, want 'group'", model.ConversationTypeGroup)
	}
	if model.ConversationTypeChannel != "channel" {
		t.Errorf("ConversationTypeChannel = %v, want 'channel'", model.ConversationTypeChannel)
	}
}

func TestMessageType_Values(t *testing.T) {
	// MessageType 现在是 int 类型
	if model.MessageTypeText != 0 {
		t.Errorf("MessageTypeText = %v, want 0", model.MessageTypeText)
	}
	if model.MessageTypeImage != 1 {
		t.Errorf("MessageTypeImage = %v, want 1", model.MessageTypeImage)
	}
	if model.MessageTypeVideo != 2 {
		t.Errorf("MessageTypeVideo = %v, want 2", model.MessageTypeVideo)
	}
	if model.MessageTypeLink != 3 {
		t.Errorf("MessageTypeLink = %v, want 3", model.MessageTypeLink)
	}
	if model.MessageTypeFile != 4 {
		t.Errorf("MessageTypeFile = %v, want 4", model.MessageTypeFile)
	}
	if model.MessageTypeSystem != 9 {
		t.Errorf("MessageTypeSystem = %v, want 9", model.MessageTypeSystem)
	}
}
