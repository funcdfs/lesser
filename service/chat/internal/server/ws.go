package server

import (
	"context"
	"net/http"

	"github.com/google/uuid"
	"github.com/lesser/chat/internal/config"
	"github.com/lesser/chat/internal/handler/ws"
)

// WSServer WebSocket 服务器（仅提供 WebSocket 和健康检查）
type WSServer struct {
	config *config.Config
	hub    *ws.Hub
	server *http.Server
}

func NewWSServer(cfg *config.Config, hub *ws.Hub) *WSServer {
	mux := http.NewServeMux()

	s := &WSServer{
		config: cfg,
		hub:    hub,
	}

	// 健康检查
	mux.HandleFunc("/health", s.healthCheck)

	// WebSocket 端点
	mux.HandleFunc("/ws/chat", s.handleWebSocket)

	s.server = &http.Server{
		Addr:    ":" + cfg.WSPort,
		Handler: mux,
	}

	return s
}

func (s *WSServer) Start() error {
	return s.server.ListenAndServe()
}

func (s *WSServer) Shutdown(ctx context.Context) error {
	return s.server.Shutdown(ctx)
}

func (s *WSServer) healthCheck(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"status":"healthy","service":"chat"}`))
}

func (s *WSServer) handleWebSocket(w http.ResponseWriter, r *http.Request) {
	userIDStr := r.URL.Query().Get("user_id")
	if userIDStr == "" {
		http.Error(w, `{"error":"需要用户ID"}`, http.StatusUnauthorized)
		return
	}

	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		http.Error(w, `{"error":"用户ID格式无效"}`, http.StatusBadRequest)
		return
	}

	s.hub.HandleWebSocket(w, r, userID)
}
