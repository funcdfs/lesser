package service

import (
	"testing"

	"github.com/google/uuid"
	"github.com/lesser/chat/internal/model"
)

func TestCreateConversationRequest_Validate(t *testing.T) {
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
			name: "valid group conversation",
			req: CreateConversationRequest{
				Type:      model.ConversationTypeGroup,
				Name:      "Test Group",
				MemberIDs: []uuid.UUID{uuid.New(), uuid.New(), uuid.New()},
				CreatorID: uuid.New(),
			},
			wantErr: false,
		},
		{
			name: "empty members",
			req: CreateConversationRequest{
				Type:      model.ConversationTypePrivate,
				MemberIDs: []uuid.UUID{},
				CreatorID: uuid.New(),
			},
			wantErr: true,
		},
		{
			name: "nil creator ID",
			req: CreateConversationRequest{
				Type:      model.ConversationTypePrivate,
				MemberIDs: []uuid.UUID{uuid.New(), uuid.New()},
				CreatorID: uuid.Nil,
			},
			wantErr: true,
		},
		{
			name: "private with wrong member count",
			req: CreateConversationRequest{
				Type:      model.ConversationTypePrivate,
				MemberIDs: []uuid.UUID{uuid.New(), uuid.New(), uuid.New()},
				CreatorID: uuid.New(),
			},
			wantErr: true,
		},
		{
			name: "group without name",
			req: CreateConversationRequest{
				Type:      model.ConversationTypeGroup,
				Name:      "",
				MemberIDs: []uuid.UUID{uuid.New(), uuid.New()},
				CreatorID: uuid.New(),
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

func TestSendMessageRequest_Validate(t *testing.T) {
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
				Content:        "Hello, world!",
				MessageType:    model.MessageTypeText,
			},
			wantErr: false,
		},
		{
			name: "valid message without type (defaults to text)",
			req: SendMessageRequest{
				ConversationID: uuid.New(),
				SenderID:       uuid.New(),
				Content:        "Hello, world!",
			},
			wantErr: false,
		},
		{
			name: "nil conversation ID",
			req: SendMessageRequest{
				ConversationID: uuid.Nil,
				SenderID:       uuid.New(),
				Content:        "Hello",
			},
			wantErr: true,
		},
		{
			name: "nil sender ID",
			req: SendMessageRequest{
				ConversationID: uuid.New(),
				SenderID:       uuid.Nil,
				Content:        "Hello",
			},
			wantErr: true,
		},
		{
			name: "empty content",
			req: SendMessageRequest{
				ConversationID: uuid.New(),
				SenderID:       uuid.New(),
				Content:        "",
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
