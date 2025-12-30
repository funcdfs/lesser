package service

import (
	"testing"

	"github.com/google/uuid"
	"github.com/lesser/chat/internal/model"
)

func TestNewChatService(t *testing.T) {
	svc := NewChatService(nil, nil, nil, nil, nil)
	if svc == nil {
		t.Error("NewChatService() returned nil")
	}
}

func TestConversationCacheKey(t *testing.T) {
	id := uuid.MustParse("11111111-1111-1111-1111-111111111111")
	key := conversationCacheKey(id)
	expected := "conversation:11111111-1111-1111-1111-111111111111"

	if key != expected {
		t.Errorf("conversationCacheKey() = %v, want %v", key, expected)
	}
}

func TestUserConversationsCacheKey(t *testing.T) {
	id := uuid.MustParse("22222222-2222-2222-2222-222222222222")
	key := userConversationsCacheKey(id)
	expected := "user_conversations:22222222-2222-2222-2222-222222222222"

	if key != expected {
		t.Errorf("userConversationsCacheKey() = %v, want %v", key, expected)
	}
}

func TestConversationCacheTTL(t *testing.T) {
	if conversationCacheTTL.Minutes() != 5 {
		t.Errorf("conversationCacheTTL = %v, want 5 minutes", conversationCacheTTL)
	}
}

func TestCreateConversationRequest_Validate_PrivateConversation(t *testing.T) {
	user1 := uuid.New()
	user2 := uuid.New()

	tests := []struct {
		name    string
		req     CreateConversationRequest
		wantErr error
	}{
		{
			name: "valid private with 2 members",
			req: CreateConversationRequest{
				Type:      model.ConversationTypePrivate,
				MemberIDs: []uuid.UUID{user1, user2},
				CreatorID: user1,
			},
			wantErr: nil,
		},
		{
			name: "private with 1 member",
			req: CreateConversationRequest{
				Type:      model.ConversationTypePrivate,
				MemberIDs: []uuid.UUID{user1},
				CreatorID: user1,
			},
			wantErr: ErrPrivateMemberCount,
		},
		{
			name: "private with 3 members",
			req: CreateConversationRequest{
				Type:      model.ConversationTypePrivate,
				MemberIDs: []uuid.UUID{user1, user2, uuid.New()},
				CreatorID: user1,
			},
			wantErr: ErrPrivateMemberCount,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.req.Validate()
			if tt.wantErr == nil && err != nil {
				t.Errorf("Validate() error = %v, want nil", err)
			}
			if tt.wantErr != nil && err != tt.wantErr {
				t.Errorf("Validate() error = %v, want %v", err, tt.wantErr)
			}
		})
	}
}

func TestCreateConversationRequest_Validate_GroupConversation(t *testing.T) {
	user1 := uuid.New()
	user2 := uuid.New()

	tests := []struct {
		name    string
		req     CreateConversationRequest
		wantErr error
	}{
		{
			name: "valid group with name",
			req: CreateConversationRequest{
				Type:      model.ConversationTypeGroup,
				Name:      "Test Group",
				MemberIDs: []uuid.UUID{user1, user2},
				CreatorID: user1,
			},
			wantErr: nil,
		},
		{
			name: "group without name",
			req: CreateConversationRequest{
				Type:      model.ConversationTypeGroup,
				Name:      "",
				MemberIDs: []uuid.UUID{user1, user2},
				CreatorID: user1,
			},
			wantErr: ErrGroupNameRequired,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.req.Validate()
			if tt.wantErr == nil && err != nil {
				t.Errorf("Validate() error = %v, want nil", err)
			}
			if tt.wantErr != nil && err != tt.wantErr {
				t.Errorf("Validate() error = %v, want %v", err, tt.wantErr)
			}
		})
	}
}

func TestCreateConversationRequest_Validate_CommonErrors(t *testing.T) {
	user1 := uuid.New()

	tests := []struct {
		name    string
		req     CreateConversationRequest
		wantErr error
	}{
		{
			name: "no members",
			req: CreateConversationRequest{
				Type:      model.ConversationTypeGroup,
				Name:      "Test",
				MemberIDs: []uuid.UUID{},
				CreatorID: user1,
			},
			wantErr: ErrNoMembers,
		},
		{
			name: "nil creator ID",
			req: CreateConversationRequest{
				Type:      model.ConversationTypeGroup,
				Name:      "Test",
				MemberIDs: []uuid.UUID{user1},
				CreatorID: uuid.Nil,
			},
			wantErr: ErrInvalidCreatorID,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.req.Validate()
			if err != tt.wantErr {
				t.Errorf("Validate() error = %v, want %v", err, tt.wantErr)
			}
		})
	}
}

func TestSendMessageRequest_Validate_AllCases(t *testing.T) {
	convID := uuid.New()
	senderID := uuid.New()

	tests := []struct {
		name    string
		req     SendMessageRequest
		wantErr error
	}{
		{
			name: "valid with explicit type",
			req: SendMessageRequest{
				ConversationID: convID,
				SenderID:       senderID,
				Content:        "Hello",
				MessageType:    model.MessageTypeText,
			},
			wantErr: nil,
		},
		{
			name: "valid without type (defaults to text)",
			req: SendMessageRequest{
				ConversationID: convID,
				SenderID:       senderID,
				Content:        "Hello",
			},
			wantErr: nil,
		},
		{
			name: "nil conversation ID",
			req: SendMessageRequest{
				ConversationID: uuid.Nil,
				SenderID:       senderID,
				Content:        "Hello",
			},
			wantErr: ErrInvalidConversationID,
		},
		{
			name: "nil sender ID",
			req: SendMessageRequest{
				ConversationID: convID,
				SenderID:       uuid.Nil,
				Content:        "Hello",
			},
			wantErr: ErrInvalidSenderID,
		},
		{
			name: "empty content",
			req: SendMessageRequest{
				ConversationID: convID,
				SenderID:       senderID,
				Content:        "",
			},
			wantErr: ErrEmptyContent,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.req.Validate()
			if tt.wantErr == nil && err != nil {
				t.Errorf("Validate() error = %v, want nil", err)
			}
			if tt.wantErr != nil && err != tt.wantErr {
				t.Errorf("Validate() error = %v, want %v", err, tt.wantErr)
			}
		})
	}
}

func TestSendMessageRequest_Validate_DefaultsMessageType(t *testing.T) {
	req := SendMessageRequest{
		ConversationID: uuid.New(),
		SenderID:       uuid.New(),
		Content:        "Hello",
		MessageType:    model.MessageTypeText, // 默认值 0
	}

	err := req.Validate()
	if err != nil {
		t.Errorf("Validate() error = %v, want nil", err)
	}

	if req.MessageType != model.MessageTypeText {
		t.Errorf("MessageType = %v, want %v", req.MessageType, model.MessageTypeText)
	}
}

func TestConversationsResult(t *testing.T) {
	result := ConversationsResult{
		Conversations: []model.Conversation{
			{ID: uuid.New()},
			{ID: uuid.New()},
		},
		Total:    100,
		Page:     2,
		PageSize: 20,
	}

	if len(result.Conversations) != 2 {
		t.Errorf("Conversations length = %v, want 2", len(result.Conversations))
	}
	if result.Total != 100 {
		t.Errorf("Total = %v, want 100", result.Total)
	}
	if result.Page != 2 {
		t.Errorf("Page = %v, want 2", result.Page)
	}
	if result.PageSize != 20 {
		t.Errorf("PageSize = %v, want 20", result.PageSize)
	}
}

func TestMessagesResult(t *testing.T) {
	result := MessagesResult{
		Messages: []model.Message{
			{ID: 1},
			{ID: 2},
			{ID: 3},
		},
		Total:    50,
		Page:     1,
		PageSize: 50,
	}

	if len(result.Messages) != 3 {
		t.Errorf("Messages length = %v, want 3", len(result.Messages))
	}
	if result.Total != 50 {
		t.Errorf("Total = %v, want 50", result.Total)
	}
	if result.Page != 1 {
		t.Errorf("Page = %v, want 1", result.Page)
	}
	if result.PageSize != 50 {
		t.Errorf("PageSize = %v, want 50", result.PageSize)
	}
}
