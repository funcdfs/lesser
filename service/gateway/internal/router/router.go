// Package router 提供 gRPC 服务路由功能
// 管理到各个后端服务的连接，支持健康检查
package router

import (
	"context"
	"fmt"
	"log/slog"
	"sync"

	"google.golang.org/grpc"
	"google.golang.org/grpc/connectivity"
	"google.golang.org/grpc/credentials/insecure"

	gwErr "github.com/funcdfs/lesser/gateway/internal/errors"
)

// ServiceName 服务名称常量
type ServiceName string

const (
	ServiceAuth         ServiceName = "auth"
	ServiceUser         ServiceName = "user"
	ServiceContent      ServiceName = "content"
	ServiceInteraction  ServiceName = "interaction"
	ServiceComment      ServiceName = "comment"
	ServiceTimeline     ServiceName = "timeline"
	ServiceChat         ServiceName = "chat"
	ServiceSearch       ServiceName = "search"
	ServiceNotification ServiceName = "notification"
)

// ServiceConfig 服务地址配置
type ServiceConfig struct {
	AuthAddr         string
	UserAddr         string
	ContentAddr      string
	InteractionAddr  string
	CommentAddr      string
	TimelineAddr     string
	ChatAddr         string
	SearchAddr       string
	NotificationAddr string
}

// Router gRPC 服务路由器
type Router struct {
	mu    sync.RWMutex
	conns map[ServiceName]*grpc.ClientConn
	log   *slog.Logger
}

// NewRouter 创建路由器并建立所有服务连接
func NewRouter(cfg ServiceConfig, log *slog.Logger) (*Router, error) {
	if log == nil {
		log = slog.Default()
	}

	r := &Router{
		conns: make(map[ServiceName]*grpc.ClientConn),
		log:   log.With(slog.String("component", "router")),
	}

	// 服务地址映射
	services := map[ServiceName]string{
		ServiceAuth:         cfg.AuthAddr,
		ServiceUser:         cfg.UserAddr,
		ServiceContent:      cfg.ContentAddr,
		ServiceInteraction:  cfg.InteractionAddr,
		ServiceComment:      cfg.CommentAddr,
		ServiceTimeline:     cfg.TimelineAddr,
		ServiceChat:         cfg.ChatAddr,
		ServiceSearch:       cfg.SearchAddr,
		ServiceNotification: cfg.NotificationAddr,
	}

	// 建立连接
	for name, addr := range services {
		if addr == "" {
			continue
		}
		conn, err := grpc.NewClient(addr, grpc.WithTransportCredentials(insecure.NewCredentials()))
		if err != nil {
			r.Close() // 清理已建立的连接
			return nil, fmt.Errorf("连接 %s 服务失败: %w", name, err)
		}
		r.conns[name] = conn
		r.log.Info("服务已连接", slog.String("service", string(name)), slog.String("addr", addr))
	}

	return r, nil
}

// GetConn 获取指定服务的连接
func (r *Router) GetConn(name ServiceName) *grpc.ClientConn {
	r.mu.RLock()
	defer r.mu.RUnlock()
	return r.conns[name]
}

// GetAuthConn 获取 Auth 服务连接
func (r *Router) GetAuthConn() *grpc.ClientConn {
	return r.GetConn(ServiceAuth)
}

// GetUserConn 获取 User 服务连接
func (r *Router) GetUserConn() *grpc.ClientConn {
	return r.GetConn(ServiceUser)
}

// GetContentConn 获取 Content 服务连接
func (r *Router) GetContentConn() *grpc.ClientConn {
	return r.GetConn(ServiceContent)
}

// GetInteractionConn 获取 Interaction 服务连接
func (r *Router) GetInteractionConn() *grpc.ClientConn {
	return r.GetConn(ServiceInteraction)
}

// GetCommentConn 获取 Comment 服务连接
func (r *Router) GetCommentConn() *grpc.ClientConn {
	return r.GetConn(ServiceComment)
}

// GetTimelineConn 获取 Timeline 服务连接
func (r *Router) GetTimelineConn() *grpc.ClientConn {
	return r.GetConn(ServiceTimeline)
}

// GetChatConn 获取 Chat 服务连接
func (r *Router) GetChatConn() *grpc.ClientConn {
	return r.GetConn(ServiceChat)
}

// GetSearchConn 获取 Search 服务连接
func (r *Router) GetSearchConn() *grpc.ClientConn {
	return r.GetConn(ServiceSearch)
}

// GetNotificationConn 获取 Notification 服务连接
func (r *Router) GetNotificationConn() *grpc.ClientConn {
	return r.GetConn(ServiceNotification)
}

// RouteByService 根据服务名路由，返回连接或错误
func (r *Router) RouteByService(name string) (*grpc.ClientConn, error) {
	serviceName := ServiceName(name)
	conn := r.GetConn(serviceName)
	if conn == nil {
		return nil, gwErr.ServiceUnavailableError(name)
	}
	return conn, nil
}

// HealthCheck 检查所有服务的健康状态
func (r *Router) HealthCheck(ctx context.Context) map[string]bool {
	r.mu.RLock()
	defer r.mu.RUnlock()

	health := make(map[string]bool)
	for name, conn := range r.conns {
		healthy := conn != nil && conn.GetState() != connectivity.Shutdown
		health[string(name)] = healthy
	}
	return health
}

// Close 关闭所有连接
func (r *Router) Close() {
	r.mu.Lock()
	defer r.mu.Unlock()

	for name, conn := range r.conns {
		if conn != nil {
			if err := conn.Close(); err != nil {
				r.log.Warn("关闭连接失败", slog.String("service", string(name)), slog.Any("error", err))
			}
		}
	}
	r.conns = make(map[ServiceName]*grpc.ClientConn)
	r.log.Info("所有连接已关闭")
}
