package model

import (
	"testing"
	"time"

	"github.com/google/uuid"
)

func TestConversationType_Values(t *testing.T) {
	tests := []struct {
		name string
		ct   ConversationType
		want string
	}{
		{"private", ConversationTypePrivate, "private"},
		{"group", ConversationTypeGroup, "group"},
		{"channel", ConversationTypeChannel, "channel"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if string(tt.ct) != tt.want {
				t.Errorf("ConversationType = %v, want %v", tt.ct, tt.want)
			}
		})
	}
}

func TestConversation_GetMemberIDs_Empty(t *testing.T) {
	conv := &Conversation{
		ID:      uuid.New(),
		Members: []ConversationMember{},
	}

	ids := conv.GetMemberIDs()
	if len(ids) != 0 {
		t.Errorf("GetMemberIDs() returned %d IDs, want 0", len(ids))
	}
}

func TestConversation_HasMember_Empty(t *testing.T) {
	conv := &Conversation{
		ID:      uuid.New(),
		Members: []ConversationMember{},
	}

	if conv.HasMember(uuid.New()) {
		t.Error("HasMember() should return false for empty members")
	}
}

func TestConversationMember_Fields(t *testing.T) {
	convID := uuid.New()
	userID := uuid.New()
	now := time.Now()

	member := ConversationMember{
		ConversationID: convID,
		UserID:         userID,
		Role:           MemberRoleOwner,
		JoinedAt:       now,
		Username:       "testuser",
		Email:          "test@example.com",
	}

	if member.ConversationID != convID {
		t.Errorf("ConversationID = %v, want %v", member.ConversationID, convID)
	}
	if member.UserID != userID {
		t.Errorf("UserID = %v, want %v", member.UserID, userID)
	}
	if member.Role != MemberRoleOwner {
		t.Errorf("Role = %v, want %v", member.Role, MemberRoleOwner)
	}
	if member.Username != "testuser" {
		t.Errorf("Username = %v, want 'testuser'", member.Username)
	}
	if member.Email != "test@example.com" {
		t.Errorf("Email = %v, want 'test@example.com'", member.Email)
	}
}

func TestConversation_Fields(t *testing.T) {
	convID := uuid.New()
	creatorID := uuid.New()
	now := time.Now()

	conv := Conversation{
		ID:          convID,
		Type:        ConversationTypeGroup,
		Name:        "Test Group",
		CreatorID:   creatorID,
		CreatedAt:   now,
		UpdatedAt:   now,
		UnreadCount: 5,
	}

	if conv.ID != convID {
		t.Errorf("ID = %v, want %v", conv.ID, convID)
	}
	if conv.Type != ConversationTypeGroup {
		t.Errorf("Type = %v, want %v", conv.Type, ConversationTypeGroup)
	}
	if conv.Name != "Test Group" {
		t.Errorf("Name = %v, want 'Test Group'", conv.Name)
	}
	if conv.CreatorID != creatorID {
		t.Errorf("CreatorID = %v, want %v", conv.CreatorID, creatorID)
	}
	if conv.UnreadCount != 5 {
		t.Errorf("UnreadCount = %v, want 5", conv.UnreadCount)
	}
}

func TestConversation_LastMessage(t *testing.T) {
	msg := &Message{
		ID:      1,
		Content: "Last message",
	}

	conv := Conversation{
		ID:          uuid.New(),
		LastMessage: msg,
	}

	if conv.LastMessage == nil {
		t.Error("LastMessage should not be nil")
		return
	}
	if conv.LastMessage.ID != 1 {
		t.Errorf("LastMessage.ID = %v, want 1", conv.LastMessage.ID)
	}
	if conv.LastMessage.Content != "Last message" {
		t.Errorf("LastMessage.Content = %v, want 'Last message'", conv.LastMessage.Content)
	}
}
