package grpc

import (
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/lesser/chat/internal/model"
)

func TestModelToProtoConversationType(t *testing.T) {
	tests := []struct {
		name  string
		input model.ConversationType
		want  ConversationType
	}{
		{"private", model.ConversationTypePrivate, ConversationType_PRIVATE},
		{"group", model.ConversationTypeGroup, ConversationType_GROUP},
		{"channel", model.ConversationTypeChannel, ConversationType_CHANNEL},
		{"unknown", model.ConversationType("unknown"), ConversationType_PRIVATE},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := modelToProtoConversationType(tt.input); got != tt.want {
				t.Errorf("modelToProtoConversationType() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestProtoToModelConversationType(t *testing.T) {
	tests := []struct {
		name  string
		input ConversationType
		want  model.ConversationType
	}{
		{"private", ConversationType_PRIVATE, model.ConversationTypePrivate},
		{"group", ConversationType_GROUP, model.ConversationTypeGroup},
		{"channel", ConversationType_CHANNEL, model.ConversationTypeChannel},
		{"unknown", ConversationType(99), model.ConversationTypePrivate},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := protoToModelConversationType(tt.input); got != tt.want {
				t.Errorf("protoToModelConversationType() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestModelToProtoConversation(t *testing.T) {
	convID := uuid.New()
	creatorID := uuid.New()
	memberID := uuid.New()
	now := time.Now()

	conv := &model.Conversation{
		ID:        convID,
		Type:      model.ConversationTypeGroup,
		Name:      "Test Group",
		CreatorID: creatorID,
		CreatedAt: now,
		Members: []model.ConversationMember{
			{UserID: memberID},
		},
	}

	proto := modelToProtoConversation(conv)

	if proto.Id != convID.String() {
		t.Errorf("ID = %v, want %v", proto.Id, convID.String())
	}
	if proto.Type != ConversationType_GROUP {
		t.Errorf("Type = %v, want GROUP", proto.Type)
	}
	if proto.Name != "Test Group" {
		t.Errorf("Name = %v, want 'Test Group'", proto.Name)
	}
	if proto.CreatorId != creatorID.String() {
		t.Errorf("CreatorId = %v, want %v", proto.CreatorId, creatorID.String())
	}
	if len(proto.MemberIds) != 1 {
		t.Errorf("MemberIds length = %v, want 1", len(proto.MemberIds))
	}
	if proto.CreatedAt == nil {
		t.Error("CreatedAt should not be nil")
	}
}

func TestModelToProtoConversation_WithLastMessage(t *testing.T) {
	convID := uuid.New()
	msgID := uuid.New()
	senderID := uuid.New()
	now := time.Now()

	conv := &model.Conversation{
		ID:        convID,
		Type:      model.ConversationTypePrivate,
		CreatorID: uuid.New(),
		CreatedAt: now,
		LastMessage: &model.Message{
			ID:             msgID,
			ConversationID: convID,
			SenderID:       senderID,
			Content:        "Hello",
			MessageType:    model.MessageTypeText,
			CreatedAt:      now,
		},
	}

	proto := modelToProtoConversation(conv)

	if proto.LastMessage == nil {
		t.Error("LastMessage should not be nil")
		return
	}
	if proto.LastMessage.Id != msgID.String() {
		t.Errorf("LastMessage.Id = %v, want %v", proto.LastMessage.Id, msgID.String())
	}
}

func TestModelToProtoMessage(t *testing.T) {
	msgID := uuid.New()
	convID := uuid.New()
	senderID := uuid.New()
	now := time.Now()

	msg := &model.Message{
		ID:             msgID,
		ConversationID: convID,
		SenderID:       senderID,
		Content:        "Test message",
		MessageType:    model.MessageTypeText,
		CreatedAt:      now,
	}

	proto := modelToProtoMessage(msg)

	if proto.Id != msgID.String() {
		t.Errorf("Id = %v, want %v", proto.Id, msgID.String())
	}
	if proto.ConversationId != convID.String() {
		t.Errorf("ConversationId = %v, want %v", proto.ConversationId, convID.String())
	}
	if proto.SenderId != senderID.String() {
		t.Errorf("SenderId = %v, want %v", proto.SenderId, senderID.String())
	}
	if proto.Content != "Test message" {
		t.Errorf("Content = %v, want 'Test message'", proto.Content)
	}
	if proto.MessageType != "text" {
		t.Errorf("MessageType = %v, want 'text'", proto.MessageType)
	}
	if proto.CreatedAt == nil {
		t.Error("CreatedAt should not be nil")
	}
}

func TestProtoTimestampToTime(t *testing.T) {
	tests := []struct {
		name string
		ts   *Timestamp
		want time.Time
	}{
		{
			name: "nil timestamp",
			ts:   nil,
			want: time.Time{},
		},
		{
			name: "valid timestamp",
			ts:   &Timestamp{Seconds: 1609459200, Nanos: 500000000},
			want: time.Unix(1609459200, 500000000),
		},
		{
			name: "zero timestamp",
			ts:   &Timestamp{Seconds: 0, Nanos: 0},
			want: time.Unix(0, 0),
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := protoTimestampToTime(tt.ts)
			if !got.Equal(tt.want) {
				t.Errorf("protoTimestampToTime() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestPagination_GetPage(t *testing.T) {
	tests := []struct {
		name string
		p    *Pagination
		want int32
	}{
		{"nil pagination", nil, 0},
		{"zero page", &Pagination{Page: 0}, 0},
		{"valid page", &Pagination{Page: 5}, 5},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := tt.p.GetPage(); got != tt.want {
				t.Errorf("GetPage() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestPagination_GetPageSize(t *testing.T) {
	tests := []struct {
		name string
		p    *Pagination
		want int32
	}{
		{"nil pagination", nil, 0},
		{"zero page size", &Pagination{PageSize: 0}, 0},
		{"valid page size", &Pagination{PageSize: 20}, 20},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := tt.p.GetPageSize(); got != tt.want {
				t.Errorf("GetPageSize() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestConversationType_Constants(t *testing.T) {
	if ConversationType_PRIVATE != 0 {
		t.Errorf("ConversationType_PRIVATE = %v, want 0", ConversationType_PRIVATE)
	}
	if ConversationType_GROUP != 1 {
		t.Errorf("ConversationType_GROUP = %v, want 1", ConversationType_GROUP)
	}
	if ConversationType_CHANNEL != 2 {
		t.Errorf("ConversationType_CHANNEL = %v, want 2", ConversationType_CHANNEL)
	}
}
