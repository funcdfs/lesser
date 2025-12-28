package model

import (
	"testing"

	"github.com/google/uuid"
)

func TestConversation_GetMemberIDs(t *testing.T) {
	user1 := uuid.New()
	user2 := uuid.New()
	user3 := uuid.New()

	conv := &Conversation{
		ID:   uuid.New(),
		Type: ConversationTypeGroup,
		Members: []ConversationMember{
			{UserID: user1},
			{UserID: user2},
			{UserID: user3},
		},
	}

	memberIDs := conv.GetMemberIDs()

	if len(memberIDs) != 3 {
		t.Errorf("GetMemberIDs() returned %d members, want 3", len(memberIDs))
	}

	// Check all IDs are present
	found := make(map[uuid.UUID]bool)
	for _, id := range memberIDs {
		found[id] = true
	}

	if !found[user1] || !found[user2] || !found[user3] {
		t.Error("GetMemberIDs() missing expected member IDs")
	}
}

func TestConversation_HasMember(t *testing.T) {
	user1 := uuid.New()
	user2 := uuid.New()
	nonMember := uuid.New()

	conv := &Conversation{
		ID:   uuid.New(),
		Type: ConversationTypePrivate,
		Members: []ConversationMember{
			{UserID: user1},
			{UserID: user2},
		},
	}

	tests := []struct {
		name   string
		userID uuid.UUID
		want   bool
	}{
		{"member user1", user1, true},
		{"member user2", user2, true},
		{"non-member", nonMember, false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := conv.HasMember(tt.userID); got != tt.want {
				t.Errorf("HasMember() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestConversation_TableName(t *testing.T) {
	conv := Conversation{}
	if got := conv.TableName(); got != "chat_conversations" {
		t.Errorf("TableName() = %v, want chat_conversations", got)
	}
}

func TestConversationMember_TableName(t *testing.T) {
	member := ConversationMember{}
	if got := member.TableName(); got != "chat_conversation_members" {
		t.Errorf("TableName() = %v, want chat_conversation_members", got)
	}
}
