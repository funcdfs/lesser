package ws

import (
	"testing"
	"time"

	"github.com/google/uuid"
)

func TestHub_RegisterUnregister(t *testing.T) {
	hub := NewHub(nil)
	go hub.Run()

	// Give hub time to start
	time.Sleep(10 * time.Millisecond)

	userID := uuid.New()
	client := &Client{
		hub:           hub,
		userID:        userID,
		send:          make(chan []byte, 256),
		conversations: make(map[uuid.UUID]bool),
	}

	// Register client
	hub.register <- client
	time.Sleep(10 * time.Millisecond)

	// Check client is registered
	hub.mu.RLock()
	_, exists := hub.clients[userID]
	hub.mu.RUnlock()

	if !exists {
		t.Error("Client should be registered")
	}

	// Unregister client
	hub.unregister <- client
	time.Sleep(10 * time.Millisecond)

	// Check client is unregistered
	hub.mu.RLock()
	_, exists = hub.clients[userID]
	hub.mu.RUnlock()

	if exists {
		t.Error("Client should be unregistered")
	}
}

func TestHub_SubscribeToConversation(t *testing.T) {
	hub := NewHub(nil)
	go hub.Run()

	time.Sleep(10 * time.Millisecond)

	conversationID := uuid.New()
	userID := uuid.New()

	client := &Client{
		hub:           hub,
		userID:        userID,
		send:          make(chan []byte, 256),
		conversations: make(map[uuid.UUID]bool),
	}

	// Register client
	hub.register <- client
	time.Sleep(10 * time.Millisecond)

	// Subscribe to conversation
	hub.SubscribeToConversation(client, conversationID)

	// Check subscription
	hub.mu.RLock()
	clients, exists := hub.conversationClients[conversationID]
	hub.mu.RUnlock()

	if !exists {
		t.Error("Conversation should have clients")
	}

	if _, ok := clients[client]; !ok {
		t.Error("Client should be subscribed to conversation")
	}

	// Check client's conversations
	client.mu.RLock()
	_, subscribed := client.conversations[conversationID]
	client.mu.RUnlock()

	if !subscribed {
		t.Error("Client should have conversation in its list")
	}
}

func TestHub_UnsubscribeFromConversation(t *testing.T) {
	hub := NewHub(nil)
	go hub.Run()

	time.Sleep(10 * time.Millisecond)

	conversationID := uuid.New()
	userID := uuid.New()

	client := &Client{
		hub:           hub,
		userID:        userID,
		send:          make(chan []byte, 256),
		conversations: make(map[uuid.UUID]bool),
	}

	// Register and subscribe
	hub.register <- client
	time.Sleep(10 * time.Millisecond)
	hub.SubscribeToConversation(client, conversationID)

	// Unsubscribe
	hub.UnsubscribeFromConversation(client, conversationID)

	// Check unsubscription
	hub.mu.RLock()
	_, exists := hub.conversationClients[conversationID]
	hub.mu.RUnlock()

	if exists {
		t.Error("Conversation should have no clients after unsubscribe")
	}

	// Check client's conversations
	client.mu.RLock()
	_, subscribed := client.conversations[conversationID]
	client.mu.RUnlock()

	if subscribed {
		t.Error("Client should not have conversation in its list")
	}
}
