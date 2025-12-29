package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func init() {
	gin.SetMode(gin.TestMode)
}

func TestGetUserID(t *testing.T) {
	tests := []struct {
		name      string
		setupCtx  func(*gin.Context)
		wantID    uuid.UUID
		wantExist bool
	}{
		{
			name: "user ID exists",
			setupCtx: func(c *gin.Context) {
				id := uuid.New()
				c.Set("userID", id)
			},
			wantExist: true,
		},
		{
			name:      "user ID not exists",
			setupCtx:  func(c *gin.Context) {},
			wantID:    uuid.Nil,
			wantExist: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			w := httptest.NewRecorder()
			c, _ := gin.CreateTestContext(w)
			tt.setupCtx(c)

			gotID, gotExist := GetUserID(c)
			if gotExist != tt.wantExist {
				t.Errorf("GetUserID() exists = %v, want %v", gotExist, tt.wantExist)
			}
			if !tt.wantExist && gotID != uuid.Nil {
				t.Errorf("GetUserID() = %v, want uuid.Nil", gotID)
			}
		})
	}
}

func TestAuthMiddleware_NoHeader(t *testing.T) {
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Request = httptest.NewRequest(http.MethodGet, "/", nil)

	// 使用 nil authClient 测试无 header 情况
	middleware := AuthMiddleware(nil)
	middleware(c)

	if w.Code != http.StatusUnauthorized {
		t.Errorf("Expected status %d, got %d", http.StatusUnauthorized, w.Code)
	}
}

func TestAuthMiddleware_InvalidHeader(t *testing.T) {
	tests := []struct {
		name   string
		header string
	}{
		{"empty header", ""},
		{"no bearer prefix", "token123"},
		{"wrong prefix", "Basic token123"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			w := httptest.NewRecorder()
			c, _ := gin.CreateTestContext(w)
			c.Request = httptest.NewRequest(http.MethodGet, "/", nil)
			if tt.header != "" {
				c.Request.Header.Set("Authorization", tt.header)
			}

			middleware := AuthMiddleware(nil)
			middleware(c)

			if w.Code != http.StatusUnauthorized {
				t.Errorf("Expected status %d, got %d", http.StatusUnauthorized, w.Code)
			}
		})
	}
}

func TestOptionalAuthMiddleware_NoHeader(t *testing.T) {
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Request = httptest.NewRequest(http.MethodGet, "/", nil)

	middleware := OptionalAuthMiddleware(nil)
	middleware(c)

	// 可选认证不应阻止请求
	if c.IsAborted() {
		t.Error("OptionalAuthMiddleware should not abort request without header")
	}
}

func TestOptionalAuthMiddleware_WithInvalidHeader(t *testing.T) {
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Request = httptest.NewRequest(http.MethodGet, "/", nil)
	c.Request.Header.Set("Authorization", "invalid")

	middleware := OptionalAuthMiddleware(nil)
	middleware(c)

	// 可选认证即使 header 无效也不应阻止请求
	if c.IsAborted() {
		t.Error("OptionalAuthMiddleware should not abort request with invalid header")
	}

	// 不应设置 userID
	_, exists := c.Get("userID")
	if exists {
		t.Error("userID should not be set with invalid header")
	}
}
