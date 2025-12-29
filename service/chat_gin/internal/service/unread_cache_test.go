package service

import (
	"testing"

	"github.com/google/uuid"
)

func TestUnreadCacheKey(t *testing.T) {
	userID := uuid.MustParse("11111111-1111-1111-1111-111111111111")
	convID := uuid.MustParse("22222222-2222-2222-2222-222222222222")

	key := unreadCacheKey(userID, convID)
	expected := "unread:11111111-1111-1111-1111-111111111111:22222222-2222-2222-2222-222222222222"

	if key != expected {
		t.Errorf("unreadCacheKey() = %v, want %v", key, expected)
	}
}

func TestUnreadCacheKey_DifferentUsers(t *testing.T) {
	user1 := uuid.New()
	user2 := uuid.New()
	convID := uuid.New()

	key1 := unreadCacheKey(user1, convID)
	key2 := unreadCacheKey(user2, convID)

	if key1 == key2 {
		t.Error("Different users should have different cache keys")
	}
}

func TestUnreadCacheKey_DifferentConversations(t *testing.T) {
	userID := uuid.New()
	conv1 := uuid.New()
	conv2 := uuid.New()

	key1 := unreadCacheKey(userID, conv1)
	key2 := unreadCacheKey(userID, conv2)

	if key1 == key2 {
		t.Error("Different conversations should have different cache keys")
	}
}

func TestUnreadCacheTTL(t *testing.T) {
	// 验证 TTL 常量值
	if UnreadCacheTTL.Hours() != 24 {
		t.Errorf("UnreadCacheTTL = %v, want 24 hours", UnreadCacheTTL)
	}
}

func TestNewUnreadCacheService(t *testing.T) {
	// 测试 nil 参数
	svc := NewUnreadCacheService(nil, nil)
	if svc == nil {
		t.Error("NewUnreadCacheService() returned nil")
	}
	if svc.cache != nil {
		t.Error("NewUnreadCacheService() cache should be nil")
	}
	if svc.messageRepo != nil {
		t.Error("NewUnreadCacheService() messageRepo should be nil")
	}
}
